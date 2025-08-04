// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/PriceOracle.sol";
import "../src/HedVaultCore.sol";
import "../src/libraries/HedVaultErrors.sol";
import "../src/libraries/Events.sol";

// Mock Chainlink Aggregator for testing
contract MockChainlinkAggregator {
    int256 private _price;
    uint256 private _updatedAt;
    uint80 private _roundId;
    uint8 private _decimals;

    constructor(int256 price, uint8 decimals) {
        _price = price;
        _decimals = decimals;
        _updatedAt = block.timestamp;
        _roundId = 1;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function description() external pure returns (string memory) {
        return "Mock Chainlink Aggregator";
    }

    function version() external pure returns (uint256) {
        return 1;
    }

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (_roundId, _price, _updatedAt, _updatedAt, _roundId);
    }

    function updatePrice(int256 newPrice) external {
        _price = newPrice;
        _updatedAt = block.timestamp;
        _roundId++;
    }
}

contract PriceOracleTest is Test {
    PriceOracle public priceOracle;
    HedVaultCore public hedVaultCore;
    MockChainlinkAggregator public mockAggregator;

    address public owner;
    address public oracleAdmin;
    address public priceUpdater;
    address public emergencyRole;
    address public user1;
    address public asset1;
    address public asset2;

    uint256 constant INITIAL_PRICE = 1000 * 1e18; // $1000
    uint256 constant MIN_PRICE = 100 * 1e18; // $100
    uint256 constant MAX_PRICE = 10000 * 1e18; // $10000
    uint256 constant HEARTBEAT = 3600; // 1 hour
    uint8 constant DECIMALS = 18;

    function setUp() public {
        owner = makeAddr("owner");
        oracleAdmin = makeAddr("oracleAdmin");
        priceUpdater = makeAddr("priceUpdater");
        emergencyRole = makeAddr("emergencyRole");
        user1 = makeAddr("user1");
        asset1 = makeAddr("asset1");
        asset2 = makeAddr("asset2");

        // Deploy HedVaultCore
        vm.prank(owner);
        hedVaultCore = new HedVaultCore(makeAddr("feeRecipient"));

        // Deploy PriceOracle
        vm.prank(owner);
        priceOracle = new PriceOracle(address(hedVaultCore));

        // Deploy mock Chainlink aggregator
        mockAggregator = new MockChainlinkAggregator(
            int256(INITIAL_PRICE),
            DECIMALS
        );

        // Grant roles
        vm.startPrank(owner);
        priceOracle.grantRole(priceOracle.ORACLE_ADMIN_ROLE(), oracleAdmin);
        priceOracle.grantRole(priceOracle.PRICE_UPDATER_ROLE(), priceUpdater);
        priceOracle.grantRole(priceOracle.EMERGENCY_ROLE(), emergencyRole);
        vm.stopPrank();
    }

    // Constructor tests
    function test_Constructor() public {
        assertTrue(
            priceOracle.hasRole(priceOracle.DEFAULT_ADMIN_ROLE(), owner)
        );
        assertTrue(priceOracle.hasRole(priceOracle.ORACLE_ADMIN_ROLE(), owner));
        assertTrue(
            priceOracle.hasRole(priceOracle.PRICE_UPDATER_ROLE(), owner)
        );
        assertTrue(priceOracle.hasRole(priceOracle.EMERGENCY_ROLE(), owner));
        assertEq(address(priceOracle.hedVaultCore()), address(hedVaultCore));
    }

    function test_ConstructorRevertsWithZeroAddress() public {
        vm.expectRevert(HedVaultErrors.ZeroAddress.selector);
        new PriceOracle(address(0));
    }

    // Price feed configuration tests
    function test_ConfigurePriceFeed() public {
        vm.prank(oracleAdmin);
        priceOracle.configurePriceFeed(
            asset1,
            address(mockAggregator),
            address(0),
            HEARTBEAT,
            DECIMALS,
            MIN_PRICE,
            MAX_PRICE
        );

        assertTrue(priceOracle.supportedAssets(asset1));

        (
            address chainlinkFeed,
            address customOracle,
            uint256 heartbeat,
            uint8 decimals,
            bool isActive,
            uint256 minPrice,
            uint256 maxPrice,

        ) = priceOracle.priceFeedConfigs(asset1);
        assertEq(chainlinkFeed, address(mockAggregator));
        assertEq(customOracle, address(0));
        assertEq(heartbeat, HEARTBEAT);
        assertEq(decimals, DECIMALS);
        assertTrue(isActive);
        assertEq(minPrice, MIN_PRICE);
        assertEq(maxPrice, MAX_PRICE);
    }

    function test_ConfigurePriceFeedRevertsWithZeroAddress() public {
        vm.expectRevert(HedVaultErrors.ZeroAddress.selector);
        vm.prank(oracleAdmin);
        priceOracle.configurePriceFeed(
            address(0),
            address(mockAggregator),
            address(0),
            HEARTBEAT,
            DECIMALS,
            MIN_PRICE,
            MAX_PRICE
        );
    }

    function test_ConfigurePriceFeedRevertsWithNoOracles() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                HedVaultErrors.InvalidConfiguration.selector,
                "At least one oracle required"
            )
        );
        vm.prank(oracleAdmin);
        priceOracle.configurePriceFeed(
            asset1,
            address(0),
            address(0),
            HEARTBEAT,
            DECIMALS,
            MIN_PRICE,
            MAX_PRICE
        );
    }

    function test_ConfigurePriceFeedRevertsWithInvalidPriceRange() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                HedVaultErrors.InvalidConfiguration.selector,
                "Invalid price range"
            )
        );
        vm.prank(oracleAdmin);
        priceOracle.configurePriceFeed(
            asset1,
            address(mockAggregator),
            address(0),
            HEARTBEAT,
            DECIMALS,
            MAX_PRICE, // min > max
            MIN_PRICE
        );
    }

    function test_ConfigurePriceFeedOnlyOracleAdmin() public {
        vm.expectRevert();
        vm.prank(user1);
        priceOracle.configurePriceFeed(
            asset1,
            address(mockAggregator),
            address(0),
            HEARTBEAT,
            DECIMALS,
            MIN_PRICE,
            MAX_PRICE
        );
    }

    // Price update tests
    function test_UpdatePrice() public {
        // Configure price feed first
        vm.prank(oracleAdmin);
        priceOracle.configurePriceFeed(
            asset1,
            address(mockAggregator),
            address(0),
            HEARTBEAT,
            DECIMALS,
            MIN_PRICE,
            MAX_PRICE
        );

        uint256 newPrice = 1200 * 1e18;
        uint256 confidence = 9000; // 90%

        vm.prank(priceUpdater);
        priceOracle.updatePrice(asset1, newPrice, confidence);

        (
            uint256 price,
            uint256 timestamp,
            uint256 returnedConfidence
        ) = priceOracle.getPrice(asset1);
        assertEq(price, newPrice);
        assertEq(timestamp, block.timestamp);
        assertEq(returnedConfidence, confidence);
    }

    function test_UpdatePriceRevertsForUnsupportedAsset() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                HedVaultErrors.OracleNotFound.selector,
                asset1
            )
        );
        vm.prank(priceUpdater);
        priceOracle.updatePrice(asset1, INITIAL_PRICE, 9000);
    }

    function test_UpdatePriceOnlyPriceUpdater() public {
        // Configure price feed first
        vm.prank(oracleAdmin);
        priceOracle.configurePriceFeed(
            asset1,
            address(mockAggregator),
            address(0),
            HEARTBEAT,
            DECIMALS,
            MIN_PRICE,
            MAX_PRICE
        );

        vm.expectRevert();
        vm.prank(user1);
        priceOracle.updatePrice(asset1, INITIAL_PRICE, 9000);
    }

    // Emergency price tests
    function test_SetEmergencyPrice() public {
        // Configure price feed first
        vm.prank(oracleAdmin);
        priceOracle.configurePriceFeed(
            asset1,
            address(mockAggregator),
            address(0),
            HEARTBEAT,
            DECIMALS,
            MIN_PRICE,
            MAX_PRICE
        );

        uint256 emergencyPrice = 500 * 1e18;

        vm.prank(emergencyRole);
        priceOracle.setEmergencyPrice(asset1, emergencyPrice);

        (uint256 price, uint256 timestamp, uint256 confidence) = priceOracle
            .getPrice(asset1);
        assertEq(price, emergencyPrice);
        assertEq(timestamp, block.timestamp);
        assertEq(confidence, 10000); // 100% confidence for emergency prices

        (
            uint256 emergencyPriceStored,
            uint256 emergencyTimestamp,
            address setter,
            bool isActive
        ) = priceOracle.emergencyPrices(asset1);
        assertEq(emergencyPriceStored, emergencyPrice);
        assertEq(emergencyTimestamp, block.timestamp);
        assertEq(setter, emergencyRole);
        assertTrue(isActive);
    }

    function test_SetEmergencyPriceRevertsWithZeroPrice() public {
        // Configure price feed first
        vm.prank(oracleAdmin);
        priceOracle.configurePriceFeed(
            asset1,
            address(mockAggregator),
            address(0),
            HEARTBEAT,
            DECIMALS,
            MIN_PRICE,
            MAX_PRICE
        );

        vm.expectRevert(HedVaultErrors.ZeroAmount.selector);
        vm.prank(emergencyRole);
        priceOracle.setEmergencyPrice(asset1, 0);
    }

    function test_ClearEmergencyPrice() public {
        // Configure price feed and set emergency price first
        vm.prank(oracleAdmin);
        priceOracle.configurePriceFeed(
            asset1,
            address(mockAggregator),
            address(0),
            HEARTBEAT,
            DECIMALS,
            MIN_PRICE,
            MAX_PRICE
        );

        vm.prank(emergencyRole);
        priceOracle.setEmergencyPrice(asset1, 500 * 1e18);

        vm.prank(emergencyRole);
        priceOracle.clearEmergencyPrice(asset1);

        (, , , bool isActive) = priceOracle.emergencyPrices(asset1);
        assertFalse(isActive);
    }

    // Price retrieval tests
    function test_GetPriceRevertsForUnsupportedAsset() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                HedVaultErrors.OracleNotFound.selector,
                asset1
            )
        );
        priceOracle.getPrice(asset1);
    }

    function test_GetPriceRevertsForStalePrice() public {
        // Configure price feed and update price
        vm.prank(oracleAdmin);
        priceOracle.configurePriceFeed(
            asset1,
            address(mockAggregator),
            address(0),
            HEARTBEAT,
            DECIMALS,
            MIN_PRICE,
            MAX_PRICE
        );

        vm.prank(priceUpdater);
        priceOracle.updatePrice(asset1, INITIAL_PRICE, 9000);

        // Advance time beyond MAX_PRICE_AGE
        vm.warp(block.timestamp + priceOracle.MAX_PRICE_AGE() + 1);

        vm.expectRevert(
            abi.encodeWithSelector(
                HedVaultErrors.StalePriceData.selector,
                asset1,
                block.timestamp - priceOracle.MAX_PRICE_AGE() - 1
            )
        );
        priceOracle.getPrice(asset1);
    }

    function test_GetPriceUnsafe() public {
        // Configure price feed and update price
        vm.prank(oracleAdmin);
        priceOracle.configurePriceFeed(
            asset1,
            address(mockAggregator),
            address(0),
            HEARTBEAT,
            DECIMALS,
            MIN_PRICE,
            MAX_PRICE
        );

        vm.prank(priceUpdater);
        priceOracle.updatePrice(asset1, INITIAL_PRICE, 9000);

        // Advance time beyond MAX_PRICE_AGE
        vm.warp(block.timestamp + priceOracle.MAX_PRICE_AGE() + 1);

        // Should not revert even with stale price
        (uint256 price, uint256 timestamp, uint256 confidence) = priceOracle
            .getPriceUnsafe(asset1);
        assertEq(price, INITIAL_PRICE);
        assertEq(confidence, 9000);
    }

    function test_GetPrices() public {
        // Configure price feeds
        vm.startPrank(oracleAdmin);
        priceOracle.configurePriceFeed(
            asset1,
            address(mockAggregator),
            address(0),
            HEARTBEAT,
            DECIMALS,
            MIN_PRICE,
            MAX_PRICE
        );
        priceOracle.configurePriceFeed(
            asset2,
            address(0),
            makeAddr("customOracle"),
            HEARTBEAT,
            DECIMALS,
            MIN_PRICE,
            MAX_PRICE
        );
        vm.stopPrank();

        // Update prices
        vm.startPrank(priceUpdater);
        priceOracle.updatePrice(asset1, 1000 * 1e18, 9000);
        priceOracle.updatePrice(asset2, 2000 * 1e18, 8500);
        vm.stopPrank();

        address[] memory assets = new address[](2);
        assets[0] = asset1;
        assets[1] = asset2;

        (
            uint256[] memory prices,
            uint256[] memory timestamps,
            uint256[] memory confidences
        ) = priceOracle.getPrices(assets);

        assertEq(prices.length, 2);
        assertEq(prices[0], 1000 * 1e18);
        assertEq(prices[1], 2000 * 1e18);
        assertEq(confidences[0], 9000);
        assertEq(confidences[1], 8500);
    }

    function test_IsPriceFresh() public {
        // Should return false for unsupported asset
        assertFalse(priceOracle.isPriceFresh(asset1));

        // Configure price feed and update price
        vm.prank(oracleAdmin);
        priceOracle.configurePriceFeed(
            asset1,
            address(mockAggregator),
            address(0),
            HEARTBEAT,
            DECIMALS,
            MIN_PRICE,
            MAX_PRICE
        );

        vm.prank(priceUpdater);
        priceOracle.updatePrice(asset1, INITIAL_PRICE, 9000);

        // Should return true for fresh price
        assertTrue(priceOracle.isPriceFresh(asset1));

        // Advance time beyond MAX_PRICE_AGE
        vm.warp(block.timestamp + priceOracle.MAX_PRICE_AGE() + 1);

        // Should return false for stale price
        assertFalse(priceOracle.isPriceFresh(asset1));
    }

    // Pause functionality tests
    function test_PauseUnpause() public {
        vm.prank(owner);
        priceOracle.pause();
        assertTrue(priceOracle.paused());

        vm.prank(owner);
        priceOracle.unpause();
        assertFalse(priceOracle.paused());
    }

    // Constants tests
    function test_Constants() public {
        assertEq(priceOracle.MAX_PRICE_AGE(), 3600); // 1 hour
        assertEq(priceOracle.MIN_CONFIDENCE(), 8000); // 80%
        assertEq(priceOracle.MAX_DEVIATION(), 1000); // 10%
    }
}
