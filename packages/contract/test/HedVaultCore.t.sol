// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/HedVaultCore.sol";
import "../src/libraries/HedVaultErrors.sol";
import "../src/libraries/Events.sol";

contract HedVaultCoreTest is Test {
    HedVaultCore public hedVaultCore;

    address public owner;
    address public feeRecipient;
    address public admin;
    address public user1;
    address public user2;

    // Mock module addresses
    address public mockRWATokenFactory;
    address public mockMarketplace;
    address public mockSwapEngine;
    address public mockLendingPool;
    address public mockRewardsDistributor;
    address public mockPriceOracle;
    address public mockComplianceManager;
    address public mockPortfolioManager;
    address public mockCrossChainBridge;
    address public mockAnalyticsEngine;

    function setUp() public {
        owner = address(this);
        feeRecipient = makeAddr("feeRecipient");
        admin = makeAddr("admin");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        // Create mock module addresses
        mockRWATokenFactory = makeAddr("rwaTokenFactory");
        mockMarketplace = makeAddr("marketplace");
        mockSwapEngine = makeAddr("swapEngine");
        mockLendingPool = makeAddr("lendingPool");
        mockRewardsDistributor = makeAddr("rewardsDistributor");
        mockPriceOracle = makeAddr("priceOracle");
        mockComplianceManager = makeAddr("complianceManager");
        mockPortfolioManager = makeAddr("portfolioManager");
        mockCrossChainBridge = makeAddr("crossChainBridge");
        mockAnalyticsEngine = makeAddr("analyticsEngine");

        hedVaultCore = new HedVaultCore(feeRecipient);
    }

    function test_Constructor() public view {
        assertEq(hedVaultCore.feeRecipient(), feeRecipient);
        assertEq(hedVaultCore.owner(), owner);
        assertTrue(hedVaultCore.admins(owner));
        assertEq(hedVaultCore.totalUsers(), 1);
        assertTrue(hedVaultCore.registeredUsers(owner));
        assertEq(hedVaultCore.VERSION(), "1.0.0");
    }

    function test_ConstructorRevertsWithZeroAddress() public {
        vm.expectRevert(HedVaultErrors.ZeroAddress.selector);
        new HedVaultCore(address(0));
    }

    function test_Initialize() public {
        address[10] memory modules = [
            mockRWATokenFactory,
            mockMarketplace,
            mockSwapEngine,
            mockLendingPool,
            mockRewardsDistributor,
            mockPriceOracle,
            mockComplianceManager,
            mockPortfolioManager,
            mockCrossChainBridge,
            mockAnalyticsEngine
        ];

        vm.expectEmit(true, true, false, true);
        emit Events.ProtocolInitialized(address(hedVaultCore), block.timestamp);

        hedVaultCore.initialize(modules);

        assertTrue(hedVaultCore.isInitialized());
        assertEq(hedVaultCore.initializationTime(), block.timestamp);
        assertEq(hedVaultCore.rwaTokenFactory(), mockRWATokenFactory);
        assertEq(hedVaultCore.marketplace(), mockMarketplace);
        assertEq(hedVaultCore.swapEngine(), mockSwapEngine);
        assertEq(hedVaultCore.lendingPool(), mockLendingPool);
        assertEq(hedVaultCore.rewardsDistributor(), mockRewardsDistributor);
        assertEq(hedVaultCore.priceOracle(), mockPriceOracle);
        assertEq(hedVaultCore.complianceManager(), mockComplianceManager);
        assertEq(hedVaultCore.portfolioManager(), mockPortfolioManager);
        assertEq(hedVaultCore.crossChainBridge(), mockCrossChainBridge);
        assertEq(hedVaultCore.analyticsEngine(), mockAnalyticsEngine);
    }

    function test_InitializeRevertsIfAlreadyInitialized() public {
        address[10] memory modules = [
            mockRWATokenFactory,
            mockMarketplace,
            mockSwapEngine,
            mockLendingPool,
            mockRewardsDistributor,
            mockPriceOracle,
            mockComplianceManager,
            mockPortfolioManager,
            mockCrossChainBridge,
            mockAnalyticsEngine
        ];

        hedVaultCore.initialize(modules);

        vm.expectRevert(HedVaultErrors.ProtocolAlreadyInitialized.selector);
        hedVaultCore.initialize(modules);
    }

    function test_InitializeRevertsWithZeroAddress() public {
        address[10] memory modules = [
            address(0), // Zero address
            mockMarketplace,
            mockSwapEngine,
            mockLendingPool,
            mockRewardsDistributor,
            mockPriceOracle,
            mockComplianceManager,
            mockPortfolioManager,
            mockCrossChainBridge,
            mockAnalyticsEngine
        ];

        vm.expectRevert(HedVaultErrors.ZeroAddress.selector);
        hedVaultCore.initialize(modules);
    }

    function test_InitializeOnlyOwner() public {
        address[10] memory modules = [
            mockRWATokenFactory,
            mockMarketplace,
            mockSwapEngine,
            mockLendingPool,
            mockRewardsDistributor,
            mockPriceOracle,
            mockComplianceManager,
            mockPortfolioManager,
            mockCrossChainBridge,
            mockAnalyticsEngine
        ];

        vm.prank(user1);
        vm.expectRevert();
        hedVaultCore.initialize(modules);
    }

    function test_RegisterUser() public {
        vm.expectEmit(true, true, false, true);
        emit Events.UserRegistered(user1, block.timestamp);

        vm.prank(user1);
        hedVaultCore.registerUser(user1);

        assertTrue(hedVaultCore.registeredUsers(user1));
        assertEq(hedVaultCore.userRegistrationTime(user1), block.timestamp);
        assertEq(hedVaultCore.totalUsers(), 2); // Owner + user1
    }

    function test_RegisterUserRevertsIfAlreadyRegistered() public {
        vm.prank(user1);
        hedVaultCore.registerUser(user1);

        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                HedVaultErrors.UserAlreadyRegistered.selector,
                user1
            )
        );
        hedVaultCore.registerUser(user1);
    }

    function test_RegisterUserRevertsWithZeroAddress() public {
        vm.expectRevert(HedVaultErrors.ZeroAddress.selector);
        hedVaultCore.registerUser(address(0));
    }

    function test_RegisterUserRevertsWhenPaused() public {
        hedVaultCore.pause();

        vm.expectRevert();
        hedVaultCore.registerUser(user1);
    }

    function test_AddAdmin() public {
        hedVaultCore.addAdmin(admin);

        assertTrue(hedVaultCore.admins(admin));
        assertEq(hedVaultCore.adminList(1), admin); // Index 1 since owner is at index 0
    }

    function test_AddAdminOnlyOwner() public {
        vm.prank(user1);
        vm.expectRevert();
        hedVaultCore.addAdmin(admin);
    }

    function test_RemoveAdmin() public {
        hedVaultCore.addAdmin(admin);
        assertTrue(hedVaultCore.admins(admin));

        hedVaultCore.removeAdmin(admin);
        assertFalse(hedVaultCore.admins(admin));
    }

    function test_UpdateFees() public {
        uint256 newTradingFee = 100;
        uint256 newLendingFee = 200;
        uint256 newSwapFee = 50;
        uint256 newBridgeFee = 300;

        hedVaultCore.updateFee("trading", newTradingFee);
        hedVaultCore.updateFee("lending", newLendingFee);
        hedVaultCore.updateFee("swap", newSwapFee);
        hedVaultCore.updateFee("bridge", newBridgeFee);

        assertEq(hedVaultCore.tradingFee(), newTradingFee);
        assertEq(hedVaultCore.lendingFee(), newLendingFee);
        assertEq(hedVaultCore.swapFee(), newSwapFee);
        assertEq(hedVaultCore.bridgeFee(), newBridgeFee);
    }

    function test_UpdateFeesRevertsIfExceedsMaximum() public {
        vm.expectRevert(
            abi.encodeWithSelector(HedVaultErrors.FeeTooHigh.selector, 600, 500)
        );
        hedVaultCore.updateFee("trading", 600); // Exceeds MAX_TRADING_FEE (500)
    }

    function test_UpdateFeeRecipient() public {
        address newFeeRecipient = makeAddr("newFeeRecipient");

        hedVaultCore.updateFeeRecipient(newFeeRecipient);
        assertEq(hedVaultCore.feeRecipient(), newFeeRecipient);
    }

    function test_UpdateFeeRecipientRevertsWithZeroAddress() public {
        vm.expectRevert(HedVaultErrors.ZeroAddress.selector);
        hedVaultCore.updateFeeRecipient(address(0));
    }

    function test_GetProtocolFee() public view {
        assertEq(hedVaultCore.getProtocolFee("trading"), 50);
        assertEq(hedVaultCore.getProtocolFee("lending"), 100);
        assertEq(hedVaultCore.getProtocolFee("swap"), 30);
        assertEq(hedVaultCore.getProtocolFee("bridge"), 200);
        assertEq(hedVaultCore.getProtocolFee("unknown"), 0);
    }

    function test_Pause() public {
        hedVaultCore.pause();
        assertTrue(hedVaultCore.paused());
    }

    function test_Unpause() public {
        hedVaultCore.pause();
        hedVaultCore.unpause();
        assertFalse(hedVaultCore.paused());
    }

    function test_PauseOnlyOwner() public {
        vm.prank(user1);
        vm.expectRevert();
        hedVaultCore.pause();
    }

    function test_ActivateEmergencyMode() public {
        hedVaultCore.activateEmergencyMode("Test emergency");
        assertTrue(hedVaultCore.emergencyMode());
    }

    function test_DeactivateEmergencyMode() public {
        hedVaultCore.activateEmergencyMode("Test emergency");
        hedVaultCore.deactivateEmergencyMode();
        assertFalse(hedVaultCore.emergencyMode());
    }

    function test_TriggerCircuitBreaker() public {
        string memory module = "marketplace";

        hedVaultCore.triggerCircuitBreaker(module, "Test circuit breaker");
        assertTrue(hedVaultCore.circuitBreakers(module));

        hedVaultCore.resetCircuitBreaker(module);
        assertFalse(hedVaultCore.circuitBreakers(module));
    }

    function test_GetProtocolStats() public view {
        (
            uint256 tvl,
            uint256 users,
            uint256 transactions,
            uint256 fees
        ) = hedVaultCore.getProtocolStats();

        assertEq(tvl, 0);
        assertEq(users, 1); // Owner is registered by default
        assertEq(transactions, 0);
        assertEq(fees, 0);
    }

    function test_ValidateTransaction() public {
        // Initialize the protocol first
        address[10] memory modules = [
            mockRWATokenFactory,
            mockMarketplace,
            mockSwapEngine,
            mockLendingPool,
            mockRewardsDistributor,
            mockPriceOracle,
            mockComplianceManager,
            mockPortfolioManager,
            mockCrossChainBridge,
            mockAnalyticsEngine
        ];
        hedVaultCore.initialize(modules);

        // Register user1 first
        hedVaultCore.registerUser(user1);

        // Check protocol state
        assertFalse(hedVaultCore.paused());
        assertFalse(hedVaultCore.emergencyMode());
        assertTrue(hedVaultCore.registeredUsers(user1));

        // Check limits
        (uint256 maxTVL, uint256 minTx, uint256 maxTx, , ) = hedVaultCore
            .getProtocolLimits();
        uint256 amount = 1000 * 1e18;
        assertTrue(amount >= minTx, "Amount below minimum");
        assertTrue(amount <= maxTx, "Amount above maximum");

        // Check TVL
        (uint256 tvl, , , ) = hedVaultCore.getProtocolStats();
        assertTrue(tvl + amount <= maxTVL, "Would exceed max TVL");

        // Check circuit breaker
        assertFalse(hedVaultCore.circuitBreakers("trading"));

        // Advance time to ensure we're past any rate limiting
        vm.warp(block.timestamp + 2 minutes);

        bool isValid = hedVaultCore.validateTransaction(
            user1,
            amount,
            "trading"
        );
        assertTrue(isValid);
    }

    function test_ValidateTransactionReturnsFalseWhenPaused() public {
        address[10] memory modules = [
            mockRWATokenFactory,
            mockMarketplace,
            mockSwapEngine,
            mockLendingPool,
            mockRewardsDistributor,
            mockPriceOracle,
            mockComplianceManager,
            mockPortfolioManager,
            mockCrossChainBridge,
            mockAnalyticsEngine
        ];
        hedVaultCore.initialize(modules);

        hedVaultCore.pause();

        bool isValid = hedVaultCore.validateTransaction(
            user1,
            1000 * 1e18,
            "trading"
        );
        assertFalse(isValid);
    }

    function test_ValidateTransactionReturnsFalseInEmergencyMode() public {
        address[10] memory modules = [
            mockRWATokenFactory,
            mockMarketplace,
            mockSwapEngine,
            mockLendingPool,
            mockRewardsDistributor,
            mockPriceOracle,
            mockComplianceManager,
            mockPortfolioManager,
            mockCrossChainBridge,
            mockAnalyticsEngine
        ];
        hedVaultCore.initialize(modules);

        hedVaultCore.activateEmergencyMode("Test emergency");

        bool isValid = hedVaultCore.validateTransaction(
            user1,
            1000 * 1e18,
            "trading"
        );
        assertFalse(isValid);
    }

    function test_GetProtocolLimits() public view {
        (
            uint256 maxTVL,
            uint256 minTx,
            uint256 maxTx,
            uint256 dailyTxLimit,
            uint256 dailyVolumeLimit
        ) = hedVaultCore.getProtocolLimits();

        assertEq(maxTVL, 1000000000 * 1e18);
        assertEq(minTx, 1 * 1e18);
        assertEq(maxTx, 10000000 * 1e18);
        assertEq(dailyTxLimit, 100);
        assertEq(dailyVolumeLimit, 1000000 * 1e18);
    }
}
