// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IHedVaultCore.sol";
import "./PriceOracle.sol";
import "./RewardsDistributor.sol";
import "./libraries/DataTypes.sol";
import "./libraries/Events.sol";
import "./libraries/HedVaultErrors.sol";
import "forge-std/console.sol";

/**
 * @title LendingPool
 * @notice Main lending and borrowing contract for the HedVault protocol
 * @dev Supports collateralized lending with dynamic interest rates and liquidations
 */
contract LendingPool is AccessControl, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    // Roles
    bytes32 public constant LENDING_ADMIN_ROLE =
        keccak256("LENDING_ADMIN_ROLE");
    bytes32 public constant LIQUIDATOR_ROLE = keccak256("LIQUIDATOR_ROLE");
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");
    bytes32 public constant RATE_MANAGER_ROLE = keccak256("RATE_MANAGER_ROLE");
    bytes32 public constant POOL_ADMIN_ROLE = keccak256("POOL_ADMIN_ROLE");

    // Core protocol references
    IHedVaultCore public immutable hedVaultCore;
    PriceOracle public immutable priceOracle;
    RewardsDistributor private rewardsDistributor;

    // Loan status enumeration
    enum LoanStatus {
        ACTIVE,
        REPAID,
        LIQUIDATED,
        DEFAULTED
    }

    // Loan information structure
    struct LoanInfo {
        uint256 loanId;
        address borrower;
        address collateralToken;
        address borrowToken;
        uint256 collateralAmount;
        uint256 borrowAmount;
        uint256 interestRate; // Annual rate in basis points
        uint256 startTime;
        uint256 lastUpdateTime;
        uint256 accruedInterest;
        LoanStatus status;
        uint256 liquidationThreshold; // In basis points (e.g., 8000 = 80%)
    }

    // Pool information for each token
    struct PoolInfo {
        uint256 totalDeposits;
        uint256 totalBorrows;
        uint256 totalReserves;
        uint256 lastUpdateTime;
        bool isActive;
        bool borrowingEnabled;
        bool depositsEnabled;
    }

    // State variables
    mapping(uint256 => LoanInfo) public loans;
    mapping(address => PoolInfo) public pools;
    mapping(address => mapping(address => uint256)) public userBalances; // user => token => balance
    mapping(address => uint256[]) public userLoans; // user => loan IDs
    mapping(address => bool) public supportedTokens;
    mapping(address => uint256) public collateralFactors; // token => factor in basis points
    mapping(address => uint256) public liquidationBonuses; // token => bonus in basis points

    uint256 public nextLoanId = 1;
    uint256 public totalLoansCreated;
    uint256 public totalLoansRepaid;
    uint256 public totalLiquidations;

    // Protocol parameters
    uint256 public constant MAX_COLLATERAL_FACTOR = 9000; // 90%
    uint256 public constant MIN_COLLATERAL_FACTOR = 1000; // 10%
    uint256 public constant MAX_LIQUIDATION_BONUS = 2000; // 20%
    uint256 public constant LIQUIDATION_THRESHOLD = 8000; // 80%
    uint256 public constant INTEREST_RATE_PRECISION = 10000; // 100%
    uint256 public constant SECONDS_PER_YEAR = 365 days;

    // Fee structure
    uint256 public protocolFeeRate = 1000; // 10% of interest
    uint256 public liquidationFeeRate = 500; // 5%
    address public feeRecipient;

    // Risk management
    uint256 public maxLoanDuration = 365 days;
    uint256 public minLoanAmount = 100e18; // 100 tokens minimum
    uint256 public maxUtilizationRate = 9000; // 90%

    // Interest rate model parameters
    uint256 public baseInterestRate = 200; // 2% base rate
    uint256 public slope1 = 400; // 4% slope below optimal
    uint256 public slope2 = 6000; // 60% slope above optimal
    uint256 public optimalUtilizationRate = 8000; // 80% optimal utilization
    uint256 public reserveFactor = 1000; // 10% reserve factor

    // Protocol constants
    uint256 public constant MAX_PROTOCOL_FEE_RATE = 2000; // 20%

    // Events
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

    event InterestRateUpdated(
        address indexed token,
        uint256 oldRate,
        uint256 newRate,
        uint256 timestamp
    );

    event PoolParametersUpdated(
        address indexed token,
        uint256 collateralFactor,
        uint256 liquidationBonus,
        bool borrowingEnabled,
        bool depositsEnabled
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

    event ReservesWithdrawn(
        address indexed token,
        uint256 amount,
        address indexed recipient
    );

    // Modifiers
    modifier validToken(address token) {
        if (!supportedTokens[token]) {
            revert HedVaultErrors.TokenNotListed(token);
        }
        _;
    }

    modifier validLoan(uint256 loanId) {
        if (loanId == 0 || loanId >= nextLoanId) {
            revert HedVaultErrors.LoanDoesNotExist(loanId);
        }
        _;
    }

    modifier onlyBorrower(uint256 loanId) {
        if (loans[loanId].borrower != msg.sender) {
            revert HedVaultErrors.UnauthorizedAccess(msg.sender, "borrower");
        }
        _;
    }

    modifier poolActive(address token) {
        if (!pools[token].isActive) {
            revert HedVaultErrors.TokenNotActive(token);
        }
        _;
    }

    constructor(
        address _hedVaultCore,
        address _priceOracle,
        address _feeRecipient,
        address _rewardsDistributor
    ) {
        if (
            _hedVaultCore == address(0) ||
            _priceOracle == address(0) ||
            _feeRecipient == address(0)
        ) {
            revert HedVaultErrors.ZeroAddress();
        }

        hedVaultCore = IHedVaultCore(_hedVaultCore);
        priceOracle = PriceOracle(_priceOracle);
        feeRecipient = _feeRecipient;

        // Initialize rewards distributor
        _initializeRewards(_rewardsDistributor);

        // Set up roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(LENDING_ADMIN_ROLE, msg.sender);
        _grantRole(LIQUIDATOR_ROLE, msg.sender);
        _grantRole(EMERGENCY_ROLE, msg.sender);
        _grantRole(RATE_MANAGER_ROLE, msg.sender);
    }

    /**
     * @notice Initialize rewards distributor connection
     * @dev Sets RewardsDistributor address directly
     * @param _rewardsDistributor Address of the rewards distributor contract
     */
    function _initializeRewards(address _rewardsDistributor) internal {
        if (_rewardsDistributor != address(0)) {
            rewardsDistributor = RewardsDistributor(_rewardsDistributor);
        }
    }

    /**
     * @notice Distribute activity rewards to user
     * @dev Safely calls RewardsDistributor without reverting main transaction
     * @param user User to receive rewards
     * @param activityType Type of activity ("lending")
     * @param amount Amount of activity for reward calculation
     */
    function _distributeReward(
        address user,
        string memory activityType,
        uint256 amount
    ) internal {
        if (address(rewardsDistributor) != address(0)) {
            try
                rewardsDistributor.distributeActivityReward(
                    user,
                    activityType,
                    amount
                )
            {
                // Reward distributed successfully
            } catch {
                // Silently fail to not block main transaction
                // Could emit an event here for monitoring
            }
        }
    }

    /**
     * @notice Deposit tokens to earn interest
     * @param token Token to deposit
     * @param amount Amount to deposit
     */
    function deposit(
        address token,
        uint256 amount
    ) external nonReentrant whenNotPaused validToken(token) poolActive(token) {
        if (amount == 0) revert HedVaultErrors.ZeroAmount();
        if (!pools[token].depositsEnabled) {
            revert HedVaultErrors.OperationNotAllowed("deposits disabled");
        }

        // Update pool state
        _updatePoolState(token);

        // Transfer tokens from user
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        // Update user balance
        userBalances[msg.sender][token] += amount;

        // Update pool totals
        pools[token].totalDeposits += amount;

        // Distribute lending rewards (0.5% of deposit amount)
        _distributeReward(msg.sender, "lending", amount);

        emit Deposit(msg.sender, token, amount, block.timestamp);
        emit Events.CollateralDeposited(msg.sender, token, amount);
    }

    /**
     * @notice Withdraw deposited tokens plus interest
     * @param token Token to withdraw
     * @param amount Amount to withdraw (0 for max)
     */
    function withdraw(
        address token,
        uint256 amount
    ) external nonReentrant whenNotPaused validToken(token) {
        // Update pool state
        _updatePoolState(token);

        uint256 userBalance = userBalances[msg.sender][token];
        if (userBalance == 0) {
            revert HedVaultErrors.InsufficientBalance(token, amount, 0);
        }

        if (amount == 0) {
            amount = userBalance;
        }

        if (amount > userBalance) {
            revert HedVaultErrors.InsufficientBalance(
                token,
                amount,
                userBalance
            );
        }

        // Check if withdrawal would exceed available liquidity
        uint256 availableLiquidity = pools[token].totalDeposits -
            pools[token].totalBorrows;
        if (amount > availableLiquidity) {
            revert HedVaultErrors.InsufficientLiquidity(token, address(0));
        }

        // Update user balance
        userBalances[msg.sender][token] -= amount;

        // Update pool totals
        pools[token].totalDeposits -= amount;

        // Transfer tokens to user
        IERC20(token).safeTransfer(msg.sender, amount);

        emit Withdraw(msg.sender, token, amount, block.timestamp);
        emit Events.CollateralWithdrawn(msg.sender, token, amount);
    }

    /**
     * @notice Create a collateralized loan
     * @param collateralToken Token to use as collateral
     * @param borrowToken Token to borrow
     * @param collateralAmount Amount of collateral
     * @param borrowAmount Amount to borrow
     * @return loanId New loan ID
     */
    function createLoan(
        address collateralToken,
        address borrowToken,
        uint256 collateralAmount,
        uint256 borrowAmount
    )
        external
        nonReentrant
        whenNotPaused
        validToken(collateralToken)
        validToken(borrowToken)
        poolActive(collateralToken)
        poolActive(borrowToken)
        returns (uint256 loanId)
    {
        if (collateralAmount == 0 || borrowAmount == 0) {
            revert HedVaultErrors.ZeroAmount();
        }
        if (borrowAmount < minLoanAmount) {
            revert HedVaultErrors.BorrowAmountTooSmall(
                borrowAmount,
                minLoanAmount
            );
        }
        if (!pools[borrowToken].borrowingEnabled) {
            revert HedVaultErrors.OperationNotAllowed("borrowing disabled");
        }

        // Update pool states
        _updatePoolState(collateralToken);
        _updatePoolState(borrowToken);

        // Check collateral ratio
        if (
            !_isValidCollateralRatio(
                collateralToken,
                borrowToken,
                collateralAmount,
                borrowAmount
            )
        ) {
            revert HedVaultErrors.InsufficientCollateral(
                borrowAmount,
                collateralAmount
            );
        }

        // Check pool utilization
        uint256 newUtilization = _calculateUtilizationAfterBorrow(
            borrowToken,
            borrowAmount
        );
        if (newUtilization > maxUtilizationRate) {
            revert HedVaultErrors.InsufficientLiquidity(
                borrowToken,
                address(0)
            );
        }

        // Transfer collateral from borrower
        IERC20(collateralToken).safeTransferFrom(
            msg.sender,
            address(this),
            collateralAmount
        );

        // Create loan
        loanId = nextLoanId++;
        loans[loanId] = LoanInfo({
            loanId: loanId,
            borrower: msg.sender,
            collateralToken: collateralToken,
            borrowToken: borrowToken,
            collateralAmount: collateralAmount,
            borrowAmount: borrowAmount,
            interestRate: _calculateInterestRate(borrowToken),
            startTime: block.timestamp,
            lastUpdateTime: block.timestamp,
            accruedInterest: 0,
            status: LoanStatus.ACTIVE,
            liquidationThreshold: LIQUIDATION_THRESHOLD
        });

        // Update user loans
        userLoans[msg.sender].push(loanId);

        // Update pool state
        pools[borrowToken].totalBorrows += borrowAmount;
        totalLoansCreated++;

        // Transfer borrowed tokens to user
        IERC20(borrowToken).safeTransfer(msg.sender, borrowAmount);

        // Distribute lending rewards for borrowing activity (0.5% of borrow amount)
        _distributeReward(msg.sender, "lending", borrowAmount);

        emit LoanCreated(
            loanId,
            msg.sender,
            collateralToken,
            borrowToken,
            collateralAmount,
            borrowAmount,
            loans[loanId].interestRate
        );
    }

    /**
     * @notice Repay a loan partially or fully
     * @param loanId Loan ID to repay
     * @param amount Amount to repay (0 for full repayment)
     */
    function repayLoan(
        uint256 loanId,
        uint256 amount
    )
        external
        nonReentrant
        whenNotPaused
        validLoan(loanId)
        onlyBorrower(loanId)
    {
        LoanInfo storage loan = loans[loanId];
        if (loan.status != LoanStatus.ACTIVE) {
            revert HedVaultErrors.LoanAlreadyRepaid(loanId);
        }

        // Update loan interest
        _updateLoanInterest(loanId);

        uint256 totalDebt = loan.borrowAmount + loan.accruedInterest;

        if (amount == 0) {
            amount = totalDebt;
        }

        if (amount > totalDebt) {
            revert HedVaultErrors.RepaymentAmountExceedsDebt(amount, totalDebt);
        }

        // Calculate protocol fee
        uint256 interestPortion = amount > loan.borrowAmount
            ? amount - loan.borrowAmount
            : 0;
        uint256 protocolFee = (interestPortion * protocolFeeRate) /
            INTEREST_RATE_PRECISION;

        // Transfer repayment from borrower
        IERC20(loan.borrowToken).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        // Transfer protocol fee
        if (protocolFee > 0) {
            IERC20(loan.borrowToken).safeTransfer(feeRecipient, protocolFee);
        }

        // Update loan state
        if (amount >= totalDebt) {
            // Full repayment
            loan.status = LoanStatus.REPAID;
            totalLoansRepaid++;

            // Return collateral
            IERC20(loan.collateralToken).safeTransfer(
                msg.sender,
                loan.collateralAmount
            );
        } else {
            // Partial repayment
            if (amount <= loan.accruedInterest) {
                loan.accruedInterest -= amount;
            } else {
                uint256 principalPayment = amount - loan.accruedInterest;
                loan.accruedInterest = 0;
                loan.borrowAmount -= principalPayment;
            }
        }

        // Update pool state - calculate actual principal repaid
        uint256 principalRepaid;
        if (amount >= totalDebt) {
            // Full repayment - principal repaid is the original borrowAmount
            principalRepaid = loan.borrowAmount;
        } else {
            // Partial repayment - calculate how much went to principal
            if (amount <= loan.accruedInterest) {
                principalRepaid = 0; // Only interest was paid
            } else {
                principalRepaid = amount - loan.accruedInterest; // Amount that went to principal
            }
        }
        pools[loan.borrowToken].totalBorrows -= principalRepaid;

        emit LoanRepaid(
            loanId,
            msg.sender,
            amount,
            interestPortion,
            block.timestamp
        );
        emit Events.LoanRepaid(loanId, msg.sender, amount, block.timestamp);
    }

    /**
     * @notice Liquidate an undercollateralized loan
     * @param loanId Loan ID to liquidate
     * @param repayAmount Amount of debt to cover
     */
    function liquidateLoan(
        uint256 loanId,
        uint256 repayAmount
    ) external nonReentrant whenNotPaused validLoan(loanId) {
        LoanInfo storage loan = loans[loanId];
        if (loan.status != LoanStatus.ACTIVE) {
            revert HedVaultErrors.LoanAlreadyLiquidated(loanId);
        }

        // Update loan interest
        _updateLoanInterest(loanId);

        // Check if loan is eligible for liquidation
        if (!_isLoanLiquidatable(loanId)) {
            revert HedVaultErrors.LoanNotDueForLiquidation(loanId);
        }

        uint256 totalDebt = loan.borrowAmount + loan.accruedInterest;
        if (repayAmount > totalDebt) {
            repayAmount = totalDebt;
        }

        // Calculate collateral to seize
        uint256 collateralToSeize = _calculateCollateralToSeize(
            loan.collateralToken,
            loan.borrowToken,
            repayAmount
        );

        // Calculate liquidation bonus on the base collateral amount
        uint256 liquidationBonus = (collateralToSeize *
            liquidationBonuses[loan.collateralToken]) / INTEREST_RATE_PRECISION;
        uint256 totalCollateralSeized = collateralToSeize + liquidationBonus;

        // Cap total collateral seized to available collateral
        if (totalCollateralSeized > loan.collateralAmount) {
            totalCollateralSeized = loan.collateralAmount;
            // Recalculate components proportionally
            collateralToSeize =
                (totalCollateralSeized * INTEREST_RATE_PRECISION) /
                (INTEREST_RATE_PRECISION +
                    liquidationBonuses[loan.collateralToken]);
            liquidationBonus = totalCollateralSeized - collateralToSeize;
        }

        // Transfer repayment from liquidator
        IERC20(loan.borrowToken).safeTransferFrom(
            msg.sender,
            address(this),
            repayAmount
        );

        // Transfer collateral to liquidator
        IERC20(loan.collateralToken).safeTransfer(
            msg.sender,
            totalCollateralSeized
        );

        // Calculate liquidation fee
        uint256 liquidationFee = (repayAmount * liquidationFeeRate) /
            INTEREST_RATE_PRECISION;
        if (liquidationFee > 0) {
            IERC20(loan.borrowToken).safeTransfer(feeRecipient, liquidationFee);
        }

        // Calculate principal repaid before updating loan state
        uint256 principalRepaid = repayAmount > loan.accruedInterest
            ? repayAmount - loan.accruedInterest
            : 0;

        // Update loan state
        if (repayAmount >= totalDebt) {
            loan.status = LoanStatus.LIQUIDATED;
            totalLiquidations++;

            // Return remaining collateral to borrower if any
            uint256 remainingCollateral = loan.collateralAmount -
                totalCollateralSeized;
            if (remainingCollateral > 0) {
                IERC20(loan.collateralToken).safeTransfer(
                    loan.borrower,
                    remainingCollateral
                );
            }
        } else {
            // Partial liquidation
            // Calculate how much of the repayAmount goes to principal vs interest
            uint256 interestPortion = loan.accruedInterest;
            uint256 principalPortion = repayAmount > interestPortion
                ? repayAmount - interestPortion
                : 0;

            // Update loan amounts
            if (repayAmount >= interestPortion) {
                loan.accruedInterest = 0;
                loan.borrowAmount -= principalPortion;
            } else {
                loan.accruedInterest -= repayAmount;
            }
            loan.collateralAmount -= totalCollateralSeized;
        }

        // Update pool state - only subtract principal portion from totalBorrows
        pools[loan.borrowToken].totalBorrows -= principalRepaid;

        emit LoanLiquidated(
            loanId,
            loan.borrower,
            msg.sender,
            totalCollateralSeized,
            repayAmount,
            liquidationBonus
        );

        emit Events.LoanLiquidated(
            loanId,
            loan.borrower,
            msg.sender,
            totalCollateralSeized,
            repayAmount
        );
    }

    // ============ INTERNAL FUNCTIONS ============

    /**
     * @notice Update pool state with latest interest
     */
    function _updatePoolState(address token) internal {
        PoolInfo storage pool = pools[token];
        if (pool.lastUpdateTime == block.timestamp) return;

        uint256 timeDelta = block.timestamp - pool.lastUpdateTime;
        if (timeDelta > 0 && pool.totalBorrows > 0) {
            uint256 borrowRate = _calculateBorrowRate(token);
            uint256 interestAccrued = (pool.totalBorrows *
                borrowRate *
                timeDelta) / (365 days * INTEREST_RATE_PRECISION);

            pool.totalBorrows += interestAccrued;
            pool.totalReserves +=
                (interestAccrued * reserveFactor) /
                INTEREST_RATE_PRECISION;
        }

        pool.lastUpdateTime = block.timestamp;
    }

    /**
     * @notice Calculate current borrow rate for a token
     */
    function _calculateBorrowRate(
        address token
    ) internal view returns (uint256) {
        PoolInfo storage pool = pools[token];
        if (pool.totalDeposits == 0) return baseInterestRate;

        uint256 utilization = (pool.totalBorrows * INTEREST_RATE_PRECISION) /
            pool.totalDeposits;

        if (utilization <= optimalUtilizationRate) {
            return
                baseInterestRate +
                (utilization * slope1) /
                INTEREST_RATE_PRECISION;
        } else {
            uint256 excessUtilization = utilization - optimalUtilizationRate;
            return
                baseInterestRate +
                (optimalUtilizationRate * slope1) /
                INTEREST_RATE_PRECISION +
                (excessUtilization * slope2) /
                INTEREST_RATE_PRECISION;
        }
    }

    /**
     * @notice Calculate interest rate for a new loan
     */
    function _calculateInterestRate(
        address token
    ) internal view returns (uint256) {
        return _calculateBorrowRate(token);
    }

    /**
     * @notice Check if collateral ratio is valid
     */
    function _isValidCollateralRatio(
        address collateralToken,
        address borrowToken,
        uint256 collateralAmount,
        uint256 borrowAmount
    ) internal view returns (bool) {
        uint256 collateralValue = _getTokenValue(
            collateralToken,
            collateralAmount
        );
        uint256 borrowValue = _getTokenValue(borrowToken, borrowAmount);
        uint256 requiredCollateral = (borrowValue * INTEREST_RATE_PRECISION) /
            collateralFactors[collateralToken];

        return collateralValue >= requiredCollateral;
    }

    /**
     * @notice Calculate utilization after a borrow
     */
    function _calculateUtilizationAfterBorrow(
        address token,
        uint256 borrowAmount
    ) internal view returns (uint256) {
        PoolInfo storage pool = pools[token];
        uint256 newTotalBorrows = pool.totalBorrows + borrowAmount;

        if (pool.totalDeposits == 0) return INTEREST_RATE_PRECISION;
        return (newTotalBorrows * INTEREST_RATE_PRECISION) / pool.totalDeposits;
    }

    /**
     * @notice Update loan interest
     */
    function _updateLoanInterest(uint256 loanId) internal {
        LoanInfo storage loan = loans[loanId];
        if (loan.lastUpdateTime == block.timestamp) return;

        uint256 timeDelta = block.timestamp - loan.lastUpdateTime;
        if (timeDelta > 0) {
            uint256 interestAccrued = (loan.borrowAmount *
                loan.interestRate *
                timeDelta) / (365 days * INTEREST_RATE_PRECISION);
            loan.accruedInterest += interestAccrued;
            loan.lastUpdateTime = block.timestamp;
        }
    }

    /**
     * @notice Check if loan is liquidatable
     */
    function _isLoanLiquidatable(uint256 loanId) internal returns (bool) {
        // Update loan interest first to ensure we have the latest debt amount
        _updateLoanInterest(loanId);

        LoanInfo storage loan = loans[loanId];
        uint256 collateralValue = _getTokenValue(
            loan.collateralToken,
            loan.collateralAmount
        );
        uint256 debtValue = _getTokenValue(
            loan.borrowToken,
            loan.borrowAmount + loan.accruedInterest
        );

        // A loan is liquidatable when health factor < 1.0
        // Health factor = (collateralValue * liquidationThreshold) / (debtValue * INTEREST_RATE_PRECISION)
        // Liquidatable when: (collateralValue * liquidationThreshold) < (debtValue * INTEREST_RATE_PRECISION)
        uint256 liquidationThreshold = collateralFactors[loan.collateralToken];
        uint256 adjustedCollateralValue = (collateralValue *
            liquidationThreshold) / INTEREST_RATE_PRECISION;
        uint256 adjustedDebtValue = debtValue;

        return adjustedDebtValue > adjustedCollateralValue;
    }

    /**
     * @notice Calculate collateral to seize during liquidation
     */
    function _calculateCollateralToSeize(
        address collateralToken,
        address borrowToken,
        uint256 repayAmount
    ) internal view returns (uint256) {
        uint256 repayValue = _getTokenValue(borrowToken, repayAmount);
        return _getTokenAmount(collateralToken, repayValue);
    }

    /**
     * @notice Get token value in USD
     */
    function _getTokenValue(
        address token,
        uint256 amount
    ) internal view returns (uint256) {
        (uint256 price, , ) = priceOracle.getPrice(token);
        uint8 decimals = IERC20Metadata(token).decimals();
        // Oracle prices are in 8 decimals, so we need to scale properly
        // Result should be in 18 decimals for consistency
        return (amount * price * 10 ** 10) / (10 ** decimals);
    }

    /**
     * @notice Get token amount from USD value
     */
    function _getTokenAmount(
        address token,
        uint256 value
    ) internal view returns (uint256) {
        (uint256 price, , ) = priceOracle.getPrice(token);
        uint8 decimals = IERC20Metadata(token).decimals();
        // Oracle prices are in 8 decimals, value is in 18 decimals
        // So we need to adjust the calculation accordingly
        return (value * (10 ** decimals)) / (price * 10 ** 10);
    }

    // ============ VIEW FUNCTIONS ============

    /**
     * @notice Get pool information
     */
    function getPoolInfo(
        address token
    ) external view returns (PoolInfo memory) {
        return pools[token];
    }

    /**
     * @notice Get loan information
     */
    function getLoanInfo(
        uint256 loanId
    ) external view returns (LoanInfo memory) {
        return loans[loanId];
    }

    /**
     * @notice Get user loans
     */
    function getUserLoans(
        address user
    ) external view returns (uint256[] memory) {
        return userLoans[user];
    }

    /**
     * @notice Get user balance in a pool
     */
    function getUserBalance(
        address user,
        address token
    ) external view returns (uint256) {
        return userBalances[user][token];
    }

    /**
     * @notice Calculate current supply APY
     */
    function getSupplyAPY(address token) external view returns (uint256) {
        PoolInfo storage pool = pools[token];
        if (pool.totalDeposits == 0) return 0;

        uint256 borrowRate = _calculateBorrowRate(token);
        uint256 utilization = (pool.totalBorrows * INTEREST_RATE_PRECISION) /
            pool.totalDeposits;
        uint256 supplyRate = (borrowRate *
            utilization *
            (INTEREST_RATE_PRECISION - reserveFactor)) /
            (INTEREST_RATE_PRECISION * INTEREST_RATE_PRECISION);

        return supplyRate;
    }

    /**
     * @notice Calculate current borrow APY
     */
    function getBorrowAPY(address token) external view returns (uint256) {
        return _calculateBorrowRate(token);
    }

    /**
     * @notice Get pool utilization rate
     */
    function getUtilizationRate(address token) external view returns (uint256) {
        PoolInfo storage pool = pools[token];
        if (pool.totalDeposits == 0) return 0;
        return
            (pool.totalBorrows * INTEREST_RATE_PRECISION) / pool.totalDeposits;
    }

    /**
     * @notice Check if user can borrow amount
     */
    function canBorrow(
        address,
        address token,
        uint256 amount
    ) external view returns (bool) {
        // Implementation for borrowing capacity check
        return pools[token].borrowingEnabled && amount >= minLoanAmount;
    }

    /**
     * @notice Get loan health factor
     */
    function getLoanHealthFactor(
        uint256 loanId
    ) external view returns (uint256) {
        LoanInfo storage loan = loans[loanId];
        if (loan.status != LoanStatus.ACTIVE) return 0;

        uint256 collateralValue = _getTokenValue(
            loan.collateralToken,
            loan.collateralAmount
        );
        uint256 debtValue = _getTokenValue(
            loan.borrowToken,
            loan.borrowAmount + loan.accruedInterest
        );

        if (debtValue == 0) return type(uint256).max;
        return
            (collateralValue * collateralFactors[loan.collateralToken]) /
            (debtValue * INTEREST_RATE_PRECISION);
    }

    /**
     * @notice Update loan interest (for testing purposes)
     */
    function updateLoanInterest(uint256 loanId) external validLoan(loanId) {
        _updateLoanInterest(loanId);
    }

    // ============ ADMIN FUNCTIONS ============

    /**
     * @notice Add a new supported token
     */
    function addSupportedToken(
        address token,
        uint256 collateralFactor,
        uint256 liquidationBonus
    ) external onlyRole(POOL_ADMIN_ROLE) {
        if (token == address(0)) revert HedVaultErrors.ZeroAddress();
        if (supportedTokens[token])
            revert HedVaultErrors.TokenAlreadySupported(token);

        supportedTokens[token] = true;
        collateralFactors[token] = collateralFactor;
        liquidationBonuses[token] = liquidationBonus;

        pools[token] = PoolInfo({
            totalDeposits: 0,
            totalBorrows: 0,
            totalReserves: 0,
            lastUpdateTime: block.timestamp,
            isActive: true,
            borrowingEnabled: true,
            depositsEnabled: true
        });

        emit TokenAdded(token, collateralFactor, liquidationBonus);
        emit Events.TokenAdded(token, collateralFactor);
    }

    /**
     * @notice Update collateral factor for a token
     */
    function updateCollateralFactor(
        address token,
        uint256 newFactor
    ) external onlyRole(POOL_ADMIN_ROLE) validToken(token) {
        if (newFactor > INTEREST_RATE_PRECISION) {
            revert HedVaultErrors.InvalidCollateralFactor(newFactor);
        }

        uint256 oldFactor = collateralFactors[token];
        collateralFactors[token] = newFactor;

        emit CollateralFactorUpdated(token, oldFactor, newFactor);
    }

    /**
     * @notice Update liquidation bonus for a token
     */
    function updateLiquidationBonus(
        address token,
        uint256 newBonus
    ) external onlyRole(POOL_ADMIN_ROLE) validToken(token) {
        uint256 oldBonus = liquidationBonuses[token];
        liquidationBonuses[token] = newBonus;

        emit LiquidationBonusUpdated(token, oldBonus, newBonus);
    }

    /**
     * @notice Update interest rate model parameters
     */
    function updateInterestRateModel(
        uint256 newBaseRate,
        uint256 newSlope1,
        uint256 newSlope2,
        uint256 newOptimalUtilization
    ) external onlyRole(POOL_ADMIN_ROLE) {
        baseInterestRate = newBaseRate;
        slope1 = newSlope1;
        slope2 = newSlope2;
        optimalUtilizationRate = newOptimalUtilization;

        emit InterestRateModelUpdated(
            newBaseRate,
            newSlope1,
            newSlope2,
            newOptimalUtilization
        );
    }

    /**
     * @notice Set pool active status
     */
    function setPoolActive(
        address token,
        bool active
    ) external onlyRole(POOL_ADMIN_ROLE) validToken(token) {
        pools[token].isActive = active;
        emit PoolStatusUpdated(token, active);
    }

    /**
     * @notice Set borrowing enabled status
     */
    function setBorrowingEnabled(
        address token,
        bool enabled
    ) external onlyRole(POOL_ADMIN_ROLE) validToken(token) {
        pools[token].borrowingEnabled = enabled;
        emit BorrowingStatusUpdated(token, enabled);
    }

    /**
     * @notice Update protocol fee rate
     */
    function updateProtocolFeeRate(
        uint256 newRate
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (newRate > MAX_PROTOCOL_FEE_RATE) {
            revert HedVaultErrors.InvalidFeeRate(newRate);
        }

        uint256 oldRate = protocolFeeRate;
        protocolFeeRate = newRate;

        emit ProtocolFeeRateUpdated(oldRate, newRate);
    }

    /**
     * @notice Update fee recipient
     */
    function updateFeeRecipient(
        address newRecipient
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (newRecipient == address(0)) revert HedVaultErrors.ZeroAddress();

        address oldRecipient = feeRecipient;
        feeRecipient = newRecipient;

        emit FeeRecipientUpdated(oldRecipient, newRecipient);
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
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    /**
     * @notice Withdraw reserves
     */
    function withdrawReserves(
        address token,
        uint256 amount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) validToken(token) {
        PoolInfo storage pool = pools[token];
        if (amount > pool.totalReserves) {
            revert HedVaultErrors.InsufficientReserves(
                amount,
                pool.totalReserves
            );
        }

        pool.totalReserves -= amount;
        IERC20(token).safeTransfer(msg.sender, amount);

        emit ReservesWithdrawn(token, amount, msg.sender);
    }
}
