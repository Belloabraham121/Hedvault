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

// src/interfaces/IChainlink.sol

/**
 * @title Chainlink Interfaces
 * @notice Common Chainlink interfaces used across the protocol
 */

// Chainlink Price Feed Interface
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

// src/PriceOracle.sol

/**
 * @title PriceOracle
 * @notice Manages price feeds for RWA assets using Chainlink and custom oracles
 * @dev Aggregates prices from multiple sources with fallback mechanisms
 */
contract PriceOracle is AccessControl, ReentrancyGuard, Pausable {
    // Roles
    bytes32 public constant ORACLE_ADMIN_ROLE = keccak256("ORACLE_ADMIN_ROLE");
    bytes32 public constant PRICE_UPDATER_ROLE =
        keccak256("PRICE_UPDATER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");

    // Core protocol reference
    IHedVaultCore public immutable hedVaultCore;

    // Price feed configurations
    struct PriceFeedConfig {
        address chainlinkFeed; // Chainlink aggregator address
        address customOracle; // Custom oracle address
        uint256 heartbeat; // Maximum time between updates (seconds)
        uint8 decimals; // Price decimals
        bool isActive; // Whether feed is active
        uint256 minPrice; // Minimum acceptable price
        uint256 maxPrice; // Maximum acceptable price
        uint256 maxPriceDeviation; // Maximum deviation from previous price (basis points)
    }

    // Asset price data
    struct AssetPrice {
        uint256 price; // Current price
        uint256 timestamp; // Last update timestamp
        uint256 confidence; // Price confidence level (0-10000 basis points)
        address source; // Price source address
        uint256 roundId; // Chainlink round ID (if applicable)
    }

    // Emergency price data (manual override)
    struct EmergencyPrice {
        uint256 price;
        uint256 timestamp;
        address setter;
        bool isActive;
    }

    // State variables
    mapping(address => PriceFeedConfig) public priceFeedConfigs;
    mapping(address => AssetPrice) public assetPrices;
    mapping(address => EmergencyPrice) public emergencyPrices;
    mapping(address => bool) public supportedAssets;

    address[] public assetList;

    // Oracle settings
    uint256 public constant MAX_PRICE_AGE = 3600; // 1 hour
    uint256 public constant MIN_CONFIDENCE = 8000; // 80%
    uint256 public constant MAX_DEVIATION = 1000; // 10%

    // Events
    event PriceFeedConfigured(
        address indexed asset,
        address chainlinkFeed,
        address customOracle,
        uint256 heartbeat
    );
    event PriceUpdated(
        address indexed asset,
        uint256 price,
        uint256 timestamp,
        address source,
        uint256 confidence
    );
    event EmergencyPriceSet(
        address indexed asset,
        uint256 price,
        address setter
    );
    event AssetAdded(address indexed asset);
    event AssetRemoved(address indexed asset);

    modifier onlyValidAsset(address asset) {
        if (!supportedAssets[asset]) {
            revert HedVaultErrors.OracleNotFound(asset);
        }
        _;
    }

    modifier priceNotStale(address asset) {
        if (block.timestamp - assetPrices[asset].timestamp > MAX_PRICE_AGE) {
            revert HedVaultErrors.StalePriceData(
                asset,
                assetPrices[asset].timestamp
            );
        }
        _;
    }

    constructor(address _hedVaultCore) {
        if (_hedVaultCore == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        hedVaultCore = IHedVaultCore(_hedVaultCore);

        // Set up roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ORACLE_ADMIN_ROLE, msg.sender);
        _grantRole(PRICE_UPDATER_ROLE, msg.sender);
        _grantRole(EMERGENCY_ROLE, msg.sender);
    }

    /**
     * @notice Configure price feed for an asset
     * @param asset Asset address
     * @param chainlinkFeed Chainlink aggregator address
     * @param customOracle Custom oracle address
     * @param heartbeat Maximum time between updates
     * @param decimals Price decimals
     * @param minPrice Minimum acceptable price
     * @param maxPrice Maximum acceptable price
     */
    function configurePriceFeed(
        address asset,
        address chainlinkFeed,
        address customOracle,
        uint256 heartbeat,
        uint8 decimals,
        uint256 minPrice,
        uint256 maxPrice
    ) external onlyRole(ORACLE_ADMIN_ROLE) {
        if (asset == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }
        if (chainlinkFeed == address(0) && customOracle == address(0)) {
            revert HedVaultErrors.InvalidConfiguration(
                "At least one oracle required"
            );
        }
        if (minPrice >= maxPrice) {
            revert HedVaultErrors.InvalidConfiguration("Invalid price range");
        }

        priceFeedConfigs[asset] = PriceFeedConfig({
            chainlinkFeed: chainlinkFeed,
            customOracle: customOracle,
            heartbeat: heartbeat,
            decimals: decimals,
            isActive: true,
            minPrice: minPrice,
            maxPrice: maxPrice,
            maxPriceDeviation: MAX_DEVIATION
        });

        if (!supportedAssets[asset]) {
            supportedAssets[asset] = true;
            assetList.push(asset);
            emit AssetAdded(asset);
        }

        emit PriceFeedConfigured(asset, chainlinkFeed, customOracle, heartbeat);
    }

    /**
     * @notice Update price for an asset
     * @param asset Asset address
     * @param price New price
     * @param confidence Price confidence level
     */
    function updatePrice(
        address asset,
        uint256 price,
        uint256 confidence
    ) external onlyRole(PRICE_UPDATER_ROLE) onlyValidAsset(asset) {
        _validateAndUpdatePrice(asset, price, confidence, msg.sender, 0);
    }

    /**
     * @notice Update prices from Chainlink feeds
     * @param assets Array of asset addresses
     */
    function updatePricesFromChainlink(
        address[] calldata assets
    ) external onlyRole(PRICE_UPDATER_ROLE) {
        for (uint256 i = 0; i < assets.length; i++) {
            _updatePriceFromChainlink(assets[i]);
        }
    }

    /**
     * @notice Set emergency price (manual override)
     * @param asset Asset address
     * @param price Emergency price
     */
    function setEmergencyPrice(
        address asset,
        uint256 price
    ) external onlyRole(EMERGENCY_ROLE) onlyValidAsset(asset) {
        if (price == 0) {
            revert HedVaultErrors.ZeroAmount();
        }

        emergencyPrices[asset] = EmergencyPrice({
            price: price,
            timestamp: block.timestamp,
            setter: msg.sender,
            isActive: true
        });

        emit EmergencyPriceSet(asset, price, msg.sender);
    }

    /**
     * @notice Clear emergency price
     * @param asset Asset address
     */
    function clearEmergencyPrice(
        address asset
    ) external onlyRole(EMERGENCY_ROLE) onlyValidAsset(asset) {
        emergencyPrices[asset].isActive = false;
    }

    /**
     * @notice Get current price for an asset
     * @param asset Asset address
     * @return price Current price
     * @return timestamp Last update timestamp
     * @return confidence Price confidence level
     */
    function getPrice(
        address asset
    )
        external
        view
        onlyValidAsset(asset)
        returns (uint256 price, uint256 timestamp, uint256 confidence)
    {
        // Check for emergency price first
        if (emergencyPrices[asset].isActive) {
            return (
                emergencyPrices[asset].price,
                emergencyPrices[asset].timestamp,
                10000 // 100% confidence for emergency prices
            );
        }

        AssetPrice memory assetPrice = assetPrices[asset];

        // Check if price is stale
        if (block.timestamp - assetPrice.timestamp > MAX_PRICE_AGE) {
            revert HedVaultErrors.StalePriceData(asset, assetPrice.timestamp);
        }

        return (assetPrice.price, assetPrice.timestamp, assetPrice.confidence);
    }

    /**
     * @notice Get price with staleness check disabled (for emergency situations)
     * @param asset Asset address
     * @return price Current price
     * @return timestamp Last update timestamp
     * @return confidence Price confidence level
     */
    function getPriceUnsafe(
        address asset
    )
        external
        view
        onlyValidAsset(asset)
        returns (uint256 price, uint256 timestamp, uint256 confidence)
    {
        // Check for emergency price first
        if (emergencyPrices[asset].isActive) {
            return (
                emergencyPrices[asset].price,
                emergencyPrices[asset].timestamp,
                10000
            );
        }

        AssetPrice memory assetPrice = assetPrices[asset];
        return (assetPrice.price, assetPrice.timestamp, assetPrice.confidence);
    }

    /**
     * @notice Get prices for multiple assets
     * @param assets Array of asset addresses
     * @return prices Array of prices
     * @return timestamps Array of timestamps
     * @return confidences Array of confidence levels
     */
    function getPrices(
        address[] calldata assets
    )
        external
        view
        returns (
            uint256[] memory prices,
            uint256[] memory timestamps,
            uint256[] memory confidences
        )
    {
        prices = new uint256[](assets.length);
        timestamps = new uint256[](assets.length);
        confidences = new uint256[](assets.length);

        for (uint256 i = 0; i < assets.length; i++) {
            (prices[i], timestamps[i], confidences[i]) = this.getPrice(
                assets[i]
            );
        }
    }

    /**
     * @notice Check if asset price is fresh
     * @param asset Asset address
     * @return isFresh True if price is fresh
     */
    function isPriceFresh(address asset) external view returns (bool) {
        if (!supportedAssets[asset]) {
            return false;
        }

        if (emergencyPrices[asset].isActive) {
            return true;
        }

        return block.timestamp - assetPrices[asset].timestamp <= MAX_PRICE_AGE;
    }

    /**
     * @notice Get all supported assets
     * @return assets Array of supported asset addresses
     */
    function getSupportedAssets() external view returns (address[] memory) {
        return assetList;
    }

    /**
     * @notice Remove asset support
     * @param asset Asset address
     */
    function removeAsset(address asset) external onlyRole(ORACLE_ADMIN_ROLE) {
        if (!supportedAssets[asset]) {
            revert HedVaultErrors.OracleNotFound(asset);
        }

        supportedAssets[asset] = false;
        priceFeedConfigs[asset].isActive = false;

        // Remove from asset list
        for (uint256 i = 0; i < assetList.length; i++) {
            if (assetList[i] == asset) {
                assetList[i] = assetList[assetList.length - 1];
                assetList.pop();
                break;
            }
        }

        emit AssetRemoved(asset);
    }

    /**
     * @notice Pause the oracle
     */
    function pause() external onlyRole(EMERGENCY_ROLE) {
        _pause();
    }

    /**
     * @notice Unpause the oracle
     */
    function unpause() external onlyRole(EMERGENCY_ROLE) {
        _unpause();
    }

    // Internal functions
    function _updatePriceFromChainlink(address asset) internal {
        PriceFeedConfig memory config = priceFeedConfigs[asset];

        if (!config.isActive || config.chainlinkFeed == address(0)) {
            return;
        }

        try
            AggregatorV3Interface(config.chainlinkFeed).latestRoundData()
        returns (
            uint80 roundId,
            int256 answer,
            uint256,
            uint256 updatedAt,
            uint80
        ) {
            if (answer <= 0) {
                return; // Invalid price
            }

            uint256 price = uint256(answer);

            // Adjust decimals if necessary
            if (
                config.decimals !=
                AggregatorV3Interface(config.chainlinkFeed).decimals()
            ) {
                uint8 feedDecimals = AggregatorV3Interface(config.chainlinkFeed)
                    .decimals();
                if (config.decimals > feedDecimals) {
                    price = price * (10 ** (config.decimals - feedDecimals));
                } else {
                    price = price / (10 ** (feedDecimals - config.decimals));
                }
            }

            // Calculate confidence based on data freshness
            uint256 confidence = _calculateConfidence(
                updatedAt,
                config.heartbeat
            );

            _validateAndUpdatePrice(
                asset,
                price,
                confidence,
                config.chainlinkFeed,
                roundId
            );
        } catch {
            // Chainlink feed failed, could try custom oracle as fallback
            return;
        }
    }

    function _validateAndUpdatePrice(
        address asset,
        uint256 price,
        uint256 confidence,
        address source,
        uint256 roundId
    ) internal {
        PriceFeedConfig memory config = priceFeedConfigs[asset];

        // Validate price range
        if (price < config.minPrice || price > config.maxPrice) {
            revert HedVaultErrors.InvalidPriceData(asset, int256(price));
        }

        // Validate confidence
        if (confidence < MIN_CONFIDENCE) {
            revert HedVaultErrors.InvalidPriceData(asset, int256(confidence));
        }

        // Check price deviation from previous price
        AssetPrice memory currentPrice = assetPrices[asset];
        if (currentPrice.price > 0) {
            uint256 deviation = price > currentPrice.price
                ? ((price - currentPrice.price) * 10000) / currentPrice.price
                : ((currentPrice.price - price) * 10000) / currentPrice.price;

            if (deviation > config.maxPriceDeviation) {
                revert HedVaultErrors.PriceDeviationTooHigh(
                    deviation,
                    config.maxPriceDeviation
                );
            }
        }

        // Update price
        assetPrices[asset] = AssetPrice({
            price: price,
            timestamp: block.timestamp,
            confidence: confidence,
            source: source,
            roundId: roundId
        });

        emit PriceUpdated(asset, price, block.timestamp, source, confidence);
    }

    function _calculateConfidence(
        uint256 updatedAt,
        uint256 heartbeat
    ) internal view returns (uint256) {
        uint256 age = block.timestamp - updatedAt;

        if (age >= heartbeat) {
            return MIN_CONFIDENCE; // Minimum confidence for stale data
        }

        // Linear decay from 100% to MIN_CONFIDENCE based on age
        uint256 maxConfidence = 10000;
        uint256 confidenceDecay = ((maxConfidence - MIN_CONFIDENCE) * age) /
            heartbeat;

        return maxConfidence - confidenceDecay;
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

// src/Marketplace.sol

/**
 * @title Marketplace
 * @notice Decentralized marketplace for buying and selling RWA tokens
 * @dev Supports limit orders, market orders, and auction mechanisms
 */
contract Marketplace is AccessControl, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    // Roles
    bytes32 public constant MARKETPLACE_ADMIN_ROLE =
        keccak256("MARKETPLACE_ADMIN_ROLE");
    bytes32 public constant FEE_MANAGER_ROLE = keccak256("FEE_MANAGER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");

    // Core protocol references
    IHedVaultCore public immutable hedVaultCore;
    PriceOracle public immutable priceOracle;
    RewardsDistributor private rewardsDistributor;

    // Order structures
    struct Order {
        uint256 orderId;
        address maker;
        address asset;
        address paymentToken;
        uint256 amount;
        uint256 price;
        uint256 filled;
        uint256 expiry;
        uint8 orderType;
        uint8 status;
        uint256 createdAt;
        uint256 fee;
    }

    struct Trade {
        uint256 tradeId;
        uint256 buyOrderId;
        uint256 sellOrderId;
        address buyer;
        address seller;
        address asset;
        uint256 amount;
        uint256 price;
        uint256 timestamp;
        uint256 buyerFee;
        uint256 sellerFee;
    }

    struct MarketData {
        address asset;
        uint256 lastPrice;
        uint256 volume24h;
        uint256 high24h;
        uint256 low24h;
        uint256 priceChange24h;
        uint256 totalTrades;
        uint256 lastTradeTime;
    }

    struct AuctionData {
        uint256 auctionId;
        address seller;
        address asset;
        uint256 amount;
        uint256 startPrice;
        uint256 reservePrice;
        uint256 currentBid;
        address highestBidder;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
        bool isSettled;
    }

    // State variables
    mapping(uint256 => Order) public orders;
    mapping(address => uint256[]) public userOrders; // user => order IDs
    mapping(address => mapping(uint8 => uint256[])) public assetOrders; // asset => order type => order IDs
    mapping(uint256 => Trade) public trades;
    mapping(address => MarketData) public marketData;
    mapping(uint256 => AuctionData) public auctions;
    mapping(address => bool) public supportedAssets;
    mapping(address => bool) public supportedPaymentTokens;

    // Enhanced order book management
    mapping(address => mapping(uint256 => uint256[])) public priceToOrders; // asset => price => order IDs
    mapping(address => uint256[]) public activePrices; // asset => sorted price levels
    mapping(address => uint256) public bestBidPrice; // asset => best bid price
    mapping(address => uint256) public bestAskPrice; // asset => best ask price

    // User trading statistics
    mapping(address => uint256) public userTotalVolume;
    mapping(address => uint256) public userTotalTrades;
    mapping(address => uint256) public userLastActivity;

    // Asset trading statistics
    mapping(address => uint256) public assetTotalVolume;
    mapping(address => uint256) public assetTotalTrades;
    mapping(address => bool) public assetTradingEnabled;

    // Order matching and execution
    mapping(uint256 => bool) public orderInMatching; // Prevent reentrancy in matching
    mapping(address => uint256) public userActiveOrders; // Count of active orders per user

    uint256 public nextOrderId = 1;
    uint256 public nextTradeId = 1;
    uint256 public nextAuctionId = 1;

    // Fee structure (in basis points)
    uint256 public makerFee = 25; // 0.25%
    uint256 public takerFee = 50; // 0.5%
    uint256 public auctionFee = 250; // 2.5%
    uint256 public protocolFee = 10; // 0.1% additional protocol fee

    // Trading limits
    uint256 public minOrderSize = 1e18; // 1 token minimum
    uint256 public maxOrderSize = 1000000e18; // 1M tokens maximum
    uint256 public maxOrderDuration = 30 days;
    uint256 public maxActiveOrdersPerUser = 100; // Limit active orders per user
    uint256 public maxSlippageAllowed = 1000; // 10% max slippage

    // Protocol settings
    address public feeRecipient;
    uint256 public totalFeesCollected;
    uint256 public totalVolumeTraded;
    uint256 public totalTradesExecuted;
    bool public emergencyStop = false;

    // Events
    event OrderCreated(
        uint256 indexed orderId,
        address indexed maker,
        address indexed asset,
        uint8 orderType,
        uint256 amount,
        uint256 price
    );
    event OrderCancelled(uint256 indexed orderId, address indexed maker);
    event OrderFilled(
        uint256 indexed orderId,
        address indexed taker,
        uint256 amount,
        uint256 price
    );
    event TradeExecuted(
        uint256 indexed tradeId,
        uint256 indexed buyOrderId,
        uint256 indexed sellOrderId,
        address buyer,
        address seller,
        address asset,
        uint256 amount,
        uint256 price
    );
    event AuctionCreated(
        uint256 indexed auctionId,
        address indexed seller,
        address indexed asset,
        uint256 amount,
        uint256 startPrice,
        uint256 endTime
    );
    event BidPlaced(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 amount
    );
    event AuctionSettled(
        uint256 indexed auctionId,
        address indexed winner,
        uint256 finalPrice
    );
    event FeesUpdated(uint256 makerFee, uint256 takerFee, uint256 auctionFee);

    modifier validAsset(address asset) {
        if (!supportedAssets[asset]) {
            revert HedVaultErrors.TokenNotListed(asset);
        }
        if (!assetTradingEnabled[asset]) {
            revert HedVaultErrors.TradingPaused(asset);
        }
        _;
    }

    modifier validPaymentToken(address token) {
        if (!supportedPaymentTokens[token]) {
            revert HedVaultErrors.TokenNotListed(token);
        }
        _;
    }

    modifier validOrder(uint256 orderId) {
        if (orderId == 0 || orderId >= nextOrderId) {
            revert HedVaultErrors.OrderDoesNotExist(orderId);
        }
        _;
    }

    modifier onlyOrderMaker(uint256 orderId) {
        if (orders[orderId].maker != msg.sender) {
            revert HedVaultErrors.UnauthorizedAccess(msg.sender, "order maker");
        }
        _;
    }

    modifier notInEmergency() {
        if (emergencyStop) {
            revert HedVaultErrors.EmergencyModeActive();
        }
        _;
    }

    modifier validUserOrderLimit() {
        if (userActiveOrders[msg.sender] >= maxActiveOrdersPerUser) {
            revert HedVaultErrors.TooManyActiveOrders(
                msg.sender,
                maxActiveOrdersPerUser
            );
        }
        _;
    }

    modifier notInMatching(uint256 orderId) {
        if (orderInMatching[orderId]) {
            revert HedVaultErrors.OrderInMatching(orderId);
        }
        _;
    }

    constructor(
        address _hedVaultCore,
        address _priceOracle,
        address _feeRecipient
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
        _initializeRewards();

        // Set up roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MARKETPLACE_ADMIN_ROLE, msg.sender);
        _grantRole(FEE_MANAGER_ROLE, msg.sender);
        _grantRole(EMERGENCY_ROLE, msg.sender);

        // Initialize protocol statistics
        totalFeesCollected = 0;
        totalVolumeTraded = 0;
        totalTradesExecuted = 0;
        emergencyStop = false;
    }

    /**
     * @notice Initialize rewards distributor connection
     * @dev Gets RewardsDistributor address from HedVaultCore
     */
    function _initializeRewards() internal {
        address rewardsAddr = hedVaultCore.rewardsDistributor();
        if (rewardsAddr != address(0)) {
            rewardsDistributor = RewardsDistributor(rewardsAddr);
        }
    }

    /**
     * @notice Distribute activity rewards to user
     * @dev Safely calls RewardsDistributor without reverting main transaction
     * @param user User to receive rewards
     * @param activityType Type of activity ("marketplace")
     * @param amount Amount of activity for reward calculation
     */
    function _distributeReward(address user, string memory activityType, uint256 amount) internal {
        if (address(rewardsDistributor) != address(0)) {
            try rewardsDistributor.distributeActivityReward(user, activityType, amount) {
                // Reward distributed successfully
            } catch {
                // Silently fail to not block main transaction
                // Could emit an event here for monitoring
            }
        }
    }

    /**
     * @notice Create a buy or sell order
     * @param asset Asset to trade
     * @param paymentToken Payment token address
     * @param amount Amount of asset
     * @param price Price per token
     * @param orderType Order type (BUY or SELL)
     * @param expiry Order expiry timestamp
     * @return orderId New order ID
     */
    function createOrder(
        address asset,
        address paymentToken,
        uint256 amount,
        uint256 price,
        uint8 orderType,
        uint256 expiry
    )
        external
        validAsset(asset)
        validPaymentToken(paymentToken)
        whenNotPaused
        nonReentrant
        notInEmergency
        validUserOrderLimit
        returns (uint256 orderId)
    {
        if (amount < minOrderSize || amount > maxOrderSize) {
            revert HedVaultErrors.InvalidAmount(
                amount,
                minOrderSize,
                maxOrderSize
            );
        }
        if (price == 0) {
            revert HedVaultErrors.ZeroAmount();
        }
        if (
            expiry <= block.timestamp ||
            expiry > block.timestamp + maxOrderDuration
        ) {
            revert HedVaultErrors.InvalidTimestamp(expiry);
        }

        orderId = nextOrderId++;

        // Calculate fee
        uint256 fee = (amount * price * makerFee) / (10000 * 1e18);

        orders[orderId] = Order({
            orderId: orderId,
            maker: msg.sender,
            asset: asset,
            paymentToken: paymentToken,
            amount: amount,
            price: price,
            filled: 0,
            expiry: expiry,
            orderType: orderType,
            status: 0, // ACTIVE
            createdAt: block.timestamp,
            fee: fee
        });

        // Handle collateral based on order type
        if (orderType == 1) {
            // SELL
            // For sell orders, lock the asset
            IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);
        } else {
            // For buy orders, lock the payment token
            uint256 totalCost = (amount * price) / 1e18 + fee;
            IERC20(paymentToken).safeTransferFrom(
                msg.sender,
                address(this),
                totalCost
            );
        }

        // Add to user orders and asset orders
        userOrders[msg.sender].push(orderId);
        assetOrders[asset][orderType].push(orderId);

        // Update order book management
        priceToOrders[asset][price].push(orderId);
        _updatePriceLevels(asset, price, orderType);

        // Update user statistics
        userActiveOrders[msg.sender]++;
        userLastActivity[msg.sender] = block.timestamp;

        // Update best bid/ask prices
        _updateBestPrices(asset, price, orderType);

        emit OrderCreated(orderId, msg.sender, asset, orderType, amount, price);
        emit Events.OrderCreated(
            orderId,
            msg.sender,
            asset,
            amount,
            price,
            orderType
        );

        // Try to match with existing orders
        _tryMatchOrder(orderId);
    }

    /**
     * @notice Cancel an active order
     * @param orderId Order ID to cancel
     */
    function cancelOrder(
        uint256 orderId
    )
        external
        validOrder(orderId)
        onlyOrderMaker(orderId)
        nonReentrant
        notInMatching(orderId)
    {
        Order storage order = orders[orderId];

        if (order.status != 0) {
            // ACTIVE
            revert HedVaultErrors.OrderDoesNotExist(orderId);
        }

        order.status = 2; // CANCELLED

        // Update user statistics
        userActiveOrders[msg.sender]--;
        userLastActivity[msg.sender] = block.timestamp;

        // Return collateral to maker
        uint256 remainingAmount = order.amount - order.filled;
        if (order.orderType == 1) {
            // SELL
            IERC20(order.asset).safeTransfer(order.maker, remainingAmount);
        } else {
            uint256 remainingCost = (remainingAmount * order.price) / 1e18;
            IERC20(order.paymentToken).safeTransfer(
                order.maker,
                remainingCost + order.fee
            );
        }

        // Clean up order book data
        _removeFromPriceLevel(order.asset, order.price, orderId);
        _updateBestPricesAfterCancel(order.asset, order.price, order.orderType);

        emit OrderCancelled(orderId, order.maker);
        emit Events.OrderCancelled(orderId, order.maker, block.timestamp);
    }

    /**
     * @notice Execute a market order (immediate fill at best available price)
     * @param asset Asset to trade
     * @param paymentToken Payment token address
     * @param amount Amount to trade
     * @param orderType Order type (BUY or SELL)
     * @param maxSlippage Maximum acceptable slippage in basis points
     */
    function marketOrder(
        address asset,
        address paymentToken,
        uint256 amount,
        uint8 orderType,
        uint256 maxSlippage
    )
        external
        validAsset(asset)
        validPaymentToken(paymentToken)
        whenNotPaused
        nonReentrant
        notInEmergency
    {
        if (amount < minOrderSize) {
            revert HedVaultErrors.InvalidAmount(
                amount,
                minOrderSize,
                maxOrderSize
            );
        }
        if (maxSlippage > maxSlippageAllowed) {
            revert HedVaultErrors.InvalidAmount(
                maxSlippage,
                0,
                maxSlippageAllowed
            );
        }

        // Update user activity
        userLastActivity[msg.sender] = block.timestamp;

        // Get oracle price for slippage calculation
        (uint256 oraclePrice, , ) = priceOracle.getPrice(asset);

        // Find and execute against best available orders
        _executeMarketOrder(
            asset,
            paymentToken,
            amount,
            orderType,
            oraclePrice,
            maxSlippage
        );

        // Update user trading statistics
        userTotalVolume[msg.sender] += amount;
        userTotalTrades[msg.sender]++;
    }

    /**
     * @notice Create an auction for selling assets
     * @param asset Asset to auction
     * @param amount Amount to auction
     * @param startPrice Starting price
     * @param reservePrice Reserve price (minimum acceptable)
     * @param duration Auction duration in seconds
     * @return auctionId New auction ID
     */
    function createAuction(
        address asset,
        uint256 amount,
        uint256 startPrice,
        uint256 reservePrice,
        uint256 duration
    )
        external
        validAsset(asset)
        whenNotPaused
        nonReentrant
        notInEmergency
        returns (uint256 auctionId)
    {
        if (amount == 0 || startPrice == 0) {
            revert HedVaultErrors.ZeroAmount();
        }
        if (reservePrice > startPrice) {
            revert HedVaultErrors.InvalidConfiguration(
                "Reserve price cannot exceed start price"
            );
        }
        if (duration < 1 hours || duration > 7 days) {
            revert HedVaultErrors.InvalidConfiguration(
                "Invalid auction duration"
            );
        }

        auctionId = nextAuctionId++;

        // Lock the asset
        IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);

        auctions[auctionId] = AuctionData({
            auctionId: auctionId,
            seller: msg.sender,
            asset: asset,
            amount: amount,
            startPrice: startPrice,
            reservePrice: reservePrice,
            currentBid: 0,
            highestBidder: address(0),
            startTime: block.timestamp,
            endTime: block.timestamp + duration,
            isActive: true,
            isSettled: false
        });

        emit AuctionCreated(
            auctionId,
            msg.sender,
            asset,
            amount,
            startPrice,
            block.timestamp + duration
        );
    }

    /**
     * @notice Place a bid on an auction
     * @param auctionId Auction ID
     * @param bidAmount Bid amount
     */
    function placeBid(
        uint256 auctionId,
        uint256 bidAmount
    ) external whenNotPaused nonReentrant notInEmergency {
        AuctionData storage auction = auctions[auctionId];

        if (!auction.isActive || auction.isSettled) {
            revert HedVaultErrors.InvalidConfiguration("Auction not active");
        }
        if (block.timestamp >= auction.endTime) {
            revert HedVaultErrors.InvalidTimestamp(auction.endTime);
        }
        if (bidAmount <= auction.currentBid) {
            revert HedVaultErrors.InvalidAmount(
                bidAmount,
                auction.currentBid,
                type(uint256).max
            );
        }
        if (bidAmount < auction.startPrice) {
            revert HedVaultErrors.InvalidAmount(
                bidAmount,
                auction.startPrice,
                type(uint256).max
            );
        }

        // Return previous bid to previous bidder
        if (auction.highestBidder != address(0)) {
            // In a real implementation, you'd use a payment token
            // For simplicity, assuming ETH bids
            payable(auction.highestBidder).transfer(auction.currentBid);
        }

        // Update auction state
        auction.currentBid = bidAmount;
        auction.highestBidder = msg.sender;

        emit BidPlaced(auctionId, msg.sender, bidAmount);
    }

    /**
     * @notice Settle an auction after it ends
     * @param auctionId Auction ID
     */
    function settleAuction(
        uint256 auctionId
    ) external nonReentrant whenNotPaused notInEmergency {
        AuctionData storage auction = auctions[auctionId];

        if (!auction.isActive || auction.isSettled) {
            revert HedVaultErrors.InvalidConfiguration("Auction not active");
        }
        if (block.timestamp < auction.endTime) {
            revert HedVaultErrors.InvalidTimestamp(auction.endTime);
        }

        auction.isActive = false;
        auction.isSettled = true;

        if (
            auction.highestBidder != address(0) &&
            auction.currentBid >= auction.reservePrice
        ) {
            // Successful auction
            uint256 fee = (auction.currentBid * auctionFee) / 10000;
            uint256 sellerProceeds = auction.currentBid - fee;

            // Transfer asset to winner
            IERC20(auction.asset).safeTransfer(
                auction.highestBidder,
                auction.amount
            );

            // Transfer proceeds to seller
            payable(auction.seller).transfer(sellerProceeds);

            // Transfer fee to protocol
            payable(feeRecipient).transfer(fee);
            totalFeesCollected += fee;

            emit AuctionSettled(
                auctionId,
                auction.highestBidder,
                auction.currentBid
            );
        } else {
            // Failed auction - return asset to seller
            IERC20(auction.asset).safeTransfer(auction.seller, auction.amount);

            // Return bid to bidder if any
            if (auction.highestBidder != address(0)) {
                payable(auction.highestBidder).transfer(auction.currentBid);
            }

            emit AuctionSettled(auctionId, address(0), 0);
        }
    }

    /**
     * @notice Update trading fees
     * @param _makerFee New maker fee in basis points
     * @param _takerFee New taker fee in basis points
     * @param _auctionFee New auction fee in basis points
     */
    function updateFees(
        uint256 _makerFee,
        uint256 _takerFee,
        uint256 _auctionFee
    ) external onlyRole(FEE_MANAGER_ROLE) {
        if (_makerFee > 1000) {
            revert HedVaultErrors.FeeTooHigh(_makerFee, 1000);
        }
        if (_takerFee > 1000) {
            revert HedVaultErrors.FeeTooHigh(_takerFee, 1000);
        }
        if (_auctionFee > 1000) {
            revert HedVaultErrors.FeeTooHigh(_auctionFee, 1000);
        }

        makerFee = _makerFee;
        takerFee = _takerFee;
        auctionFee = _auctionFee;

        emit FeesUpdated(_makerFee, _takerFee, _auctionFee);
    }

    /**
     * @notice Add supported asset
     * @param asset Asset address
     */
    function addSupportedAsset(
        address asset
    ) external onlyRole(MARKETPLACE_ADMIN_ROLE) {
        if (asset == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }
        supportedAssets[asset] = true;
    }

    /**
     * @notice Add supported payment token
     * @param token Payment token address
     */
    function addSupportedPaymentToken(
        address token
    ) external onlyRole(MARKETPLACE_ADMIN_ROLE) {
        if (token == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }
        supportedPaymentTokens[token] = true;
    }

    // View functions
    function getOrder(uint256 orderId) external view returns (Order memory) {
        return orders[orderId];
    }

    function getUserOrders(
        address user
    ) external view returns (uint256[] memory) {
        return userOrders[user];
    }

    function getAssetOrders(
        address asset,
        uint8 orderType
    ) external view returns (uint256[] memory) {
        return assetOrders[asset][orderType];
    }

    function getMarketData(
        address asset
    ) external view returns (MarketData memory) {
        return marketData[asset];
    }

    function getAuction(
        uint256 auctionId
    ) external view returns (AuctionData memory) {
        return auctions[auctionId];
    }

    /**
     * @notice Pause the contract
     */
    function pause() external onlyRole(EMERGENCY_ROLE) {
        _pause();
    }

    /**
     * @notice Unpause the contract
     */
    function unpause() external onlyRole(EMERGENCY_ROLE) {
        _unpause();
    }

    /**
     * @notice Activate emergency stop
     */
    function activateEmergencyStop() external onlyRole(EMERGENCY_ROLE) {
        emergencyStop = true;
        emit Events.EmergencyStopActivated(msg.sender, block.timestamp);
    }

    /**
     * @notice Deactivate emergency stop
     */
    function deactivateEmergencyStop() external onlyRole(EMERGENCY_ROLE) {
        emergencyStop = false;
        emit Events.EmergencyStopDeactivated(msg.sender, block.timestamp);
    }

    /**
     * @notice Enable/disable trading for a specific asset
     * @param asset Asset address
     * @param enabled Whether trading is enabled
     */
    function setAssetTradingEnabled(
        address asset,
        bool enabled
    ) external onlyRole(MARKETPLACE_ADMIN_ROLE) {
        if (!supportedAssets[asset]) {
            revert HedVaultErrors.TokenNotListed(asset);
        }

        assetTradingEnabled[asset] = enabled;
        emit Events.AssetTradingStatusChanged(asset, enabled, block.timestamp);
    }

    /**
     * @notice Update trading limits
     * @param _maxActiveOrdersPerUser Maximum active orders per user
     * @param _maxSlippageAllowed Maximum allowed slippage
     */
    function updateTradingLimits(
        uint256 _maxActiveOrdersPerUser,
        uint256 _maxSlippageAllowed
    ) external onlyRole(MARKETPLACE_ADMIN_ROLE) {
        if (_maxActiveOrdersPerUser == 0) {
            revert HedVaultErrors.InvalidAmount(
                _maxActiveOrdersPerUser,
                1,
                type(uint256).max
            );
        }
        if (_maxSlippageAllowed > 5000) {
            revert HedVaultErrors.InvalidAmount(_maxSlippageAllowed, 0, 5000);
        }

        maxActiveOrdersPerUser = _maxActiveOrdersPerUser;
        maxSlippageAllowed = _maxSlippageAllowed;

        emit Events.TradingLimitsUpdated(
            _maxActiveOrdersPerUser,
            _maxSlippageAllowed,
            block.timestamp
        );
    }

    // Internal functions
    function _tryMatchOrder(uint256 orderId) internal {
        Order storage order = orders[orderId];

        // Get opposite order type
        uint8 oppositeType = order.orderType == 0 // BUY
            ? 1 // SELL
            : 0; // BUY

        uint256[] memory oppositeOrders = assetOrders[order.asset][
            oppositeType
        ];

        for (
            uint256 i = 0;
            i < oppositeOrders.length && order.filled < order.amount;
            i++
        ) {
            uint256 oppositeOrderId = oppositeOrders[i];
            Order storage oppositeOrder = orders[oppositeOrderId];

            if (
                oppositeOrder.status != 0 || // ACTIVE
                oppositeOrder.expiry <= block.timestamp ||
                !_canMatch(order, oppositeOrder)
            ) {
                continue;
            }

            _executeMatch(orderId, oppositeOrderId);
        }
    }

    function _canMatch(
        Order memory order1,
        Order memory order2
    ) internal pure returns (bool) {
        if (order1.orderType == 0) {
            // BUY
            return order1.price >= order2.price;
        } else {
            return order1.price <= order2.price;
        }
    }

    function _executeMatch(uint256 orderId1, uint256 orderId2) internal {
        Order storage order1 = orders[orderId1];
        Order storage order2 = orders[orderId2];

        uint256 tradeAmount = _min(
            order1.amount - order1.filled,
            order2.amount - order2.filled
        );
        uint256 tradePrice = order2.price; // Price discovery: use maker's price

        // Update order fill amounts
        order1.filled += tradeAmount;
        order2.filled += tradeAmount;

        // Update order status if fully filled
        if (order1.filled == order1.amount) {
            order1.status = 1; // FILLED
        }
        if (order2.filled == order2.amount) {
            order2.status = 1; // FILLED
        }

        // Execute the trade
        _executeTrade(orderId1, orderId2, tradeAmount, tradePrice);
    }

    function _executeTrade(
        uint256 buyOrderId,
        uint256 sellOrderId,
        uint256 amount,
        uint256 price
    ) internal {
        Order storage buyOrder = orders[buyOrderId];
        Order storage sellOrder = orders[sellOrderId];

        // Ensure correct order types
        if (buyOrder.orderType == 1) {
            // SELL
            (buyOrderId, sellOrderId) = (sellOrderId, buyOrderId);
            (buyOrder, sellOrder) = (sellOrder, buyOrder);
        }

        uint256 tradeValue = (amount * price) / 1e18;
        uint256 buyerFee = (tradeValue * takerFee) / 10000;
        uint256 sellerFee = (tradeValue * makerFee) / 10000;

        // Transfer asset from seller to buyer
        IERC20(buyOrder.asset).safeTransfer(buyOrder.maker, amount);

        // Transfer payment from buyer to seller
        uint256 sellerProceeds = tradeValue - sellerFee;
        IERC20(buyOrder.paymentToken).safeTransfer(
            sellOrder.maker,
            sellerProceeds
        );

        // Transfer fees to protocol
        uint256 totalFees = buyerFee + sellerFee;
        IERC20(buyOrder.paymentToken).safeTransfer(feeRecipient, totalFees);
        totalFeesCollected += totalFees;

        // Record trade
        uint256 tradeId = nextTradeId++;
        trades[tradeId] = Trade({
            tradeId: tradeId,
            buyOrderId: buyOrderId,
            sellOrderId: sellOrderId,
            buyer: buyOrder.maker,
            seller: sellOrder.maker,
            asset: buyOrder.asset,
            amount: amount,
            price: price,
            timestamp: block.timestamp,
            buyerFee: buyerFee,
            sellerFee: sellerFee
        });

        // Update market data
        _updateMarketData(buyOrder.asset, price, amount);

        // Distribute marketplace rewards to both buyer and seller (0.25% of trade value each)
        _distributeReward(buyOrder.maker, "marketplace", tradeValue);
        _distributeReward(sellOrder.maker, "marketplace", tradeValue);

        emit TradeExecuted(
            tradeId,
            buyOrderId,
            sellOrderId,
            buyOrder.maker,
            sellOrder.maker,
            buyOrder.asset,
            amount,
            price
        );
    }

    function _executeMarketOrder(
        address asset,
        address paymentToken,
        uint256 amount,
        uint8 orderType,
        uint256 oraclePrice,
        uint256 maxSlippage
    ) internal {
        // Simplified market order execution
        // In a real implementation, this would be more sophisticated
        uint8 oppositeType = orderType == 0 // BUY
            ? 1 // SELL
            : 0; // BUY

        uint256[] memory oppositeOrders = assetOrders[asset][oppositeType];
        uint256 remainingAmount = amount;

        for (
            uint256 i = 0;
            i < oppositeOrders.length && remainingAmount > 0;
            i++
        ) {
            Order storage oppositeOrder = orders[oppositeOrders[i]];

            if (
                oppositeOrder.status != 0 || // ACTIVE
                oppositeOrder.expiry <= block.timestamp
            ) {
                continue;
            }

            // Check slippage
            uint256 slippage = _calculateSlippage(
                oppositeOrder.price,
                oraclePrice
            );
            if (slippage > maxSlippage) {
                continue;
            }

            uint256 fillAmount = _min(
                remainingAmount,
                oppositeOrder.amount - oppositeOrder.filled
            );

            // Execute market order directly without creating temporary order
            uint256 tradeAmount = fillAmount;
            uint256 tradePrice = oppositeOrder.price;

            // Update opposite order fill amount
            oppositeOrder.filled += tradeAmount;

            // Update opposite order status if fully filled
            if (oppositeOrder.filled == oppositeOrder.amount) {
                oppositeOrder.status = 1; // FILLED
            }

            // Execute the trade directly
            uint256 tradeValue = (tradeAmount * tradePrice) / 1e18;
            uint256 buyerFee = (tradeValue * takerFee) / 10000;
            uint256 sellerFee = (tradeValue * makerFee) / 10000;

            if (orderType == 0) { // BUY market order
                // Transfer asset from seller to buyer
                IERC20(asset).safeTransfer(msg.sender, tradeAmount);
                
                // Transfer payment from buyer to seller
                uint256 sellerProceeds = tradeValue - sellerFee;
                IERC20(paymentToken).safeTransferFrom(msg.sender, oppositeOrder.maker, sellerProceeds);
                
                // Transfer fees from buyer to protocol
                IERC20(paymentToken).safeTransferFrom(msg.sender, feeRecipient, buyerFee + sellerFee);
            } else { // SELL market order
                // Transfer asset from seller to buyer
                IERC20(asset).safeTransferFrom(msg.sender, oppositeOrder.maker, tradeAmount);
                
                // Transfer payment from buyer to seller
                uint256 sellerProceeds = tradeValue - sellerFee;
                IERC20(paymentToken).safeTransfer(msg.sender, sellerProceeds);
                
                // Transfer fees to protocol (already collected from buyer's locked funds)
                IERC20(paymentToken).safeTransfer(feeRecipient, buyerFee + sellerFee);
            }
            
            totalFeesCollected += buyerFee + sellerFee;

            // Record trade
            uint256 tradeId = nextTradeId++;
            trades[tradeId] = Trade({
                tradeId: tradeId,
                buyOrderId: orderType == 0 ? 0 : oppositeOrders[i], // Use 0 for market orders
                sellOrderId: orderType == 1 ? 0 : oppositeOrders[i], // Use 0 for market orders
                buyer: orderType == 0 ? msg.sender : oppositeOrder.maker,
                seller: orderType == 1 ? msg.sender : oppositeOrder.maker,
                asset: asset,
                amount: tradeAmount,
                price: tradePrice,
                timestamp: block.timestamp,
                buyerFee: buyerFee,
                sellerFee: sellerFee
            });

            // Update market data
            _updateMarketData(asset, tradePrice, tradeAmount);

            emit TradeExecuted(
                tradeId,
                orderType == 0 ? 0 : oppositeOrders[i],
                orderType == 1 ? 0 : oppositeOrders[i],
                orderType == 0 ? msg.sender : oppositeOrder.maker,
                orderType == 1 ? msg.sender : oppositeOrder.maker,
                asset,
                tradeAmount,
                tradePrice
            );
            remainingAmount -= fillAmount;
        }

        if (remainingAmount > 0) {
            revert HedVaultErrors.InvalidAmount(remainingAmount, 0, amount);
        }
    }

    function _updateMarketData(
        address asset,
        uint256 price,
        uint256 volume
    ) internal {
        MarketData storage data = marketData[asset];

        // Update 24h data (simplified)
        if (block.timestamp - data.lastTradeTime > 24 hours) {
            data.volume24h = volume;
            data.high24h = price;
            data.low24h = price;
            data.priceChange24h = 0;
        } else {
            data.volume24h += volume;
            if (price > data.high24h) data.high24h = price;
            if (price < data.low24h || data.low24h == 0) data.low24h = price;
        }

        data.lastPrice = price;
        data.totalTrades++;
        data.lastTradeTime = block.timestamp;
    }

    function _calculateSlippage(
        uint256 executionPrice,
        uint256 oraclePrice
    ) internal pure returns (uint256) {
        if (oraclePrice == 0) return 0;

        uint256 priceDiff = executionPrice > oraclePrice
            ? executionPrice - oraclePrice
            : oraclePrice - executionPrice;

        return (priceDiff * 10000) / oraclePrice;
    }

    function _min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @notice Update price levels for order book management
     * @param asset Asset address
     * @param price Price level
     */
    function _updatePriceLevels(address asset, uint256 price, uint8) internal {
        uint256[] storage prices = activePrices[asset];

        // Check if price level already exists
        bool exists = false;
        for (uint256 i = 0; i < prices.length; i++) {
            if (prices[i] == price) {
                exists = true;
                break;
            }
        }

        // Add new price level if it doesn't exist
        if (!exists) {
            prices.push(price);
            // Sort prices (simple insertion sort for small arrays)
            for (uint256 i = prices.length - 1; i > 0; i--) {
                if (prices[i] < prices[i - 1]) {
                    (prices[i], prices[i - 1]) = (prices[i - 1], prices[i]);
                } else {
                    break;
                }
            }
        }
    }

    /**
     * @notice Update best bid and ask prices
     * @param asset Asset address
     * @param price New price
     * @param orderType Order type (0=BUY, 1=SELL)
     */
    function _updateBestPrices(
        address asset,
        uint256 price,
        uint8 orderType
    ) internal {
        if (orderType == 0) {
            // BUY order
            if (price > bestBidPrice[asset]) {
                bestBidPrice[asset] = price;
            }
        } else {
            // SELL order
            if (bestAskPrice[asset] == 0 || price < bestAskPrice[asset]) {
                bestAskPrice[asset] = price;
            }
        }
    }

    /**
     * @notice Remove order from price level
     * @param asset Asset address
     * @param price Price level
     * @param orderId Order ID to remove
     */
    function _removeFromPriceLevel(
        address asset,
        uint256 price,
        uint256 orderId
    ) internal {
        uint256[] storage orderIds = priceToOrders[asset][price];

        for (uint256 i = 0; i < orderIds.length; i++) {
            if (orderIds[i] == orderId) {
                // Move last element to current position and pop
                orderIds[i] = orderIds[orderIds.length - 1];
                orderIds.pop();
                break;
            }
        }

        // If no more orders at this price level, remove from active prices
        if (orderIds.length == 0) {
            _removePriceLevel(asset, price);
        }
    }

    /**
     * @notice Remove price level from active prices
     * @param asset Asset address
     * @param price Price to remove
     */
    function _removePriceLevel(address asset, uint256 price) internal {
        uint256[] storage prices = activePrices[asset];

        for (uint256 i = 0; i < prices.length; i++) {
            if (prices[i] == price) {
                prices[i] = prices[prices.length - 1];
                prices.pop();
                break;
            }
        }
    }

    /**
     * @notice Update best prices after order cancellation
     * @param asset Asset address
     * @param cancelledPrice Cancelled order price
     * @param orderType Order type
     */
    function _updateBestPricesAfterCancel(
        address asset,
        uint256 cancelledPrice,
        uint8 orderType
    ) internal {
        if (orderType == 0) {
            // BUY order
            if (cancelledPrice == bestBidPrice[asset]) {
                // Recalculate best bid
                bestBidPrice[asset] = _findBestBidPrice(asset);
            }
        } else {
            // SELL order
            if (cancelledPrice == bestAskPrice[asset]) {
                // Recalculate best ask
                bestAskPrice[asset] = _findBestAskPrice(asset);
            }
        }
    }

    /**
     * @notice Find best bid price for an asset
     * @param asset Asset address
     * @return bestBid Best bid price
     */
    function _findBestBidPrice(
        address asset
    ) internal view returns (uint256 bestBid) {
        uint256[] memory buyOrders = assetOrders[asset][0]; // BUY orders

        for (uint256 i = 0; i < buyOrders.length; i++) {
            Order memory order = orders[buyOrders[i]];
            if (order.status == 0 && order.expiry > block.timestamp) {
                // ACTIVE and not expired
                if (order.price > bestBid) {
                    bestBid = order.price;
                }
            }
        }

        return bestBid;
    }

    /**
     * @notice Find best ask price for an asset
     * @param asset Asset address
     * @return bestAsk Best ask price
     */
    function _findBestAskPrice(
        address asset
    ) internal view returns (uint256 bestAsk) {
        uint256[] memory sellOrders = assetOrders[asset][1]; // SELL orders

        for (uint256 i = 0; i < sellOrders.length; i++) {
            Order memory order = orders[sellOrders[i]];
            if (order.status == 0 && order.expiry > block.timestamp) {
                // ACTIVE and not expired
                if (bestAsk == 0 || order.price < bestAsk) {
                    bestAsk = order.price;
                }
            }
        }

        return bestAsk;
    }

    // Support for receiving ETH (for auctions)
    receive() external payable {}
}

