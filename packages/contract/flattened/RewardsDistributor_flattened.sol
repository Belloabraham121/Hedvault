// SPDX-License-Identifier: MIT
pragma solidity >=0.4.16 >=0.6.2 >=0.8.4 ^0.8.20;

// lib/openzeppelin-contracts/contracts/access/IAccessControl.sol

// OpenZeppelin Contracts (last updated v5.4.0) (access/IAccessControl.sol)

/**
 * @dev External interface of AccessControl declared to support ERC-165 detection.
 */
interface IAccessControl {
    /**
     * @dev The `account` is missing a role.
     */
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    /**
     * @dev The caller of a function is not the expected one.
     *
     * NOTE: Don't confuse with {AccessControlUnauthorizedAccount}.
     */
    error AccessControlBadConfirmation();

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted to signal this.
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call. This account bears the admin role (for the granted role).
     * Expected in cases where the role was granted using the internal {AccessControl-_grantRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     */
    function renounceRole(bytes32 role, address callerConfirmation) external;
}

// lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// lib/openzeppelin-contracts/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuard.sol)

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

// lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts (last updated v5.4.0) (utils/introspection/IERC165.sol)

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// src/interfaces/IHedVaultCore.sol

/**
 * @title IHedVaultCore
 * @notice Interface for the HedVault Core contract
 */
interface IHedVaultCore {
    // View functions
    function feeRecipient() external view returns (address);
    function tradingFee() external view returns (uint256);
    function lendingFee() external view returns (uint256);
    function swapFee() external view returns (uint256);
    function bridgeFee() external view returns (uint256);
    function isInitialized() external view returns (bool);
    function emergencyMode() external view returns (bool);
    function admins(address admin) external view returns (bool);
    function circuitBreakers(
        string calldata module
    ) external view returns (bool);

    // Module addresses
    function rwaTokenFactory() external view returns (address);
    function marketplace() external view returns (address);
    function swapEngine() external view returns (address);
    function lendingPool() external view returns (address);
    function rewardsDistributor() external view returns (address);
    function priceOracle() external view returns (address);
    function complianceManager() external view returns (address);
    function portfolioManager() external view returns (address);
    function crossChainBridge() external view returns (address);
    function analyticsEngine() external view returns (address);

    // Functions
    function getProtocolFee(
        string calldata operation
    ) external view returns (uint256);
    function isValidModule(address module) external view returns (bool);
    function updateStatistics(
        address user,
        uint256 transactionValue,
        uint256 feeAmount
    ) external;

    // Events
    event ProtocolInitialized(address indexed core, uint256 timestamp);
    event ProtocolPaused(address indexed admin, uint256 timestamp);
    event ProtocolUnpaused(address indexed admin, uint256 timestamp);
    event FeeUpdated(string feeType, uint256 oldFee, uint256 newFee);
    event AdminAdded(address indexed admin, address indexed addedBy);
    event AdminRemoved(address indexed admin, address indexed removedBy);
}

// src/libraries/DataTypes.sol

/**
 * @title DataTypes
 * @notice Common data structures used throughout the HedVault protocol
 */
library DataTypes {
    /**
     * @notice Real World Asset metadata structure
     * @param assetType Type of RWA (real estate, precious metals, art, etc.)
     * @param location Physical location of the asset
     * @param valuation Current valuation in USD
     * @param lastValuationDate Timestamp of last valuation
     * @param certificationHash IPFS hash of certification documents
     * @param isActive Whether the asset is currently active
     */
    struct RWAMetadata {
        string assetType;
        string location;
        uint256 valuation;
        uint256 lastValuationDate;
        string certificationHash;
        bool isActive;
        address oracle;
        uint256 totalSupply;
        uint256 minInvestment;
    }

    /**
     * @notice Asset information structure
     * @param tokenAddress Address of the RWA token
     * @param creator Address of the asset creator
     * @param creationTime Timestamp when asset was tokenized
     * @param metadata RWA metadata
     * @param complianceLevel KYC/AML compliance level required
     */
    struct AssetInfo {
        address tokenAddress;
        address creator;
        uint256 creationTime;
        RWAMetadata metadata;
        uint8 complianceLevel;
        bool isListed;
        uint256 tradingVolume;
        uint256 holders;
    }

    /**
     * @notice User profile structure
     * @param isVerified KYC verification status
     * @param complianceLevel User's compliance level
     * @param registrationDate When user registered
     * @param totalInvested Total amount invested by user
     * @param portfolioValue Current portfolio value
     */
    struct UserProfile {
        bool isVerified;
        uint8 complianceLevel;
        uint256 registrationDate;
        uint256 totalInvested;
        uint256 portfolioValue;
        uint256 rewardsClaimed;
        address[] ownedAssets;
    }

    /**
     * @notice Loan information structure
     * @param borrower Address of the borrower
     * @param collateralToken Address of collateral token
     * @param collateralAmount Amount of collateral
     * @param borrowAmount Amount borrowed
     * @param interestRate Interest rate (basis points)
     * @param duration Loan duration in seconds
     * @param startTime Loan start timestamp
     * @param isActive Whether loan is active
     */
    struct LoanInfo {
        address borrower;
        address collateralToken;
        uint256 collateralAmount;
        uint256 borrowAmount;
        uint256 interestRate;
        uint256 duration;
        uint256 startTime;
        bool isActive;
        uint256 repaidAmount;
        bool isLiquidated;
    }

    /**
     * @notice Reward information structure
     * @param user Address of the user
     * @param rewardType Type of reward (staking, trading, etc.)
     * @param amount Reward amount
     * @param timestamp When reward was earned
     * @param isClaimed Whether reward has been claimed
     */
    struct RewardInfo {
        address user;
        string rewardType;
        uint256 amount;
        uint256 timestamp;
        bool isClaimed;
        uint256 vestingPeriod;
        uint256 claimableDate;
    }

    /**
     * @notice Order structure for marketplace
     * @param orderId Unique order identifier
     * @param seller Address of the seller
     * @param buyer Address of the buyer (0x0 for open orders)
     * @param tokenAddress Address of the token being traded
     * @param amount Amount of tokens
     * @param price Price per token
     * @param orderType 0 = buy, 1 = sell
     * @param status Order status (0 = open, 1 = filled, 2 = cancelled)
     * @param createdAt Order creation timestamp
     */
    struct Order {
        uint256 orderId;
        address seller;
        address buyer;
        address tokenAddress;
        uint256 amount;
        uint256 price;
        uint8 orderType;
        uint8 status;
        uint256 createdAt;
        uint256 filledAmount;
    }

    /**
     * @notice Swap information structure
     * @param user Address initiating the swap
     * @param tokenIn Input token address
     * @param tokenOut Output token address
     * @param amountIn Input amount
     * @param amountOut Output amount
     * @param slippageTolerance Maximum slippage allowed (basis points)
     * @param deadline Swap deadline timestamp
     */
    struct SwapInfo {
        address user;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 amountOut;
        uint256 slippageTolerance;
        uint256 deadline;
        uint256 executedAt;
        bool isCompleted;
    }

    /**
     * @notice Price feed information
     * @param oracle Oracle address
     * @param price Current price
     * @param timestamp Last update timestamp
     * @param decimals Price decimals
     * @param isActive Whether feed is active
     */
    struct PriceFeed {
        address oracle;
        uint256 price;
        uint256 timestamp;
        uint8 decimals;
        bool isActive;
        uint256 heartbeat;
        uint256 deviation;
    }

    /**
     * @notice Portfolio allocation structure
     * @param tokenAddress Address of the asset token
     * @param allocation Percentage allocation (basis points)
     * @param currentValue Current value in USD
     * @param targetValue Target value in USD
     */
    struct PortfolioAllocation {
        address tokenAddress;
        uint256 allocation;
        uint256 currentValue;
        uint256 targetValue;
        uint256 lastRebalance;
    }

    // Enums for better type safety
    enum AssetType {
        RealEstate,
        PreciousMetals,
        Art,
        Commodities,
        Bonds,
        Other
    }

    enum OrderStatus {
        Open,
        Filled,
        Cancelled,
        PartiallyFilled
    }

    enum LoanStatus {
        Active,
        Repaid,
        Liquidated,
        Defaulted
    }

    enum ComplianceLevel {
        None,
        Basic,
        Intermediate,
        Advanced,
        Institutional
    }

    // Constants
    uint256 public constant BASIS_POINTS = 10000;
    uint256 public constant MAX_SLIPPAGE = 1000; // 10%
    uint256 public constant MIN_LOAN_DURATION = 1 days;
    uint256 public constant MAX_LOAN_DURATION = 365 days;
    uint256 public constant PRICE_STALENESS_THRESHOLD = 1 hours;
}

// src/libraries/HedVaultErrors.sol

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
    error OracleUpdateFailed(address token);
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

// lib/openzeppelin-contracts/contracts/interfaces/IERC165.sol

// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC165.sol)

// lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol

// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC20.sol)

// lib/openzeppelin-contracts/contracts/utils/Pausable.sol

// OpenZeppelin Contracts (last updated v5.3.0) (utils/Pausable.sol)

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    bool private _paused;

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev The operation failed because the contract is paused.
     */
    error EnforcedPause();

    /**
     * @dev The operation failed because the contract is not paused.
     */
    error ExpectedPause();

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        if (paused()) {
            revert EnforcedPause();
        }
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        if (!paused()) {
            revert ExpectedPause();
        }
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol

// OpenZeppelin Contracts (last updated v5.4.0) (utils/introspection/ERC165.sol)

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC-165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165 is IERC165 {
    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// src/libraries/Events.sol

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

// lib/openzeppelin-contracts/contracts/access/AccessControl.sol

// OpenZeppelin Contracts (last updated v5.4.0) (access/AccessControl.sol)

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```solidity
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```solidity
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it. We recommend using {AccessControlDefaultAdminRules}
 * to enforce additional security measures for this role.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }

    mapping(bytes32 role => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with an {AccessControlUnauthorizedAccount} error including the required role.
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        return _roles[role].hasRole[account];
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `_msgSender()`
     * is missing `role`. Overriding this function changes the behavior of the {onlyRole} modifier.
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `account`
     * is missing `role`.
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert AccessControlUnauthorizedAccount(account, role);
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessControlBadConfirmation();
        }

        _revokeRole(role, callerConfirmation);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Attempts to grant `role` to `account` and returns a boolean indicating if `role` was granted.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual returns (bool) {
        if (!hasRole(role, account)) {
            _roles[role].hasRole[account] = true;
            emit RoleGranted(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Attempts to revoke `role` from `account` and returns a boolean indicating if `role` was revoked.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual returns (bool) {
        if (hasRole(role, account)) {
            _roles[role].hasRole[account] = false;
            emit RoleRevoked(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }
}

// lib/openzeppelin-contracts/contracts/interfaces/IERC1363.sol

// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC1363.sol)

/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}

// lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v5.3.0) (token/ERC20/utils/SafeERC20.sol)

/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Variant of {safeTransfer} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransfer(IERC20 token, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Variant of {safeTransferFrom} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransferFrom(IERC20 token, address from, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
    }
}

// src/RewardsDistributor.sol

/**
 * @title RewardsDistributor
 * @notice Manages reward distribution, staking, and vesting for the HedVault protocol
 * @dev Handles multiple reward types including staking, trading, lending, and governance rewards
 */
contract RewardsDistributor is AccessControl, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    // Role definitions
    bytes32 public constant REWARDS_ADMIN_ROLE = keccak256("REWARDS_ADMIN_ROLE");
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");

    // Core contracts
    IHedVaultCore public immutable hedVaultCore;
    IERC20 public immutable rewardToken; // HedVault native token

    // Reward pools for different activities
    struct RewardPool {
        uint256 totalAllocated;
        uint256 totalDistributed;
        uint256 rewardRate; // Rewards per second
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
        bool isActive;
        uint256 periodFinish;
        uint256 duration; // Reward period duration
    }

    // User staking information
    struct UserStake {
        uint256 amount;
        uint256 rewardPerTokenPaid;
        uint256 rewards;
        uint256 stakingTime;
        uint256 lockPeriod; // Lock period in seconds
        bool isLocked;
    }

    // Vesting schedule
    struct VestingSchedule {
        uint256 totalAmount;
        uint256 releasedAmount;
        uint256 startTime;
        uint256 duration;
        uint256 cliffDuration;
        bool revocable;
        bool revoked;
    }

    // State variables
    mapping(string => RewardPool) public rewardPools; // Pool name => RewardPool
    mapping(address => mapping(string => UserStake)) public userStakes; // User => Pool => Stake
    mapping(address => uint256) public totalStaked;
    mapping(string => uint256) public poolTotalStaked;
    mapping(address => VestingSchedule[]) public vestingSchedules;
    mapping(address => uint256) public pendingRewards;
    mapping(address => uint256) public claimedRewards;
    
    string[] public poolNames;
    uint256 public totalRewardsDistributed;
    uint256 public stakingFee = 100; // 1% in basis points
    uint256 public unstakingFee = 50; // 0.5% in basis points
    uint256 public constant MAX_FEE = 1000; // 10% max fee
    uint256 public constant BASIS_POINTS = 10000;
    uint256 public constant MIN_STAKE_AMOUNT = 1e18; // 1 token minimum
    uint256 public constant MAX_LOCK_PERIOD = 365 days;

    // Events
    event RewardPoolCreated(string indexed poolName, uint256 totalAllocated, uint256 duration);
    event RewardPoolUpdated(string indexed poolName, uint256 newRewardRate, uint256 newDuration);
    event Staked(address indexed user, string indexed poolName, uint256 amount, uint256 lockPeriod);
    event Unstaked(address indexed user, string indexed poolName, uint256 amount);
    event RewardClaimed(address indexed user, string indexed poolName, uint256 amount);
    event VestingScheduleCreated(address indexed beneficiary, uint256 amount, uint256 duration);
    event VestingReleased(address indexed beneficiary, uint256 amount);
    event VestingRevoked(address indexed beneficiary, uint256 scheduleId);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    modifier validPool(string memory poolName) {
        if (!rewardPools[poolName].isActive) {
            revert HedVaultErrors.InvalidConfiguration("Pool not active");
        }
        _;
    }

    modifier updateReward(address account, string memory poolName) {
        RewardPool storage pool = rewardPools[poolName];
        pool.rewardPerTokenStored = rewardPerToken(poolName);
        pool.lastUpdateTime = lastTimeRewardApplicable(poolName);
        
        if (account != address(0)) {
            UserStake storage userStake = userStakes[account][poolName];
            userStake.rewards = earned(account, poolName);
            userStake.rewardPerTokenPaid = pool.rewardPerTokenStored;
        }
        _;
    }

    constructor(
        address _hedVaultCore,
        address _rewardToken
    ) {
        if (_hedVaultCore == address(0) || _rewardToken == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        hedVaultCore = IHedVaultCore(_hedVaultCore);
        rewardToken = IERC20(_rewardToken);

        // Set up roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(REWARDS_ADMIN_ROLE, msg.sender);
        _grantRole(DISTRIBUTOR_ROLE, msg.sender);
        _grantRole(EMERGENCY_ROLE, msg.sender);
    }

    /**
     * @notice Create a new reward pool (automatically called by protocol)
     * @param poolName Name of the reward pool
     * @param totalAllocated Total tokens allocated to this pool
     * @param duration Duration of the reward period
     */
    function createRewardPool(
        string calldata poolName,
        uint256 totalAllocated,
        uint256 duration
    ) external onlyRole(REWARDS_ADMIN_ROLE) {
        if (bytes(poolName).length == 0) {
            revert HedVaultErrors.InvalidConfiguration("Empty pool name");
        }
        if (totalAllocated == 0 || duration == 0) {
            revert HedVaultErrors.InvalidConfiguration("Invalid parameters");
        }
        if (rewardPools[poolName].isActive) {
            revert HedVaultErrors.InvalidConfiguration("Pool already exists");
        }

        uint256 rewardRate = totalAllocated / duration;
        
        rewardPools[poolName] = RewardPool({
            totalAllocated: totalAllocated,
            totalDistributed: 0,
            rewardRate: rewardRate,
            lastUpdateTime: block.timestamp,
            rewardPerTokenStored: 0,
            isActive: true,
            periodFinish: block.timestamp + duration,
            duration: duration
        });

        poolNames.push(poolName);

        // Transfer tokens to contract
        rewardToken.safeTransferFrom(msg.sender, address(this), totalAllocated);

        emit RewardPoolCreated(poolName, totalAllocated, duration);
    }

    /**
     * @notice Initialize default reward pools automatically
     * @dev Called during contract deployment to set up all protocol reward pools
     */
    function initializeDefaultPools() external onlyRole(REWARDS_ADMIN_ROLE) {
        uint256 poolDuration = 365 days; // 1 year reward cycles
        uint256 baseAllocation = 100000 * 10**18; // 100k tokens per pool
        
        // Auto-create all protocol reward pools
        string[8] memory defaultPools = [
            "staking",           // Staking rewards
            "trading",          // Trading volume rewards
            "lending",          // Lending protocol rewards
            "governance",       // Governance participation
            "marketplace",      // NFT marketplace activity
            "liquidity",        // Liquidity provision
            "rwa_tokenization", // RWA tokenization rewards
            "referral"          // Referral program rewards
        ];
        
        for (uint i = 0; i < defaultPools.length; i++) {
            if (!rewardPools[defaultPools[i]].isActive) {
                rewardPools[defaultPools[i]] = RewardPool({
                    totalAllocated: baseAllocation,
                    totalDistributed: 0,
                    rewardRate: baseAllocation / poolDuration,
                    lastUpdateTime: block.timestamp,
                    rewardPerTokenStored: 0,
                    isActive: true,
                    periodFinish: block.timestamp + poolDuration,
                    duration: poolDuration
                });
                
                poolNames.push(defaultPools[i]);
                emit RewardPoolCreated(defaultPools[i], baseAllocation, poolDuration);
            }
        }
    }

    /**
     * @notice Automatically distribute rewards based on user activity
     * @param user User address to reward
     * @param activityType Type of activity ("trading", "lending", "staking", "governance")
     * @param amount Activity amount (volume, stake, etc.)
     */
    function distributeActivityReward(
        address user,
        string calldata activityType,
        uint256 amount
    ) external onlyRole(DISTRIBUTOR_ROLE) {
        if (!rewardPools[activityType].isActive) {
            return; // Skip if pool doesn't exist
        }
        
        // Calculate reward based on activity
        uint256 rewardAmount = _calculateActivityReward(activityType, amount);
        
        if (rewardAmount > 0) {
            pendingRewards[user] += rewardAmount;
            rewardPools[activityType].totalDistributed += rewardAmount;
            
            emit RewardClaimed(user, activityType, rewardAmount);
        }
    }

    /**
     * @notice Auto-claim all pending rewards for a user
     * @param user User address
     */
    function autoClaimRewards(address user) external nonReentrant {
        uint256 totalPending = pendingRewards[user];
        
        if (totalPending > 0) {
            pendingRewards[user] = 0;
            claimedRewards[user] += totalPending;
            totalRewardsDistributed += totalPending;
            
            rewardToken.safeTransfer(user, totalPending);
            
            emit RewardClaimed(user, "auto-claim", totalPending);
        }
    }

    /**
     * @notice Stake tokens in a reward pool
     * @param poolName Name of the pool to stake in
     * @param amount Amount to stake
     * @param lockPeriod Lock period in seconds (0 for no lock)
     */
    function stake(
        string calldata poolName,
        uint256 amount,
        uint256 lockPeriod
    ) external validPool(poolName) updateReward(msg.sender, poolName) whenNotPaused nonReentrant {
        if (amount < MIN_STAKE_AMOUNT) {
            revert HedVaultErrors.InvalidConfiguration("Amount too small");
        }
        if (lockPeriod > MAX_LOCK_PERIOD) {
            revert HedVaultErrors.InvalidConfiguration("Lock period too long");
        }

        UserStake storage userStake = userStakes[msg.sender][poolName];
        
        // Calculate staking fee
        uint256 fee = (amount * stakingFee) / BASIS_POINTS;
        uint256 stakeAmount = amount - fee;

        userStake.amount += stakeAmount;
        userStake.stakingTime = block.timestamp;
        userStake.lockPeriod = lockPeriod;
        userStake.isLocked = lockPeriod > 0;

        totalStaked[msg.sender] += stakeAmount;
        poolTotalStaked[poolName] += stakeAmount;

        // Transfer tokens from user
        rewardToken.safeTransferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, poolName, stakeAmount, lockPeriod);
    }

    /**
     * @notice Unstake tokens from a reward pool
     * @param poolName Name of the pool to unstake from
     * @param amount Amount to unstake
     */
    function unstake(
        string calldata poolName,
        uint256 amount
    ) external validPool(poolName) updateReward(msg.sender, poolName) nonReentrant {
        UserStake storage userStake = userStakes[msg.sender][poolName];
        
        if (amount > userStake.amount) {
            revert HedVaultErrors.InvalidConfiguration("Insufficient stake");
        }
        
        // Check lock period
        if (userStake.isLocked && block.timestamp < userStake.stakingTime + userStake.lockPeriod) {
            revert HedVaultErrors.InvalidConfiguration("Stake is locked");
        }

        // Calculate unstaking fee
        uint256 fee = (amount * unstakingFee) / BASIS_POINTS;
        uint256 withdrawAmount = amount - fee;

        userStake.amount -= amount;
        totalStaked[msg.sender] -= amount;
        poolTotalStaked[poolName] -= amount;

        // Transfer tokens to user
        rewardToken.safeTransfer(msg.sender, withdrawAmount);

        emit Unstaked(msg.sender, poolName, withdrawAmount);
    }

    /**
     * @notice Claim rewards from a pool
     * @param poolName Name of the pool to claim from
     */
    function claimRewards(
        string calldata poolName
    ) external validPool(poolName) updateReward(msg.sender, poolName) nonReentrant {
        UserStake storage userStake = userStakes[msg.sender][poolName];
        uint256 reward = userStake.rewards;
        
        if (reward > 0) {
            userStake.rewards = 0;
            claimedRewards[msg.sender] += reward;
            totalRewardsDistributed += reward;
            
            rewardPools[poolName].totalDistributed += reward;
            
            rewardToken.safeTransfer(msg.sender, reward);
            
            emit RewardClaimed(msg.sender, poolName, reward);
        }
    }

    /**
     * @notice Create a vesting schedule for a beneficiary
     * @param beneficiary Address of the beneficiary
     * @param amount Total amount to vest
     * @param duration Vesting duration
     * @param cliffDuration Cliff period before vesting starts
     * @param revocable Whether the schedule can be revoked
     */
    function createVestingSchedule(
        address beneficiary,
        uint256 amount,
        uint256 duration,
        uint256 cliffDuration,
        bool revocable
    ) external onlyRole(REWARDS_ADMIN_ROLE) {
        if (beneficiary == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }
        if (amount == 0 || duration == 0) {
            revert HedVaultErrors.InvalidConfiguration("Invalid parameters");
        }
        if (cliffDuration > duration) {
            revert HedVaultErrors.InvalidConfiguration("Cliff too long");
        }

        vestingSchedules[beneficiary].push(VestingSchedule({
            totalAmount: amount,
            releasedAmount: 0,
            startTime: block.timestamp,
            duration: duration,
            cliffDuration: cliffDuration,
            revocable: revocable,
            revoked: false
        }));

        // Transfer tokens to contract
        rewardToken.safeTransferFrom(msg.sender, address(this), amount);

        emit VestingScheduleCreated(beneficiary, amount, duration);
    }

    /**
     * @notice Release vested tokens
     * @param scheduleId ID of the vesting schedule
     */
    function releaseVestedTokens(uint256 scheduleId) external nonReentrant {
        VestingSchedule[] storage schedules = vestingSchedules[msg.sender];
        
        if (scheduleId >= schedules.length) {
            revert HedVaultErrors.InvalidConfiguration("Invalid schedule ID");
        }

        VestingSchedule storage schedule = schedules[scheduleId];
        
        if (schedule.revoked) {
            revert HedVaultErrors.InvalidConfiguration("Schedule revoked");
        }

        uint256 releasableAmount = _getReleasableAmount(schedule);
        
        if (releasableAmount == 0) {
            revert HedVaultErrors.InvalidConfiguration("No tokens to release");
        }

        schedule.releasedAmount += releasableAmount;
        
        rewardToken.safeTransfer(msg.sender, releasableAmount);
        
        emit VestingReleased(msg.sender, releasableAmount);
    }

    /**
     * @notice Revoke a vesting schedule (admin only)
     * @param beneficiary Address of the beneficiary
     * @param scheduleId ID of the schedule to revoke
     */
    function revokeVestingSchedule(
        address beneficiary,
        uint256 scheduleId
    ) external onlyRole(REWARDS_ADMIN_ROLE) {
        VestingSchedule[] storage schedules = vestingSchedules[beneficiary];
        
        if (scheduleId >= schedules.length) {
            revert HedVaultErrors.InvalidConfiguration("Invalid schedule ID");
        }

        VestingSchedule storage schedule = schedules[scheduleId];
        
        if (!schedule.revocable) {
            revert HedVaultErrors.InvalidConfiguration("Schedule not revocable");
        }
        if (schedule.revoked) {
            revert HedVaultErrors.InvalidConfiguration("Already revoked");
        }

        // Release any vested amount first
        uint256 releasableAmount = _getReleasableAmount(schedule);
        if (releasableAmount > 0) {
            schedule.releasedAmount += releasableAmount;
            rewardToken.safeTransfer(beneficiary, releasableAmount);
        }

        schedule.revoked = true;
        
        emit VestingRevoked(beneficiary, scheduleId);
    }

    /**
     * @notice Emergency withdraw for users (admin only)
     * @param user User address
     * @param amount Amount to withdraw
     */
    function emergencyWithdraw(
        address user,
        uint256 amount
    ) external onlyRole(EMERGENCY_ROLE) {
        if (totalStaked[user] < amount) {
            revert HedVaultErrors.InvalidConfiguration("Insufficient balance");
        }

        totalStaked[user] -= amount;
        rewardToken.safeTransfer(user, amount);
        
        emit EmergencyWithdraw(user, amount);
    }

    // View functions
    function lastTimeRewardApplicable(string memory poolName) public view returns (uint256) {
        RewardPool memory pool = rewardPools[poolName];
        return block.timestamp < pool.periodFinish ? block.timestamp : pool.periodFinish;
    }

    function rewardPerToken(string memory poolName) public view returns (uint256) {
        RewardPool memory pool = rewardPools[poolName];
        uint256 totalStakedInPool = poolTotalStaked[poolName];
        
        if (totalStakedInPool == 0) {
            return pool.rewardPerTokenStored;
        }
        
        return pool.rewardPerTokenStored + 
            (((lastTimeRewardApplicable(poolName) - pool.lastUpdateTime) * pool.rewardRate * 1e18) / totalStakedInPool);
    }

    function earned(address account, string memory poolName) public view returns (uint256) {
        UserStake memory userStake = userStakes[account][poolName];
        return (userStake.amount * (rewardPerToken(poolName) - userStake.rewardPerTokenPaid)) / 1e18 + userStake.rewards;
    }

    function getVestingScheduleCount(address beneficiary) external view returns (uint256) {
        return vestingSchedules[beneficiary].length;
    }

    function getVestingSchedule(address beneficiary, uint256 scheduleId) external view returns (VestingSchedule memory) {
        return vestingSchedules[beneficiary][scheduleId];
    }

    function getReleasableAmount(address beneficiary, uint256 scheduleId) external view returns (uint256) {
        VestingSchedule memory schedule = vestingSchedules[beneficiary][scheduleId];
        return _getReleasableAmount(schedule);
    }

    function getPoolNames() external view returns (string[] memory) {
        return poolNames;
    }

    function getUserStakeInfo(address user, string memory poolName) external view returns (UserStake memory) {
        return userStakes[user][poolName];
    }

    /**
     * @notice Get comprehensive user rewards data across all pools and activities
     * @param user User address to query
     * @return totalEarned Total rewards earned across all pools
     * @return totalPending Total pending rewards from activities
     * @return totalStakedAmount Total amount staked across all pools
     * @return totalClaimedRewards Total rewards already claimed
     * @return poolEarnings Array of earnings per active pool
     * @return poolStakes Array of stake amounts per active pool
     * @return vestingAmounts Array of releasable vesting amounts
     * @return activePoolNames Array of active pool names
     */
    function getUserRewardsOverview(address user) external view returns (
        uint256 totalEarned,
        uint256 totalPending,
        uint256 totalStakedAmount,
        uint256 totalClaimedRewards,
        uint256[] memory poolEarnings,
        uint256[] memory poolStakes,
        uint256[] memory vestingAmounts,
        string[] memory activePoolNames
    ) {
        // Initialize return arrays
        poolEarnings = new uint256[](poolNames.length);
        poolStakes = new uint256[](poolNames.length);
        activePoolNames = new string[](poolNames.length);
        
        uint256 activePoolCount = 0;
        
        // Calculate totals across all pools
        for (uint256 i = 0; i < poolNames.length; i++) {
            string memory poolName = poolNames[i];
            
            if (rewardPools[poolName].isActive) {
                UserStake memory userStake = userStakes[user][poolName];
                uint256 poolEarned = earned(user, poolName);
                
                poolEarnings[activePoolCount] = poolEarned;
                poolStakes[activePoolCount] = userStake.amount;
                activePoolNames[activePoolCount] = poolName;
                
                totalEarned += poolEarned;
                totalStakedAmount += userStake.amount;
                activePoolCount++;
            }
        }
        
        // Resize arrays to actual active pool count
        assembly {
            mstore(poolEarnings, activePoolCount)
            mstore(poolStakes, activePoolCount)
            mstore(activePoolNames, activePoolCount)
        }
        
        // Add pending rewards from activity-based rewards
        totalPending = pendingRewards[user];
        totalEarned += totalPending;
        
        // Get claimed rewards
        totalClaimedRewards = claimedRewards[user];
        
        // Calculate vesting amounts
        VestingSchedule[] memory schedules = vestingSchedules[user];
        vestingAmounts = new uint256[](schedules.length);
        
        for (uint256 i = 0; i < schedules.length; i++) {
            if (!schedules[i].revoked) {
                vestingAmounts[i] = _getReleasableAmount(schedules[i]);
                totalEarned += vestingAmounts[i];
            }
        }
        
        return (
            totalEarned,
            totalPending,
            totalStakedAmount,
            totalClaimedRewards,
            poolEarnings,
            poolStakes,
            vestingAmounts,
            activePoolNames
        );
    }

    /**
     * @notice Get detailed breakdown of user's position across all protocol activities
     * @param user User address to query
     * @return stakingRewards Rewards from staking activities
     * @return tradingRewards Rewards from trading activities
     * @return lendingRewards Rewards from lending activities
     * @return governanceRewards Rewards from governance participation
     * @return marketplaceRewards Rewards from marketplace activities
     * @return liquidityRewards Rewards from liquidity provision
     * @return rwaRewards Rewards from RWA tokenization
     * @return referralRewards Rewards from referral program
     * @return totalVestingAmount Total amount in vesting schedules
     * @return totalReleasableVesting Total releasable vesting amount
     */
    function getUserPositionBreakdown(address user) external view returns (
        uint256 stakingRewards,
        uint256 tradingRewards,
        uint256 lendingRewards,
        uint256 governanceRewards,
        uint256 marketplaceRewards,
        uint256 liquidityRewards,
        uint256 rwaRewards,
        uint256 referralRewards,
        uint256 totalVestingAmount,
        uint256 totalReleasableVesting
    ) {
        // Get rewards from each specific pool
        stakingRewards = earned(user, "staking");
        tradingRewards = earned(user, "trading");
        lendingRewards = earned(user, "lending");
        governanceRewards = earned(user, "governance");
        marketplaceRewards = earned(user, "marketplace");
        liquidityRewards = earned(user, "liquidity");
        rwaRewards = earned(user, "rwa_tokenization");
        referralRewards = earned(user, "referral");
        
        // Calculate vesting totals
        VestingSchedule[] memory schedules = vestingSchedules[user];
        for (uint256 i = 0; i < schedules.length; i++) {
            if (!schedules[i].revoked) {
                totalVestingAmount += schedules[i].totalAmount - schedules[i].releasedAmount;
                totalReleasableVesting += _getReleasableAmount(schedules[i]);
            }
        }
        
        return (
            stakingRewards,
            tradingRewards,
            lendingRewards,
            governanceRewards,
            marketplaceRewards,
            liquidityRewards,
            rwaRewards,
            referralRewards,
            totalVestingAmount,
            totalReleasableVesting
        );
    }

    // Internal functions
    function _getReleasableAmount(VestingSchedule memory schedule) internal view returns (uint256) {
        if (schedule.revoked) {
            return 0;
        }
        
        uint256 currentTime = block.timestamp;
        
        if (currentTime < schedule.startTime + schedule.cliffDuration) {
            return 0;
        }
        
        if (currentTime >= schedule.startTime + schedule.duration) {
            return schedule.totalAmount - schedule.releasedAmount;
        }
        
        uint256 timeFromStart = currentTime - schedule.startTime;
        uint256 vestedAmount = (schedule.totalAmount * timeFromStart) / schedule.duration;
        
        return vestedAmount - schedule.releasedAmount;
    }

    /**
     * @notice Calculate reward amount based on activity type and amount
     * @param activityType Type of activity
     * @param amount Activity amount
     * @return Calculated reward amount
     */
    function _calculateActivityReward(string memory activityType, uint256 amount) internal pure returns (uint256) {
        // Different reward rates for different activities
        if (keccak256(bytes(activityType)) == keccak256(bytes("trading"))) {
            return (amount * 10) / BASIS_POINTS; // 0.1% of trading volume
        } else if (keccak256(bytes(activityType)) == keccak256(bytes("lending"))) {
            return (amount * 50) / BASIS_POINTS; // 0.5% of lending amount
        } else if (keccak256(bytes(activityType)) == keccak256(bytes("staking"))) {
            return (amount * 100) / BASIS_POINTS; // 1% of staking amount
        } else if (keccak256(bytes(activityType)) == keccak256(bytes("governance"))) {
            return 1000 * 10**18; // Fixed 1000 tokens for governance participation
        } else if (keccak256(bytes(activityType)) == keccak256(bytes("marketplace"))) {
            return (amount * 25) / BASIS_POINTS; // 0.25% of marketplace transaction value
        } else if (keccak256(bytes(activityType)) == keccak256(bytes("liquidity"))) {
            return (amount * 75) / BASIS_POINTS; // 0.75% of liquidity provided
        } else if (keccak256(bytes(activityType)) == keccak256(bytes("rwa_tokenization"))) {
            return (amount * 200) / BASIS_POINTS; // 2% of RWA tokenization value
        } else if (keccak256(bytes(activityType)) == keccak256(bytes("referral"))) {
            return 500 * 10**18; // Fixed 500 tokens for successful referral
        }
        
        return 0;
    }

    // Admin functions
    function updateStakingFee(uint256 newFee) external onlyRole(REWARDS_ADMIN_ROLE) {
        if (newFee > MAX_FEE) {
            revert HedVaultErrors.InvalidConfiguration("Fee too high");
        }
        stakingFee = newFee;
    }

    function updateUnstakingFee(uint256 newFee) external onlyRole(REWARDS_ADMIN_ROLE) {
        if (newFee > MAX_FEE) {
            revert HedVaultErrors.InvalidConfiguration("Fee too high");
        }
        unstakingFee = newFee;
    }

    function updateRewardPool(
        string calldata poolName,
        uint256 newRewardRate,
        uint256 newDuration
    ) external onlyRole(REWARDS_ADMIN_ROLE) updateReward(address(0), poolName) {
        RewardPool storage pool = rewardPools[poolName];
        
        if (!pool.isActive) {
            revert HedVaultErrors.InvalidConfiguration("Pool not active");
        }

        pool.rewardRate = newRewardRate;
        pool.duration = newDuration;
        pool.periodFinish = block.timestamp + newDuration;
        
        emit RewardPoolUpdated(poolName, newRewardRate, newDuration);
    }

    function pause() external onlyRole(EMERGENCY_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(EMERGENCY_ROLE) {
        _unpause();
    }

    function deactivatePool(string calldata poolName) external onlyRole(REWARDS_ADMIN_ROLE) {
        rewardPools[poolName].isActive = false;
    }

    function activatePool(string calldata poolName) external onlyRole(REWARDS_ADMIN_ROLE) {
        rewardPools[poolName].isActive = true;
    }
}

