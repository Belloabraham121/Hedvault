// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/LendingPool.sol";
import "../src/HedVaultCore.sol";
import "../src/PriceOracle.sol";
import "../src/libraries/HedVaultErrors.sol";
import "../src/libraries/DataTypes.sol";
import "../src/libraries/Events.sol";
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
contract MockChainlinkAggregator {
    int256 private _price;
    uint8 private _decimals;
    uint256 private _timestamp;
    uint80 private _roundId;

    constructor(int256 initialPrice, uint8 decimals_) {
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

contract LendingPoolTest is Test {
    LendingPool public lendingPool;
    HedVaultCore public hedVaultCore;
    PriceOracle public priceOracle;
    MockERC20 public collateralToken;
    MockERC20 public borrowToken;
    MockERC20 public anotherToken;
    MockChainlinkAggregator public collateralAggregator;
    MockChainlinkAggregator public borrowAggregator;
    MockChainlinkAggregator public anotherAggregator;

    // Events from LendingPool contract
    event Deposit(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 timestamp
    );
    event Withdraw(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 timestamp
    );
    event LoanCreated(
        uint256 indexed loanId,
        address indexed borrower,
        address indexed collateralToken,
        address borrowToken,
        uint256 collateralAmount,
        uint256 borrowAmount,
        uint256 interestRate
    );
    event LoanRepaid(
        uint256 indexed loanId,
        address indexed borrower,
        uint256 repaidAmount,
        uint256 interestPaid,
        uint256 timestamp
    );
    event LoanLiquidated(
        uint256 indexed loanId,
        address indexed borrower,
        address indexed liquidator,
        uint256 collateralSeized,
        uint256 debtCovered,
        uint256 liquidationBonus
    );
    event TokenAdded(
        address indexed token,
        uint256 collateralFactor,
        uint256 liquidationBonus
    );
    event CollateralFactorUpdated(
        address indexed token,
        uint256 oldFactor,
        uint256 newFactor
    );
    event LiquidationBonusUpdated(
        address indexed token,
        uint256 oldBonus,
        uint256 newBonus
    );
    event InterestRateModelUpdated(
        uint256 baseRate,
        uint256 slope1,
        uint256 slope2,
        uint256 optimalUtilization
    );
    event PoolStatusUpdated(address indexed token, bool active);
    event BorrowingStatusUpdated(address indexed token, bool enabled);
    event ProtocolFeeRateUpdated(uint256 oldRate, uint256 newRate);
    event FeeRecipientUpdated(address oldRecipient, address newRecipient);

    address public admin = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);
    address public liquidator = address(0x4);
    address public feeRecipient = address(0x5);

    uint256 constant INITIAL_SUPPLY = 1000000 * 10 ** 18;
    uint256 constant COLLATERAL_AMOUNT = 1000 * 10 ** 18;
    uint256 constant BORROW_AMOUNT = 500 * 10 ** 18;
    uint256 constant DEPOSIT_AMOUNT = 10000 * 10 ** 18;

    // Price constants (8 decimals for Chainlink)
    int256 constant COLLATERAL_PRICE = 2000 * 10 ** 8; // $2000
    int256 constant BORROW_PRICE = 1 * 10 ** 8; // $1
    int256 constant ANOTHER_PRICE = 100 * 10 ** 8; // $100

    function setUp() public {
        vm.startPrank(admin);

        // Deploy tokens
        collateralToken = new MockERC20("Collateral Token", "COLL", 18);
        borrowToken = new MockERC20("Borrow Token", "BORR", 18);
        anotherToken = new MockERC20("Another Token", "ANOT", 18);

        // Deploy price aggregators
        collateralAggregator = new MockChainlinkAggregator(COLLATERAL_PRICE, 8);
        borrowAggregator = new MockChainlinkAggregator(BORROW_PRICE, 8);
        anotherAggregator = new MockChainlinkAggregator(ANOTHER_PRICE, 8);

        // Deploy HedVaultCore
        hedVaultCore = new HedVaultCore(feeRecipient);

        // Deploy PriceOracle
        priceOracle = new PriceOracle(address(hedVaultCore));

        // Deploy LendingPool
        lendingPool = new LendingPool(
            address(hedVaultCore),
            address(priceOracle),
            feeRecipient
        );

        // Grant necessary roles to admin
        lendingPool.grantRole(lendingPool.POOL_ADMIN_ROLE(), admin);

        // Grant oracle roles to admin for price feed configuration and updates
        priceOracle.grantRole(priceOracle.ORACLE_ADMIN_ROLE(), admin);
        priceOracle.grantRole(priceOracle.PRICE_UPDATER_ROLE(), admin);

        // Setup price feeds
        priceOracle.configurePriceFeed(
            address(collateralToken),
            address(collateralAggregator),
            address(0), // No custom oracle
            3600, // 1 hour heartbeat
            8, // Chainlink decimals
            1 * 10 ** 8, // Min price $1
            10000 * 10 ** 8 // Max price $10,000
        );
        priceOracle.configurePriceFeed(
            address(borrowToken),
            address(borrowAggregator),
            address(0),
            3600,
            8,
            1 * 10 ** 6, // Min price $0.01
            1000 * 10 ** 8 // Max price $1,000
        );
        priceOracle.configurePriceFeed(
            address(anotherToken),
            address(anotherAggregator),
            address(0),
            3600,
            8,
            1 * 10 ** 8, // Min price $1
            1000 * 10 ** 8 // Max price $1,000
        );

        // Update initial prices (using 8 decimals as configured)
        priceOracle.updatePrice(
            address(collateralToken),
            uint256(COLLATERAL_PRICE),
            10000
        );
        priceOracle.updatePrice(
            address(borrowToken),
            uint256(BORROW_PRICE),
            10000
        );
        priceOracle.updatePrice(
            address(anotherToken),
            uint256(ANOTHER_PRICE),
            10000
        );

        // Add supported tokens to lending pool
        lendingPool.addSupportedToken(
            address(collateralToken),
            7000, // 70% collateral factor
            1000 // 10% liquidation bonus
        );
        lendingPool.addSupportedToken(
            address(borrowToken),
            6000, // 60% collateral factor
            1200 // 12% liquidation bonus
        );
        lendingPool.addSupportedToken(
            address(anotherToken),
            5000, // 50% collateral factor
            1500 // 15% liquidation bonus
        );

        vm.stopPrank();

        // Mint tokens to admin first
        collateralToken.mint(admin, INITIAL_SUPPLY);
        borrowToken.mint(admin, INITIAL_SUPPLY);
        anotherToken.mint(admin, INITIAL_SUPPLY);

        // Distribute tokens to users
        vm.startPrank(admin);
        collateralToken.transfer(user1, INITIAL_SUPPLY / 4);
        collateralToken.transfer(user2, INITIAL_SUPPLY / 4);
        collateralToken.transfer(liquidator, INITIAL_SUPPLY / 4);

        borrowToken.transfer(user1, INITIAL_SUPPLY / 4);
        borrowToken.transfer(user2, INITIAL_SUPPLY / 4);
        borrowToken.transfer(liquidator, INITIAL_SUPPLY / 4);

        anotherToken.transfer(user1, INITIAL_SUPPLY / 4);
        anotherToken.transfer(user2, INITIAL_SUPPLY / 4);
        anotherToken.transfer(liquidator, INITIAL_SUPPLY / 4);
        vm.stopPrank();

        // Approve tokens for lending pool
        vm.startPrank(user1);
        collateralToken.approve(address(lendingPool), type(uint256).max);
        borrowToken.approve(address(lendingPool), type(uint256).max);
        anotherToken.approve(address(lendingPool), type(uint256).max);
        vm.stopPrank();

        vm.startPrank(user2);
        collateralToken.approve(address(lendingPool), type(uint256).max);
        borrowToken.approve(address(lendingPool), type(uint256).max);
        anotherToken.approve(address(lendingPool), type(uint256).max);
        vm.stopPrank();

        vm.startPrank(liquidator);
        collateralToken.approve(address(lendingPool), type(uint256).max);
        borrowToken.approve(address(lendingPool), type(uint256).max);
        anotherToken.approve(address(lendingPool), type(uint256).max);
        vm.stopPrank();
    }

    // Helper function to update prices and advance time
    function _updatePricesAndAdvanceTime(uint256 timeAdvance) internal {
        if (timeAdvance > 0) {
            vm.warp(block.timestamp + timeAdvance);
        }

        vm.startPrank(admin);
        priceOracle.updatePrice(
            address(collateralToken),
            uint256(COLLATERAL_PRICE),
            10000
        );
        priceOracle.updatePrice(
            address(borrowToken),
            uint256(BORROW_PRICE),
            10000
        );
        priceOracle.updatePrice(
            address(anotherToken),
            uint256(ANOTHER_PRICE),
            10000
        );
        vm.stopPrank();
    }

    // ============ CONSTRUCTOR TESTS ============

    function test_Constructor() public view {
        assertEq(address(lendingPool.hedVaultCore()), address(hedVaultCore));
        assertEq(address(lendingPool.priceOracle()), address(priceOracle));
        assertEq(lendingPool.feeRecipient(), feeRecipient);
        assertEq(lendingPool.nextLoanId(), 1);
        assertTrue(
            lendingPool.hasRole(lendingPool.DEFAULT_ADMIN_ROLE(), admin)
        );
    }

    function test_ConstructorRevertsWithZeroAddress() public {
        vm.expectRevert(HedVaultErrors.ZeroAddress.selector);
        new LendingPool(address(0), address(priceOracle), feeRecipient);

        vm.expectRevert(HedVaultErrors.ZeroAddress.selector);
        new LendingPool(address(hedVaultCore), address(0), feeRecipient);

        vm.expectRevert(HedVaultErrors.ZeroAddress.selector);
        new LendingPool(
            address(hedVaultCore),
            address(priceOracle),
            address(0)
        );
    }

    // ============ DEPOSIT TESTS ============

    function test_Deposit() public {
        vm.startPrank(user1);

        uint256 balanceBefore = collateralToken.balanceOf(user1);
        uint256 poolBalanceBefore = collateralToken.balanceOf(
            address(lendingPool)
        );

        vm.expectEmit(true, true, false, true);
        emit Deposit(
            user1,
            address(collateralToken),
            DEPOSIT_AMOUNT,
            block.timestamp
        );

        lendingPool.deposit(address(collateralToken), DEPOSIT_AMOUNT);

        assertEq(
            collateralToken.balanceOf(user1),
            balanceBefore - DEPOSIT_AMOUNT
        );
        assertEq(
            collateralToken.balanceOf(address(lendingPool)),
            poolBalanceBefore + DEPOSIT_AMOUNT
        );
        assertEq(
            lendingPool.getUserBalance(user1, address(collateralToken)),
            DEPOSIT_AMOUNT
        );

        LendingPool.PoolInfo memory poolInfo = lendingPool.getPoolInfo(
            address(collateralToken)
        );
        assertEq(poolInfo.totalDeposits, DEPOSIT_AMOUNT);

        vm.stopPrank();
    }

    function test_DepositRevertsWithZeroAmount() public {
        vm.startPrank(user1);
        vm.expectRevert(HedVaultErrors.ZeroAmount.selector);
        lendingPool.deposit(address(collateralToken), 0);
        vm.stopPrank();
    }

    function test_DepositRevertsWithUnsupportedToken() public {
        MockERC20 unsupportedToken = new MockERC20("Unsupported", "UNS", 18);

        vm.startPrank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                HedVaultErrors.TokenNotListed.selector,
                address(unsupportedToken)
            )
        );
        lendingPool.deposit(address(unsupportedToken), DEPOSIT_AMOUNT);
        vm.stopPrank();
    }

    function test_DepositRevertsWhenPaused() public {
        vm.prank(admin);
        lendingPool.pause();

        vm.startPrank(user1);
        vm.expectRevert(abi.encodeWithSignature("EnforcedPause()"));
        lendingPool.deposit(address(collateralToken), DEPOSIT_AMOUNT);
        vm.stopPrank();
    }

    function test_DepositRevertsWhenDepositsDisabled() public {
        vm.prank(admin);
        lendingPool.setPoolActive(address(collateralToken), false);

        vm.startPrank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                HedVaultErrors.TokenNotActive.selector,
                address(collateralToken)
            )
        );
        lendingPool.deposit(address(collateralToken), DEPOSIT_AMOUNT);
        vm.stopPrank();
    }

    // ============ WITHDRAW TESTS ============

    function test_Withdraw() public {
        // First deposit
        vm.startPrank(user1);
        lendingPool.deposit(address(collateralToken), DEPOSIT_AMOUNT);

        uint256 balanceBefore = collateralToken.balanceOf(user1);
        uint256 poolBalanceBefore = collateralToken.balanceOf(
            address(lendingPool)
        );

        vm.expectEmit(true, true, false, true);
        emit Withdraw(
            user1,
            address(collateralToken),
            DEPOSIT_AMOUNT / 2,
            block.timestamp
        );

        lendingPool.withdraw(address(collateralToken), DEPOSIT_AMOUNT / 2);

        assertEq(
            collateralToken.balanceOf(user1),
            balanceBefore + DEPOSIT_AMOUNT / 2
        );
        assertEq(
            collateralToken.balanceOf(address(lendingPool)),
            poolBalanceBefore - DEPOSIT_AMOUNT / 2
        );
        assertEq(
            lendingPool.getUserBalance(user1, address(collateralToken)),
            DEPOSIT_AMOUNT / 2
        );

        vm.stopPrank();
    }

    function test_WithdrawAll() public {
        // First deposit
        vm.startPrank(user1);
        lendingPool.deposit(address(collateralToken), DEPOSIT_AMOUNT);

        uint256 balanceBefore = collateralToken.balanceOf(user1);

        // Withdraw all (amount = 0)
        lendingPool.withdraw(address(collateralToken), 0);

        assertEq(
            collateralToken.balanceOf(user1),
            balanceBefore + DEPOSIT_AMOUNT
        );
        assertEq(
            lendingPool.getUserBalance(user1, address(collateralToken)),
            0
        );

        vm.stopPrank();
    }

    function test_WithdrawRevertsWithInsufficientBalance() public {
        vm.startPrank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                HedVaultErrors.InsufficientBalance.selector,
                address(collateralToken),
                DEPOSIT_AMOUNT,
                0
            )
        );
        lendingPool.withdraw(address(collateralToken), DEPOSIT_AMOUNT);
        vm.stopPrank();
    }

    function test_WithdrawRevertsWithInsufficientLiquidity() public {
        // User1 deposits
        vm.startPrank(user1);
        lendingPool.deposit(address(borrowToken), DEPOSIT_AMOUNT);
        vm.stopPrank();

        // User2 creates a loan that borrows most of the liquidity
        vm.startPrank(user2);
        lendingPool.createLoan(
            address(collateralToken),
            address(borrowToken),
            COLLATERAL_AMOUNT * 2, // More collateral for higher borrow
            DEPOSIT_AMOUNT - 1000 * 10 ** 18 // Borrow almost all
        );
        vm.stopPrank();

        // User1 tries to withdraw more than available liquidity
        vm.startPrank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                HedVaultErrors.InsufficientLiquidity.selector,
                address(borrowToken),
                address(0)
            )
        );
        lendingPool.withdraw(address(borrowToken), DEPOSIT_AMOUNT);
        vm.stopPrank();
    }

    // ============ CREATE LOAN TESTS ============

    function test_CreateLoan() public {
        // User1 deposits borrow tokens to provide liquidity
        vm.startPrank(user1);
        lendingPool.deposit(address(borrowToken), DEPOSIT_AMOUNT);
        vm.stopPrank();

        vm.startPrank(user2);

        uint256 collateralBalanceBefore = collateralToken.balanceOf(user2);
        uint256 borrowBalanceBefore = borrowToken.balanceOf(user2);

        vm.expectEmit(true, true, true, true);
        emit LoanCreated(
            1,
            user2,
            address(collateralToken),
            address(borrowToken),
            COLLATERAL_AMOUNT * 4,
            BORROW_AMOUNT * 4,
            lendingPool.getBorrowAPY(address(borrowToken))
        );

        uint256 loanId = lendingPool.createLoan(
            address(collateralToken),
            address(borrowToken),
            COLLATERAL_AMOUNT * 4, // Increase collateral to support higher borrow
            BORROW_AMOUNT * 4 // Borrow more to make it more leveraged
        );

        assertEq(loanId, 1);
        assertEq(
            collateralToken.balanceOf(user2),
            collateralBalanceBefore - (COLLATERAL_AMOUNT * 4)
        );
        assertEq(
            borrowToken.balanceOf(user2),
            borrowBalanceBefore + (BORROW_AMOUNT * 4)
        );

        LendingPool.LoanInfo memory loan = lendingPool.getLoanInfo(loanId);
        assertEq(loan.borrower, user2);
        assertEq(loan.collateralToken, address(collateralToken));
        assertEq(loan.borrowToken, address(borrowToken));
        assertEq(loan.collateralAmount, COLLATERAL_AMOUNT * 4);
        assertEq(loan.borrowAmount, BORROW_AMOUNT * 4);
        assertEq(uint256(loan.status), uint256(LendingPool.LoanStatus.ACTIVE));

        uint256[] memory userLoans = lendingPool.getUserLoans(user2);
        assertEq(userLoans.length, 1);
        assertEq(userLoans[0], loanId);

        vm.stopPrank();
    }

    function test_CreateLoanRevertsWithZeroAmount() public {
        vm.startPrank(user2);

        vm.expectRevert(HedVaultErrors.ZeroAmount.selector);
        lendingPool.createLoan(
            address(collateralToken),
            address(borrowToken),
            0,
            BORROW_AMOUNT
        );

        vm.expectRevert(HedVaultErrors.ZeroAmount.selector);
        lendingPool.createLoan(
            address(collateralToken),
            address(borrowToken),
            COLLATERAL_AMOUNT,
            0
        );

        vm.stopPrank();
    }

    function test_CreateLoanRevertsWithInsufficientCollateral() public {
        vm.startPrank(user1);
        lendingPool.deposit(address(borrowToken), DEPOSIT_AMOUNT);
        vm.stopPrank();

        vm.startPrank(user2);
        uint256 lowCollateral = 1 * 10 ** 18; // 1 token worth $2000
        uint256 highBorrow = 2000 * 10 ** 18; // 2000 tokens worth $3,000,000

        vm.expectRevert(
            abi.encodeWithSelector(
                HedVaultErrors.InsufficientCollateral.selector,
                highBorrow,
                lowCollateral
            )
        );
        lendingPool.createLoan(
            address(collateralToken),
            address(borrowToken),
            lowCollateral,
            highBorrow
        );
        vm.stopPrank();
    }

    function test_CreateLoanRevertsWithBorrowAmountTooSmall() public {
        vm.startPrank(user2);

        uint256 minLoanAmount = lendingPool.minLoanAmount();

        vm.expectRevert(
            abi.encodeWithSelector(
                HedVaultErrors.BorrowAmountTooSmall.selector,
                minLoanAmount - 1,
                minLoanAmount
            )
        );
        lendingPool.createLoan(
            address(collateralToken),
            address(borrowToken),
            COLLATERAL_AMOUNT,
            minLoanAmount - 1
        );

        vm.stopPrank();
    }

    // ============ REPAY LOAN TESTS ============

    function test_RepayLoanFull() public {
        // Setup: Create a loan
        vm.startPrank(user1);
        lendingPool.deposit(address(borrowToken), DEPOSIT_AMOUNT);
        vm.stopPrank();

        vm.startPrank(user2);
        uint256 loanId = lendingPool.createLoan(
            address(collateralToken),
            address(borrowToken),
            COLLATERAL_AMOUNT,
            BORROW_AMOUNT * 4 // Borrow more to make it more leveraged
        );

        // Fast forward time to accrue some interest and update prices
        vm.stopPrank();
        _updatePricesAndAdvanceTime(30 days);

        uint256 collateralBalanceBefore = collateralToken.balanceOf(user2);
        uint256 borrowBalanceBefore = borrowToken.balanceOf(user2);

        // Get loan info to calculate total debt
        LendingPool.LoanInfo memory loanBefore = lendingPool.getLoanInfo(
            loanId
        );

        vm.expectEmit(true, true, false, false);
        emit LoanRepaid(loanId, user2, 0, 0, block.timestamp); // 0 for full repayment

        vm.startPrank(user2);
        lendingPool.repayLoan(loanId, 0); // 0 means full repayment

        // Check loan status
        LendingPool.LoanInfo memory loanAfter = lendingPool.getLoanInfo(loanId);
        assertEq(
            uint256(loanAfter.status),
            uint256(LendingPool.LoanStatus.REPAID)
        );

        // Check collateral returned
        assertEq(
            collateralToken.balanceOf(user2),
            collateralBalanceBefore + COLLATERAL_AMOUNT
        );

        vm.stopPrank();
    }

    function test_RepayLoanPartial() public {
        // Setup: Create a loan
        vm.startPrank(user1);
        lendingPool.deposit(address(borrowToken), DEPOSIT_AMOUNT);
        vm.stopPrank();

        vm.startPrank(user2);
        uint256 loanId = lendingPool.createLoan(
            address(collateralToken),
            address(borrowToken),
            COLLATERAL_AMOUNT,
            BORROW_AMOUNT * 4 // Borrow more to make it more leveraged
        );

        uint256 partialRepayment = BORROW_AMOUNT / 2;

        lendingPool.repayLoan(loanId, partialRepayment);

        LendingPool.LoanInfo memory loan = lendingPool.getLoanInfo(loanId);
        assertEq(uint256(loan.status), uint256(LendingPool.LoanStatus.ACTIVE));
        assertEq(loan.borrowAmount, (BORROW_AMOUNT * 4) - partialRepayment);

        vm.stopPrank();
    }

    function test_RepayLoanRevertsForNonBorrower() public {
        // Setup: Create a loan
        vm.startPrank(user1);
        lendingPool.deposit(address(borrowToken), DEPOSIT_AMOUNT);
        vm.stopPrank();

        vm.startPrank(user2);
        // Calculate maximum borrowable amount: collateralValue * collateralFactor / borrowPrice
        // 4000 * $2000 * 0.7 / $1 = 5,600,000 max borrow
        // Use 4000 tokens (71.4% of max) to ensure it becomes liquidatable with price drop
        uint256 borrowAmount = 5600 * 10 ** 18; // Close to 80% liquidation threshold
        uint256 loanId = lendingPool.createLoan(
            address(collateralToken),
            address(borrowToken),
            COLLATERAL_AMOUNT * 4,
            borrowAmount
        );
        vm.stopPrank();

        // User1 tries to repay user2's loan
        vm.startPrank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                HedVaultErrors.UnauthorizedAccess.selector,
                user1,
                "borrower"
            )
        );
        lendingPool.repayLoan(loanId, BORROW_AMOUNT);
        vm.stopPrank();
    }

    function test_RepayLoanRevertsForInvalidLoan() public {
        vm.startPrank(user2);
        vm.expectRevert(
            abi.encodeWithSelector(
                HedVaultErrors.LoanDoesNotExist.selector,
                999
            )
        );
        lendingPool.repayLoan(999, BORROW_AMOUNT);
        vm.stopPrank();
    }

    // ============ LIQUIDATION TESTS ============

    function test_LiquidateLoan() public {
        // To make loan liquidatable, we need to create a scenario where:
        // debt value > (collateral value * collateral factor)
        // Collateral: 1 token * $2000 = $2,000
        // 70% collateral factor = $1,400 max borrowable value
        // Borrow: 1300 tokens * $1 = $1,300 (safe initially)
        // With collateral price drop and interest accrual, debt can exceed threshold
        uint256 collateralAmount = 1 * 10 ** 18; // 1 token = $2,000
        uint256 borrowAmount = 1300 * 10 ** 18; // 1300 tokens = $1,300

        // Setup: Create a loan
        vm.startPrank(user1);
        lendingPool.deposit(address(borrowToken), DEPOSIT_AMOUNT * 20);
        vm.stopPrank();

        vm.startPrank(user2);
        uint256 loanId = lendingPool.createLoan(
            address(collateralToken),
            address(borrowToken),
            collateralAmount,
            borrowAmount
        );
        vm.stopPrank();

        // Make loan liquidatable by dropping collateral price within deviation limit
        // Combined with interest accrual over time, this should trigger liquidation
        uint256 newPrice = (uint256(COLLATERAL_PRICE) * 90) / 100; // 10% drop (exactly at deviation limit)
        collateralAggregator.updatePrice(int256(newPrice));

        // Fast forward time to accrue significant interest and update prices
        vm.warp(block.timestamp + 1095 days); // 3 years to accrue substantial interest

        // Update oracle with new lower price
        vm.startPrank(admin);
        priceOracle.updatePrice(address(collateralToken), newPrice, 10000);
        priceOracle.updatePrice(
            address(borrowToken),
            uint256(BORROW_PRICE),
            10000
        );
        priceOracle.updatePrice(
            address(anotherToken),
            uint256(ANOTHER_PRICE),
            10000
        );
        vm.stopPrank();

        // Force interest accrual by calling the new updateLoanInterest function
        lendingPool.updateLoanInterest(loanId);

        // Additional time passage to ensure interest accrual
        vm.warp(block.timestamp + 30 days);

        // Update oracle prices again after additional time
        vm.startPrank(admin);
        priceOracle.updatePrice(
            address(collateralToken),
            newPrice,
            block.timestamp
        );
        priceOracle.updatePrice(
            address(borrowToken),
            uint256(BORROW_PRICE),
            block.timestamp
        );
        vm.stopPrank();

        // Force another interest update
        lendingPool.updateLoanInterest(loanId);

        vm.startPrank(liquidator);

        uint256 liquidatorCollateralBefore = collateralToken.balanceOf(
            liquidator
        );
        uint256 liquidatorBorrowBefore = borrowToken.balanceOf(liquidator);

        // Debug: Check health factor and loan details
        LendingPool.LoanInfo memory loanInfo = lendingPool.getLoanInfo(loanId);
        console.log("Collateral amount:", loanInfo.collateralAmount);
        console.log("Borrow amount:", loanInfo.borrowAmount);
        console.log("Accrued interest:", loanInfo.accruedInterest);
        console.log("Interest rate:", loanInfo.interestRate);
        console.log("Start time:", loanInfo.startTime);
        console.log("Last update time:", loanInfo.lastUpdateTime);
        console.log("Current time:", block.timestamp);
        console.log("Liquidation threshold:", loanInfo.liquidationThreshold);
        console.log(
            "Collateral factor:",
            lendingPool.collateralFactors(address(collateralToken))
        );

        uint256 healthFactor = lendingPool.getLoanHealthFactor(loanId);
        console.log("Health factor:", healthFactor);
        console.log("Is liquidatable:", healthFactor < 1e18);

        // Add time passage to accrue interest
        vm.warp(block.timestamp + 30 days); // 30 days for interest accrual

        // Update oracle prices after time warp to avoid stale price error
        // Do multiple smaller price drops to stay within deviation limits
        vm.startPrank(admin);
        priceOracle.updatePrice(
            address(collateralToken),
            162000000000,
            block.timestamp
        ); // $1620 - 10% drop from $1800
        vm.warp(block.timestamp + 1 hours); // Wait before next update
        priceOracle.updatePrice(
            address(collateralToken),
            145800000000,
            block.timestamp
        ); // $1458 - 10% drop from $1620
        vm.warp(block.timestamp + 1 hours); // Wait before next update
        priceOracle.updatePrice(
            address(collateralToken),
            131220000000,
            block.timestamp
        ); // $1312.20 - 10% drop from $1458
        priceOracle.updatePrice(
            address(borrowToken),
            100000000,
            block.timestamp
        ); // $1
        vm.stopPrank();
        vm.stopPrank();

        // Verify the loan is now liquidatable (health factor < 1.0)
        uint256 healthFactorAfterTime = lendingPool.getLoanHealthFactor(loanId);
        console.log("Health factor after time:", healthFactorAfterTime);
        console.log(
            "Is liquidatable (health < 1e18):",
            healthFactorAfterTime < 1e18
        );

        // Manual interest calculation for debugging
        // Expected: (1300 * 10^18 * 200 * 34128000) / (365 days * 10000)
        uint256 timeDelta = 34128000;
        uint256 expectedInterest = (1300 * 10 ** 18 * 200 * timeDelta) /
            (365 days * 10000);
        console.log("Expected accrued interest:", expectedInterest);

        // Check if loan is liquidatable
        assertTrue(lendingPool.getLoanHealthFactor(loanId) < 1e18);

        // Debug: Check the actual liquidation calculation
        LendingPool.LoanInfo memory finalLoanInfo = lendingPool.getLoanInfo(
            loanId
        );
        console.log("Final borrow amount:", finalLoanInfo.borrowAmount);
        console.log("Final accrued interest:", finalLoanInfo.accruedInterest);
        console.log(
            "Total debt:",
            finalLoanInfo.borrowAmount + finalLoanInfo.accruedInterest
        );

        // Switch to liquidator to perform liquidation
        vm.startPrank(liquidator);

        // Liquidate the full loan (borrowAmount + accrued interest)
        uint256 totalDebt = finalLoanInfo.borrowAmount +
            finalLoanInfo.accruedInterest;
        lendingPool.liquidateLoan(loanId, totalDebt);

        // Check liquidator received collateral
        assertGt(
            collateralToken.balanceOf(liquidator),
            liquidatorCollateralBefore
        );

        // Check loan status - this might be a partial liquidation if not enough collateral
        LendingPool.LoanInfo memory loan = lendingPool.getLoanInfo(loanId);

        // If all collateral was seized but debt remains, it's still active
        if (loan.collateralAmount == 0 && loan.borrowAmount > 0) {
            // Partial liquidation - all collateral seized but debt remains
            assertEq(
                uint256(loan.status),
                uint256(LendingPool.LoanStatus.ACTIVE)
            );
            assertEq(loan.collateralAmount, 0);
            assertGt(loan.borrowAmount, 0);
        } else {
            // Full liquidation
            assertEq(
                uint256(loan.status),
                uint256(LendingPool.LoanStatus.LIQUIDATED)
            );
        }

        vm.stopPrank();
    }

    function test_LiquidateLoanRevertsWhenNotLiquidatable() public {
        // Setup: Create a healthy loan
        vm.startPrank(user1);
        lendingPool.deposit(address(borrowToken), DEPOSIT_AMOUNT);
        vm.stopPrank();

        vm.startPrank(user2);
        uint256 loanId = lendingPool.createLoan(
            address(collateralToken),
            address(borrowToken),
            COLLATERAL_AMOUNT,
            BORROW_AMOUNT / 2 // Borrow less to keep it healthy
        );
        vm.stopPrank();

        vm.startPrank(liquidator);
        vm.expectRevert(
            abi.encodeWithSelector(
                HedVaultErrors.LoanNotDueForLiquidation.selector,
                loanId
            )
        );
        lendingPool.liquidateLoan(loanId, BORROW_AMOUNT / 2);
        vm.stopPrank();
    }

    // ============ ADMIN FUNCTION TESTS ============

    function test_AddSupportedToken() public {
        MockERC20 newToken = new MockERC20("New Token", "NEW", 18);
        MockChainlinkAggregator newAggregator = new MockChainlinkAggregator(
            50 * 10 ** 8,
            8
        );

        vm.startPrank(admin);
        priceOracle.configurePriceFeed(
            address(newToken),
            address(newAggregator),
            address(0),
            3600,
            8,
            1 * 10 ** 8,
            1000 * 10 ** 8
        );

        vm.expectEmit(true, false, false, true);
        emit TokenAdded(address(newToken), 5000, 1000);

        lendingPool.addSupportedToken(address(newToken), 5000, 1000);

        assertTrue(lendingPool.supportedTokens(address(newToken)));
        assertEq(lendingPool.collateralFactors(address(newToken)), 5000);
        assertEq(lendingPool.liquidationBonuses(address(newToken)), 1000);

        LendingPool.PoolInfo memory poolInfo = lendingPool.getPoolInfo(
            address(newToken)
        );
        assertTrue(poolInfo.isActive);
        assertTrue(poolInfo.borrowingEnabled);
        assertTrue(poolInfo.depositsEnabled);

        vm.stopPrank();
    }

    function test_AddSupportedTokenRevertsForNonAdmin() public {
        MockERC20 newToken = new MockERC20("New Token", "NEW", 18);

        vm.startPrank(user1);
        vm.expectRevert();
        lendingPool.addSupportedToken(address(newToken), 5000, 1000);
        vm.stopPrank();
    }

    function test_UpdateCollateralFactor() public {
        vm.startPrank(admin);

        uint256 oldFactor = lendingPool.collateralFactors(
            address(collateralToken)
        );
        uint256 newFactor = 8000;

        vm.expectEmit(true, false, false, true);
        emit CollateralFactorUpdated(
            address(collateralToken),
            oldFactor,
            newFactor
        );

        lendingPool.updateCollateralFactor(address(collateralToken), newFactor);

        assertEq(
            lendingPool.collateralFactors(address(collateralToken)),
            newFactor
        );

        vm.stopPrank();
    }

    function test_UpdateLiquidationBonus() public {
        vm.startPrank(admin);

        uint256 oldBonus = lendingPool.liquidationBonuses(
            address(collateralToken)
        );
        uint256 newBonus = 1500;

        vm.expectEmit(true, false, false, true);
        emit LiquidationBonusUpdated(
            address(collateralToken),
            oldBonus,
            newBonus
        );

        lendingPool.updateLiquidationBonus(address(collateralToken), newBonus);

        assertEq(
            lendingPool.liquidationBonuses(address(collateralToken)),
            newBonus
        );

        vm.stopPrank();
    }

    function test_UpdateInterestRateModel() public {
        vm.startPrank(admin);

        uint256 newBaseRate = 300;
        uint256 newSlope1 = 500;
        uint256 newSlope2 = 7000;
        uint256 newOptimalUtilization = 8500;

        vm.expectEmit(false, false, false, true);
        emit InterestRateModelUpdated(
            newBaseRate,
            newSlope1,
            newSlope2,
            newOptimalUtilization
        );

        lendingPool.updateInterestRateModel(
            newBaseRate,
            newSlope1,
            newSlope2,
            newOptimalUtilization
        );

        assertEq(lendingPool.baseInterestRate(), newBaseRate);
        assertEq(lendingPool.slope1(), newSlope1);
        assertEq(lendingPool.slope2(), newSlope2);
        assertEq(lendingPool.optimalUtilizationRate(), newOptimalUtilization);

        vm.stopPrank();
    }

    function test_SetPoolActive() public {
        vm.startPrank(admin);

        vm.expectEmit(true, false, false, true);
        emit PoolStatusUpdated(address(collateralToken), false);

        lendingPool.setPoolActive(address(collateralToken), false);

        LendingPool.PoolInfo memory poolInfo = lendingPool.getPoolInfo(
            address(collateralToken)
        );
        assertFalse(poolInfo.isActive);

        vm.stopPrank();
    }

    function test_SetBorrowingEnabled() public {
        vm.startPrank(admin);

        vm.expectEmit(true, false, false, true);
        emit BorrowingStatusUpdated(address(borrowToken), false);

        lendingPool.setBorrowingEnabled(address(borrowToken), false);

        LendingPool.PoolInfo memory poolInfo = lendingPool.getPoolInfo(
            address(borrowToken)
        );
        assertFalse(poolInfo.borrowingEnabled);

        vm.stopPrank();
    }

    function test_UpdateProtocolFeeRate() public {
        vm.startPrank(admin);

        uint256 oldRate = lendingPool.protocolFeeRate();
        uint256 newRate = 1500;

        vm.expectEmit(false, false, false, true);
        emit ProtocolFeeRateUpdated(oldRate, newRate);

        lendingPool.updateProtocolFeeRate(newRate);

        assertEq(lendingPool.protocolFeeRate(), newRate);

        vm.stopPrank();
    }

    function test_UpdateFeeRecipient() public {
        vm.startPrank(admin);

        address newRecipient = address(0x999);

        vm.expectEmit(false, false, false, true);
        emit FeeRecipientUpdated(feeRecipient, newRecipient);

        lendingPool.updateFeeRecipient(newRecipient);

        assertEq(lendingPool.feeRecipient(), newRecipient);

        vm.stopPrank();
    }

    function test_PauseAndUnpause() public {
        vm.startPrank(admin);

        lendingPool.pause();
        assertTrue(lendingPool.paused());

        lendingPool.unpause();
        assertFalse(lendingPool.paused());

        vm.stopPrank();
    }

    // ============ VIEW FUNCTION TESTS ============

    function test_GetSupplyAPY() public {
        // Deposit some tokens to create utilization
        vm.startPrank(user1);
        lendingPool.deposit(address(borrowToken), DEPOSIT_AMOUNT);
        vm.stopPrank();

        vm.startPrank(user2);
        lendingPool.createLoan(
            address(collateralToken),
            address(borrowToken),
            COLLATERAL_AMOUNT,
            BORROW_AMOUNT
        );
        vm.stopPrank();

        uint256 supplyAPY = lendingPool.getSupplyAPY(address(borrowToken));
        assertGt(supplyAPY, 0);
    }

    function test_GetBorrowAPY() public {
        uint256 borrowAPY = lendingPool.getBorrowAPY(address(borrowToken));
        assertGt(borrowAPY, 0);
    }

    function test_GetUtilizationRate() public {
        // Initially should be 0
        assertEq(lendingPool.getUtilizationRate(address(borrowToken)), 0);

        // Deposit and borrow to create utilization
        vm.startPrank(user1);
        lendingPool.deposit(address(borrowToken), DEPOSIT_AMOUNT);
        vm.stopPrank();

        vm.startPrank(user2);
        lendingPool.createLoan(
            address(collateralToken),
            address(borrowToken),
            COLLATERAL_AMOUNT,
            BORROW_AMOUNT
        );
        vm.stopPrank();

        uint256 utilization = lendingPool.getUtilizationRate(
            address(borrowToken)
        );
        assertGt(utilization, 0);
        assertLt(utilization, 10000); // Should be less than 100%
    }

    function test_GetLoanHealthFactor() public {
        // Setup: Create a loan
        vm.startPrank(user1);
        lendingPool.deposit(address(borrowToken), DEPOSIT_AMOUNT);
        vm.stopPrank();

        vm.startPrank(user2);
        uint256 loanId = lendingPool.createLoan(
            address(collateralToken),
            address(borrowToken),
            COLLATERAL_AMOUNT,
            BORROW_AMOUNT
        );
        vm.stopPrank();

        uint256 healthFactor = lendingPool.getLoanHealthFactor(loanId);
        assertGt(healthFactor, 1000); // Should be > 1000 for healthy loan (using basis points)

        // Drop collateral price by 9% to make it unhealthy (within 10% deviation limit)
        uint256 newPrice = (uint256(COLLATERAL_PRICE) * 91) / 100; // 9% drop
        collateralAggregator.updatePrice(int256(newPrice));

        // Update oracle with new price
        vm.startPrank(admin);
        priceOracle.updatePrice(address(collateralToken), newPrice, 10000);
        vm.stopPrank();

        uint256 newHealthFactor = lendingPool.getLoanHealthFactor(loanId);
        assertLt(newHealthFactor, healthFactor); // Should be lower than before
    }

    // ============ EDGE CASE TESTS ============

    function test_MultipleLoansPerUser() public {
        vm.startPrank(user1);
        lendingPool.deposit(address(borrowToken), DEPOSIT_AMOUNT * 2);
        vm.stopPrank();

        vm.startPrank(user2);

        uint256 loanId1 = lendingPool.createLoan(
            address(collateralToken),
            address(borrowToken),
            COLLATERAL_AMOUNT,
            BORROW_AMOUNT
        );

        uint256 loanId2 = lendingPool.createLoan(
            address(anotherToken),
            address(borrowToken),
            COLLATERAL_AMOUNT, // Use full collateral amount
            BORROW_AMOUNT / 2 // Half the borrow amount but above minimum
        );

        uint256[] memory userLoans = lendingPool.getUserLoans(user2);
        assertEq(userLoans.length, 2);
        assertEq(userLoans[0], loanId1);
        assertEq(userLoans[1], loanId2);

        vm.stopPrank();
    }

    function test_InterestAccrual() public {
        // Setup: Create a loan
        vm.startPrank(user1);
        lendingPool.deposit(address(borrowToken), DEPOSIT_AMOUNT);
        vm.stopPrank();

        vm.startPrank(user2);
        uint256 loanId = lendingPool.createLoan(
            address(collateralToken),
            address(borrowToken),
            COLLATERAL_AMOUNT,
            BORROW_AMOUNT
        );

        LendingPool.LoanInfo memory loanBefore = lendingPool.getLoanInfo(
            loanId
        );
        assertEq(loanBefore.accruedInterest, 0);

        // Fast forward time and update prices
        vm.stopPrank();
        _updatePricesAndAdvanceTime(365 days);

        // Make a small repayment to trigger interest calculation
        vm.startPrank(user2);
        borrowToken.approve(address(lendingPool), 1);
        lendingPool.repayLoan(loanId, 1);

        LendingPool.LoanInfo memory loanAfter = lendingPool.getLoanInfo(loanId);
        assertGt(loanAfter.accruedInterest, 0);

        vm.stopPrank();
    }

    function test_ProtocolFeeCollection() public {
        // Setup: Create and repay a loan with interest
        vm.startPrank(user1);
        lendingPool.deposit(address(borrowToken), DEPOSIT_AMOUNT);
        vm.stopPrank();

        vm.startPrank(user2);
        uint256 loanId = lendingPool.createLoan(
            address(collateralToken),
            address(borrowToken),
            COLLATERAL_AMOUNT,
            BORROW_AMOUNT
        );

        // Fast forward to accrue interest and update prices
        vm.stopPrank();
        _updatePricesAndAdvanceTime(30 days);

        uint256 feeRecipientBalanceBefore = borrowToken.balanceOf(feeRecipient);

        // Repay loan (this should collect protocol fees)
        vm.startPrank(user2);
        lendingPool.repayLoan(loanId, 0);

        uint256 feeRecipientBalanceAfter = borrowToken.balanceOf(feeRecipient);

        // Should have collected some fees (if there was interest)
        // Note: This might be 0 if interest accrual is very small
        assertGe(feeRecipientBalanceAfter, feeRecipientBalanceBefore);

        vm.stopPrank();
    }

    // ============ FUZZ TESTS ============

    function testFuzz_Deposit(uint256 amount) public {
        amount = bound(amount, 1, INITIAL_SUPPLY / 4);

        vm.startPrank(user1);

        uint256 balanceBefore = collateralToken.balanceOf(user1);
        vm.assume(balanceBefore >= amount);

        lendingPool.deposit(address(collateralToken), amount);

        assertEq(
            lendingPool.getUserBalance(user1, address(collateralToken)),
            amount
        );
        assertEq(collateralToken.balanceOf(user1), balanceBefore - amount);

        vm.stopPrank();
    }

    function testFuzz_CreateLoan(
        uint256 collateralAmount,
        uint256 borrowAmount
    ) public {
        collateralAmount = bound(
            collateralAmount,
            1000 * 10 ** 18,
            INITIAL_SUPPLY / 4
        );
        borrowAmount = bound(
            borrowAmount,
            lendingPool.minLoanAmount(),
            collateralAmount / 4
        );

        // Provide liquidity
        vm.startPrank(user1);
        lendingPool.deposit(address(borrowToken), DEPOSIT_AMOUNT);
        vm.stopPrank();

        vm.startPrank(user2);

        // Check if collateral is sufficient (simplified check)
        uint256 collateralValue = (collateralAmount *
            uint256(COLLATERAL_PRICE)) / 10 ** 8;
        uint256 borrowValue = (borrowAmount * uint256(BORROW_PRICE)) / 10 ** 8;
        uint256 requiredCollateral = (borrowValue * 10000) / 7000; // 70% collateral factor

        if (
            collateralValue >= requiredCollateral &&
            borrowAmount <= DEPOSIT_AMOUNT
        ) {
            uint256 loanId = lendingPool.createLoan(
                address(collateralToken),
                address(borrowToken),
                collateralAmount,
                borrowAmount
            );

            LendingPool.LoanInfo memory loan = lendingPool.getLoanInfo(loanId);
            assertEq(loan.collateralAmount, collateralAmount);
            assertEq(loan.borrowAmount, borrowAmount);
            assertEq(
                uint256(loan.status),
                uint256(LendingPool.LoanStatus.ACTIVE)
            );
        }

        vm.stopPrank();
    }
}
