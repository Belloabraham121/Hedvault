// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./libraries/HedVaultErrors.sol";

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
