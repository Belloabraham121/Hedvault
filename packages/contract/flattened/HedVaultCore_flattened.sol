// SPDX-License-Identifier: MIT
pragma solidity >=0.4.16 >=0.6.2 ^0.8.20;

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

// lib/openzeppelin-contracts/contracts/utils/Errors.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/Errors.sol)

/**
 * @dev Collection of common custom errors used in multiple contracts
 *
 * IMPORTANT: Backwards compatibility is not guaranteed in future versions of the library.
 * It is recommended to avoid relying on the error API for critical functionality.
 *
 * _Available since v5.1._
 */
library Errors {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error InsufficientBalance(uint256 balance, uint256 needed);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedCall();

    /**
     * @dev The deployment failed.
     */
    error FailedDeployment();

    /**
     * @dev A necessary precompile is missing.
     */
    error MissingPrecompile(address);
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

// lib/openzeppelin-contracts/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// lib/openzeppelin-contracts/contracts/interfaces/IERC165.sol

// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC165.sol)

// lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol

// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC20.sol)

// lib/openzeppelin-contracts/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v5.4.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert Errors.InsufficientBalance(address(this).balance, amount);
        }

        (bool success, bytes memory returndata) = recipient.call{value: amount}("");
        if (!success) {
            _revert(returndata);
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {Errors.FailedCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert Errors.InsufficientBalance(address(this).balance, value);
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {Errors.FailedCall}) in case
     * of an unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {Errors.FailedCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {Errors.FailedCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            assembly ("memory-safe") {
                revert(add(returndata, 0x20), mload(returndata))
            }
        } else {
            revert Errors.FailedCall();
        }
    }
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

// src/HedVaultCore.sol

/**
 * @title HedVaultCore
 * @notice Main protocol contract for HedVault - coordinates all modules and manages protocol state
 * @dev This contract serves as the central hub for the HedVault protocol
 */
contract HedVaultCore is Ownable, Pausable, ReentrancyGuard {
    using Address for address;

    // Protocol version
    string public constant VERSION = "1.0.0";

    // Protocol fee recipient
    address public feeRecipient;

    // Protocol fees (in basis points)
    uint256 public tradingFee = 50; // 0.5%
    uint256 public lendingFee = 100; // 1%
    uint256 public swapFee = 30; // 0.3%
    uint256 public bridgeFee = 200; // 2%

    // Maximum fees (safety limits)
    uint256 public constant MAX_TRADING_FEE = 500; // 5%
    uint256 public constant MAX_LENDING_FEE = 1000; // 10%
    uint256 public constant MAX_SWAP_FEE = 300; // 3%
    uint256 public constant MAX_BRIDGE_FEE = 1000; // 10%

    // Protocol modules
    address public rwaTokenFactory;
    address public marketplace;
    address public swapEngine;
    address public lendingPool;
    address public rewardsDistributor;
    address public priceOracle;
    address public complianceManager;
    address public portfolioManager;
    address public crossChainBridge;
    address public analyticsEngine;

    // Admin addresses
    mapping(address => bool) public admins;
    address[] public adminList;

    // Protocol state
    bool public isInitialized;
    uint256 public initializationTime;

    // Emergency state
    bool public emergencyMode;
    mapping(string => bool) public circuitBreakers;

    // Protocol statistics
    uint256 public totalValueLocked;
    uint256 public totalUsers;
    uint256 public totalTransactions;
    uint256 public totalFeesCollected;

    // Rate limiting and user tracking
    mapping(address => uint256) public lastTransactionTime;
    mapping(address => uint256) public dailyTransactionCount;
    mapping(address => uint256) public dailyTransactionVolume;
    mapping(address => bool) public registeredUsers;
    mapping(address => uint256) public userRegistrationTime;
    uint256 public constant RATE_LIMIT_WINDOW = 1 minutes;
    uint256 public constant DAILY_TRANSACTION_LIMIT = 100;
    uint256 public constant DAILY_VOLUME_LIMIT = 1000000 * 1e18; // 1M USD

    // Protocol limits
    uint256 public maxTVL = 1000000000 * 1e18; // 1B USD max TVL
    uint256 public minTransactionAmount = 1 * 1e18; // 1 USD minimum
    uint256 public maxTransactionAmount = 10000000 * 1e18; // 10M USD maximum

    // Modifiers
    modifier onlyAdmin() {
        if (!admins[msg.sender] && msg.sender != owner()) {
            revert HedVaultErrors.OnlyAdmin(msg.sender);
        }
        _;
    }

    modifier onlyModule(address module) {
        if (!_isValidModule(module)) {
            revert HedVaultErrors.UnauthorizedAccess(msg.sender, "module");
        }
        _;
    }

    modifier whenInitialized() {
        if (!isInitialized) {
            revert HedVaultErrors.ProtocolNotInitialized();
        }
        _;
    }

    modifier whenNotEmergency() {
        if (emergencyMode) {
            revert HedVaultErrors.EmergencyModeActive();
        }
        _;
    }

    modifier rateLimit() {
        if (
            block.timestamp - lastTransactionTime[msg.sender] <
            RATE_LIMIT_WINDOW
        ) {
            revert HedVaultErrors.RateLimitExceeded(msg.sender);
        }
        lastTransactionTime[msg.sender] = block.timestamp;
        _;
    }

    constructor(address _feeRecipient) Ownable(msg.sender) {
        if (_feeRecipient == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }
        feeRecipient = _feeRecipient;
        admins[msg.sender] = true;
        adminList.push(msg.sender);

        // Register the owner as the first user
        registeredUsers[msg.sender] = true;
        userRegistrationTime[msg.sender] = block.timestamp;
        totalUsers = 1;
    }

    /**
     * @notice Initialize the protocol with all module addresses
     * @param _modules Array of module addresses in specific order
     */
    function initialize(address[10] calldata _modules) external onlyOwner {
        if (isInitialized) {
            revert HedVaultErrors.ProtocolAlreadyInitialized();
        }

        // Validate all module addresses
        for (uint256 i = 0; i < _modules.length; i++) {
            if (_modules[i] == address(0)) {
                revert HedVaultErrors.ZeroAddress();
            }
        }

        // Set module addresses
        rwaTokenFactory = _modules[0];
        marketplace = _modules[1];
        swapEngine = _modules[2];
        lendingPool = _modules[3];
        rewardsDistributor = _modules[4];
        priceOracle = _modules[5];
        complianceManager = _modules[6];
        portfolioManager = _modules[7];
        crossChainBridge = _modules[8];
        analyticsEngine = _modules[9];

        isInitialized = true;
        initializationTime = block.timestamp;

        emit Events.ProtocolInitialized(address(this), block.timestamp);
    }

    /**
     * @notice Register a new user in the protocol
     * @param user User address to register
     */
    function registerUser(address user) external whenNotPaused {
        if (user == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }
        if (registeredUsers[user]) {
            revert HedVaultErrors.UserAlreadyRegistered(user);
        }

        registeredUsers[user] = true;
        userRegistrationTime[user] = block.timestamp;
        totalUsers++;

        emit Events.UserRegistered(user, block.timestamp);
    }

    /**
     * @notice Update a specific module address
     * @param moduleType Type of module to update
     * @param newModule New module address
     */
    function updateModule(
        string calldata moduleType,
        address newModule
    ) external onlyOwner whenInitialized {
        if (newModule == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        address oldModule;
        bytes32 moduleHash = keccak256(bytes(moduleType));

        if (moduleHash == keccak256(bytes("rwaTokenFactory"))) {
            oldModule = rwaTokenFactory;
            rwaTokenFactory = newModule;
        } else if (moduleHash == keccak256(bytes("marketplace"))) {
            oldModule = marketplace;
            marketplace = newModule;
        } else if (moduleHash == keccak256(bytes("swapEngine"))) {
            oldModule = swapEngine;
            swapEngine = newModule;
        } else if (moduleHash == keccak256(bytes("lendingPool"))) {
            oldModule = lendingPool;
            lendingPool = newModule;
        } else if (moduleHash == keccak256(bytes("rewardsDistributor"))) {
            oldModule = rewardsDistributor;
            rewardsDistributor = newModule;
        } else if (moduleHash == keccak256(bytes("priceOracle"))) {
            oldModule = priceOracle;
            priceOracle = newModule;
        } else if (moduleHash == keccak256(bytes("complianceManager"))) {
            oldModule = complianceManager;
            complianceManager = newModule;
        } else if (moduleHash == keccak256(bytes("portfolioManager"))) {
            oldModule = portfolioManager;
            portfolioManager = newModule;
        } else if (moduleHash == keccak256(bytes("crossChainBridge"))) {
            oldModule = crossChainBridge;
            crossChainBridge = newModule;
        } else if (moduleHash == keccak256(bytes("analyticsEngine"))) {
            oldModule = analyticsEngine;
            analyticsEngine = newModule;
        } else {
            revert HedVaultErrors.InvalidConfiguration(moduleType);
        }

        emit Events.ModuleUpdated(moduleType, oldModule, newModule);
    }

    /**
     * @notice Update protocol limits
     * @param limitType Type of limit to update
     * @param newLimit New limit value
     */
    function updateProtocolLimit(
        string calldata limitType,
        uint256 newLimit
    ) external onlyAdmin {
        if (newLimit == 0) {
            revert HedVaultErrors.ZeroAmount();
        }

        uint256 oldLimit;
        bytes32 limitHash = keccak256(bytes(limitType));

        if (limitHash == keccak256(bytes("maxTVL"))) {
            oldLimit = maxTVL;
            maxTVL = newLimit;
        } else if (limitHash == keccak256(bytes("minTransactionAmount"))) {
            oldLimit = minTransactionAmount;
            minTransactionAmount = newLimit;
        } else if (limitHash == keccak256(bytes("maxTransactionAmount"))) {
            oldLimit = maxTransactionAmount;
            maxTransactionAmount = newLimit;
        } else {
            revert HedVaultErrors.InvalidConfiguration(limitType);
        }

        emit Events.ProtocolLimitUpdated(limitType, oldLimit, newLimit);
    }

    /**
     * @notice Add a new admin
     * @param admin Address to add as admin
     */
    function addAdmin(address admin) external onlyOwner {
        if (admin == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }
        if (admins[admin]) {
            revert HedVaultErrors.AdminAlreadyExists(admin);
        }

        admins[admin] = true;
        adminList.push(admin);

        emit Events.AdminAdded(admin, msg.sender);
    }

    /**
     * @notice Remove an admin
     * @param admin Address to remove from admins
     */
    function removeAdmin(address admin) external onlyOwner {
        if (!admins[admin]) {
            revert HedVaultErrors.AdminDoesNotExist(admin);
        }
        if (adminList.length <= 1) {
            revert HedVaultErrors.CannotRemoveLastAdmin();
        }

        admins[admin] = false;

        // Remove from admin list
        for (uint256 i = 0; i < adminList.length; i++) {
            if (adminList[i] == admin) {
                adminList[i] = adminList[adminList.length - 1];
                adminList.pop();
                break;
            }
        }

        emit Events.AdminRemoved(admin, msg.sender);
    }

    /**
     * @notice Update protocol fees
     * @param feeType Type of fee to update
     * @param newFee New fee amount in basis points
     */
    function updateFee(
        string calldata feeType,
        uint256 newFee
    ) external onlyAdmin {
        uint256 oldFee;

        if (keccak256(bytes(feeType)) == keccak256(bytes("trading"))) {
            if (newFee > MAX_TRADING_FEE) {
                revert HedVaultErrors.FeeTooHigh(newFee, MAX_TRADING_FEE);
            }
            oldFee = tradingFee;
            tradingFee = newFee;
        } else if (keccak256(bytes(feeType)) == keccak256(bytes("lending"))) {
            if (newFee > MAX_LENDING_FEE) {
                revert HedVaultErrors.FeeTooHigh(newFee, MAX_LENDING_FEE);
            }
            oldFee = lendingFee;
            lendingFee = newFee;
        } else if (keccak256(bytes(feeType)) == keccak256(bytes("swap"))) {
            if (newFee > MAX_SWAP_FEE) {
                revert HedVaultErrors.FeeTooHigh(newFee, MAX_SWAP_FEE);
            }
            oldFee = swapFee;
            swapFee = newFee;
        } else if (keccak256(bytes(feeType)) == keccak256(bytes("bridge"))) {
            if (newFee > MAX_BRIDGE_FEE) {
                revert HedVaultErrors.FeeTooHigh(newFee, MAX_BRIDGE_FEE);
            }
            oldFee = bridgeFee;
            bridgeFee = newFee;
        } else {
            revert HedVaultErrors.InvalidConfiguration(feeType);
        }

        emit Events.FeeUpdated(feeType, oldFee, newFee);
    }

    /**
     * @notice Update fee recipient
     * @param newFeeRecipient New fee recipient address
     */
    function updateFeeRecipient(address newFeeRecipient) external onlyOwner {
        if (newFeeRecipient == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }
        feeRecipient = newFeeRecipient;
    }

    /**
     * @notice Pause the protocol
     */
    function pause() external onlyAdmin {
        _pause();
        emit Events.ProtocolPaused(msg.sender, block.timestamp);
    }

    /**
     * @notice Unpause the protocol
     */
    function unpause() external onlyAdmin {
        _unpause();
        emit Events.ProtocolUnpaused(msg.sender, block.timestamp);
    }

    /**
     * @notice Activate emergency mode
     * @param reason Reason for emergency activation
     */
    function activateEmergencyMode(string calldata reason) external onlyAdmin {
        emergencyMode = true;
        _pause();
        emit Events.RecoveryModeActivated(msg.sender, reason, block.timestamp);
    }

    /**
     * @notice Deactivate emergency mode
     */
    function deactivateEmergencyMode() external onlyOwner {
        emergencyMode = false;
        _unpause();
    }

    /**
     * @notice Trigger circuit breaker for specific module
     * @param module Module name to halt
     * @param reason Reason for circuit breaker
     */
    function triggerCircuitBreaker(
        string calldata module,
        string calldata reason
    ) external onlyAdmin {
        circuitBreakers[module] = true;
        emit Events.CircuitBreakerTriggered(module, reason, block.timestamp);
    }

    /**
     * @notice Reset circuit breaker for specific module
     * @param module Module name to reset
     */
    function resetCircuitBreaker(string calldata module) external onlyAdmin {
        circuitBreakers[module] = false;
    }

    /**
     * @notice Update protocol statistics (called by modules)
     * @param user User address
     * @param transactionValue Value of transaction
     * @param feeAmount Fee collected
     */
    function updateStatistics(
        address user,
        uint256 transactionValue,
        uint256 feeAmount
    ) external onlyModule(msg.sender) whenNotPaused whenNotEmergency {
        if (user == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        // Check if this is a new user
        bool isNewUser = lastTransactionTime[user] == 0;

        // Reset daily counters if it's a new day
        uint256 currentDay = block.timestamp / 1 days;
        uint256 lastTransactionDay = lastTransactionTime[user] / 1 days;

        if (currentDay > lastTransactionDay) {
            dailyTransactionCount[user] = 0;
            dailyTransactionVolume[user] = 0;
        }

        // Update daily counters
        dailyTransactionCount[user]++;
        dailyTransactionVolume[user] += transactionValue;

        // Check daily limits
        if (dailyTransactionCount[user] > DAILY_TRANSACTION_LIMIT) {
            revert HedVaultErrors.DailyLimitExceeded(
                user,
                dailyTransactionCount[user],
                DAILY_TRANSACTION_LIMIT
            );
        }
        if (dailyTransactionVolume[user] > DAILY_VOLUME_LIMIT) {
            revert HedVaultErrors.DailyLimitExceeded(
                user,
                dailyTransactionVolume[user],
                DAILY_VOLUME_LIMIT
            );
        }

        // Update user's last transaction time
        lastTransactionTime[user] = block.timestamp;

        // Update global statistics
        totalTransactions++;
        totalFeesCollected += feeAmount;

        // Count new users
        if (isNewUser) {
            totalUsers++;
        }

        // Update TVL - this is simplified, in practice would need more sophisticated calculation
        // considering different types of transactions (deposits vs trades)
        if (transactionValue > 0) {
            totalValueLocked += transactionValue;
        }

        // Emit statistics update event
        emit Events.StatisticsUpdated(
            user,
            transactionValue,
            feeAmount,
            totalValueLocked
        );
    }

    /**
     * @notice Get protocol fee for specific operation
     * @param operation Operation type
     * @return fee Fee in basis points
     */
    function getProtocolFee(
        string calldata operation
    ) external view returns (uint256 fee) {
        if (keccak256(bytes(operation)) == keccak256(bytes("trading"))) {
            return tradingFee;
        } else if (keccak256(bytes(operation)) == keccak256(bytes("lending"))) {
            return lendingFee;
        } else if (keccak256(bytes(operation)) == keccak256(bytes("swap"))) {
            return swapFee;
        } else if (keccak256(bytes(operation)) == keccak256(bytes("bridge"))) {
            return bridgeFee;
        }
        return 0;
    }

    /**
     * @notice Check if address is a valid protocol module
     * @param module Address to check
     * @return isValid True if valid module
     */
    function isValidModule(
        address module
    ) external view returns (bool isValid) {
        return _isValidModule(module);
    }

    /**
     * @notice Get all admin addresses
     * @return admins Array of admin addresses
     */
    function getAdmins() external view returns (address[] memory) {
        return adminList;
    }

    /**
     * @notice Get protocol statistics
     * @return tvl Total value locked
     * @return users Total number of users
     * @return transactions Total number of transactions
     * @return fees Total fees collected
     */
    function getProtocolStats()
        external
        view
        returns (uint256 tvl, uint256 users, uint256 transactions, uint256 fees)
    {
        return (
            totalValueLocked,
            totalUsers,
            totalTransactions,
            totalFeesCollected
        );
    }

    /**
     * @notice Get user information
     * @param user User address
     * @return isRegistered Whether user is registered
     * @return registrationTime When user registered
     * @return lastTransaction Last transaction timestamp
     * @return dailyTxCount Daily transaction count
     * @return dailyVolume Daily transaction volume
     */
    function getUserInfo(
        address user
    )
        external
        view
        returns (
            bool isRegistered,
            uint256 registrationTime,
            uint256 lastTransaction,
            uint256 dailyTxCount,
            uint256 dailyVolume
        )
    {
        return (
            registeredUsers[user],
            userRegistrationTime[user],
            lastTransactionTime[user],
            dailyTransactionCount[user],
            dailyTransactionVolume[user]
        );
    }

    /**
     * @notice Validate transaction before execution
     * @param user User address
     * @param amount Transaction amount
     * @param operation Operation type
     * @return isValid Whether transaction is valid
     */
    function validateTransaction(
        address user,
        uint256 amount,
        string calldata operation
    ) external view returns (bool isValid) {
        // Check if protocol is operational
        if (paused() || emergencyMode) {
            return false;
        }

        // Check if user is registered
        if (!registeredUsers[user]) {
            return false;
        }

        // Check transaction amount limits
        if (amount < minTransactionAmount || amount > maxTransactionAmount) {
            return false;
        }

        // Check TVL limits
        if (totalValueLocked + amount > maxTVL) {
            return false;
        }

        // Check daily limits
        uint256 currentDay = block.timestamp / 1 days;
        uint256 lastTransactionDay = lastTransactionTime[user] / 1 days;

        uint256 userDailyCount = dailyTransactionCount[user];
        uint256 userDailyVolume = dailyTransactionVolume[user];

        // Reset counters if it's a new day
        if (currentDay > lastTransactionDay) {
            userDailyCount = 0;
            userDailyVolume = 0;
        }

        if (userDailyCount >= DAILY_TRANSACTION_LIMIT) {
            return false;
        }

        if (userDailyVolume + amount > DAILY_VOLUME_LIMIT) {
            return false;
        }

        // Check rate limiting
        if (block.timestamp - lastTransactionTime[user] < RATE_LIMIT_WINDOW) {
            return false;
        }

        // Check circuit breakers
        if (circuitBreakers[operation]) {
            return false;
        }

        return true;
    }

    /**
     * @notice Get protocol health status
     * @return isHealthy Overall protocol health
     * @return tvlUtilization TVL utilization percentage
     * @return activeModules Number of active modules
     * @return lastActivity Last activity timestamp
     */
    function getProtocolHealth()
        external
        view
        returns (
            bool isHealthy,
            uint256 tvlUtilization,
            uint256 activeModules,
            uint256 lastActivity
        )
    {
        // Calculate TVL utilization
        tvlUtilization = maxTVL > 0 ? (totalValueLocked * 10000) / maxTVL : 0;

        // Count active modules
        activeModules = 0;
        if (rwaTokenFactory != address(0)) activeModules++;
        if (marketplace != address(0)) activeModules++;
        if (swapEngine != address(0)) activeModules++;
        if (lendingPool != address(0)) activeModules++;
        if (rewardsDistributor != address(0)) activeModules++;
        if (priceOracle != address(0)) activeModules++;
        if (complianceManager != address(0)) activeModules++;
        if (portfolioManager != address(0)) activeModules++;
        if (crossChainBridge != address(0)) activeModules++;
        if (analyticsEngine != address(0)) activeModules++;

        // Determine overall health
        isHealthy =
            isInitialized &&
            !paused() &&
            !emergencyMode &&
            activeModules >= 5 && // At least 5 core modules
            tvlUtilization < 9000; // Less than 90% TVL utilization

        // Get last activity (simplified)
        lastActivity = initializationTime;

        return (isHealthy, tvlUtilization, activeModules, lastActivity);
    }

    /**
     * @notice Batch update multiple fees
     * @param feeTypes Array of fee types
     * @param newFees Array of new fee values
     */
    function batchUpdateFees(
        string[] calldata feeTypes,
        uint256[] calldata newFees
    ) external onlyAdmin {
        if (feeTypes.length != newFees.length) {
            revert HedVaultErrors.ArrayLengthMismatch(
                feeTypes.length,
                newFees.length
            );
        }
        if (feeTypes.length == 0) {
            revert HedVaultErrors.EmptyArray();
        }

        for (uint256 i = 0; i < feeTypes.length; i++) {
            this.updateFee(feeTypes[i], newFees[i]);
        }
    }

    /**
     * @notice Internal function to check if address is a valid module
     * @param module Address to check
     * @return isValid True if valid module
     */
    function _isValidModule(
        address module
    ) internal view returns (bool isValid) {
        return
            module == rwaTokenFactory ||
            module == marketplace ||
            module == swapEngine ||
            module == lendingPool ||
            module == rewardsDistributor ||
            module == priceOracle ||
            module == complianceManager ||
            module == portfolioManager ||
            module == crossChainBridge ||
            module == analyticsEngine;
    }

    /**
     * @notice Emergency withdrawal function
     * @param token Token address to withdraw (address(0) for native ETH)
     * @param amount Amount to withdraw
     * @param recipient Recipient address
     */
    function emergencyWithdraw(
        address token,
        uint256 amount,
        address recipient
    ) external onlyOwner nonReentrant {
        if (!emergencyMode) {
            revert HedVaultErrors.EmergencyModeNotActive();
        }
        if (recipient == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }
        if (amount == 0) {
            revert HedVaultErrors.ZeroAmount();
        }

        if (token == address(0)) {
            // Handle native ETH withdrawal
            uint256 balance = address(this).balance;
            if (amount > balance) {
                revert HedVaultErrors.InsufficientBalance(
                    token,
                    amount,
                    balance
                );
            }

            (bool success, ) = recipient.call{value: amount}("");
            if (!success) {
                revert HedVaultErrors.EmergencyWithdrawalFailed(
                    "ETH transfer failed"
                );
            }
        } else {
            // Handle ERC20 token withdrawal
            IERC20 tokenContract = IERC20(token);
            uint256 balance = tokenContract.balanceOf(address(this));

            if (amount > balance) {
                revert HedVaultErrors.InsufficientBalance(
                    token,
                    amount,
                    balance
                );
            }

            bool success = tokenContract.transfer(recipient, amount);
            if (!success) {
                revert HedVaultErrors.EmergencyWithdrawalFailed(
                    "Token transfer failed"
                );
            }
        }

        emit Events.EmergencyWithdrawal(
            recipient,
            token,
            amount,
            "Emergency withdrawal executed"
        );
    }

    /**
     * @notice Receive function to accept ETH deposits
     */
    receive() external payable {
        // Only accept ETH when not paused and not in emergency mode
        if (paused() || emergencyMode) {
            revert HedVaultErrors.ProtocolPaused();
        }

        emit Events.ETHDeposited(msg.sender, msg.value, block.timestamp);
    }

    /**
     * @notice Fallback function
     */
    fallback() external payable {
        revert HedVaultErrors.FunctionNotImplemented("fallback");
    }

    /**
     * @notice Get contract version
     * @return version Contract version string
     */
    function getVersion() external pure returns (string memory version) {
        return VERSION;
    }

    /**
     * @notice Check if a specific circuit breaker is active
     * @param module Module name to check
     * @return isActive Whether circuit breaker is active
     */
    function isCircuitBreakerActive(
        string calldata module
    ) external view returns (bool isActive) {
        return circuitBreakers[module];
    }

    /**
     * @notice Get all module addresses
     * @return modules Array of module addresses
     */
    function getAllModules()
        external
        view
        returns (address[10] memory modules)
    {
        modules[0] = rwaTokenFactory;
        modules[1] = marketplace;
        modules[2] = swapEngine;
        modules[3] = lendingPool;
        modules[4] = rewardsDistributor;
        modules[5] = priceOracle;
        modules[6] = complianceManager;
        modules[7] = portfolioManager;
        modules[8] = crossChainBridge;
        modules[9] = analyticsEngine;
        return modules;
    }

    /**
     * @notice Get protocol limits
     * @return maxTVLLimit Maximum TVL limit
     * @return minTxAmount Minimum transaction amount
     * @return maxTxAmount Maximum transaction amount
     * @return dailyTxLimit Daily transaction limit
     * @return dailyVolumeLimit Daily volume limit
     */
    function getProtocolLimits()
        external
        view
        returns (
            uint256 maxTVLLimit,
            uint256 minTxAmount,
            uint256 maxTxAmount,
            uint256 dailyTxLimit,
            uint256 dailyVolumeLimit
        )
    {
        return (
            maxTVL,
            minTransactionAmount,
            maxTransactionAmount,
            DAILY_TRANSACTION_LIMIT,
            DAILY_VOLUME_LIMIT
        );
    }
}

