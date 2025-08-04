// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/SwapEngine.sol";
import "../src/PriceOracle.sol";
import "../src/HedVaultCore.sol";
import "../src/libraries/HedVaultErrors.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Mock ERC20 token for testing
contract MockERC20 is ERC20 {
    uint8 private _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals_
    ) ERC20(name, symbol) {
        _decimals = decimals_;
        _mint(msg.sender, 1000000 * 10 ** decimals_);
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}

// Mock Chainlink Aggregator for price feeds
contract MockAggregatorV3 {
    int256 private _price;
    uint8 private _decimals;
    uint256 private _timestamp;
    uint80 private _roundId;

    constructor(uint8 decimals_, int256 initialPrice) {
        _price = initialPrice;
        _decimals = decimals_;
        _timestamp = block.timestamp;
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

    function getRoundData(
        uint80 _roundId_
    )
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
        return (_roundId_, _price, _timestamp, _timestamp, _roundId_);
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
        return (_roundId, _price, _timestamp, _timestamp, _roundId);
    }

    function updatePrice(int256 newPrice) external {
        _price = newPrice;
        _timestamp = block.timestamp;
        _roundId++;
    }
}

contract SwapEngineTest is Test {
    SwapEngine public swapEngine;
    PriceOracle public priceOracle;
    HedVaultCore public hedVaultCore;
    MockERC20 public tokenA;
    MockERC20 public tokenB;
    MockERC20 public tokenC;
    MockAggregatorV3 public aggregatorA;
    MockAggregatorV3 public aggregatorB;
    MockAggregatorV3 public aggregatorC;

    address public admin = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);
    address public feeRecipient = address(0x4);
    address public liquidityProvider = address(0x5);

    uint256 public constant INITIAL_SUPPLY = 1000000 * 10**18;
    uint256 public constant INITIAL_LIQUIDITY_A = 10000 * 10**18;
    uint256 public constant INITIAL_LIQUIDITY_B = 20000 * 10**18;
    uint256 public constant DEFAULT_FEE_RATE = 30; // 0.3%
    
    int256 public constant PRICE_A = 100 * 10**8; // $100
    int256 public constant PRICE_B = 50 * 10**8;  // $50
    int256 public constant PRICE_C = 200 * 10**8; // $200

    function setUp() public {
        vm.startPrank(admin);

        // Deploy mock tokens
        tokenA = new MockERC20("Token A", "TKNA", 18);
        tokenB = new MockERC20("Token B", "TKNB", 18);
        tokenC = new MockERC20("Token C", "TKNC", 18);

        // Deploy mock aggregators
        aggregatorA = new MockAggregatorV3(8, PRICE_A);
        aggregatorB = new MockAggregatorV3(8, PRICE_B);
        aggregatorC = new MockAggregatorV3(8, PRICE_C);

        // Deploy core contracts
        hedVaultCore = new HedVaultCore(feeRecipient);
        priceOracle = new PriceOracle(address(hedVaultCore));
        swapEngine = new SwapEngine(
            address(hedVaultCore),
            address(priceOracle),
            feeRecipient
        );

        // Setup price feeds
        priceOracle.configurePriceFeed(
            address(tokenA),
            address(aggregatorA),
            address(0), // no custom oracle
            3600, // 1 hour heartbeat
            8, // decimals
            1 * 10**8, // min price
            10000 * 10**8 // max price
        );
        priceOracle.configurePriceFeed(
            address(tokenB),
            address(aggregatorB),
            address(0),
            3600,
            8,
            1 * 10**8,
            10000 * 10**8
        );
        priceOracle.configurePriceFeed(
            address(tokenC),
            address(aggregatorC),
            address(0),
            3600,
            8,
            1 * 10**8,
            10000 * 10**8
        );

        // Set initial prices in the oracle
        priceOracle.updatePrice(address(tokenA), uint256(PRICE_A), 10000); // $100 with 100% confidence
        priceOracle.updatePrice(address(tokenB), uint256(PRICE_B), 10000); // $50 with 100% confidence
        priceOracle.updatePrice(address(tokenC), uint256(PRICE_C), 10000); // $200 with 100% confidence

        // Add supported tokens
        swapEngine.addSupportedToken(address(tokenA));
        swapEngine.addSupportedToken(address(tokenB));
        swapEngine.addSupportedToken(address(tokenC));

        vm.stopPrank();

        // Mint tokens to users
        tokenA.mint(user1, INITIAL_SUPPLY);
        tokenB.mint(user1, INITIAL_SUPPLY);
        tokenC.mint(user1, INITIAL_SUPPLY);
        
        tokenA.mint(user2, INITIAL_SUPPLY);
        tokenB.mint(user2, INITIAL_SUPPLY);
        tokenC.mint(user2, INITIAL_SUPPLY);
        
        tokenA.mint(liquidityProvider, INITIAL_SUPPLY);
        tokenB.mint(liquidityProvider, INITIAL_SUPPLY);
        tokenC.mint(liquidityProvider, INITIAL_SUPPLY);
    }

    // ============ POOL CREATION TESTS ============

    function test_CreatePool() public {
        vm.startPrank(liquidityProvider);
        
        tokenA.approve(address(swapEngine), INITIAL_LIQUIDITY_A);
        tokenB.approve(address(swapEngine), INITIAL_LIQUIDITY_B);
        
        uint256 poolId = swapEngine.createPool(
            address(tokenA),
            address(tokenB),
            INITIAL_LIQUIDITY_A,
            INITIAL_LIQUIDITY_B,
            DEFAULT_FEE_RATE
        );
        
        assertEq(poolId, 1);
        
        SwapEngine.LiquidityPool memory pool = swapEngine.getPool(poolId);
        assertEq(pool.tokenA, address(tokenA));
        assertEq(pool.tokenB, address(tokenB));
        assertEq(pool.reserveA, INITIAL_LIQUIDITY_A);
        assertEq(pool.reserveB, INITIAL_LIQUIDITY_B);
        assertEq(pool.feeRate, DEFAULT_FEE_RATE);
        assertTrue(pool.isActive);
        
        vm.stopPrank();
    }

    function test_CreatePoolRevertsWithSameToken() public {
        vm.startPrank(liquidityProvider);
        
        tokenA.approve(address(swapEngine), INITIAL_LIQUIDITY_A);
        
        vm.expectRevert();
        swapEngine.createPool(
            address(tokenA),
            address(tokenA),
            INITIAL_LIQUIDITY_A,
            INITIAL_LIQUIDITY_A,
            DEFAULT_FEE_RATE
        );
        
        vm.stopPrank();
    }

    function test_CreatePoolRevertsWithZeroAmount() public {
        vm.startPrank(liquidityProvider);
        
        vm.expectRevert(HedVaultErrors.ZeroAmount.selector);
        swapEngine.createPool(
            address(tokenA),
            address(tokenB),
            0,
            INITIAL_LIQUIDITY_B,
            DEFAULT_FEE_RATE
        );
        
        vm.stopPrank();
    }

    function test_CreatePoolRevertsWithHighFee() public {
        vm.startPrank(liquidityProvider);
        
        tokenA.approve(address(swapEngine), INITIAL_LIQUIDITY_A);
        tokenB.approve(address(swapEngine), INITIAL_LIQUIDITY_B);
        
        vm.expectRevert();
        swapEngine.createPool(
            address(tokenA),
            address(tokenB),
            INITIAL_LIQUIDITY_A,
            INITIAL_LIQUIDITY_B,
            1500 // 15% fee, above MAX_FEE_RATE
        );
        
        vm.stopPrank();
    }

    function test_CreatePoolRevertsWithUnsupportedToken() public {
        MockERC20 unsupportedToken = new MockERC20("Unsupported", "UNS", 18);
        
        vm.startPrank(liquidityProvider);
        
        vm.expectRevert();
        swapEngine.createPool(
            address(unsupportedToken),
            address(tokenB),
            INITIAL_LIQUIDITY_A,
            INITIAL_LIQUIDITY_B,
            DEFAULT_FEE_RATE
        );
        
        vm.stopPrank();
    }

    // ============ LIQUIDITY MANAGEMENT TESTS ============

    function test_AddLiquidity() public {
        // First create a pool
        uint256 poolId = _createTestPool();
        
        vm.startPrank(user1);
        
        uint256 addAmountA = 1000 * 10**18;
        uint256 addAmountB = 2000 * 10**18;
        
        tokenA.approve(address(swapEngine), addAmountA);
        tokenB.approve(address(swapEngine), addAmountB);
        
        uint256 liquidityBefore = swapEngine.getPool(poolId).totalLiquidity;
        
        uint256 liquidity = swapEngine.addLiquidity(
            poolId,
            addAmountA,
            addAmountB,
            0 // minLiquidity
        );
        
        assertGt(liquidity, 0);
        
        SwapEngine.LiquidityPool memory pool = swapEngine.getPool(poolId);
        assertGt(pool.totalLiquidity, liquidityBefore);
        
        vm.stopPrank();
    }

    function test_RemoveLiquidity() public {
        uint256 poolId = _createTestPool();
        
        vm.startPrank(liquidityProvider);
        
        SwapEngine.LiquidityPosition[] memory positions = swapEngine.getPoolPositions(poolId);
        uint256 positionIndex = 0;
        uint256 liquidityToRemove = positions[positionIndex].liquidity / 2;
        
        uint256 balanceABefore = tokenA.balanceOf(liquidityProvider);
        uint256 balanceBBefore = tokenB.balanceOf(liquidityProvider);
        
        (uint256 amountA, uint256 amountB) = swapEngine.removeLiquidity(
            poolId,
            positionIndex,
            liquidityToRemove,
            0, // minAmountA
            0  // minAmountB
        );
        
        assertGt(amountA, 0);
        assertGt(amountB, 0);
        assertEq(tokenA.balanceOf(liquidityProvider), balanceABefore + amountA);
        assertEq(tokenB.balanceOf(liquidityProvider), balanceBBefore + amountB);
        
        vm.stopPrank();
    }

    function test_RemoveLiquidityRevertsForWrongOwner() public {
        uint256 poolId = _createTestPool();
        
        vm.startPrank(user1);
        
        vm.expectRevert();
        swapEngine.removeLiquidity(
            poolId,
            0, // position index
            1000,
            0,
            0
        );
        
        vm.stopPrank();
    }

    // ============ SWAP TESTS ============

    function test_Swap() public {
        uint256 poolId = _createTestPool();
        
        vm.startPrank(user1);
        
        uint256 swapAmount = 100 * 10**18;
        tokenA.approve(address(swapEngine), swapAmount);
        
        uint256 balanceBBefore = tokenB.balanceOf(user1);
        
        uint256 amountOut = swapEngine.swap(
            poolId,
            address(tokenA),
            swapAmount,
            0, // minAmountOut
            5000 // maxSlippage (50%)
        );
        
        assertGt(amountOut, 0);
        assertEq(tokenB.balanceOf(user1), balanceBBefore + amountOut);
        
        vm.stopPrank();
    }

    function test_SwapRevertsWithZeroAmount() public {
        uint256 poolId = _createTestPool();
        
        vm.startPrank(user1);
        
        vm.expectRevert(HedVaultErrors.ZeroAmount.selector);
        swapEngine.swap(
            poolId,
            address(tokenA),
            0,
            0,
            5000
        );
        
        vm.stopPrank();
    }

    function test_SwapRevertsWithUnsupportedToken() public {
        uint256 poolId = _createTestPool();
        
        vm.startPrank(user1);
        
        vm.expectRevert();
        swapEngine.swap(
            poolId,
            address(tokenC), // tokenC is not in the pool
            100 * 10**18,
            0,
            5000
        );
        
        vm.stopPrank();
    }

    function test_SwapRevertsWithHighSlippage() public {
        uint256 poolId = _createTestPool();
        
        vm.startPrank(user1);
        
        uint256 swapAmount = 100 * 10**18;
        tokenA.approve(address(swapEngine), swapAmount);
        
        // Get quote first
        (uint256 expectedOut, ) = swapEngine.getSwapQuote(
            poolId,
            address(tokenA),
            swapAmount
        );
        
        // Set minAmountOut higher than expected
        vm.expectRevert();
        swapEngine.swap(
            poolId,
            address(tokenA),
            swapAmount,
            expectedOut + 1, // Higher than possible
            5000
        );
        
        vm.stopPrank();
    }

    // ============ QUOTE TESTS ============

    function test_GetSwapQuote() public {
        uint256 poolId = _createTestPool();
        
        uint256 swapAmount = 100 * 10**18;
        
        (uint256 amountOut, uint256 fee) = swapEngine.getSwapQuote(
            poolId,
            address(tokenA),
            swapAmount
        );
        
        assertGt(amountOut, 0);
        assertGt(fee, 0);
        assertEq(fee, (swapAmount * DEFAULT_FEE_RATE) / 10000);
    }

    // ============ ADMIN TESTS ============

    function test_AddSupportedToken() public {
        MockERC20 newToken = new MockERC20("New Token", "NEW", 18);
        
        vm.startPrank(admin);
        
        swapEngine.addSupportedToken(address(newToken));
        assertTrue(swapEngine.supportedTokens(address(newToken)));
        
        vm.stopPrank();
    }

    function test_AddSupportedTokenRevertsForNonAdmin() public {
        MockERC20 newToken = new MockERC20("New Token", "NEW", 18);
        
        vm.startPrank(user1);
        
        vm.expectRevert();
        swapEngine.addSupportedToken(address(newToken));
        
        vm.stopPrank();
    }

    function test_UpdatePoolFeeRate() public {
        uint256 poolId = _createTestPool();
        
        vm.startPrank(admin);
        
        uint256 newFeeRate = 50; // 0.5%
        swapEngine.updatePoolFeeRate(poolId, newFeeRate);
        
        SwapEngine.LiquidityPool memory pool = swapEngine.getPool(poolId);
        assertEq(pool.feeRate, newFeeRate);
        
        vm.stopPrank();
    }

    function test_UpdatePoolFeeRateRevertsForHighFee() public {
        uint256 poolId = _createTestPool();
        
        vm.startPrank(admin);
        
        vm.expectRevert();
        swapEngine.updatePoolFeeRate(poolId, 1500); // 15%, above MAX_FEE_RATE
        
        vm.stopPrank();
    }

    // ============ PAUSE TESTS ============

    function test_PauseAndUnpause() public {
        vm.startPrank(admin);
        
        swapEngine.pause();
        assertTrue(swapEngine.paused());
        
        swapEngine.unpause();
        assertFalse(swapEngine.paused());
        
        vm.stopPrank();
    }

    function test_SwapRevertsWhenPaused() public {
        uint256 poolId = _createTestPool();
        
        vm.prank(admin);
        swapEngine.pause();
        
        vm.startPrank(user1);
        
        tokenA.approve(address(swapEngine), 100 * 10**18);
        
        vm.expectRevert();
        swapEngine.swap(
            poolId,
            address(tokenA),
            100 * 10**18,
            0,
            5000
        );
        
        vm.stopPrank();
    }

    // ============ VIEW FUNCTION TESTS ============

    function test_GetPoolByTokens() public {
        uint256 poolId = _createTestPool();
        
        uint256 foundPoolId = swapEngine.getPoolByTokens(
            address(tokenA),
            address(tokenB)
        );
        
        assertEq(foundPoolId, poolId);
        
        // Test reverse order
        foundPoolId = swapEngine.getPoolByTokens(
            address(tokenB),
            address(tokenA)
        );
        
        assertEq(foundPoolId, poolId);
    }

    function test_GetUserPositions() public {
        _createTestPool();
        
        uint256[] memory positions = swapEngine.getUserPositions(liquidityProvider);
        assertEq(positions.length, 1);
    }

    // ============ EDGE CASE TESTS ============

    function test_MultiplePoolsWithSameTokens() public {
        uint256 poolId1 = _createTestPool();
        
        vm.startPrank(liquidityProvider);
        
        // Try to create another pool with same tokens
        tokenA.approve(address(swapEngine), INITIAL_LIQUIDITY_A);
        tokenB.approve(address(swapEngine), INITIAL_LIQUIDITY_B);
        
        vm.expectRevert();
        swapEngine.createPool(
            address(tokenA),
            address(tokenB),
            INITIAL_LIQUIDITY_A,
            INITIAL_LIQUIDITY_B,
            DEFAULT_FEE_RATE
        );
        
        vm.stopPrank();
    }

    function test_LargeSwap() public {
        uint256 poolId = _createTestPool();
        
        vm.startPrank(user1);
        
        // Try to swap more than available liquidity
        uint256 largeAmount = INITIAL_LIQUIDITY_A + 1;
        tokenA.approve(address(swapEngine), largeAmount);
        
        // This should revert due to insufficient liquidity
        vm.expectRevert();
        swapEngine.swap(
            poolId,
            address(tokenA),
            largeAmount,
            0,
            5000
        );
        
        vm.stopPrank();
    }

    // ============ HELPER FUNCTIONS ============

    function _createTestPool() internal returns (uint256 poolId) {
        vm.startPrank(liquidityProvider);
        
        tokenA.approve(address(swapEngine), INITIAL_LIQUIDITY_A);
        tokenB.approve(address(swapEngine), INITIAL_LIQUIDITY_B);
        
        poolId = swapEngine.createPool(
            address(tokenA),
            address(tokenB),
            INITIAL_LIQUIDITY_A,
            INITIAL_LIQUIDITY_B,
            DEFAULT_FEE_RATE
        );
        
        // Ensure pool has sufficient liquidity for testing
        require(swapEngine.getPool(poolId).reserveA > 0, "Pool reserve A is zero");
        require(swapEngine.getPool(poolId).reserveB > 0, "Pool reserve B is zero");
        
        vm.stopPrank();
    }

    // ============ FUZZ TESTS ============

    function testFuzz_CreatePool(
        uint256 amountA,
        uint256 amountB,
        uint256 feeRate
    ) public {
        amountA = bound(amountA, 1000 * 10**18, INITIAL_SUPPLY / 4);
        amountB = bound(amountB, 1000 * 10**18, INITIAL_SUPPLY / 4);
        feeRate = bound(feeRate, 1, 1000); // 0.01% to 10%
        
        vm.startPrank(liquidityProvider);
        
        tokenA.approve(address(swapEngine), amountA);
        tokenB.approve(address(swapEngine), amountB);
        
        uint256 poolId = swapEngine.createPool(
            address(tokenA),
            address(tokenB),
            amountA,
            amountB,
            feeRate
        );
        
        SwapEngine.LiquidityPool memory pool = swapEngine.getPool(poolId);
        assertEq(pool.reserveA, amountA);
        assertEq(pool.reserveB, amountB);
        assertEq(pool.feeRate, feeRate);
        
        vm.stopPrank();
    }

    function testFuzz_Swap(
        uint256 swapAmount
    ) public {
        uint256 poolId = _createTestPool();
        
        swapAmount = bound(swapAmount, 1 * 10**18, INITIAL_LIQUIDITY_A / 10);
        
        vm.startPrank(user1);
        
        tokenA.approve(address(swapEngine), swapAmount);
        
        uint256 balanceBefore = tokenB.balanceOf(user1);
        
        uint256 amountOut = swapEngine.swap(
            poolId,
            address(tokenA),
            swapAmount,
            0,
            5000
        );
        
        assertGt(amountOut, 0);
        assertEq(tokenB.balanceOf(user1), balanceBefore + amountOut);
        
        vm.stopPrank();
    }
}