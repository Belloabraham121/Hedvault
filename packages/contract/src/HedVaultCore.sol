// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./libraries/DataTypes.sol";
import "./libraries/Events.sol";
import "./libraries/HedVaultErrors.sol";

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
