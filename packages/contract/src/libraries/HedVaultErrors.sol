// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Errors
 * @notice Custom error definitions for the HedVault protocol
 * @dev Using custom errors for better gas efficiency and clearer error messages
 */
library HedVaultErrors {
    // Access Control Errors
    error UnauthorizedAccess(address caller, string requiredRole);
    error OnlyOwner(address caller);
    error OnlyAdmin(address caller);
    error AdminAlreadyExists(address admin);
    error AdminDoesNotExist(address admin);
    error CannotRemoveLastAdmin();

    // Protocol State Errors
    error ProtocolPaused();
    error ProtocolNotPaused();
    error ProtocolAlreadyInitialized();
    error ProtocolNotInitialized();
    error InvalidConfiguration(string parameter);

    // Validation Errors
    error ZeroAddress();
    error ZeroAmount();
    error InvalidAmount(uint256 amount, uint256 min, uint256 max);
    error InvalidPercentage(uint256 percentage);
    error InvalidTimestamp(uint256 timestamp);
    error InvalidDuration(uint256 duration);
    error ArrayLengthMismatch(uint256 length1, uint256 length2);
    error EmptyArray();
    error IndexOutOfBounds(uint256 index, uint256 length);

    // RWA Token Errors
    error TokenAlreadyExists(address token);
    error TokenDoesNotExist(address token);
    error TokenNotActive(address token);
    error TokenCreationFailed(string reason);
    error InvalidTokenMetadata(string field);
    error InsufficientTokenSupply(uint256 requested, uint256 available);
    error TokenNotListed(address token);
    error TokenAlreadyListed(address token);
    error TokenAlreadySupported(address token);
    error MinInvestmentNotMet(uint256 amount, uint256 minimum);

    // Trading and Marketplace Errors
    error OrderDoesNotExist(uint256 orderId);
    error OrderAlreadyFilled(uint256 orderId);
    error OrderAlreadyCancelled(uint256 orderId);
    error OrderExpired(uint256 orderId);
    error InsufficientBalance(
        address token,
        uint256 required,
        uint256 available
    );
    error InvalidOrderType(uint8 orderType);
    error InvalidPrice(uint256 price);
    error SelfTrade(address user);
    error OrderNotOwned(uint256 orderId, address caller);
    error MarketClosed();
    error TradingHalted(address token);
    error TradingPaused(address asset);
    error TooManyActiveOrders(address user, uint256 maxAllowed);
    error OrderInMatching(uint256 orderId);

    // Swap Errors
    error SwapExpired(uint256 deadline);
    error SlippageExceeded(uint256 expected, uint256 actual);
    error InsufficientLiquidity(address tokenA, address tokenB);
    error InvalidSwapPath(address[] path);
    error SwapAmountTooSmall(uint256 amount);
    error SwapAmountTooLarge(uint256 amount);
    error IdenticalTokens(address token);
    error PairDoesNotExist(address tokenA, address tokenB);

    // Lending and Borrowing Errors
    error LoanDoesNotExist(uint256 loanId);
    error LoanAlreadyRepaid(uint256 loanId);
    error LoanAlreadyLiquidated(uint256 loanId);
    error InsufficientCollateral(uint256 required, uint256 provided);
    error CollateralRatioTooLow(uint256 ratio, uint256 minimum);
    error LoanNotDueForLiquidation(uint256 loanId);
    error RepaymentAmountExceedsDebt(uint256 amount, uint256 debt);
    error InterestRateTooHigh(uint256 rate, uint256 maximum);
    error LoanDurationInvalid(uint256 duration);
    error BorrowAmountTooSmall(uint256 amount, uint256 minimum);
    error BorrowAmountTooLarge(uint256 amount, uint256 maximum);
    error InvalidCollateralFactor(uint256 factor);
    error InsufficientReserves(uint256 requested, uint256 available);

    // Oracle Errors
    error OracleNotFound(address token);
    error StalePriceData(address oracle, uint256 lastUpdate);
    error InvalidPriceData(address oracle, int256 price);
    error OracleAlreadyExists(address token, address oracle);
    error PriceDeviationTooHigh(uint256 deviation, uint256 threshold);
    error NoValidPriceFeeds(address token);
    error OracleCallFailed(address oracle);
    error EmergencyPriceExpired(address token);
    error AssetNotSupported(address asset);
    error SequencerDown();
    error GracePeriodNotOver();
    error InvalidParameter(string parameter);

    // Rewards Errors
    error RewardAlreadyClaimed(address user, uint256 rewardId);
    error RewardNotClaimable(uint256 rewardId, uint256 claimableDate);
    error InsufficientRewardBalance(uint256 required, uint256 available);
    error InvalidRewardType(string rewardType);
    error RewardCalculationFailed(address user);
    error VestingPeriodNotComplete(uint256 claimableDate);
    error RewardDistributionFailed(string reason);

    // Compliance Errors
    error UserNotVerified(address user);
    error UserAlreadyRegistered(address user);
    error InsufficientComplianceLevel(
        address user,
        uint8 required,
        uint8 current
    );
    error UserSuspended(address user);
    error KYCExpired(address user);
    error ComplianceViolation(address user, string violation);
    error InvalidComplianceLevel(uint8 level);
    error ComplianceCheckFailed(address user, string reason);

    // Portfolio Errors
    error PortfolioNotFound(address user);
    error InvalidAllocation(uint256 allocation);
    error AllocationExceedsLimit(uint256 total, uint256 limit);
    error RebalanceNotRequired(address user);
    error RebalanceFailed(string reason);
    error AssetNotInPortfolio(address user, address token);
    error PortfolioValueCalculationFailed(address user);

    // Cross-Chain Errors
    error UnsupportedChain(uint256 chainId);
    error BridgeNotActive(uint256 chainId);
    error InsufficientBridgeFee(uint256 provided, uint256 required);
    error TransferAlreadyProcessed(bytes32 transferId);
    error TransferNotFound(bytes32 transferId);
    error CrossChainTransferFailed(bytes32 transferId, string reason);
    error InvalidDestinationAddress(address destination);

    // Analytics Errors
    error AnalyticsDataNotAvailable(address user);
    error InvalidMetricType(string metricType);
    error CalculationPeriodTooShort(uint256 period, uint256 minimum);
    error InsufficientDataForAnalysis(address user);
    error RiskAssessmentFailed(address user, string reason);

    // Emergency Errors
    error EmergencyModeActive();
    error EmergencyModeNotActive();
    error CircuitBreakerTriggered(string module);
    error RecoveryModeActive();
    error UnauthorizedEmergencyAction(address caller);
    error EmergencyWithdrawalFailed(string reason);

    // Fee Errors
    error FeeTooHigh(uint256 fee, uint256 maximum);
    error InsufficientFeePayment(uint256 provided, uint256 required);
    error FeeCollectionFailed(string reason);
    error InvalidFeeRecipient(address recipient);
    error InvalidFeeRate(uint256 rate);

    // General Business Logic Errors
    error OperationNotAllowed(string operation);
    error ContractNotSupported(address contractAddress);
    error FunctionNotImplemented(string functionName);
    error DeprecatedFunction(string functionName);
    error MaintenanceMode();
    error RateLimitExceeded(address user);
    error DailyLimitExceeded(address user, uint256 amount, uint256 limit);
    error TransactionTooLarge(uint256 amount, uint256 maximum);
    error TransactionTooSmall(uint256 amount, uint256 minimum);

    // Reentrancy Errors
    error ReentrantCall();
    error NonReentrantFunction();

    // Upgrade Errors
    error UpgradeNotAuthorized(address caller);
    error InvalidImplementation(address implementation);
    error UpgradeFailed(string reason);
    error VersionMismatch(uint256 expected, uint256 actual);

    // Integration Errors
    error ExternalCallFailed(address target, bytes data);
    error InvalidExternalResponse(address target);
    error ExternalServiceUnavailable(string service);
    error IntegrationNotConfigured(string integration);

    // Math Errors
    error DivisionByZero();
    error Overflow(uint256 value);
    error Underflow(uint256 value);
    error InvalidCalculation(string calculation);
    error PrecisionLoss(string operation);
}
