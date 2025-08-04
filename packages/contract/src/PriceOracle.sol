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
 * @title PriceOracle
 * @notice Manages price feeds for RWA assets using Chainlink and custom oracles
 * @dev Aggregates prices from multiple sources with fallback mechanisms
 */
contract PriceOracle is AccessControl, ReentrancyGuard, Pausable {
    // Roles
    bytes32 public constant ORACLE_ADMIN_ROLE = keccak256("ORACLE_ADMIN_ROLE");
    bytes32 public constant PRICE_UPDATER_ROLE =
        keccak256("PRICE_UPDATER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");

    // Core protocol reference
    IHedVaultCore public immutable hedVaultCore;

    // Price feed configurations
    struct PriceFeedConfig {
        address chainlinkFeed; // Chainlink aggregator address
        address customOracle; // Custom oracle address
        uint256 heartbeat; // Maximum time between updates (seconds)
        uint8 decimals; // Price decimals
        bool isActive; // Whether feed is active
        uint256 minPrice; // Minimum acceptable price
        uint256 maxPrice; // Maximum acceptable price
        uint256 maxPriceDeviation; // Maximum deviation from previous price (basis points)
    }

    // Asset price data
    struct AssetPrice {
        uint256 price; // Current price
        uint256 timestamp; // Last update timestamp
        uint256 confidence; // Price confidence level (0-10000 basis points)
        address source; // Price source address
        uint256 roundId; // Chainlink round ID (if applicable)
    }

    // Emergency price data (manual override)
    struct EmergencyPrice {
        uint256 price;
        uint256 timestamp;
        address setter;
        bool isActive;
    }

    // State variables
    mapping(address => PriceFeedConfig) public priceFeedConfigs;
    mapping(address => AssetPrice) public assetPrices;
    mapping(address => EmergencyPrice) public emergencyPrices;
    mapping(address => bool) public supportedAssets;

    address[] public assetList;

    // Oracle settings
    uint256 public constant MAX_PRICE_AGE = 3600; // 1 hour
    uint256 public constant MIN_CONFIDENCE = 8000; // 80%
    uint256 public constant MAX_DEVIATION = 1000; // 10%

    // Events
    event PriceFeedConfigured(
        address indexed asset,
        address chainlinkFeed,
        address customOracle,
        uint256 heartbeat
    );
    event PriceUpdated(
        address indexed asset,
        uint256 price,
        uint256 timestamp,
        address source,
        uint256 confidence
    );
    event EmergencyPriceSet(
        address indexed asset,
        uint256 price,
        address setter
    );
    event AssetAdded(address indexed asset);
    event AssetRemoved(address indexed asset);

    modifier onlyValidAsset(address asset) {
        if (!supportedAssets[asset]) {
            revert HedVaultErrors.OracleNotFound(asset);
        }
        _;
    }

    modifier priceNotStale(address asset) {
        if (block.timestamp - assetPrices[asset].timestamp > MAX_PRICE_AGE) {
            revert HedVaultErrors.StalePriceData(
                asset,
                assetPrices[asset].timestamp
            );
        }
        _;
    }

    constructor(address _hedVaultCore) {
        if (_hedVaultCore == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        hedVaultCore = IHedVaultCore(_hedVaultCore);

        // Set up roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ORACLE_ADMIN_ROLE, msg.sender);
        _grantRole(PRICE_UPDATER_ROLE, msg.sender);
        _grantRole(EMERGENCY_ROLE, msg.sender);
    }

    /**
     * @notice Configure price feed for an asset
     * @param asset Asset address
     * @param chainlinkFeed Chainlink aggregator address
     * @param customOracle Custom oracle address
     * @param heartbeat Maximum time between updates
     * @param decimals Price decimals
     * @param minPrice Minimum acceptable price
     * @param maxPrice Maximum acceptable price
     */
    function configurePriceFeed(
        address asset,
        address chainlinkFeed,
        address customOracle,
        uint256 heartbeat,
        uint8 decimals,
        uint256 minPrice,
        uint256 maxPrice
    ) external onlyRole(ORACLE_ADMIN_ROLE) {
        if (asset == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }
        if (chainlinkFeed == address(0) && customOracle == address(0)) {
            revert HedVaultErrors.InvalidConfiguration(
                "At least one oracle required"
            );
        }
        if (minPrice >= maxPrice) {
            revert HedVaultErrors.InvalidConfiguration("Invalid price range");
        }

        priceFeedConfigs[asset] = PriceFeedConfig({
            chainlinkFeed: chainlinkFeed,
            customOracle: customOracle,
            heartbeat: heartbeat,
            decimals: decimals,
            isActive: true,
            minPrice: minPrice,
            maxPrice: maxPrice,
            maxPriceDeviation: MAX_DEVIATION
        });

        if (!supportedAssets[asset]) {
            supportedAssets[asset] = true;
            assetList.push(asset);
            emit AssetAdded(asset);
        }

        emit PriceFeedConfigured(asset, chainlinkFeed, customOracle, heartbeat);
    }

    /**
     * @notice Update price for an asset
     * @param asset Asset address
     * @param price New price
     * @param confidence Price confidence level
     */
    function updatePrice(
        address asset,
        uint256 price,
        uint256 confidence
    ) external onlyRole(PRICE_UPDATER_ROLE) onlyValidAsset(asset) {
        _validateAndUpdatePrice(asset, price, confidence, msg.sender, 0);
    }

    /**
     * @notice Update prices from Chainlink feeds
     * @param assets Array of asset addresses
     */
    function updatePricesFromChainlink(
        address[] calldata assets
    ) external onlyRole(PRICE_UPDATER_ROLE) {
        for (uint256 i = 0; i < assets.length; i++) {
            _updatePriceFromChainlink(assets[i]);
        }
    }

    /**
     * @notice Set emergency price (manual override)
     * @param asset Asset address
     * @param price Emergency price
     */
    function setEmergencyPrice(
        address asset,
        uint256 price
    ) external onlyRole(EMERGENCY_ROLE) onlyValidAsset(asset) {
        if (price == 0) {
            revert HedVaultErrors.ZeroAmount();
        }

        emergencyPrices[asset] = EmergencyPrice({
            price: price,
            timestamp: block.timestamp,
            setter: msg.sender,
            isActive: true
        });

        emit EmergencyPriceSet(asset, price, msg.sender);
    }

    /**
     * @notice Clear emergency price
     * @param asset Asset address
     */
    function clearEmergencyPrice(
        address asset
    ) external onlyRole(EMERGENCY_ROLE) onlyValidAsset(asset) {
        emergencyPrices[asset].isActive = false;
    }

    /**
     * @notice Get current price for an asset
     * @param asset Asset address
     * @return price Current price
     * @return timestamp Last update timestamp
     * @return confidence Price confidence level
     */
    function getPrice(
        address asset
    )
        external
        view
        onlyValidAsset(asset)
        returns (uint256 price, uint256 timestamp, uint256 confidence)
    {
        // Check for emergency price first
        if (emergencyPrices[asset].isActive) {
            return (
                emergencyPrices[asset].price,
                emergencyPrices[asset].timestamp,
                10000 // 100% confidence for emergency prices
            );
        }

        AssetPrice memory assetPrice = assetPrices[asset];

        // Check if price is stale
        if (block.timestamp - assetPrice.timestamp > MAX_PRICE_AGE) {
            revert HedVaultErrors.StalePriceData(asset, assetPrice.timestamp);
        }

        return (assetPrice.price, assetPrice.timestamp, assetPrice.confidence);
    }

    /**
     * @notice Get price with staleness check disabled (for emergency situations)
     * @param asset Asset address
     * @return price Current price
     * @return timestamp Last update timestamp
     * @return confidence Price confidence level
     */
    function getPriceUnsafe(
        address asset
    )
        external
        view
        onlyValidAsset(asset)
        returns (uint256 price, uint256 timestamp, uint256 confidence)
    {
        // Check for emergency price first
        if (emergencyPrices[asset].isActive) {
            return (
                emergencyPrices[asset].price,
                emergencyPrices[asset].timestamp,
                10000
            );
        }

        AssetPrice memory assetPrice = assetPrices[asset];
        return (assetPrice.price, assetPrice.timestamp, assetPrice.confidence);
    }

    /**
     * @notice Get prices for multiple assets
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
     * @notice Check if asset price is fresh
     * @param asset Asset address
     * @return isFresh True if price is fresh
     */
    function isPriceFresh(address asset) external view returns (bool) {
        if (!supportedAssets[asset]) {
            return false;
        }

        if (emergencyPrices[asset].isActive) {
            return true;
        }

        return block.timestamp - assetPrices[asset].timestamp <= MAX_PRICE_AGE;
    }

    /**
     * @notice Get all supported assets
     * @return assets Array of supported asset addresses
     */
    function getSupportedAssets() external view returns (address[] memory) {
        return assetList;
    }

    /**
     * @notice Remove asset support
     * @param asset Asset address
     */
    function removeAsset(address asset) external onlyRole(ORACLE_ADMIN_ROLE) {
        if (!supportedAssets[asset]) {
            revert HedVaultErrors.OracleNotFound(asset);
        }

        supportedAssets[asset] = false;
        priceFeedConfigs[asset].isActive = false;

        // Remove from asset list
        for (uint256 i = 0; i < assetList.length; i++) {
            if (assetList[i] == asset) {
                assetList[i] = assetList[assetList.length - 1];
                assetList.pop();
                break;
            }
        }

        emit AssetRemoved(asset);
    }

    /**
     * @notice Pause the oracle
     */
    function pause() external onlyRole(EMERGENCY_ROLE) {
        _pause();
    }

    /**
     * @notice Unpause the oracle
     */
    function unpause() external onlyRole(EMERGENCY_ROLE) {
        _unpause();
    }

    // Internal functions
    function _updatePriceFromChainlink(address asset) internal {
        PriceFeedConfig memory config = priceFeedConfigs[asset];

        if (!config.isActive || config.chainlinkFeed == address(0)) {
            return;
        }

        try
            AggregatorV3Interface(config.chainlinkFeed).latestRoundData()
        returns (
            uint80 roundId,
            int256 answer,
            uint256,
            uint256 updatedAt,
            uint80
        ) {
            if (answer <= 0) {
                return; // Invalid price
            }

            uint256 price = uint256(answer);

            // Adjust decimals if necessary
            if (
                config.decimals !=
                AggregatorV3Interface(config.chainlinkFeed).decimals()
            ) {
                uint8 feedDecimals = AggregatorV3Interface(config.chainlinkFeed)
                    .decimals();
                if (config.decimals > feedDecimals) {
                    price = price * (10 ** (config.decimals - feedDecimals));
                } else {
                    price = price / (10 ** (feedDecimals - config.decimals));
                }
            }

            // Calculate confidence based on data freshness
            uint256 confidence = _calculateConfidence(
                updatedAt,
                config.heartbeat
            );

            _validateAndUpdatePrice(
                asset,
                price,
                confidence,
                config.chainlinkFeed,
                roundId
            );
        } catch {
            // Chainlink feed failed, could try custom oracle as fallback
            return;
        }
    }

    function _validateAndUpdatePrice(
        address asset,
        uint256 price,
        uint256 confidence,
        address source,
        uint256 roundId
    ) internal {
        PriceFeedConfig memory config = priceFeedConfigs[asset];

        // Validate price range
        if (price < config.minPrice || price > config.maxPrice) {
            revert HedVaultErrors.InvalidPriceData(asset, int256(price));
        }

        // Validate confidence
        if (confidence < MIN_CONFIDENCE) {
            revert HedVaultErrors.InvalidPriceData(asset, int256(confidence));
        }

        // Check price deviation from previous price
        AssetPrice memory currentPrice = assetPrices[asset];
        if (currentPrice.price > 0) {
            uint256 deviation = price > currentPrice.price
                ? ((price - currentPrice.price) * 10000) / currentPrice.price
                : ((currentPrice.price - price) * 10000) / currentPrice.price;

            if (deviation > config.maxPriceDeviation) {
                revert HedVaultErrors.PriceDeviationTooHigh(
                    deviation,
                    config.maxPriceDeviation
                );
            }
        }

        // Update price
        assetPrices[asset] = AssetPrice({
            price: price,
            timestamp: block.timestamp,
            confidence: confidence,
            source: source,
            roundId: roundId
        });

        emit PriceUpdated(asset, price, block.timestamp, source, confidence);
    }

    function _calculateConfidence(
        uint256 updatedAt,
        uint256 heartbeat
    ) internal view returns (uint256) {
        uint256 age = block.timestamp - updatedAt;

        if (age >= heartbeat) {
            return MIN_CONFIDENCE; // Minimum confidence for stale data
        }

        // Linear decay from 100% to MIN_CONFIDENCE based on age
        uint256 maxConfidence = 10000;
        uint256 confidenceDecay = ((maxConfidence - MIN_CONFIDENCE) * age) /
            heartbeat;

        return maxConfidence - confidenceDecay;
    }
}
