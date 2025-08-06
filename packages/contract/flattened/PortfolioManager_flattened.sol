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

// src/PortfolioManager.sol

/**
 * @title PortfolioManager
 * @notice Manages user portfolios and asset allocations
 * @dev Handles portfolio creation, rebalancing, and performance tracking
 */
contract PortfolioManager is AccessControl, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    // Roles
    bytes32 public constant PORTFOLIO_ADMIN_ROLE =
        keccak256("PORTFOLIO_ADMIN_ROLE");
    bytes32 public constant REBALANCER_ROLE = keccak256("REBALANCER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");

    // Core protocol references
    IHedVaultCore public immutable hedVaultCore;
    PriceOracle public immutable priceOracle;

    // Portfolio structures
    struct Portfolio {
        address owner;
        string name;
        DataTypes.PortfolioAllocation[] allocations;
        uint256 totalValue; // Cached total value in USD
        uint256 lastRebalance;
        uint256 createdAt;
        bool isActive;
        uint8 riskLevel; // 1-10 scale
        uint256 targetRebalanceThreshold; // Basis points (e.g., 500 = 5%)
    }

    struct AssetHolding {
        address asset;
        uint256 amount;
        uint256 targetAllocation; // Basis points (e.g., 2500 = 25%)
        uint256 currentAllocation; // Basis points
        uint256 lastPrice;
        uint256 unrealizedPnL; // Profit/Loss since acquisition
    }

    struct PortfolioPerformance {
        uint256 totalReturn; // Basis points
        uint256 dailyReturn; // Basis points
        uint256 weeklyReturn; // Basis points
        uint256 monthlyReturn; // Basis points
        uint256 yearlyReturn; // Basis points
        uint256 maxDrawdown; // Basis points
        uint256 sharpeRatio; // Scaled by 1000
        uint256 volatility; // Basis points
        uint256 lastUpdated;
    }

    // State variables
    mapping(address => uint256[]) public userPortfolios; // user => portfolio IDs
    mapping(uint256 => Portfolio) public portfolios;
    mapping(uint256 => mapping(address => AssetHolding))
        public portfolioHoldings;
    mapping(uint256 => address[]) public portfolioAssets; // portfolio ID => asset addresses
    mapping(uint256 => PortfolioPerformance) public portfolioPerformance;
    mapping(address => bool) public supportedAssets;

    uint256 public nextPortfolioId = 1;
    uint256 public totalPortfolios;
    uint256 public totalValueLocked;

    // Portfolio limits and settings
    uint256 public constant MAX_ASSETS_PER_PORTFOLIO = 20;
    uint256 public constant MIN_ALLOCATION = 100; // 1%
    uint256 public constant MAX_ALLOCATION = 5000; // 50%
    uint256 public constant REBALANCE_COOLDOWN = 1 days;
    uint256 public constant PERFORMANCE_UPDATE_INTERVAL = 1 hours;

    // Events
    event PortfolioCreated(
        uint256 indexed portfolioId,
        address indexed owner,
        string name,
        uint8 riskLevel
    );
    event AssetAdded(
        uint256 indexed portfolioId,
        address indexed asset,
        uint256 amount,
        uint256 targetAllocation
    );
    event AssetRemoved(
        uint256 indexed portfolioId,
        address indexed asset,
        uint256 amount
    );
    event PortfolioRebalanced(
        uint256 indexed portfolioId,
        uint256 totalValue,
        uint256 timestamp
    );
    event AllocationUpdated(
        uint256 indexed portfolioId,
        address indexed asset,
        uint256 oldAllocation,
        uint256 newAllocation
    );
    event PerformanceUpdated(
        uint256 indexed portfolioId,
        uint256 totalReturn,
        uint256 sharpeRatio
    );

    modifier onlyPortfolioOwner(uint256 portfolioId) {
        if (portfolios[portfolioId].owner != msg.sender) {
            revert HedVaultErrors.UnauthorizedAccess(
                msg.sender,
                "portfolio owner"
            );
        }
        _;
    }

    modifier validPortfolio(uint256 portfolioId) {
        if (portfolioId == 0 || portfolioId >= nextPortfolioId) {
            revert HedVaultErrors.PortfolioNotFound(msg.sender);
        }
        if (!portfolios[portfolioId].isActive) {
            revert HedVaultErrors.InvalidConfiguration("Portfolio not active");
        }
        _;
    }

    modifier supportedAsset(address asset) {
        if (!supportedAssets[asset]) {
            revert HedVaultErrors.TokenNotListed(asset);
        }
        _;
    }

    constructor(address _hedVaultCore, address _priceOracle) {
        if (_hedVaultCore == address(0) || _priceOracle == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        hedVaultCore = IHedVaultCore(_hedVaultCore);
        priceOracle = PriceOracle(_priceOracle);

        // Set up roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PORTFOLIO_ADMIN_ROLE, msg.sender);
        _grantRole(REBALANCER_ROLE, msg.sender);
        _grantRole(EMERGENCY_ROLE, msg.sender);
    }

    /**
     * @notice Create a new portfolio
     * @param name Portfolio name
     * @param riskLevel Risk level (1-10)
     * @param targetRebalanceThreshold Rebalance threshold in basis points
     * @return portfolioId New portfolio ID
     */
    function createPortfolio(
        string calldata name,
        uint8 riskLevel,
        uint256 targetRebalanceThreshold
    ) external whenNotPaused returns (uint256 portfolioId) {
        if (bytes(name).length == 0) {
            revert HedVaultErrors.InvalidConfiguration("Empty portfolio name");
        }
        if (riskLevel == 0 || riskLevel > 10) {
            revert HedVaultErrors.InvalidConfiguration(
                "Risk level must be 1-10"
            );
        }
        if (targetRebalanceThreshold > 5000) {
            // Max 50%
            revert HedVaultErrors.InvalidConfiguration(
                "Rebalance threshold too high"
            );
        }

        portfolioId = nextPortfolioId++;

        portfolios[portfolioId] = Portfolio({
            owner: msg.sender,
            name: name,
            allocations: new DataTypes.PortfolioAllocation[](0),
            totalValue: 0,
            lastRebalance: block.timestamp,
            createdAt: block.timestamp,
            isActive: true,
            riskLevel: riskLevel,
            targetRebalanceThreshold: targetRebalanceThreshold
        });

        userPortfolios[msg.sender].push(portfolioId);
        totalPortfolios++;

        emit PortfolioCreated(portfolioId, msg.sender, name, riskLevel);
    }

    /**
     * @notice Add asset to portfolio
     * @param portfolioId Portfolio ID
     * @param asset Asset address
     * @param amount Amount to add
     * @param targetAllocation Target allocation in basis points
     */
    function addAsset(
        uint256 portfolioId,
        address asset,
        uint256 amount,
        uint256 targetAllocation
    )
        external
        onlyPortfolioOwner(portfolioId)
        validPortfolio(portfolioId)
        supportedAsset(asset)
        nonReentrant
    {
        if (amount == 0) {
            revert HedVaultErrors.ZeroAmount();
        }
        if (
            targetAllocation < MIN_ALLOCATION ||
            targetAllocation > MAX_ALLOCATION
        ) {
            revert HedVaultErrors.InvalidAllocation(targetAllocation);
        }
        if (portfolioAssets[portfolioId].length >= MAX_ASSETS_PER_PORTFOLIO) {
            revert HedVaultErrors.InvalidConfiguration(
                "Too many assets in portfolio"
            );
        }

        // Check if total allocations don't exceed 100%
        uint256 totalAllocation = _getTotalTargetAllocation(portfolioId) +
            targetAllocation;
        if (totalAllocation > 10000) {
            revert HedVaultErrors.AllocationExceedsLimit(
                totalAllocation,
                10000
            );
        }

        // Transfer asset from user
        IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);

        // Add or update holding
        if (portfolioHoldings[portfolioId][asset].amount == 0) {
            portfolioAssets[portfolioId].push(asset);
        }

        AssetHolding storage holding = portfolioHoldings[portfolioId][asset];
        holding.asset = asset;
        holding.amount += amount;
        holding.targetAllocation = targetAllocation;

        // Get current price for valuation
        (uint256 price, , ) = priceOracle.getPrice(asset);
        holding.lastPrice = price;

        // Update portfolio total value
        _updatePortfolioValue(portfolioId);

        // Update total value locked
        uint256 assetValue = (amount * price) / (10 ** 18);
        totalValueLocked += assetValue;

        emit AssetAdded(portfolioId, asset, amount, targetAllocation);
    }

    /**
     * @notice Remove asset from portfolio
     * @param portfolioId Portfolio ID
     * @param asset Asset address
     * @param amount Amount to remove (0 = remove all)
     */
    function removeAsset(
        uint256 portfolioId,
        address asset,
        uint256 amount
    )
        external
        onlyPortfolioOwner(portfolioId)
        validPortfolio(portfolioId)
        nonReentrant
    {
        AssetHolding storage holding = portfolioHoldings[portfolioId][asset];
        if (holding.amount == 0) {
            revert HedVaultErrors.AssetNotInPortfolio(msg.sender, asset);
        }

        uint256 removeAmount = amount == 0 ? holding.amount : amount;
        if (removeAmount > holding.amount) {
            revert HedVaultErrors.InsufficientBalance(
                asset,
                removeAmount,
                holding.amount
            );
        }

        // Transfer asset back to user
        IERC20(asset).safeTransfer(msg.sender, removeAmount);

        holding.amount -= removeAmount;

        // Remove from portfolio if no balance left
        if (holding.amount == 0) {
            _removeAssetFromPortfolio(portfolioId, asset);
        }

        // Update portfolio total value
        uint256 oldValue = portfolios[portfolioId].totalValue;
        _updatePortfolioValue(portfolioId);

        // Update total value locked
        uint256 valueRemoved = oldValue - portfolios[portfolioId].totalValue;
        if (totalValueLocked >= valueRemoved) {
            totalValueLocked -= valueRemoved;
        }

        emit AssetRemoved(portfolioId, asset, removeAmount);
    }

    /**
     * @notice Rebalance portfolio to target allocations
     * @param portfolioId Portfolio ID
     */
    function rebalancePortfolio(
        uint256 portfolioId
    ) external validPortfolio(portfolioId) nonReentrant {
        Portfolio storage portfolio = portfolios[portfolioId];

        // Check cooldown
        if (block.timestamp - portfolio.lastRebalance < REBALANCE_COOLDOWN) {
            revert HedVaultErrors.InvalidTimestamp(
                portfolio.lastRebalance + REBALANCE_COOLDOWN
            );
        }

        // Only owner or authorized rebalancer can rebalance
        if (
            msg.sender != portfolio.owner &&
            !hasRole(REBALANCER_ROLE, msg.sender)
        ) {
            revert HedVaultErrors.UnauthorizedAccess(
                msg.sender,
                "portfolio owner or rebalancer"
            );
        }

        _updatePortfolioValue(portfolioId);

        // Check if rebalancing is needed
        if (!_needsRebalancing(portfolioId)) {
            revert HedVaultErrors.InvalidConfiguration("Rebalance not needed");
        }

        // Perform rebalancing logic
        _performRebalance(portfolioId);

        portfolio.lastRebalance = block.timestamp;

        emit PortfolioRebalanced(
            portfolioId,
            portfolio.totalValue,
            block.timestamp
        );
    }

    /**
     * @notice Update target allocations
     * @param portfolioId Portfolio ID
     * @param assets Asset addresses
     * @param allocations Target allocations in basis points
     */
    function updateAllocations(
        uint256 portfolioId,
        address[] calldata assets,
        uint256[] calldata allocations
    ) external onlyPortfolioOwner(portfolioId) validPortfolio(portfolioId) {
        if (assets.length != allocations.length) {
            revert HedVaultErrors.ArrayLengthMismatch(
                assets.length,
                allocations.length
            );
        }

        uint256 totalAllocation = 0;
        for (uint256 i = 0; i < assets.length; i++) {
            if (portfolioHoldings[portfolioId][assets[i]].amount == 0) {
                revert HedVaultErrors.AssetNotInPortfolio(
                    msg.sender,
                    assets[i]
                );
            }
            if (
                allocations[i] < MIN_ALLOCATION ||
                allocations[i] > MAX_ALLOCATION
            ) {
                revert HedVaultErrors.InvalidAllocation(allocations[i]);
            }

            totalAllocation += allocations[i];

            uint256 oldAllocation = portfolioHoldings[portfolioId][assets[i]]
                .targetAllocation;
            portfolioHoldings[portfolioId][assets[i]]
                .targetAllocation = allocations[i];

            emit AllocationUpdated(
                portfolioId,
                assets[i],
                oldAllocation,
                allocations[i]
            );
        }

        if (totalAllocation > 10000) {
            revert HedVaultErrors.AllocationExceedsLimit(
                totalAllocation,
                10000
            );
        }
    }

    /**
     * @notice Update portfolio performance metrics
     * @param portfolioId Portfolio ID
     */
    function updatePerformance(
        uint256 portfolioId
    ) external validPortfolio(portfolioId) {
        PortfolioPerformance storage performance = portfolioPerformance[
            portfolioId
        ];

        // Check if update is needed
        if (
            block.timestamp - performance.lastUpdated <
            PERFORMANCE_UPDATE_INTERVAL
        ) {
            return;
        }

        _calculatePerformanceMetrics(portfolioId);
        performance.lastUpdated = block.timestamp;

        emit PerformanceUpdated(
            portfolioId,
            performance.totalReturn,
            performance.sharpeRatio
        );
    }

    /**
     * @notice Add supported asset
     * @param asset Asset address
     */
    function addSupportedAsset(
        address asset
    ) external onlyRole(PORTFOLIO_ADMIN_ROLE) {
        if (asset == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }
        supportedAssets[asset] = true;
    }

    /**
     * @notice Remove supported asset
     * @param asset Asset address
     */
    function removeSupportedAsset(
        address asset
    ) external onlyRole(PORTFOLIO_ADMIN_ROLE) {
        supportedAssets[asset] = false;
    }

    // View functions
    function getPortfolio(
        uint256 portfolioId
    ) external view returns (Portfolio memory) {
        return portfolios[portfolioId];
    }

    function getPortfolioAssets(
        uint256 portfolioId
    ) external view returns (address[] memory) {
        return portfolioAssets[portfolioId];
    }

    function getPortfolioHolding(
        uint256 portfolioId,
        address asset
    ) external view returns (AssetHolding memory) {
        return portfolioHoldings[portfolioId][asset];
    }

    function getUserPortfolios(
        address user
    ) external view returns (uint256[] memory) {
        return userPortfolios[user];
    }

    function getPortfolioValue(
        uint256 portfolioId
    ) external view returns (uint256) {
        return _calculatePortfolioValue(portfolioId);
    }

    function getPortfolioPerformance(
        uint256 portfolioId
    ) external view returns (PortfolioPerformance memory) {
        return portfolioPerformance[portfolioId];
    }

    /**
     * @notice Get portfolio statistics
     * @param portfolioId Portfolio ID
     * @return totalAssets Number of assets in portfolio
     * @return totalAllocation Total target allocation
     * @return isBalanced Whether portfolio is balanced
     * @return riskScore Calculated risk score
     */
    function getPortfolioStats(
        uint256 portfolioId
    )
        external
        view
        validPortfolio(portfolioId)
        returns (
            uint256 totalAssets,
            uint256 totalAllocation,
            bool isBalanced,
            uint256 riskScore
        )
    {
        address[] memory assets = portfolioAssets[portfolioId];
        totalAssets = assets.length;
        totalAllocation = _getTotalTargetAllocation(portfolioId);
        isBalanced = !_needsRebalancing(portfolioId);

        // Calculate risk score based on portfolio concentration and volatility
        riskScore = _calculateRiskScore(portfolioId);
    }

    /**
     * @notice Get detailed portfolio allocation breakdown
     * @param portfolioId Portfolio ID
     * @return assets Array of asset addresses
     * @return targetAllocations Array of target allocations
     * @return currentAllocations Array of current allocations
     * @return values Array of current values
     */
    function getPortfolioBreakdown(
        uint256 portfolioId
    )
        external
        view
        validPortfolio(portfolioId)
        returns (
            address[] memory assets,
            uint256[] memory targetAllocations,
            uint256[] memory currentAllocations,
            uint256[] memory values
        )
    {
        assets = portfolioAssets[portfolioId];
        uint256 length = assets.length;

        targetAllocations = new uint256[](length);
        currentAllocations = new uint256[](length);
        values = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            AssetHolding memory holding = portfolioHoldings[portfolioId][
                assets[i]
            ];
            targetAllocations[i] = holding.targetAllocation;
            currentAllocations[i] = holding.currentAllocation;
            values[i] = (holding.amount * holding.lastPrice) / (10 ** 18);
        }
    }

    /**
     * @notice Batch update multiple asset allocations
     * @param portfolioId Portfolio ID
     * @param assets Array of asset addresses
     * @param amounts Array of amounts to add/remove (positive = add, negative = remove)
     * @param newAllocations Array of new target allocations
     */
    function batchUpdateAssets(
        uint256 portfolioId,
        address[] calldata assets,
        int256[] calldata amounts,
        uint256[] calldata newAllocations
    )
        external
        onlyPortfolioOwner(portfolioId)
        validPortfolio(portfolioId)
        nonReentrant
    {
        if (
            assets.length != amounts.length ||
            assets.length != newAllocations.length
        ) {
            revert HedVaultErrors.ArrayLengthMismatch(
                assets.length,
                amounts.length
            );
        }

        // Validate total allocation
        uint256 totalAllocation = 0;
        for (uint256 i = 0; i < newAllocations.length; i++) {
            totalAllocation += newAllocations[i];
        }
        if (totalAllocation > 10000) {
            revert HedVaultErrors.AllocationExceedsLimit(
                totalAllocation,
                10000
            );
        }

        // Process each asset update
        for (uint256 i = 0; i < assets.length; i++) {
            if (!supportedAssets[assets[i]]) {
                revert HedVaultErrors.TokenNotListed(assets[i]);
            }

            AssetHolding storage holding = portfolioHoldings[portfolioId][
                assets[i]
            ];

            // Handle amount changes
            if (amounts[i] > 0) {
                // Add assets
                uint256 addAmount = uint256(amounts[i]);
                IERC20(assets[i]).safeTransferFrom(
                    msg.sender,
                    address(this),
                    addAmount
                );

                if (holding.amount == 0) {
                    portfolioAssets[portfolioId].push(assets[i]);
                    holding.asset = assets[i];
                }
                holding.amount += addAmount;

                // Update total value locked
                (uint256 price, , ) = priceOracle.getPrice(assets[i]);
                uint256 assetValue = (addAmount * price) / (10 ** 18);
                totalValueLocked += assetValue;
            } else if (amounts[i] < 0) {
                // Remove assets
                uint256 removeAmount = uint256(-amounts[i]);
                if (removeAmount > holding.amount) {
                    revert HedVaultErrors.InsufficientBalance(
                        assets[i],
                        removeAmount,
                        holding.amount
                    );
                }

                IERC20(assets[i]).safeTransfer(msg.sender, removeAmount);
                holding.amount -= removeAmount;

                if (holding.amount == 0) {
                    _removeAssetFromPortfolio(portfolioId, assets[i]);
                }
            }

            // Update allocation
            if (holding.amount > 0) {
                holding.targetAllocation = newAllocations[i];
            }
        }

        // Update portfolio value
        _updatePortfolioValue(portfolioId);
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

    // Internal functions
    function _updatePortfolioValue(uint256 portfolioId) internal {
        uint256 totalValue = _calculatePortfolioValue(portfolioId);
        portfolios[portfolioId].totalValue = totalValue;

        // Update current allocations
        address[] memory assets = portfolioAssets[portfolioId];
        for (uint256 i = 0; i < assets.length; i++) {
            AssetHolding storage holding = portfolioHoldings[portfolioId][
                assets[i]
            ];
            (uint256 price, , ) = priceOracle.getPriceUnsafe(assets[i]);
            uint256 assetValue = (holding.amount * price) / (10 ** 18); // Assuming 18 decimals
            holding.currentAllocation = totalValue > 0
                ? (assetValue * 10000) / totalValue
                : 0;
            holding.lastPrice = price;
        }
    }

    function _calculatePortfolioValue(
        uint256 portfolioId
    ) internal view returns (uint256) {
        uint256 totalValue = 0;
        address[] memory assets = portfolioAssets[portfolioId];

        for (uint256 i = 0; i < assets.length; i++) {
            AssetHolding memory holding = portfolioHoldings[portfolioId][
                assets[i]
            ];
            if (holding.amount > 0) {
                (uint256 price, , ) = priceOracle.getPriceUnsafe(assets[i]);
                totalValue += (holding.amount * price) / (10 ** 18); // Assuming 18 decimals
            }
        }

        return totalValue;
    }

    function _getTotalTargetAllocation(
        uint256 portfolioId
    ) internal view returns (uint256) {
        uint256 totalAllocation = 0;
        address[] memory assets = portfolioAssets[portfolioId];

        for (uint256 i = 0; i < assets.length; i++) {
            totalAllocation += portfolioHoldings[portfolioId][assets[i]]
                .targetAllocation;
        }

        return totalAllocation;
    }

    function _needsRebalancing(
        uint256 portfolioId
    ) internal view returns (bool) {
        Portfolio memory portfolio = portfolios[portfolioId];
        address[] memory assets = portfolioAssets[portfolioId];

        for (uint256 i = 0; i < assets.length; i++) {
            AssetHolding memory holding = portfolioHoldings[portfolioId][
                assets[i]
            ];
            uint256 deviation = holding.currentAllocation >
                holding.targetAllocation
                ? holding.currentAllocation - holding.targetAllocation
                : holding.targetAllocation - holding.currentAllocation;

            if (deviation > portfolio.targetRebalanceThreshold) {
                return true;
            }
        }

        return false;
    }

    struct RebalanceAction {
        address asset;
        bool isSell;
        uint256 amount;
        uint256 value;
    }

    function _performRebalance(uint256 portfolioId) internal {
        Portfolio storage portfolio = portfolios[portfolioId];
        address[] memory assets = portfolioAssets[portfolioId];
        uint256 totalValue = portfolio.totalValue;

        if (totalValue == 0) {
            return; // Nothing to rebalance
        }

        // Track rebalancing operations for events
        uint256 totalRebalanced = 0;
        uint256 assetsRebalanced = 0;

        // First pass: Calculate all adjustments and validate feasibility

        RebalanceAction[] memory actions = new RebalanceAction[](assets.length);
        uint256 actionCount = 0;
        uint256 totalSellValue = 0;
        uint256 totalBuyValue = 0;

        // Calculate required adjustments for each asset
        for (uint256 i = 0; i < assets.length; i++) {
            AssetHolding storage holding = portfolioHoldings[portfolioId][
                assets[i]
            ];

            // Calculate target value for this asset
            uint256 targetValue = (totalValue * holding.targetAllocation) /
                10000;

            // Get current price with validation
            (uint256 price, uint256 timestamp, uint256 confidence) = priceOracle
                .getPrice(assets[i]);

            // Validate price data quality
            if (block.timestamp - timestamp > 3600) {
                // 1 hour staleness check
                continue; // Skip rebalancing for stale prices
            }
            if (confidence < 9000) {
                // 90% confidence threshold
                continue; // Skip rebalancing for low confidence prices
            }

            uint256 currentValue = (holding.amount * price) / (10 ** 18);

            // Calculate unrealized PnL with overflow protection
            if (holding.lastPrice > 0) {
                int256 priceDiff = int256(price) - int256(holding.lastPrice);
                int256 pnlChange = (priceDiff * int256(holding.amount)) /
                    int256(10 ** 18);

                // Safe PnL update with bounds checking
                if (pnlChange >= 0) {
                    holding.unrealizedPnL += uint256(pnlChange);
                } else {
                    uint256 loss = uint256(-pnlChange);
                    if (loss <= holding.unrealizedPnL) {
                        holding.unrealizedPnL -= loss;
                    } else {
                        holding.unrealizedPnL = 0;
                    }
                }
            }

            // Calculate required adjustment
            if (currentValue != targetValue) {
                uint256 deviation = currentValue > targetValue
                    ? currentValue - targetValue
                    : targetValue - currentValue;

                // Only rebalance if deviation exceeds threshold
                uint256 deviationBps = (deviation * 10000) / totalValue;
                if (deviationBps > portfolio.targetRebalanceThreshold) {
                    if (currentValue > targetValue) {
                        // Need to sell some of this asset
                        uint256 excessValue = currentValue - targetValue;
                        uint256 sellAmount = (excessValue * (10 ** 18)) / price;

                        // Apply slippage protection (max 2% slippage)
                        uint256 maxSlippage = (sellAmount * 200) / 10000; // 2%
                        sellAmount = sellAmount > maxSlippage
                            ? sellAmount - maxSlippage
                            : sellAmount;

                        if (sellAmount > 0 && sellAmount <= holding.amount) {
                            actions[actionCount] = RebalanceAction({
                                asset: assets[i],
                                isSell: true,
                                amount: sellAmount,
                                value: excessValue
                            });
                            actionCount++;
                            totalSellValue += excessValue;
                        }
                    } else {
                        // Need to buy more of this asset
                        uint256 deficitValue = targetValue - currentValue;
                        uint256 buyAmount = (deficitValue * (10 ** 18)) / price;

                        // Apply slippage protection (max 2% slippage)
                        uint256 maxSlippage = (buyAmount * 200) / 10000; // 2%
                        buyAmount = buyAmount > maxSlippage
                            ? buyAmount + maxSlippage
                            : buyAmount;

                        if (buyAmount > 0) {
                            actions[actionCount] = RebalanceAction({
                                asset: assets[i],
                                isSell: false,
                                amount: buyAmount,
                                value: deficitValue
                            });
                            actionCount++;
                            totalBuyValue += deficitValue;
                        }
                    }
                }
            }

            // Update current allocation and price
            uint256 newCurrentValue = (holding.amount * price) / (10 ** 18);
            holding.currentAllocation = totalValue > 0
                ? (newCurrentValue * 10000) / totalValue
                : 0;
            holding.lastPrice = price;
        }

        // Validate rebalancing feasibility
        if (totalSellValue < totalBuyValue) {
            // Insufficient liquidity from sells to cover buys
            // Scale down buy orders proportionally
            uint256 scaleFactor = totalSellValue > 0
                ? (totalSellValue * 10000) / totalBuyValue
                : 0;

            for (uint256 i = 0; i < actionCount; i++) {
                if (!actions[i].isSell) {
                    actions[i].amount =
                        (actions[i].amount * scaleFactor) /
                        10000;
                    actions[i].value = (actions[i].value * scaleFactor) / 10000;
                }
            }
        }

        // Execute rebalancing actions
        for (uint256 i = 0; i < actionCount; i++) {
            RebalanceAction memory action = actions[i];
            AssetHolding storage holding = portfolioHoldings[portfolioId][
                action.asset
            ];

            if (action.isSell) {
                // Execute sell order
                if (action.amount <= holding.amount) {
                    holding.amount -= action.amount;
                    totalRebalanced += action.value;
                    assetsRebalanced++;

                    // In production: Execute DEX swap or market order
                    // _executeSwap(action.asset, baseAsset, action.amount);
                }
            } else {
                // Execute buy order
                holding.amount += action.amount;
                totalRebalanced += action.value;
                assetsRebalanced++;

                // In production: Execute DEX swap or market order
                // _executeSwap(baseAsset, action.asset, action.value);
            }
        }

        // Update portfolio allocations array
        delete portfolio.allocations;
        for (uint256 i = 0; i < assets.length; i++) {
            AssetHolding memory holding = portfolioHoldings[portfolioId][
                assets[i]
            ];
            if (holding.amount > 0) {
                portfolio.allocations.push(
                    DataTypes.PortfolioAllocation({
                        tokenAddress: assets[i],
                        allocation: holding.targetAllocation,
                        currentValue: (holding.amount * holding.lastPrice) /
                            (10 ** 18),
                        targetValue: (totalValue * holding.targetAllocation) /
                            10000,
                        lastRebalance: block.timestamp
                    })
                );
            }
        }

        // Update portfolio total value after rebalancing
        _updatePortfolioValue(portfolioId);

        // Emit rebalancing event
        emit PortfolioRebalanced(
            portfolioId,
            portfolio.totalValue,
            block.timestamp
        );
    }

    function _removeAssetFromPortfolio(
        uint256 portfolioId,
        address asset
    ) internal {
        address[] storage assets = portfolioAssets[portfolioId];
        for (uint256 i = 0; i < assets.length; i++) {
            if (assets[i] == asset) {
                assets[i] = assets[assets.length - 1];
                assets.pop();
                break;
            }
        }
        delete portfolioHoldings[portfolioId][asset];
    }

    function _calculatePerformanceMetrics(uint256 portfolioId) internal {
        PortfolioPerformance storage performance = portfolioPerformance[
            portfolioId
        ];
        Portfolio memory portfolio = portfolios[portfolioId];
        address[] memory assets = portfolioAssets[portfolioId];

        uint256 currentValue = portfolio.totalValue;
        uint256 initialValue = 0;
        uint256 totalUnrealizedPnL = 0;

        // Calculate initial investment value and total unrealized PnL
        for (uint256 i = 0; i < assets.length; i++) {
            AssetHolding memory holding = portfolioHoldings[portfolioId][
                assets[i]
            ];
            totalUnrealizedPnL += holding.unrealizedPnL;

            // Estimate initial value (current value minus unrealized PnL)
            uint256 assetCurrentValue = (holding.amount * holding.lastPrice) /
                (10 ** 18);
            initialValue += assetCurrentValue > holding.unrealizedPnL
                ? assetCurrentValue - holding.unrealizedPnL
                : assetCurrentValue;
        }

        // Calculate total return (basis points)
        if (initialValue > 0) {
            performance.totalReturn =
                ((currentValue * 10000) / initialValue) -
                10000;
        } else {
            performance.totalReturn = 0;
        }

        // Calculate time-based returns (simplified)
        uint256 timeSinceCreation = block.timestamp - portfolio.createdAt;

        if (timeSinceCreation >= 1 days) {
            performance.dailyReturn =
                (performance.totalReturn * 1 days) /
                timeSinceCreation;
        }

        if (timeSinceCreation >= 7 days) {
            performance.weeklyReturn =
                (performance.totalReturn * 7 days) /
                timeSinceCreation;
        }

        if (timeSinceCreation >= 30 days) {
            performance.monthlyReturn =
                (performance.totalReturn * 30 days) /
                timeSinceCreation;
        }

        if (timeSinceCreation >= 365 days) {
            performance.yearlyReturn =
                (performance.totalReturn * 365 days) /
                timeSinceCreation;
        }

        // Simplified volatility calculation (based on asset count and allocation spread)
        uint256 volatilityScore = 0;
        for (uint256 i = 0; i < assets.length; i++) {
            AssetHolding memory holding = portfolioHoldings[portfolioId][
                assets[i]
            ];
            // Higher allocation concentration increases volatility
            volatilityScore +=
                (holding.currentAllocation * holding.currentAllocation) /
                10000;
        }
        performance.volatility = volatilityScore;

        // Simplified Sharpe ratio calculation (return / volatility)
        if (performance.volatility > 0) {
            performance.sharpeRatio =
                (performance.totalReturn * 1000) /
                performance.volatility;
        } else {
            performance.sharpeRatio = 0;
        }

        // Calculate max drawdown (simplified - based on current unrealized losses)
        uint256 totalLosses = 0;
        for (uint256 i = 0; i < assets.length; i++) {
            AssetHolding memory holding = portfolioHoldings[portfolioId][
                assets[i]
            ];
            if (holding.unrealizedPnL < 0) {
                totalLosses += uint256(-int256(holding.unrealizedPnL));
            }
        }

        if (currentValue > 0) {
            performance.maxDrawdown = (totalLosses * 10000) / currentValue;
        } else {
            performance.maxDrawdown = 0;
        }
    }

    /**
     * @notice Calculate portfolio risk score
     * @param portfolioId Portfolio ID
     * @return riskScore Risk score (0-1000, higher = riskier)
     */
    function _calculateRiskScore(
        uint256 portfolioId
    ) internal view returns (uint256 riskScore) {
        address[] memory assets = portfolioAssets[portfolioId];
        Portfolio memory portfolio = portfolios[portfolioId];

        if (assets.length == 0) {
            return 0;
        }

        // Base risk from portfolio risk level setting
        riskScore = uint256(portfolio.riskLevel) * 100; // 100-1000 range

        // Concentration risk - higher concentration = higher risk
        uint256 concentrationRisk = 0;
        for (uint256 i = 0; i < assets.length; i++) {
            AssetHolding memory holding = portfolioHoldings[portfolioId][
                assets[i]
            ];
            // Square the allocation to penalize concentration
            concentrationRisk +=
                (holding.currentAllocation * holding.currentAllocation) /
                10000;
        }

        // Diversification bonus - more assets = lower risk
        uint256 diversificationBonus = assets.length > 10
            ? 100
            : assets.length * 10;

        // Combine factors
        riskScore = riskScore + concentrationRisk - diversificationBonus;

        // Cap at reasonable bounds
        if (riskScore > 1000) riskScore = 1000;
        if (riskScore < 0) riskScore = 0;
    }
}

