// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DataTypes.sol";

/**
 * @title Events
 * @notice All events used throughout the HedVault protocol
 */
library Events {
    // Core Protocol Events
    event ProtocolInitialized(address indexed core, uint256 timestamp);
    event ProtocolPaused(address indexed admin, uint256 timestamp);
    event ProtocolUnpaused(address indexed admin, uint256 timestamp);
    event FeeUpdated(string feeType, uint256 oldFee, uint256 newFee);
    event AdminAdded(address indexed admin, address indexed addedBy);
    event AdminRemoved(address indexed admin, address indexed removedBy);
    event StatisticsUpdated(
        address indexed user,
        uint256 transactionValue,
        uint256 feeAmount,
        uint256 totalValueLocked
    );
    event UserRegistered(address indexed user, uint256 timestamp);
    event ModuleUpdated(
        string moduleType,
        address indexed oldModule,
        address indexed newModule
    );
    event ProtocolLimitUpdated(
        string limitType,
        uint256 oldLimit,
        uint256 newLimit
    );
    event ETHDeposited(
        address indexed depositor,
        uint256 amount,
        uint256 timestamp
    );

    // RWA Token Events
    event RWATokenCreated(
        address indexed tokenAddress,
        address indexed creator,
        string assetType,
        uint256 totalSupply,
        uint256 valuation
    );

    event RWATokenUpdated(
        address indexed tokenAddress,
        uint256 newValuation,
        uint256 timestamp
    );

    event RWATokenListed(
        address indexed tokenAddress,
        address indexed lister,
        uint256 timestamp
    );

    event RWATokenDelisted(
        address indexed tokenAddress,
        address indexed delister,
        uint256 timestamp
    );

    // Trading and Marketplace Events
    event OrderCreated(
        uint256 indexed orderId,
        address indexed user,
        address indexed tokenAddress,
        uint256 amount,
        uint256 price,
        uint8 orderType
    );

    event OrderFilled(
        uint256 indexed orderId,
        address indexed buyer,
        address indexed seller,
        address tokenAddress,
        uint256 amount,
        uint256 price
    );

    event OrderCancelled(
        uint256 indexed orderId,
        address indexed user,
        uint256 timestamp
    );

    event OrderPartiallyFilled(
        uint256 indexed orderId,
        address indexed buyer,
        address indexed seller,
        uint256 filledAmount,
        uint256 remainingAmount
    );

    event MarketOrderExecuted(
        address indexed user,
        address indexed asset,
        address indexed paymentToken,
        uint256 amount,
        uint8 orderType,
        uint256 timestamp
    );

    event EmergencyStopActivated(
        address indexed admin,
        uint256 timestamp
    );

    event EmergencyStopDeactivated(
        address indexed admin,
        uint256 timestamp
    );

    event AssetTradingStatusChanged(
        address indexed asset,
        bool enabled,
        uint256 timestamp
    );

    event TradingLimitsUpdated(
        uint256 maxActiveOrdersPerUser,
        uint256 maxSlippageAllowed,
        uint256 timestamp
    );

    // Swap Events
    event SwapExecuted(
        address indexed user,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        uint256 timestamp
    );

    event SwapFailed(
        address indexed user,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        string reason
    );

    event LiquidityAdded(
        address indexed provider,
        address indexed tokenA,
        address indexed tokenB,
        uint256 amountA,
        uint256 amountB
    );

    event LiquidityRemoved(
        address indexed provider,
        address indexed tokenA,
        address indexed tokenB,
        uint256 amountA,
        uint256 amountB
    );

    // Lending and Borrowing Events
    event LoanCreated(
        uint256 indexed loanId,
        address indexed borrower,
        address indexed collateralToken,
        uint256 collateralAmount,
        uint256 borrowAmount,
        uint256 interestRate
    );

    event LoanRepaid(
        uint256 indexed loanId,
        address indexed borrower,
        uint256 repaidAmount,
        uint256 timestamp
    );

    event LoanLiquidated(
        uint256 indexed loanId,
        address indexed borrower,
        address indexed liquidator,
        uint256 collateralSeized,
        uint256 debtCovered
    );

    event CollateralDeposited(
        address indexed user,
        address indexed token,
        uint256 amount
    );

    event CollateralWithdrawn(
        address indexed user,
        address indexed token,
        uint256 amount
    );

    event InterestRateUpdated(
        address indexed token,
        uint256 oldRate,
        uint256 newRate
    );

    event TokenAdded(
        address indexed token,
        uint256 collateralFactor
    );

    event PoolDeposit(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 timestamp
    );

    event PoolWithdraw(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 timestamp
    );

    // Rewards Events
    event RewardEarned(
        address indexed user,
        string rewardType,
        uint256 amount,
        uint256 timestamp
    );

    event RewardClaimed(
        address indexed user,
        uint256 amount,
        uint256 timestamp
    );

    event RewardDistributed(
        address indexed token,
        uint256 totalAmount,
        uint256 recipients
    );

    event StakingRewardUpdated(
        address indexed token,
        uint256 oldRate,
        uint256 newRate
    );

    event VestingScheduleCreated(
        address indexed user,
        uint256 amount,
        uint256 vestingPeriod,
        uint256 claimableDate
    );

    // Oracle Events
    event PriceUpdated(
        address indexed token,
        uint256 oldPrice,
        uint256 newPrice,
        uint256 timestamp
    );

    event OracleAdded(
        address indexed token,
        address indexed oracle,
        uint256 heartbeat
    );

    event OracleRemoved(address indexed token, address indexed oracle);

    event PriceFeedStale(
        address indexed token,
        address indexed oracle,
        uint256 lastUpdate
    );

    event EmergencyPriceSet(
        address indexed token,
        uint256 price,
        address indexed setter
    );

    // Compliance Events
    event UserVerified(
        address indexed user,
        uint8 complianceLevel,
        uint256 timestamp
    );

    event UserSuspended(address indexed user, string reason, uint256 timestamp);

    event ComplianceViolation(
        address indexed user,
        string violationType,
        uint256 timestamp
    );

    event KYCStatusUpdated(
        address indexed user,
        bool oldStatus,
        bool newStatus
    );

    // Portfolio Events
    event PortfolioRebalanced(address indexed user, uint256 timestamp);

    event AllocationUpdated(
        address indexed user,
        address indexed token,
        uint256 oldAllocation,
        uint256 newAllocation
    );

    event PerformanceCalculated(
        address indexed user,
        uint256 portfolioValue,
        int256 performance,
        uint256 timestamp
    );

    // Cross-Chain Events
    event CrossChainTransferInitiated(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 destinationChain,
        bytes32 transferId
    );

    event CrossChainTransferCompleted(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 sourceChain,
        bytes32 transferId
    );

    event BridgeFeePaid(
        address indexed user,
        uint256 amount,
        uint256 destinationChain
    );

    // Analytics Events
    event TransactionAnalyzed(
        address indexed user,
        string transactionType,
        uint256 value,
        uint256 timestamp
    );

    event RiskAssessmentUpdated(
        address indexed user,
        uint256 oldRiskScore,
        uint256 newRiskScore
    );

    event PerformanceMetricCalculated(
        string metricType,
        uint256 value,
        uint256 timestamp
    );

    // Emergency Events
    event EmergencyWithdrawal(
        address indexed user,
        address indexed token,
        uint256 amount,
        string reason
    );

    event CircuitBreakerTriggered(
        string module,
        string reason,
        uint256 timestamp
    );

    event RecoveryModeActivated(
        address indexed admin,
        string reason,
        uint256 timestamp
    );

    // Governance Events (for future use)
    event ProposalCreated(
        uint256 indexed proposalId,
        address indexed proposer,
        string description
    );

    event VoteCast(
        uint256 indexed proposalId,
        address indexed voter,
        bool support,
        uint256 weight
    );

    event ProposalExecuted(uint256 indexed proposalId, uint256 timestamp);
}
