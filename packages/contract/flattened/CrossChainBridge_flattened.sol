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

// src/CrossChainBridge.sol

/**
 * @title CrossChainBridge
 * @notice Cross-chain bridge for RWA assets
 * @dev Handles asset bridging, message passing, and security validations
 */
contract CrossChainBridge is AccessControl, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    // Roles
    bytes32 public constant BRIDGE_OPERATOR_ROLE =
        keccak256("BRIDGE_OPERATOR_ROLE");
    bytes32 public constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");
    bytes32 public constant FEE_MANAGER_ROLE = keccak256("FEE_MANAGER_ROLE");

    // Chain IDs
    uint256 public immutable CURRENT_CHAIN_ID;

    // Bridge configuration
    struct BridgeConfig {
        bool isActive;
        uint256 minTransferAmount;
        uint256 maxTransferAmount;
        uint256 dailyLimit;
        uint256 dailyTransferred;
        uint256 lastResetTime;
        uint256 confirmationsRequired;
    }

    // Asset configuration
    struct AssetConfig {
        bool isSupported;
        uint256 bridgeFee; // Fee in basis points (1 = 0.01%)
        uint256 minAmount;
        uint256 maxAmount;
        address wrappedToken; // Wrapped version on destination chain
    }

    // Bridge transaction
    struct BridgeTransaction {
        bytes32 txHash;
        address user;
        address asset;
        uint256 amount;
        uint256 sourceChain;
        uint256 destinationChain;
        uint256 timestamp;
        uint256 confirmations;
        bool isCompleted;
        bool isCancelled;
    }

    // Message passing
    struct CrossChainMessage {
        bytes32 messageId;
        address sender;
        uint256 sourceChain;
        uint256 destinationChain;
        bytes data;
        uint256 timestamp;
        bool isExecuted;
    }

    // State variables
    mapping(uint256 => BridgeConfig) public bridgeConfigs;
    mapping(address => AssetConfig) public assetConfigs;
    mapping(bytes32 => BridgeTransaction) public bridgeTransactions;
    mapping(bytes32 => CrossChainMessage) public crossChainMessages;
    mapping(bytes32 => mapping(address => bool)) public validatorConfirmations;
    mapping(uint256 => mapping(address => uint256)) public userDailyTransferred;
    mapping(uint256 => mapping(address => uint256)) public userLastResetTime;

    uint256 public bridgeFeeCollected;
    uint256 public nextTransactionId;
    uint256 public nextMessageId;

    // Constants
    uint256 public constant MAX_BRIDGE_FEE = 1000; // 10%
    uint256 public constant MIN_CONFIRMATIONS = 2;
    uint256 public constant MAX_CONFIRMATIONS = 10;
    uint256 public constant MESSAGE_EXPIRY = 7 days;

    // Events
    event BridgeInitiated(
        bytes32 indexed txHash,
        address indexed user,
        address indexed asset,
        uint256 amount,
        uint256 sourceChain,
        uint256 destinationChain
    );

    event BridgeCompleted(
        bytes32 indexed txHash,
        address indexed user,
        address indexed asset,
        uint256 amount
    );

    event BridgeCancelled(bytes32 indexed txHash, string reason);

    event MessageSent(
        bytes32 indexed messageId,
        address indexed sender,
        uint256 sourceChain,
        uint256 destinationChain,
        bytes data
    );

    event MessageExecuted(bytes32 indexed messageId, address indexed executor);

    event ValidatorConfirmation(
        bytes32 indexed txHash,
        address indexed validator,
        bool confirmed
    );

    event ChainConfigUpdated(
        uint256 indexed chainId,
        bool isActive,
        uint256 minAmount,
        uint256 maxAmount
    );

    event AssetConfigUpdated(
        address indexed asset,
        bool isSupported,
        uint256 bridgeFee,
        uint256 minAmount,
        uint256 maxAmount
    );

    event FeesCollected(address indexed collector, uint256 amount);

    /**
     * @notice Constructor
     * @param admin Admin address
     */
    constructor(address admin) {
        if (admin == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        CURRENT_CHAIN_ID = block.chainid;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(BRIDGE_OPERATOR_ROLE, admin);
        _grantRole(VALIDATOR_ROLE, admin);
        _grantRole(FEE_MANAGER_ROLE, admin);

        nextTransactionId = 1;
        nextMessageId = 1;
    }

    // Bridge Operations

    /**
     * @notice Initiate bridge transfer
     * @param asset Asset to bridge
     * @param amount Amount to bridge
     * @param destinationChain Destination chain ID
     * @param recipient Recipient address on destination chain
     * @return txHash Transaction hash
     */
    function initiateBridge(
        address asset,
        uint256 amount,
        uint256 destinationChain,
        address recipient
    ) external nonReentrant whenNotPaused returns (bytes32 txHash) {
        if (asset == address(0) || recipient == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        if (amount == 0) {
            revert HedVaultErrors.ZeroAmount();
        }

        if (destinationChain == CURRENT_CHAIN_ID) {
            revert HedVaultErrors.InvalidParameter("destinationChain");
        }

        // Check bridge configuration
        BridgeConfig memory config = bridgeConfigs[destinationChain];
        if (!config.isActive) {
            revert HedVaultErrors.BridgeNotActive(destinationChain);
        }

        // Check asset configuration
        AssetConfig memory assetConfig = assetConfigs[asset];
        if (!assetConfig.isSupported) {
            revert HedVaultErrors.AssetNotSupported(asset);
        }

        // Validate amount
        if (amount < assetConfig.minAmount || amount > assetConfig.maxAmount) {
            revert HedVaultErrors.InvalidAmount(
                amount,
                assetConfig.minAmount,
                assetConfig.maxAmount
            );
        }

        if (
            amount < config.minTransferAmount ||
            amount > config.maxTransferAmount
        ) {
            revert HedVaultErrors.InvalidAmount(
                amount,
                config.minTransferAmount,
                config.maxTransferAmount
            );
        }

        // Check daily limits
        _checkDailyLimits(destinationChain, msg.sender, amount);

        // Calculate fees
        uint256 bridgeFee = (amount * assetConfig.bridgeFee) / 10000;
        uint256 transferAmount = amount - bridgeFee;

        // Transfer tokens to bridge
        IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);

        // Update fee collection
        bridgeFeeCollected += bridgeFee;

        // Create transaction hash
        txHash = keccak256(
            abi.encodePacked(
                nextTransactionId,
                msg.sender,
                asset,
                transferAmount,
                CURRENT_CHAIN_ID,
                destinationChain,
                block.timestamp
            )
        );

        // Store bridge transaction
        bridgeTransactions[txHash] = BridgeTransaction({
            txHash: txHash,
            user: recipient,
            asset: asset,
            amount: transferAmount,
            sourceChain: CURRENT_CHAIN_ID,
            destinationChain: destinationChain,
            timestamp: block.timestamp,
            confirmations: 0,
            isCompleted: false,
            isCancelled: false
        });

        // Update daily limits
        _updateDailyLimits(destinationChain, msg.sender, amount);

        nextTransactionId++;

        emit BridgeInitiated(
            txHash,
            msg.sender,
            asset,
            transferAmount,
            CURRENT_CHAIN_ID,
            destinationChain
        );

        return txHash;
    }

    /**
     * @notice Complete bridge transfer (destination chain)
     * @param txHash Transaction hash from source chain
     */
    function completeBridge(
        bytes32 txHash
    ) external onlyRole(BRIDGE_OPERATOR_ROLE) nonReentrant {
        BridgeTransaction storage transaction = bridgeTransactions[txHash];

        if (transaction.txHash == bytes32(0)) {
            revert HedVaultErrors.TransferNotFound(txHash);
        }

        if (transaction.isCompleted || transaction.isCancelled) {
            revert HedVaultErrors.TransferAlreadyProcessed(txHash);
        }

        if (transaction.destinationChain != CURRENT_CHAIN_ID) {
            revert HedVaultErrors.UnsupportedChain(CURRENT_CHAIN_ID);
        }

        BridgeConfig memory config = bridgeConfigs[transaction.sourceChain];
        if (transaction.confirmations < config.confirmationsRequired) {
            revert HedVaultErrors.OperationNotAllowed(
                "insufficient confirmations"
            );
        }

        // Mark as completed
        transaction.isCompleted = true;

        // Transfer tokens to user
        AssetConfig memory assetConfig = assetConfigs[transaction.asset];
        address tokenToTransfer = assetConfig.wrappedToken != address(0)
            ? assetConfig.wrappedToken
            : transaction.asset;

        IERC20(tokenToTransfer).safeTransfer(
            transaction.user,
            transaction.amount
        );

        emit BridgeCompleted(
            txHash,
            transaction.user,
            transaction.asset,
            transaction.amount
        );
    }

    /**
     * @notice Cancel bridge transfer
     * @param txHash Transaction hash
     * @param reason Cancellation reason
     */
    function cancelBridge(
        bytes32 txHash,
        string calldata reason
    ) external onlyRole(BRIDGE_OPERATOR_ROLE) {
        BridgeTransaction storage transaction = bridgeTransactions[txHash];

        if (transaction.txHash == bytes32(0)) {
            revert HedVaultErrors.TransferNotFound(txHash);
        }

        if (transaction.isCompleted || transaction.isCancelled) {
            revert HedVaultErrors.TransferAlreadyProcessed(txHash);
        }

        transaction.isCancelled = true;

        // Refund tokens if on source chain
        if (transaction.sourceChain == CURRENT_CHAIN_ID) {
            IERC20(transaction.asset).safeTransfer(
                transaction.user,
                transaction.amount
            );
        }

        emit BridgeCancelled(txHash, reason);
    }

    // Validator Functions

    /**
     * @notice Confirm bridge transaction
     * @param txHash Transaction hash
     * @param confirmed Whether to confirm or reject
     */
    function confirmTransaction(
        bytes32 txHash,
        bool confirmed
    ) external onlyRole(VALIDATOR_ROLE) {
        BridgeTransaction storage transaction = bridgeTransactions[txHash];

        if (transaction.txHash == bytes32(0)) {
            revert HedVaultErrors.TransferNotFound(txHash);
        }

        if (transaction.isCompleted || transaction.isCancelled) {
            revert HedVaultErrors.TransferAlreadyProcessed(txHash);
        }

        if (validatorConfirmations[txHash][msg.sender]) {
            revert HedVaultErrors.OperationNotAllowed("already confirmed");
        }

        validatorConfirmations[txHash][msg.sender] = true;

        if (confirmed) {
            transaction.confirmations++;
        }

        emit ValidatorConfirmation(txHash, msg.sender, confirmed);
    }

    // Message Passing

    /**
     * @notice Send cross-chain message
     * @param destinationChain Destination chain ID
     * @param data Message data
     * @return messageId Message ID
     */
    function sendMessage(
        uint256 destinationChain,
        bytes calldata data
    ) external returns (bytes32 messageId) {
        if (destinationChain == CURRENT_CHAIN_ID) {
            revert HedVaultErrors.InvalidParameter("destinationChain");
        }

        BridgeConfig memory config = bridgeConfigs[destinationChain];
        if (!config.isActive) {
            revert HedVaultErrors.BridgeNotActive(destinationChain);
        }

        messageId = keccak256(
            abi.encodePacked(
                nextMessageId,
                msg.sender,
                CURRENT_CHAIN_ID,
                destinationChain,
                data,
                block.timestamp
            )
        );

        crossChainMessages[messageId] = CrossChainMessage({
            messageId: messageId,
            sender: msg.sender,
            sourceChain: CURRENT_CHAIN_ID,
            destinationChain: destinationChain,
            data: data,
            timestamp: block.timestamp,
            isExecuted: false
        });

        nextMessageId++;

        emit MessageSent(
            messageId,
            msg.sender,
            CURRENT_CHAIN_ID,
            destinationChain,
            data
        );

        return messageId;
    }

    /**
     * @notice Execute cross-chain message
     * @param messageId Message ID
     * @param target Target contract
     */
    function executeMessage(
        bytes32 messageId,
        address target
    ) external onlyRole(BRIDGE_OPERATOR_ROLE) {
        CrossChainMessage storage message = crossChainMessages[messageId];

        if (message.messageId == bytes32(0)) {
            revert HedVaultErrors.OperationNotAllowed("message not found");
        }

        if (message.isExecuted) {
            revert HedVaultErrors.OperationNotAllowed(
                "message already executed"
            );
        }

        if (message.destinationChain != CURRENT_CHAIN_ID) {
            revert HedVaultErrors.UnsupportedChain(CURRENT_CHAIN_ID);
        }

        if (block.timestamp > message.timestamp + MESSAGE_EXPIRY) {
            revert HedVaultErrors.OperationNotAllowed("message expired");
        }

        message.isExecuted = true;

        // Execute message
        (bool success, ) = target.call(message.data);
        if (!success) {
            revert HedVaultErrors.ExternalCallFailed(target, message.data);
        }

        emit MessageExecuted(messageId, msg.sender);
    }

    // Configuration Functions

    /**
     * @notice Configure bridge for chain
     * @param chainId Chain ID
     * @param config Bridge configuration
     */
    function configureBridge(
        uint256 chainId,
        BridgeConfig calldata config
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (chainId == CURRENT_CHAIN_ID) {
            revert HedVaultErrors.InvalidParameter("chainId");
        }

        if (
            config.confirmationsRequired < MIN_CONFIRMATIONS ||
            config.confirmationsRequired > MAX_CONFIRMATIONS
        ) {
            revert HedVaultErrors.InvalidParameter("confirmationsRequired");
        }

        bridgeConfigs[chainId] = config;

        emit ChainConfigUpdated(
            chainId,
            config.isActive,
            config.minTransferAmount,
            config.maxTransferAmount
        );
    }

    /**
     * @notice Configure asset for bridging
     * @param asset Asset address
     * @param config Asset configuration
     */
    function configureAsset(
        address asset,
        AssetConfig calldata config
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (asset == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        if (config.bridgeFee > MAX_BRIDGE_FEE) {
            revert HedVaultErrors.FeeTooHigh(config.bridgeFee, MAX_BRIDGE_FEE);
        }

        assetConfigs[asset] = config;

        emit AssetConfigUpdated(
            asset,
            config.isSupported,
            config.bridgeFee,
            config.minAmount,
            config.maxAmount
        );
    }

    // Fee Management

    /**
     * @notice Collect bridge fees
     * @param asset Asset to collect fees for
     * @param amount Amount to collect
     * @param recipient Fee recipient
     */
    function collectFees(
        address asset,
        uint256 amount,
        address recipient
    ) external onlyRole(FEE_MANAGER_ROLE) {
        if (recipient == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        if (amount > bridgeFeeCollected) {
            revert HedVaultErrors.InsufficientBalance(
                asset,
                amount,
                bridgeFeeCollected
            );
        }

        bridgeFeeCollected -= amount;
        IERC20(asset).safeTransfer(recipient, amount);

        emit FeesCollected(recipient, amount);
    }

    // View Functions

    /**
     * @notice Get bridge transaction details
     * @param txHash Transaction hash
     * @return transaction Bridge transaction
     */
    function getBridgeTransaction(
        bytes32 txHash
    ) external view returns (BridgeTransaction memory transaction) {
        return bridgeTransactions[txHash];
    }

    /**
     * @notice Get cross-chain message details
     * @param messageId Message ID
     * @return message Cross-chain message
     */
    function getCrossChainMessage(
        bytes32 messageId
    ) external view returns (CrossChainMessage memory message) {
        return crossChainMessages[messageId];
    }

    /**
     * @notice Check if chain is supported
     * @param chainId Chain ID
     * @return isSupported Whether chain is supported
     */
    function isChainSupported(
        uint256 chainId
    ) external view returns (bool isSupported) {
        return bridgeConfigs[chainId].isActive;
    }

    /**
     * @notice Check if asset is supported
     * @param asset Asset address
     * @return isSupported Whether asset is supported
     */
    function isAssetSupported(
        address asset
    ) external view returns (bool isSupported) {
        return assetConfigs[asset].isSupported;
    }

    /**
     * @notice Calculate bridge fee
     * @param asset Asset address
     * @param amount Amount to bridge
     * @return fee Bridge fee
     */
    function calculateBridgeFee(
        address asset,
        uint256 amount
    ) external view returns (uint256 fee) {
        AssetConfig memory config = assetConfigs[asset];
        return (amount * config.bridgeFee) / 10000;
    }

    /**
     * @notice Get user's daily transfer limit remaining
     * @param chainId Chain ID
     * @param user User address
     * @return remaining Remaining daily limit
     */
    function getUserDailyLimitRemaining(
        uint256 chainId,
        address user
    ) external view returns (uint256 remaining) {
        BridgeConfig memory config = bridgeConfigs[chainId];

        uint256 userTransferred = userDailyTransferred[chainId][user];
        uint256 lastReset = userLastResetTime[chainId][user];

        // Reset if new day
        if (_isNewDay(lastReset)) {
            userTransferred = 0;
        }

        if (userTransferred >= config.dailyLimit) {
            return 0;
        }

        return config.dailyLimit - userTransferred;
    }

    // Internal Functions

    /**
     * @notice Check daily limits
     * @param chainId Chain ID
     * @param user User address
     * @param amount Amount to transfer
     */
    function _checkDailyLimits(
        uint256 chainId,
        address user,
        uint256 amount
    ) internal view {
        BridgeConfig memory config = bridgeConfigs[chainId];

        // Check bridge daily limit
        uint256 bridgeTransferred = config.dailyTransferred;
        if (_isNewDay(config.lastResetTime)) {
            bridgeTransferred = 0;
        }

        if (bridgeTransferred + amount > config.dailyLimit) {
            revert HedVaultErrors.DailyLimitExceeded(
                address(0),
                amount,
                config.dailyLimit
            );
        }

        // Check user daily limit
        uint256 userTransferred = userDailyTransferred[chainId][user];
        uint256 userLastReset = userLastResetTime[chainId][user];

        if (_isNewDay(userLastReset)) {
            userTransferred = 0;
        }

        if (userTransferred + amount > config.dailyLimit) {
            revert HedVaultErrors.DailyLimitExceeded(
                user,
                amount,
                config.dailyLimit
            );
        }
    }

    /**
     * @notice Update daily limits
     * @param chainId Chain ID
     * @param user User address
     * @param amount Amount transferred
     */
    function _updateDailyLimits(
        uint256 chainId,
        address user,
        uint256 amount
    ) internal {
        BridgeConfig storage config = bridgeConfigs[chainId];

        // Update bridge daily limit
        if (_isNewDay(config.lastResetTime)) {
            config.dailyTransferred = 0;
            config.lastResetTime = block.timestamp;
        }
        config.dailyTransferred += amount;

        // Update user daily limit
        if (_isNewDay(userLastResetTime[chainId][user])) {
            userDailyTransferred[chainId][user] = 0;
            userLastResetTime[chainId][user] = block.timestamp;
        }
        userDailyTransferred[chainId][user] += amount;
    }

    /**
     * @notice Check if it's a new day
     * @param lastTime Last timestamp
     * @return isNewDay Whether it's a new day
     */
    function _isNewDay(uint256 lastTime) internal view returns (bool isNewDay) {
        return (block.timestamp / 1 days) > (lastTime / 1 days);
    }

    // Emergency Functions

    /**
     * @notice Pause bridge operations
     */
    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    /**
     * @notice Unpause bridge operations
     */
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    /**
     * @notice Emergency withdraw
     * @param asset Asset to withdraw
     * @param amount Amount to withdraw
     * @param recipient Recipient address
     */
    function emergencyWithdraw(
        address asset,
        uint256 amount,
        address recipient
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (recipient == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        IERC20(asset).safeTransfer(recipient, amount);
    }
}

