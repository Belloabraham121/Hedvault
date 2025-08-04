// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./interfaces/IHedVaultCore.sol";
import "./libraries/DataTypes.sol";
import "./libraries/Events.sol";
import "./libraries/HedVaultErrors.sol";

// Chainlink interfaces for RWA data
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

// Interface for Chainlink Functions (for custom offchain data)
interface IChainlinkFunctions {
    function sendRequest(
        bytes calldata source,
        bytes calldata secrets,
        string[] calldata args,
        uint64 subscriptionId,
        uint32 gasLimit
    ) external returns (bytes32 requestId);
}

/**
 * @title RWAOffchainOracle
 * @notice Enhanced oracle for Real World Assets with offchain data integration
 * @dev Integrates with Chainlink price feeds and Functions for comprehensive RWA data
 */
contract RWAOffchainOracle is AccessControl, ReentrancyGuard, Pausable {
    // Roles
    bytes32 public constant ORACLE_ADMIN_ROLE = keccak256("ORACLE_ADMIN_ROLE");
    bytes32 public constant DATA_PROVIDER_ROLE = keccak256("DATA_PROVIDER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");

    // Core protocol reference
    IHedVaultCore public immutable hedVaultCore;
    
    // Chainlink Functions router (for offchain data)
    IChainlinkFunctions public chainlinkFunctions;
    uint64 public subscriptionId;

    // RWA-specific data structures
    struct RWAAssetData {
        address assetToken;           // RWA token address
        string assetType;            // Real estate, commodities, etc.
        address chainlinkFeed;       // Chainlink price feed (if available)
        string offchainDataSource;   // API endpoint for offchain data
        uint256 lastPrice;          // Last known price
        uint256 lastUpdate;         // Last update timestamp
        uint256 confidence;         // Data confidence level (0-10000)
        bool useOffchainData;       // Whether to use offchain data
        bool isActive;              // Whether asset is active
    }

    struct OffchainDataRequest {
        address assetToken;
        string dataSource;
        string[] parameters;
        uint256 timestamp;
        address requester;
        bool fulfilled;
    }

    struct RWAMarketData {
        uint256 marketCap;          // Total market capitalization
        uint256 tradingVolume24h;   // 24h trading volume
        uint256 liquidityIndex;     // Liquidity index (0-10000)
        uint256 volatilityIndex;    // Volatility index (0-10000)
        uint256 lastUpdated;       // Last update timestamp
    }

    // State variables
    mapping(address => RWAAssetData) public rwaAssets;
    mapping(bytes32 => OffchainDataRequest) public dataRequests;
    mapping(address => RWAMarketData) public marketData;
    mapping(string => address[]) public assetsByType;
    mapping(address => bool) public supportedAssets;
    
    address[] public assetList;
    
    // Oracle settings
    uint256 public constant MAX_DATA_AGE = 3600; // 1 hour
    uint256 public constant MIN_CONFIDENCE = 7000; // 70%
    uint256 public constant OFFCHAIN_REQUEST_FEE = 0.1 ether; // Fee for offchain requests

    // Hedera-specific Chainlink feeds for RWA assets
    mapping(string => address) public rwaTypeFeeds;

    // Events
    event RWAAssetRegistered(
        address indexed assetToken,
        string assetType,
        address chainlinkFeed,
        string offchainDataSource
    );
    
    event OffchainDataRequested(
        bytes32 indexed requestId,
        address indexed assetToken,
        string dataSource
    );
    
    event OffchainDataReceived(
        bytes32 indexed requestId,
        address indexed assetToken,
        uint256 price,
        uint256 confidence
    );
    
    event RWAMarketDataUpdated(
        address indexed assetToken,
        uint256 marketCap,
        uint256 volume24h,
        uint256 liquidityIndex
    );

    modifier onlyValidAsset(address asset) {
        if (!supportedAssets[asset]) {
            revert HedVaultErrors.OracleNotFound(asset);
        }
        _;
    }

    constructor(
        address _hedVaultCore,
        address _chainlinkFunctions,
        uint64 _subscriptionId
    ) {
        if (_hedVaultCore == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        hedVaultCore = IHedVaultCore(_hedVaultCore);
        chainlinkFunctions = IChainlinkFunctions(_chainlinkFunctions);
        subscriptionId = _subscriptionId;

        // Set up roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ORACLE_ADMIN_ROLE, msg.sender);
        _grantRole(DATA_PROVIDER_ROLE, msg.sender);
        _grantRole(EMERGENCY_ROLE, msg.sender);

        // Initialize RWA-specific Chainlink feeds for Hedera
        _initializeHederaRWAFeeds();
    }

    /**
     * @notice Register a new RWA asset for price tracking
     * @param assetToken RWA token address
     * @param assetType Type of real world asset
     * @param chainlinkFeed Chainlink price feed address (optional)
     * @param offchainDataSource API endpoint for offchain data
     * @param useOffchainData Whether to use offchain data
     */
    function registerRWAAsset(
        address assetToken,
        string calldata assetType,
        address chainlinkFeed,
        string calldata offchainDataSource,
        bool useOffchainData
    ) external onlyRole(ORACLE_ADMIN_ROLE) {
        if (assetToken == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        rwaAssets[assetToken] = RWAAssetData({
            assetToken: assetToken,
            assetType: assetType,
            chainlinkFeed: chainlinkFeed,
            offchainDataSource: offchainDataSource,
            lastPrice: 0,
            lastUpdate: 0,
            confidence: 0,
            useOffchainData: useOffchainData,
            isActive: true
        });

        if (!supportedAssets[assetToken]) {
            supportedAssets[assetToken] = true;
            assetList.push(assetToken);
            assetsByType[assetType].push(assetToken);
        }

        emit RWAAssetRegistered(assetToken, assetType, chainlinkFeed, offchainDataSource);
    }

    /**
     * @notice Get current price for an RWA asset
     * @param assetToken RWA token address
     * @return price Current price
     * @return timestamp Last update timestamp
     * @return confidence Price confidence level
     */
    function getRWAPrice(
        address assetToken
    )
        external
        view
        onlyValidAsset(assetToken)
        returns (uint256 price, uint256 timestamp, uint256 confidence)
    {
        RWAAssetData memory asset = rwaAssets[assetToken];
        
        // Check if data is stale
        if (block.timestamp - asset.lastUpdate > MAX_DATA_AGE) {
            revert HedVaultErrors.StalePriceData(assetToken, asset.lastUpdate);
        }

        return (asset.lastPrice, asset.lastUpdate, asset.confidence);
    }

    /**
     * @notice Update price from Chainlink feed
     * @param assetToken RWA token address
     */
    function updatePriceFromChainlink(
        address assetToken
    ) external onlyRole(DATA_PROVIDER_ROLE) onlyValidAsset(assetToken) {
        RWAAssetData storage asset = rwaAssets[assetToken];
        
        if (asset.chainlinkFeed == address(0)) {
            revert HedVaultErrors.InvalidConfiguration("No Chainlink feed configured");
        }

        try AggregatorV3Interface(asset.chainlinkFeed).latestRoundData() returns (
            uint80 roundId,
            int256 answer,
            uint256,
            uint256 updatedAt,
            uint80
        ) {
            if (answer <= 0) {
                revert HedVaultErrors.InvalidPriceData(assetToken, answer);
            }

            uint256 price = uint256(answer);
            uint256 confidence = _calculateConfidence(updatedAt, 3600); // 1 hour heartbeat

            asset.lastPrice = price;
            asset.lastUpdate = block.timestamp;
            asset.confidence = confidence;

            emit Events.PriceUpdated(assetToken, asset.lastPrice, price, block.timestamp);
        } catch {
            revert HedVaultErrors.OracleUpdateFailed(assetToken);
        }
    }

    /**
     * @notice Request offchain data for an RWA asset
     * @param assetToken RWA token address
     * @param parameters Additional parameters for the request
     */
    function requestOffchainData(
        address assetToken,
        string[] calldata parameters
    ) external payable onlyValidAsset(assetToken) {
        if (msg.value < OFFCHAIN_REQUEST_FEE) {
            revert HedVaultErrors.InsufficientFeePayment(msg.value, OFFCHAIN_REQUEST_FEE);
        }

        RWAAssetData memory asset = rwaAssets[assetToken];
        
        if (!asset.useOffchainData) {
            revert HedVaultErrors.InvalidConfiguration("Offchain data not enabled for asset");
        }

        // Create JavaScript source code for Chainlink Functions
        bytes memory source = abi.encodePacked(
            "const response = await Functions.makeHttpRequest({",
            "url: '", asset.offchainDataSource, "',",
            "method: 'GET'",
            "});",
            "if (response.error) throw new Error('API request failed');",
            "const price = response.data.price;",
            "const confidence = response.data.confidence || 8000;",
            "return Functions.encodeUint256(price);"
        );

        // Send request to Chainlink Functions
        bytes32 requestId = chainlinkFunctions.sendRequest(
            source,
            "", // No secrets needed for public APIs
            parameters,
            subscriptionId,
            300000 // Gas limit
        );

        dataRequests[requestId] = OffchainDataRequest({
            assetToken: assetToken,
            dataSource: asset.offchainDataSource,
            parameters: parameters,
            timestamp: block.timestamp,
            requester: msg.sender,
            fulfilled: false
        });

        emit OffchainDataRequested(requestId, assetToken, asset.offchainDataSource);
    }

    /**
     * @notice Fulfill offchain data request (called by Chainlink Functions)
     * @param requestId Request ID
     * @param response Encoded response data
     */
    function fulfillOffchainRequest(
        bytes32 requestId,
        bytes calldata response
    ) external {
        // Note: In production, this should be restricted to Chainlink Functions router
        OffchainDataRequest storage request = dataRequests[requestId];
        
        if (request.fulfilled) {
            revert HedVaultErrors.InvalidConfiguration("Request already fulfilled");
        }

        uint256 price = abi.decode(response, (uint256));
        uint256 confidence = 8000; // Default confidence for offchain data

        RWAAssetData storage asset = rwaAssets[request.assetToken];
        asset.lastPrice = price;
        asset.lastUpdate = block.timestamp;
        asset.confidence = confidence;

        request.fulfilled = true;

        emit OffchainDataReceived(requestId, request.assetToken, price, confidence);
        emit Events.PriceUpdated(request.assetToken, asset.lastPrice, price, block.timestamp);
    }

    /**
     * @notice Update market data for an RWA asset
     * @param assetToken RWA token address
     * @param marketCap Market capitalization
     * @param volume24h 24-hour trading volume
     * @param liquidityIndex Liquidity index
     * @param volatilityIndex Volatility index
     */
    function updateMarketData(
        address assetToken,
        uint256 marketCap,
        uint256 volume24h,
        uint256 liquidityIndex,
        uint256 volatilityIndex
    ) external onlyRole(DATA_PROVIDER_ROLE) onlyValidAsset(assetToken) {
        marketData[assetToken] = RWAMarketData({
            marketCap: marketCap,
            tradingVolume24h: volume24h,
            liquidityIndex: liquidityIndex,
            volatilityIndex: volatilityIndex,
            lastUpdated: block.timestamp
        });

        emit RWAMarketDataUpdated(assetToken, marketCap, volume24h, liquidityIndex);
    }

    /**
     * @notice Get market data for an RWA asset
     * @param assetToken RWA token address
     * @return Market data struct
     */
    function getMarketData(
        address assetToken
    ) external view onlyValidAsset(assetToken) returns (RWAMarketData memory) {
        return marketData[assetToken];
    }

    /**
     * @notice Get all assets of a specific type
     * @param assetType Asset type
     * @return Array of asset addresses
     */
    function getAssetsByType(
        string calldata assetType
    ) external view returns (address[] memory) {
        return assetsByType[assetType];
    }

    /**
     * @notice Get all supported assets
     * @return Array of all asset addresses
     */
    function getAllAssets() external view returns (address[] memory) {
        return assetList;
    }

    /**
     * @notice Initialize Hedera-specific RWA feeds
     */
    function _initializeHederaRWAFeeds() internal {
        // Real Estate Index feeds (hypothetical addresses for demonstration)
        rwaTypeFeeds["RealEstate"] = 0x1234567890123456789012345678901234567890;
        rwaTypeFeeds["PreciousMetals"] = 0x2345678901234567890123456789012345678901;
        rwaTypeFeeds["Commodities"] = 0x3456789012345678901234567890123456789012;
        rwaTypeFeeds["Art"] = 0x4567890123456789012345678901234567890123;
        rwaTypeFeeds["Bonds"] = 0x5678901234567890123456789012345678901234;
    }

    /**
     * @notice Calculate confidence based on data age
     * @param updatedAt Last update timestamp
     * @param heartbeat Expected update frequency
     * @return confidence Confidence level (0-10000)
     */
    function _calculateConfidence(
        uint256 updatedAt,
        uint256 heartbeat
    ) internal view returns (uint256) {
        uint256 age = block.timestamp - updatedAt;
        
        if (age >= heartbeat) {
            return MIN_CONFIDENCE;
        }
        
        uint256 maxConfidence = 10000;
        uint256 confidenceDecay = ((maxConfidence - MIN_CONFIDENCE) * age) / heartbeat;
        
        return maxConfidence - confidenceDecay;
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
    function unpause() external onlyRole(EMERGENCY_ROLE) {
        _unpause();
    }

    /**
     * @notice Withdraw accumulated fees
     */
    function withdrawFees() external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            payable(msg.sender).transfer(balance);
        }
    }

    /**
     * @notice Update Chainlink Functions configuration
     * @param _chainlinkFunctions New Chainlink Functions router
     * @param _subscriptionId New subscription ID
     */
    function updateChainlinkConfig(
        address _chainlinkFunctions,
        uint64 _subscriptionId
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        chainlinkFunctions = IChainlinkFunctions(_chainlinkFunctions);
        subscriptionId = _subscriptionId;
    }

    // Receive function to accept HBAR payments
    receive() external payable {}
}