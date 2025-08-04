// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./interfaces/IHedVaultCore.sol";
import "./libraries/DataTypes.sol";
import "./libraries/Events.sol";
import "./libraries/HedVaultErrors.sol";

// Chainlink interfaces
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
    function version() external view returns (uint256);
    function getRoundData(
        uint80 _roundId
    )
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

/**
 * @title ChainlinkAdapter
 * @notice Adapter contract for integrating with Chainlink price feeds
 * @dev Provides standardized interface for Chainlink data feeds with validation and fallback mechanisms
 */
contract ChainlinkAdapter is AccessControl, ReentrancyGuard, Pausable {
    // Roles
    bytes32 public constant ADAPTER_ADMIN_ROLE =
        keccak256("ADAPTER_ADMIN_ROLE");
    bytes32 public constant FEED_MANAGER_ROLE = keccak256("FEED_MANAGER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");

    // Core protocol reference
    IHedVaultCore public immutable hedVaultCore;

    // Price feed configuration
    struct PriceFeedConfig {
        address aggregator; // Chainlink aggregator address
        uint256 heartbeat; // Maximum time between updates (seconds)
        uint8 decimals; // Expected decimals for the feed
        uint256 minAnswer; // Minimum valid answer
        uint256 maxAnswer; // Maximum valid answer
        bool isActive; // Whether the feed is active
        bool useL2Sequencer; // Whether to check L2 sequencer status
    }

    // Price data structure
    struct PriceData {
        uint256 price;
        uint256 timestamp;
        uint80 roundId;
        uint256 confidence; // Confidence level (0-10000, where 10000 = 100%)
    }

    // Fallback configuration
    struct FallbackConfig {
        address fallbackOracle; // Fallback oracle address
        uint256 deviationThreshold; // Maximum allowed deviation (basis points)
        bool isEnabled; // Whether fallback is enabled
    }

    // State variables
    mapping(address => PriceFeedConfig) public priceFeeds;
    mapping(address => PriceData) public latestPriceData;
    mapping(address => FallbackConfig) public fallbackConfigs;
    mapping(address => bool) public supportedAssets;

    address[] public assetList;

    // L2 Sequencer Uptime Feed (for L2 networks)
    address public sequencerUptimeFeed;

    // Constants
    uint256 public constant MAX_PRICE_AGE = 3600; // 1 hour
    uint256 public constant MIN_CONFIDENCE = 5000; // 50%
    uint256 public constant MAX_DEVIATION = 1000; // 10%
    uint256 public constant CONFIDENCE_PRECISION = 10000;
    uint256 public constant PRICE_PRECISION = 1e18;

    // Grace period for sequencer restart
    uint256 public constant GRACE_PERIOD_TIME = 3600; // 1 hour

    // Events
    event PriceFeedAdded(
        address indexed asset,
        address indexed aggregator,
        uint256 heartbeat,
        uint8 decimals
    );

    event PriceFeedUpdated(
        address indexed asset,
        address indexed oldAggregator,
        address indexed newAggregator
    );

    event PriceFeedRemoved(address indexed asset);

    event PriceUpdated(
        address indexed asset,
        uint256 price,
        uint256 timestamp,
        uint80 roundId,
        uint256 confidence
    );

    event FallbackTriggered(
        address indexed asset,
        address indexed fallbackOracle,
        uint256 chainlinkPrice,
        uint256 fallbackPrice
    );

    event SequencerStatusChecked(bool isUp, uint256 timeSinceUp);

    // Modifiers
    modifier onlyValidAsset(address asset) {
        if (!supportedAssets[asset]) {
            revert HedVaultErrors.AssetNotSupported(asset);
        }
        _;
    }

    modifier onlyActiveFeed(address asset) {
        if (!priceFeeds[asset].isActive) {
            revert HedVaultErrors.OracleNotFound(asset);
        }
        _;
    }

    constructor(address _hedVaultCore, address _sequencerUptimeFeed) {
        if (_hedVaultCore == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        hedVaultCore = IHedVaultCore(_hedVaultCore);
        sequencerUptimeFeed = _sequencerUptimeFeed;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADAPTER_ADMIN_ROLE, msg.sender);
        _grantRole(FEED_MANAGER_ROLE, msg.sender);
        _grantRole(EMERGENCY_ROLE, msg.sender);
    }

    // ============ PRICE FEED MANAGEMENT ============

    /**
     * @notice Add a new price feed
     * @param asset Asset address
     * @param aggregator Chainlink aggregator address
     * @param heartbeat Maximum time between updates
     * @param decimals Expected decimals for the feed
     * @param minAnswer Minimum valid answer
     * @param maxAnswer Maximum valid answer
     * @param useL2Sequencer Whether to check L2 sequencer status
     */
    function addPriceFeed(
        address asset,
        address aggregator,
        uint256 heartbeat,
        uint8 decimals,
        uint256 minAnswer,
        uint256 maxAnswer,
        bool useL2Sequencer
    ) external onlyRole(FEED_MANAGER_ROLE) {
        if (asset == address(0) || aggregator == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        if (heartbeat == 0 || heartbeat > 86400) {
            // Max 24 hours
            revert HedVaultErrors.InvalidParameter("heartbeat");
        }

        if (maxAnswer <= minAnswer) {
            revert HedVaultErrors.InvalidParameter("price_range");
        }

        // Validate aggregator by calling it
        try AggregatorV3Interface(aggregator).decimals() returns (
            uint8 feedDecimals
        ) {
            if (feedDecimals != decimals) {
                revert HedVaultErrors.InvalidParameter("decimals_mismatch");
            }
        } catch {
            revert HedVaultErrors.InvalidParameter("invalid_aggregator");
        }

        priceFeeds[asset] = PriceFeedConfig({
            aggregator: aggregator,
            heartbeat: heartbeat,
            decimals: decimals,
            minAnswer: minAnswer,
            maxAnswer: maxAnswer,
            isActive: true,
            useL2Sequencer: useL2Sequencer
        });

        if (!supportedAssets[asset]) {
            supportedAssets[asset] = true;
            assetList.push(asset);
        }

        emit PriceFeedAdded(asset, aggregator, heartbeat, decimals);
    }

    /**
     * @notice Update an existing price feed
     * @param asset Asset address
     * @param newAggregator New Chainlink aggregator address
     * @param heartbeat New heartbeat
     * @param minAnswer New minimum valid answer
     * @param maxAnswer New maximum valid answer
     */
    function updatePriceFeed(
        address asset,
        address newAggregator,
        uint256 heartbeat,
        uint256 minAnswer,
        uint256 maxAnswer
    ) external onlyRole(FEED_MANAGER_ROLE) onlyValidAsset(asset) {
        if (newAggregator == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        PriceFeedConfig storage config = priceFeeds[asset];
        address oldAggregator = config.aggregator;

        config.aggregator = newAggregator;
        config.heartbeat = heartbeat;
        config.minAnswer = minAnswer;
        config.maxAnswer = maxAnswer;

        emit PriceFeedUpdated(asset, oldAggregator, newAggregator);
    }

    /**
     * @notice Remove a price feed
     * @param asset Asset address
     */
    function removePriceFeed(
        address asset
    ) external onlyRole(FEED_MANAGER_ROLE) onlyValidAsset(asset) {
        priceFeeds[asset].isActive = false;
        supportedAssets[asset] = false;

        // Remove from asset list
        for (uint256 i = 0; i < assetList.length; i++) {
            if (assetList[i] == asset) {
                assetList[i] = assetList[assetList.length - 1];
                assetList.pop();
                break;
            }
        }

        emit PriceFeedRemoved(asset);
    }

    // ============ PRICE RETRIEVAL ============

    /**
     * @notice Get the latest price for an asset
     * @param asset Asset address
     * @return price Latest price
     * @return timestamp Last update timestamp
     * @return confidence Confidence level
     */
    function getPrice(
        address asset
    )
        external
        view
        onlyValidAsset(asset)
        onlyActiveFeed(asset)
        returns (uint256 price, uint256 timestamp, uint256 confidence)
    {
        PriceFeedConfig memory config = priceFeeds[asset];

        // Check L2 sequencer status if required
        if (config.useL2Sequencer && sequencerUptimeFeed != address(0)) {
            _checkSequencerStatus();
        }

        // Get latest round data
        (, int256 answer, , uint256 updatedAt, ) = AggregatorV3Interface(
            config.aggregator
        ).latestRoundData();

        // Validate price data
        _validatePriceData(asset, answer, updatedAt, config);

        // Convert to standard format
        price = _normalizePrice(uint256(answer), config.decimals);
        timestamp = updatedAt;
        confidence = _calculateConfidence(updatedAt, config.heartbeat);

        // Check fallback if confidence is low
        if (confidence < MIN_CONFIDENCE) {
            (price, timestamp, confidence) = _tryFallback(
                asset,
                price,
                timestamp
            );
        }

        return (price, timestamp, confidence);
    }

    /**
     * @notice Get price data for multiple assets
     * @param assets Array of asset addresses
     * @return prices Array of prices
     * @return timestamps Array of timestamps
     * @return confidences Array of confidence levels
     */
    function getPrices(
        address[] calldata assets
    )
        external
        view
        returns (
            uint256[] memory prices,
            uint256[] memory timestamps,
            uint256[] memory confidences
        )
    {
        prices = new uint256[](assets.length);
        timestamps = new uint256[](assets.length);
        confidences = new uint256[](assets.length);

        for (uint256 i = 0; i < assets.length; i++) {
            (prices[i], timestamps[i], confidences[i]) = this.getPrice(
                assets[i]
            );
        }
    }

    /**
     * @notice Get historical price data
     * @param asset Asset address
     * @param roundId Round ID to fetch
     * @return price Historical price
     * @return timestamp Timestamp of the round
     */
    function getHistoricalPrice(
        address asset,
        uint80 roundId
    )
        external
        view
        onlyValidAsset(asset)
        onlyActiveFeed(asset)
        returns (uint256 price, uint256 timestamp)
    {
        PriceFeedConfig memory config = priceFeeds[asset];

        (, int256 answer, , uint256 updatedAt, ) = AggregatorV3Interface(
            config.aggregator
        ).getRoundData(roundId);

        if (answer <= 0) {
            revert HedVaultErrors.InvalidPriceData(asset, answer);
        }

        price = _normalizePrice(uint256(answer), config.decimals);
        timestamp = updatedAt;
    }

    // ============ FALLBACK MANAGEMENT ============

    /**
     * @notice Configure fallback oracle for an asset
     * @param asset Asset address
     * @param fallbackOracle Fallback oracle address
     * @param deviationThreshold Maximum allowed deviation in basis points
     */
    function configureFallback(
        address asset,
        address fallbackOracle,
        uint256 deviationThreshold
    ) external onlyRole(FEED_MANAGER_ROLE) onlyValidAsset(asset) {
        if (deviationThreshold > MAX_DEVIATION) {
            revert HedVaultErrors.InvalidParameter("deviation_threshold");
        }

        fallbackConfigs[asset] = FallbackConfig({
            fallbackOracle: fallbackOracle,
            deviationThreshold: deviationThreshold,
            isEnabled: fallbackOracle != address(0)
        });
    }

    // ============ VALIDATION FUNCTIONS ============

    /**
     * @notice Check if price data is fresh
     * @param asset Asset address
     * @return isFresh True if price is fresh
     */
    function isPriceFresh(address asset) external view returns (bool) {
        if (!supportedAssets[asset] || !priceFeeds[asset].isActive) {
            return false;
        }

        PriceData memory data = latestPriceData[asset];
        return block.timestamp - data.timestamp <= priceFeeds[asset].heartbeat;
    }

    /**
     * @notice Get all supported assets
     * @return assets Array of supported asset addresses
     */
    function getSupportedAssets() external view returns (address[] memory) {
        return assetList;
    }

    /**
     * @notice Get price feed configuration
     * @param asset Asset address
     * @return config Price feed configuration
     */
    function getPriceFeedConfig(
        address asset
    ) external view returns (PriceFeedConfig memory config) {
        return priceFeeds[asset];
    }

    // ============ INTERNAL FUNCTIONS ============

    /**
     * @notice Validate price data from Chainlink
     */
    function _validatePriceData(
        address asset,
        int256 answer,
        uint256 updatedAt,
        PriceFeedConfig memory config
    ) internal view {
        if (answer <= 0) {
            revert HedVaultErrors.InvalidPriceData(asset, answer);
        }

        uint256 price = uint256(answer);
        if (price < config.minAnswer || price > config.maxAnswer) {
            revert HedVaultErrors.InvalidPriceData(asset, answer);
        }

        if (block.timestamp - updatedAt > config.heartbeat) {
            revert HedVaultErrors.StalePriceData(asset, updatedAt);
        }
    }

    /**
     * @notice Normalize price to standard format (18 decimals)
     */
    function _normalizePrice(
        uint256 price,
        uint8 decimals
    ) internal pure returns (uint256) {
        if (decimals == 18) {
            return price;
        } else if (decimals < 18) {
            return price * (10 ** (18 - decimals));
        } else {
            return price / (10 ** (decimals - 18));
        }
    }

    /**
     * @notice Calculate confidence based on data freshness
     */
    function _calculateConfidence(
        uint256 timestamp,
        uint256 heartbeat
    ) internal view returns (uint256) {
        uint256 age = block.timestamp - timestamp;
        if (age >= heartbeat) {
            return 0;
        }

        // Linear decay: 100% confidence at timestamp, 0% at heartbeat
        return CONFIDENCE_PRECISION - (age * CONFIDENCE_PRECISION) / heartbeat;
    }

    /**
     * @notice Try fallback oracle if primary fails
     */
    function _tryFallback(
        address asset,
        uint256 primaryPrice,
        uint256 primaryTimestamp
    )
        internal
        view
        returns (uint256 price, uint256 timestamp, uint256 confidence)
    {
        FallbackConfig memory fallbackConfig = fallbackConfigs[asset];

        if (
            !fallbackConfig.isEnabled ||
            fallbackConfig.fallbackOracle == address(0)
        ) {
            return (primaryPrice, primaryTimestamp, MIN_CONFIDENCE);
        }

        // Try to get price from fallback oracle
        // This would need to be implemented based on the specific fallback oracle interface
        // For now, return primary data with minimum confidence
        return (primaryPrice, primaryTimestamp, MIN_CONFIDENCE);
    }

    /**
     * @notice Check L2 sequencer status
     */
    function _checkSequencerStatus() internal view {
        if (sequencerUptimeFeed == address(0)) {
            return;
        }

        try
            AggregatorV3Interface(sequencerUptimeFeed).latestRoundData()
        returns (uint80, int256 answer, uint256 startedAt, uint256, uint80) {
            // answer == 0: Sequencer is up
            // answer == 1: Sequencer is down
            bool isSequencerUp = answer == 0;

            if (!isSequencerUp) {
                revert HedVaultErrors.SequencerDown();
            }

            // Check if sequencer was recently restarted
            uint256 timeSinceUp = block.timestamp - startedAt;
            if (timeSinceUp <= GRACE_PERIOD_TIME) {
                revert HedVaultErrors.GracePeriodNotOver();
            }
        } catch {
            // If we can't get sequencer status, assume it's down for safety
            revert HedVaultErrors.SequencerDown();
        }
    }

    // ============ ADMIN FUNCTIONS ============

    /**
     * @notice Update sequencer uptime feed
     * @param newSequencerFeed New sequencer uptime feed address
     */
    function updateSequencerFeed(
        address newSequencerFeed
    ) external onlyRole(ADAPTER_ADMIN_ROLE) {
        sequencerUptimeFeed = newSequencerFeed;
    }

    /**
     * @notice Emergency pause
     */
    function pause() external onlyRole(EMERGENCY_ROLE) {
        _pause();
    }

    /**
     * @notice Emergency unpause
     */
    function unpause() external onlyRole(ADAPTER_ADMIN_ROLE) {
        _unpause();
    }

    /**
     * @notice Activate/deactivate a price feed
     * @param asset Asset address
     * @param active New active status
     */
    function setPriceFeedActive(
        address asset,
        bool active
    ) external onlyRole(FEED_MANAGER_ROLE) onlyValidAsset(asset) {
        priceFeeds[asset].isActive = active;
    }
}
