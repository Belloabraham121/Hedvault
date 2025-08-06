// SPDX-License-Identifier: MIT
pragma solidity >=0.4.16 >=0.8.4 ^0.8.20;

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

// src/ComplianceManager.sol

/**
 * @title ComplianceManager
 * @notice Manages KYC/AML compliance for the HedVault protocol
 * @dev Handles user verification, transaction monitoring, and regulatory compliance
 */
contract ComplianceManager is AccessControl, Pausable, ReentrancyGuard {
    bytes32 public constant COMPLIANCE_ADMIN_ROLE =
        keccak256("COMPLIANCE_ADMIN_ROLE");
    bytes32 public constant KYC_OFFICER_ROLE = keccak256("KYC_OFFICER_ROLE");
    bytes32 public constant AML_OFFICER_ROLE = keccak256("AML_OFFICER_ROLE");
    bytes32 public constant REGULATORY_ROLE = keccak256("REGULATORY_ROLE");

    // Compliance levels
    enum ComplianceLevel {
        NONE, // No verification
        BASIC, // Basic KYC
        ENHANCED, // Enhanced due diligence
        INSTITUTIONAL // Institutional verification
    }

    // Risk levels
    enum RiskLevel {
        LOW,
        MEDIUM,
        HIGH,
        CRITICAL
    }

    // Transaction status
    enum TransactionStatus {
        PENDING,
        APPROVED,
        REJECTED,
        FLAGGED,
        UNDER_REVIEW
    }

    // User compliance data
    struct UserCompliance {
        ComplianceLevel level;
        RiskLevel riskLevel;
        bool isVerified;
        bool isBlacklisted;
        bool isSanctioned;
        uint256 verificationDate;
        uint256 lastReviewDate;
        uint256 dailyTransactionLimit;
        uint256 monthlyTransactionLimit;
        uint256 dailyTransactionVolume;
        uint256 monthlyTransactionVolume;
        uint256 lastTransactionDate;
        string jurisdiction;
        bytes32 kycHash;
        address verifiedBy;
    }

    // Transaction monitoring data
    struct TransactionMonitoring {
        uint256 transactionId;
        address user;
        address asset;
        uint256 amount;
        uint256 timestamp;
        TransactionStatus status;
        RiskLevel riskLevel;
        string transactionType;
        string flagReason;
        address reviewedBy;
        uint256 reviewDate;
    }

    // Regulatory reporting data
    struct RegulatoryReport {
        uint256 reportId;
        uint256 startDate;
        uint256 endDate;
        uint256 totalTransactions;
        uint256 flaggedTransactions;
        uint256 totalVolume;
        string reportType;
        string jurisdiction;
        bytes32 reportHash;
        bool isSubmitted;
        uint256 submissionDate;
    }

    // Sanctions list entry
    struct SanctionEntry {
        address entity;
        string reason;
        uint256 addedDate;
        bool isActive;
        address addedBy;
    }

    // State variables
    IHedVaultCore public immutable hedVaultCore;

    mapping(address => UserCompliance) public userCompliance;
    mapping(uint256 => TransactionMonitoring) public transactionMonitoring;
    mapping(uint256 => RegulatoryReport) public regulatoryReports;
    mapping(address => SanctionEntry) public sanctionsList;
    mapping(string => bool) public supportedJurisdictions;
    mapping(address => bool) public authorizedReporters;

    uint256 public nextTransactionId;
    uint256 public nextReportId;

    // Compliance thresholds
    uint256 public constant MAX_DAILY_TRANSACTION_BASIC = 10000e18; // $10,000
    uint256 public constant MAX_MONTHLY_TRANSACTION_BASIC = 50000e18; // $50,000
    uint256 public constant MAX_DAILY_TRANSACTION_ENHANCED = 100000e18; // $100,000
    uint256 public constant MAX_MONTHLY_TRANSACTION_ENHANCED = 1000000e18; // $1,000,000
    uint256 public constant SUSPICIOUS_TRANSACTION_THRESHOLD = 10000e18; // $10,000
    uint256 public constant HIGH_RISK_THRESHOLD = 50000e18; // $50,000

    // Events
    event UserVerified(
        address indexed user,
        ComplianceLevel level,
        address indexed verifiedBy
    );
    event UserBlacklisted(
        address indexed user,
        string reason,
        address indexed addedBy
    );
    event UserRemovedFromBlacklist(
        address indexed user,
        address indexed removedBy
    );
    event TransactionFlagged(
        uint256 indexed transactionId,
        address indexed user,
        string reason
    );
    event TransactionApproved(
        uint256 indexed transactionId,
        address indexed reviewedBy
    );
    event TransactionRejected(
        uint256 indexed transactionId,
        address indexed reviewedBy,
        string reason
    );
    event RegulatoryReportGenerated(
        uint256 indexed reportId,
        string reportType,
        string jurisdiction
    );
    event SanctionAdded(
        address indexed entity,
        string reason,
        address indexed addedBy
    );
    event SanctionRemoved(address indexed entity, address indexed removedBy);
    event ComplianceLevelUpdated(
        address indexed user,
        ComplianceLevel oldLevel,
        ComplianceLevel newLevel
    );
    event JurisdictionAdded(string jurisdiction, address indexed addedBy);
    event JurisdictionRemoved(string jurisdiction, address indexed removedBy);

    constructor(address _hedVaultCore, address _admin) {
        if (_hedVaultCore == address(0) || _admin == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        hedVaultCore = IHedVaultCore(_hedVaultCore);

        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(COMPLIANCE_ADMIN_ROLE, _admin);
        _grantRole(KYC_OFFICER_ROLE, _admin);
        _grantRole(AML_OFFICER_ROLE, _admin);
        _grantRole(REGULATORY_ROLE, _admin);

        // Add default supported jurisdictions
        supportedJurisdictions["US"] = true;
        supportedJurisdictions["EU"] = true;
        supportedJurisdictions["UK"] = true;
        supportedJurisdictions["CA"] = true;
        supportedJurisdictions["AU"] = true;

        nextTransactionId = 1;
        nextReportId = 1;
    }

    // User verification functions

    /**
     * @notice Verify a user with KYC
     * @param user User address
     * @param level Compliance level
     * @param jurisdiction User's jurisdiction
     * @param kycHash Hash of KYC documents
     */
    function verifyUser(
        address user,
        ComplianceLevel level,
        string calldata jurisdiction,
        bytes32 kycHash
    ) external onlyRole(KYC_OFFICER_ROLE) whenNotPaused {
        if (user == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        if (!supportedJurisdictions[jurisdiction]) {
            revert HedVaultErrors.InvalidConfiguration(jurisdiction);
        }

        if (sanctionsList[user].isActive) {
            revert HedVaultErrors.UnauthorizedAccess(user, "sanctioned entity");
        }

        UserCompliance storage compliance = userCompliance[user];
        ComplianceLevel oldLevel = compliance.level;

        compliance.level = level;
        compliance.isVerified = true;
        compliance.verificationDate = block.timestamp;
        compliance.lastReviewDate = block.timestamp;
        compliance.jurisdiction = jurisdiction;
        compliance.kycHash = kycHash;
        compliance.verifiedBy = msg.sender;

        // Set transaction limits based on compliance level
        if (level == ComplianceLevel.BASIC) {
            compliance.dailyTransactionLimit = MAX_DAILY_TRANSACTION_BASIC;
            compliance.monthlyTransactionLimit = MAX_MONTHLY_TRANSACTION_BASIC;
            compliance.riskLevel = RiskLevel.LOW;
        } else if (
            level == ComplianceLevel.ENHANCED ||
            level == ComplianceLevel.INSTITUTIONAL
        ) {
            compliance.dailyTransactionLimit = MAX_DAILY_TRANSACTION_ENHANCED;
            compliance
                .monthlyTransactionLimit = MAX_MONTHLY_TRANSACTION_ENHANCED;
            compliance.riskLevel = RiskLevel.LOW;
        }

        emit UserVerified(user, level, msg.sender);
        emit ComplianceLevelUpdated(user, oldLevel, level);
    }

    /**
     * @notice Add user to blacklist
     * @param user User address
     * @param reason Reason for blacklisting
     */
    function blacklistUser(
        address user,
        string calldata reason
    ) external onlyRole(AML_OFFICER_ROLE) whenNotPaused {
        if (user == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        userCompliance[user].isBlacklisted = true;
        userCompliance[user].isVerified = false;

        emit UserBlacklisted(user, reason, msg.sender);
    }

    /**
     * @notice Remove user from blacklist
     * @param user User address
     */
    function removeFromBlacklist(
        address user
    ) external onlyRole(COMPLIANCE_ADMIN_ROLE) whenNotPaused {
        if (user == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        userCompliance[user].isBlacklisted = false;

        emit UserRemovedFromBlacklist(user, msg.sender);
    }

    /**
     * @notice Update user's risk level
     * @param user User address
     * @param riskLevel New risk level
     */
    function updateUserRiskLevel(
        address user,
        RiskLevel riskLevel
    ) external onlyRole(AML_OFFICER_ROLE) whenNotPaused {
        if (user == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        userCompliance[user].riskLevel = riskLevel;
        userCompliance[user].lastReviewDate = block.timestamp;
    }

    // Transaction monitoring functions

    /**
     * @notice Monitor a transaction for compliance
     * @param user User address
     * @param asset Asset address
     * @param amount Transaction amount
     * @param transactionType Type of transaction
     * @return isApproved Whether transaction is approved
     * @return transactionId Transaction monitoring ID
     */
    function monitorTransaction(
        address user,
        address asset,
        uint256 amount,
        string calldata transactionType
    ) external whenNotPaused returns (bool isApproved, uint256 transactionId) {
        if (user == address(0) || asset == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        UserCompliance storage compliance = userCompliance[user];

        // Check if user is blacklisted or sanctioned
        if (compliance.isBlacklisted || compliance.isSanctioned) {
            revert HedVaultErrors.UnauthorizedAccess(
                user,
                "blacklisted or sanctioned"
            );
        }

        // Check if user is verified
        if (!compliance.isVerified) {
            revert HedVaultErrors.UnauthorizedAccess(user, "not verified");
        }

        transactionId = nextTransactionId++;

        TransactionMonitoring storage monitoring = transactionMonitoring[
            transactionId
        ];
        monitoring.transactionId = transactionId;
        monitoring.user = user;
        monitoring.asset = asset;
        monitoring.amount = amount;
        monitoring.timestamp = block.timestamp;
        monitoring.transactionType = transactionType;

        // Determine risk level and status
        RiskLevel txRiskLevel = _assessTransactionRisk(
            user,
            amount,
            transactionType
        );
        monitoring.riskLevel = txRiskLevel;

        // Check transaction limits
        bool exceedsLimits = _checkTransactionLimits(user, amount);

        if (txRiskLevel == RiskLevel.CRITICAL || exceedsLimits) {
            monitoring.status = TransactionStatus.FLAGGED;
            monitoring.flagReason = exceedsLimits
                ? "Exceeds transaction limits"
                : "High risk transaction";
            isApproved = false;

            emit TransactionFlagged(transactionId, user, monitoring.flagReason);
        } else if (txRiskLevel == RiskLevel.HIGH) {
            monitoring.status = TransactionStatus.UNDER_REVIEW;
            isApproved = false;
        } else {
            monitoring.status = TransactionStatus.APPROVED;
            isApproved = true;

            // Update user's transaction volume
            _updateTransactionVolume(user, amount);
        }

        return (isApproved, transactionId);
    }

    /**
     * @notice Approve a flagged transaction
     * @param transactionId Transaction ID
     */
    function approveTransaction(
        uint256 transactionId
    ) external onlyRole(AML_OFFICER_ROLE) whenNotPaused {
        TransactionMonitoring storage monitoring = transactionMonitoring[
            transactionId
        ];

        if (monitoring.transactionId == 0) {
            revert HedVaultErrors.InvalidConfiguration("Transaction not found");
        }

        if (monitoring.status == TransactionStatus.APPROVED) {
            revert HedVaultErrors.InvalidConfiguration(
                "Transaction already approved"
            );
        }

        monitoring.status = TransactionStatus.APPROVED;
        monitoring.reviewedBy = msg.sender;
        monitoring.reviewDate = block.timestamp;

        // Update user's transaction volume
        _updateTransactionVolume(monitoring.user, monitoring.amount);

        emit TransactionApproved(transactionId, msg.sender);
    }

    /**
     * @notice Reject a flagged transaction
     * @param transactionId Transaction ID
     * @param reason Rejection reason
     */
    function rejectTransaction(
        uint256 transactionId,
        string calldata reason
    ) external onlyRole(AML_OFFICER_ROLE) whenNotPaused {
        TransactionMonitoring storage monitoring = transactionMonitoring[
            transactionId
        ];

        if (monitoring.transactionId == 0) {
            revert HedVaultErrors.InvalidConfiguration("Transaction not found");
        }

        monitoring.status = TransactionStatus.REJECTED;
        monitoring.flagReason = reason;
        monitoring.reviewedBy = msg.sender;
        monitoring.reviewDate = block.timestamp;

        emit TransactionRejected(transactionId, msg.sender, reason);
    }

    // Sanctions management

    /**
     * @notice Add entity to sanctions list
     * @param entity Entity address
     * @param reason Sanction reason
     */
    function addToSanctionsList(
        address entity,
        string calldata reason
    ) external onlyRole(REGULATORY_ROLE) whenNotPaused {
        if (entity == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        sanctionsList[entity] = SanctionEntry({
            entity: entity,
            reason: reason,
            addedDate: block.timestamp,
            isActive: true,
            addedBy: msg.sender
        });

        // Update user compliance if they exist
        if (userCompliance[entity].isVerified) {
            userCompliance[entity].isSanctioned = true;
            userCompliance[entity].isVerified = false;
        }

        emit SanctionAdded(entity, reason, msg.sender);
    }

    /**
     * @notice Remove entity from sanctions list
     * @param entity Entity address
     */
    function removeFromSanctionsList(
        address entity
    ) external onlyRole(REGULATORY_ROLE) whenNotPaused {
        if (entity == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        sanctionsList[entity].isActive = false;

        // Update user compliance
        if (userCompliance[entity].level != ComplianceLevel.NONE) {
            userCompliance[entity].isSanctioned = false;
        }

        emit SanctionRemoved(entity, msg.sender);
    }

    // Regulatory reporting

    /**
     * @notice Generate regulatory report
     * @param startDate Report start date
     * @param endDate Report end date
     * @param reportType Type of report
     * @param jurisdiction Jurisdiction for report
     * @return reportId Generated report ID
     */
    function generateRegulatoryReport(
        uint256 startDate,
        uint256 endDate,
        string calldata reportType,
        string calldata jurisdiction
    )
        external
        onlyRole(REGULATORY_ROLE)
        whenNotPaused
        returns (uint256 reportId)
    {
        if (startDate >= endDate) {
            revert HedVaultErrors.InvalidConfiguration("Invalid date range");
        }

        if (!supportedJurisdictions[jurisdiction]) {
            revert HedVaultErrors.InvalidConfiguration(jurisdiction);
        }

        reportId = nextReportId++;

        // Calculate report statistics
        (
            uint256 totalTx,
            uint256 flaggedTx,
            uint256 totalVolume
        ) = _calculateReportStats(startDate, endDate, jurisdiction);

        RegulatoryReport storage report = regulatoryReports[reportId];
        report.reportId = reportId;
        report.startDate = startDate;
        report.endDate = endDate;
        report.totalTransactions = totalTx;
        report.flaggedTransactions = flaggedTx;
        report.totalVolume = totalVolume;
        report.reportType = reportType;
        report.jurisdiction = jurisdiction;
        report.reportHash = keccak256(
            abi.encodePacked(
                reportId,
                startDate,
                endDate,
                totalTx,
                flaggedTx,
                totalVolume
            )
        );
        report.isSubmitted = false;

        emit RegulatoryReportGenerated(reportId, reportType, jurisdiction);

        return reportId;
    }

    /**
     * @notice Submit regulatory report
     * @param reportId Report ID
     */
    function submitRegulatoryReport(
        uint256 reportId
    ) external onlyRole(REGULATORY_ROLE) whenNotPaused {
        RegulatoryReport storage report = regulatoryReports[reportId];

        if (report.reportId == 0) {
            revert HedVaultErrors.InvalidConfiguration("Report not found");
        }

        if (report.isSubmitted) {
            revert HedVaultErrors.InvalidConfiguration(
                "Report already submitted"
            );
        }

        report.isSubmitted = true;
        report.submissionDate = block.timestamp;
    }

    // Administrative functions

    /**
     * @notice Add supported jurisdiction
     * @param jurisdiction Jurisdiction code
     */
    function addJurisdiction(
        string calldata jurisdiction
    ) external onlyRole(COMPLIANCE_ADMIN_ROLE) {
        supportedJurisdictions[jurisdiction] = true;
        emit JurisdictionAdded(jurisdiction, msg.sender);
    }

    /**
     * @notice Remove supported jurisdiction
     * @param jurisdiction Jurisdiction code
     */
    function removeJurisdiction(
        string calldata jurisdiction
    ) external onlyRole(COMPLIANCE_ADMIN_ROLE) {
        supportedJurisdictions[jurisdiction] = false;
        emit JurisdictionRemoved(jurisdiction, msg.sender);
    }

    /**
     * @notice Authorize reporter
     * @param reporter Reporter address
     */
    function authorizeReporter(
        address reporter
    ) external onlyRole(COMPLIANCE_ADMIN_ROLE) {
        if (reporter == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }
        authorizedReporters[reporter] = true;
    }

    /**
     * @notice Revoke reporter authorization
     * @param reporter Reporter address
     */
    function revokeReporter(
        address reporter
    ) external onlyRole(COMPLIANCE_ADMIN_ROLE) {
        authorizedReporters[reporter] = false;
    }

    /**
     * @notice Pause the contract
     */
    function pause() external onlyRole(COMPLIANCE_ADMIN_ROLE) {
        _pause();
    }

    /**
     * @notice Unpause the contract
     */
    function unpause() external onlyRole(COMPLIANCE_ADMIN_ROLE) {
        _unpause();
    }

    // View functions

    /**
     * @notice Check if user is compliant for transaction
     * @param user User address
     * @param amount Transaction amount
     * @return isCompliant Whether user is compliant
     */
    function isUserCompliant(
        address user,
        uint256 amount
    ) external view returns (bool isCompliant) {
        UserCompliance memory compliance = userCompliance[user];

        if (
            !compliance.isVerified ||
            compliance.isBlacklisted ||
            compliance.isSanctioned
        ) {
            return false;
        }

        return !_checkTransactionLimits(user, amount);
    }

    /**
     * @notice Get user compliance data
     * @param user User address
     * @return compliance User compliance data
     */
    function getUserCompliance(
        address user
    ) external view returns (UserCompliance memory compliance) {
        return userCompliance[user];
    }

    /**
     * @notice Get transaction monitoring data
     * @param transactionId Transaction ID
     * @return monitoring Transaction monitoring data
     */
    function getTransactionMonitoring(
        uint256 transactionId
    ) external view returns (TransactionMonitoring memory monitoring) {
        return transactionMonitoring[transactionId];
    }

    /**
     * @notice Get regulatory report
     * @param reportId Report ID
     * @return report Regulatory report data
     */
    function getRegulatoryReport(
        uint256 reportId
    ) external view returns (RegulatoryReport memory report) {
        return regulatoryReports[reportId];
    }

    /**
     * @notice Check if entity is sanctioned
     * @param entity Entity address
     * @return sanctioned Whether entity is sanctioned
     */
    function isSanctioned(
        address entity
    ) external view returns (bool sanctioned) {
        return sanctionsList[entity].isActive;
    }

    /**
     * @notice Get user's remaining daily limit
     * @param user User address
     * @return remainingLimit Remaining daily transaction limit
     */
    function getRemainingDailyLimit(
        address user
    ) external view returns (uint256 remainingLimit) {
        UserCompliance memory compliance = userCompliance[user];

        // Reset daily volume if it's a new day
        if (_isNewDay(compliance.lastTransactionDate)) {
            return compliance.dailyTransactionLimit;
        }

        if (
            compliance.dailyTransactionVolume >=
            compliance.dailyTransactionLimit
        ) {
            return 0;
        }

        return
            compliance.dailyTransactionLimit -
            compliance.dailyTransactionVolume;
    }

    // Internal functions

    /**
     * @notice Assess transaction risk level
     * @param user User address
     * @param amount Transaction amount
     * @param transactionType Transaction type
     * @return riskLevel Risk level
     */
    function _assessTransactionRisk(
        address user,
        uint256 amount,
        string memory transactionType
    ) internal view returns (RiskLevel riskLevel) {
        UserCompliance memory compliance = userCompliance[user];

        // Base risk from user's risk level
        riskLevel = compliance.riskLevel;

        // Increase risk based on amount
        if (amount >= HIGH_RISK_THRESHOLD) {
            if (riskLevel < RiskLevel.CRITICAL) {
                riskLevel = RiskLevel.CRITICAL;
            }
        } else if (amount >= SUSPICIOUS_TRANSACTION_THRESHOLD) {
            if (riskLevel < RiskLevel.HIGH) {
                riskLevel = RiskLevel.HIGH;
            }
        }

        // Increase risk for certain transaction types
        if (
            keccak256(bytes(transactionType)) ==
            keccak256(bytes("CROSS_BORDER")) ||
            keccak256(bytes(transactionType)) ==
            keccak256(bytes("CASH_EQUIVALENT"))
        ) {
            if (riskLevel < RiskLevel.HIGH) {
                riskLevel = RiskLevel.HIGH;
            }
        }

        return riskLevel;
    }

    /**
     * @notice Check if transaction exceeds limits
     * @param user User address
     * @param amount Transaction amount
     * @return exceedsLimits Whether transaction exceeds limits
     */
    function _checkTransactionLimits(
        address user,
        uint256 amount
    ) internal view returns (bool exceedsLimits) {
        UserCompliance memory compliance = userCompliance[user];

        // Check daily limit
        uint256 dailyVolume = compliance.dailyTransactionVolume;
        if (_isNewDay(compliance.lastTransactionDate)) {
            dailyVolume = 0;
        }

        if (dailyVolume + amount > compliance.dailyTransactionLimit) {
            return true;
        }

        // Check monthly limit
        uint256 monthlyVolume = compliance.monthlyTransactionVolume;
        if (_isNewMonth(compliance.lastTransactionDate)) {
            monthlyVolume = 0;
        }

        if (monthlyVolume + amount > compliance.monthlyTransactionLimit) {
            return true;
        }

        return false;
    }

    /**
     * @notice Update user's transaction volume
     * @param user User address
     * @param amount Transaction amount
     */
    function _updateTransactionVolume(address user, uint256 amount) internal {
        UserCompliance storage compliance = userCompliance[user];

        // Reset volumes if new period
        if (_isNewDay(compliance.lastTransactionDate)) {
            compliance.dailyTransactionVolume = 0;
        }

        if (_isNewMonth(compliance.lastTransactionDate)) {
            compliance.monthlyTransactionVolume = 0;
        }

        compliance.dailyTransactionVolume += amount;
        compliance.monthlyTransactionVolume += amount;
        compliance.lastTransactionDate = block.timestamp;
    }

    /**
     * @notice Calculate report statistics
     * @param startDate Start date
     * @param endDate End date
     * @param jurisdiction Jurisdiction
     * @return totalTx Total transactions
     * @return flaggedTx Flagged transactions
     * @return totalVolume Total volume
     */
    function _calculateReportStats(
        uint256 startDate,
        uint256 endDate,
        string memory jurisdiction
    )
        internal
        view
        returns (uint256 totalTx, uint256 flaggedTx, uint256 totalVolume)
    {
        // This is a simplified implementation
        // In a real system, this would iterate through all transactions in the period
        // and filter by jurisdiction

        for (uint256 i = 1; i < nextTransactionId; i++) {
            TransactionMonitoring memory monitoring = transactionMonitoring[i];

            if (
                monitoring.timestamp >= startDate &&
                monitoring.timestamp <= endDate
            ) {
                UserCompliance memory compliance = userCompliance[
                    monitoring.user
                ];

                if (
                    keccak256(bytes(compliance.jurisdiction)) ==
                    keccak256(bytes(jurisdiction))
                ) {
                    totalTx++;
                    totalVolume += monitoring.amount;

                    if (
                        monitoring.status == TransactionStatus.FLAGGED ||
                        monitoring.status == TransactionStatus.REJECTED
                    ) {
                        flaggedTx++;
                    }
                }
            }
        }

        return (totalTx, flaggedTx, totalVolume);
    }

    /**
     * @notice Check if it's a new day
     * @param lastDate Last transaction date
     * @return isNewDay Whether it's a new day
     */
    function _isNewDay(uint256 lastDate) internal view returns (bool isNewDay) {
        return (block.timestamp / 1 days) > (lastDate / 1 days);
    }

    /**
     * @notice Check if it's a new month
     * @param lastDate Last transaction date
     * @return isNewMonth Whether it's a new month
     */
    function _isNewMonth(
        uint256 lastDate
    ) internal view returns (bool isNewMonth) {
        return (block.timestamp / 30 days) > (lastDate / 30 days);
    }

    // Regulatory hooks

    /**
     * @notice Pre-transaction hook for compliance checks
     * @param user User address
     * @param amount Transaction amount
     * @param transactionType Transaction type
     * @return isAllowed Whether transaction is allowed
     */
    function preTransactionHook(
        address user,
        address, // asset - unused but required for interface
        uint256 amount,
        string calldata transactionType
    ) external view returns (bool isAllowed) {
        UserCompliance memory compliance = userCompliance[user];

        // Basic compliance checks
        if (
            !compliance.isVerified ||
            compliance.isBlacklisted ||
            compliance.isSanctioned
        ) {
            return false;
        }

        // Check transaction limits
        if (_checkTransactionLimits(user, amount)) {
            return false;
        }

        // Check risk level
        RiskLevel riskLevel = _assessTransactionRisk(
            user,
            amount,
            transactionType
        );
        if (riskLevel == RiskLevel.CRITICAL) {
            return false;
        }

        return true;
    }

    /**
     * @notice Post-transaction hook for monitoring
     * @param user User address
     * @param asset Asset address
     * @param amount Transaction amount
     * @param transactionType Transaction type
     * @param success Whether transaction was successful
     */
    function postTransactionHook(
        address user,
        address asset,
        uint256 amount,
        string calldata transactionType,
        bool success
    ) external {
        if (success) {
            // Monitor the transaction
            this.monitorTransaction(user, asset, amount, transactionType);
        }
    }
}

