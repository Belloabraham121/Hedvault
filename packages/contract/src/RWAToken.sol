// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./libraries/DataTypes.sol";
import "./libraries/Events.sol";
import "./libraries/HedVaultErrors.sol";

/**
 * @title RWAToken
 * @notice Individual RWA token contract with compliance and transfer restrictions
 * @dev ERC20 token with additional features for real-world asset tokenization
 */
contract RWAToken is ERC20, ERC20Pausable, AccessControl, ReentrancyGuard {
    // Roles
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant COMPLIANCE_ROLE = keccak256("COMPLIANCE_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // Token metadata
    address public immutable creator;
    address public immutable factory;
    uint256 public immutable creationTime;

    // Transfer restrictions
    bool public transfersEnabled = true;
    mapping(address => bool) public blacklisted;
    mapping(address => bool) public whitelisted;
    bool public whitelistEnabled = false;

    // Compliance requirements
    uint8 public requiredComplianceLevel = 1;
    mapping(address => uint8) public userComplianceLevel;

    // Holder tracking
    address[] public holders;
    mapping(address => bool) public isHolder;
    uint256 public holderCount;

    // Transfer limits
    uint256 public maxTransferAmount;
    uint256 public dailyTransferLimit;
    mapping(address => uint256) public dailyTransferred;
    mapping(address => uint256) public lastTransferDay;

    // Dividend/reward tracking
    uint256 public totalDividendsDistributed;
    mapping(address => uint256) public dividendsClaimed;

    // Events
    event TransfersEnabled(bool enabled);
    event UserBlacklisted(address indexed user, bool blacklisted);
    event UserWhitelisted(address indexed user, bool whitelisted);
    event WhitelistEnabled(bool enabled);
    event ComplianceLevelUpdated(address indexed user, uint8 level);
    event RequiredComplianceLevelUpdated(uint8 level);
    event TransferLimitUpdated(uint256 maxAmount, uint256 dailyLimit);
    event DividendDistributed(uint256 amount, uint256 totalHolders);
    event DividendClaimed(address indexed user, uint256 amount);

    modifier onlyFactory() {
        if (msg.sender != factory) {
            revert HedVaultErrors.UnauthorizedAccess(msg.sender, "factory");
        }
        _;
    }

    modifier onlyCreatorOrAdmin() {
        if (msg.sender != creator && !hasRole(ADMIN_ROLE, msg.sender)) {
            revert HedVaultErrors.UnauthorizedAccess(
                msg.sender,
                "creator or admin"
            );
        }
        _;
    }

    modifier transferAllowed(
        address from,
        address to,
        uint256 amount
    ) {
        _checkTransferAllowed(from, to, amount);
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        address _creator,
        address _factory
    ) ERC20(name, symbol) {
        if (_creator == address(0) || _factory == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }
        if (totalSupply == 0) {
            revert HedVaultErrors.ZeroAmount();
        }

        creator = _creator;
        factory = _factory;
        creationTime = block.timestamp;

        // Set up roles
        _grantRole(DEFAULT_ADMIN_ROLE, _creator);
        _grantRole(ADMIN_ROLE, _creator);
        _grantRole(MINTER_ROLE, _creator);
        _grantRole(BURNER_ROLE, _creator);
        _grantRole(COMPLIANCE_ROLE, _factory);

        // Mint initial supply to creator
        _mint(_creator, totalSupply);

        // Add creator as first holder
        _addHolder(_creator);

        // Set initial transfer limits (can be updated later)
        maxTransferAmount = totalSupply / 10; // 10% of total supply
        dailyTransferLimit = totalSupply / 100; // 1% of total supply per day
    }

    /**
     * @notice Transfer tokens with compliance checks
     * @param to Recipient address
     * @param amount Amount to transfer
     * @return success True if transfer successful
     */
    function transfer(
        address to,
        uint256 amount
    ) public override transferAllowed(msg.sender, to, amount) returns (bool) {
        _updateHolders(msg.sender, to, amount);
        _updateDailyTransfer(msg.sender, amount);
        return super.transfer(to, amount);
    }

    /**
     * @notice Transfer tokens from one address to another with compliance checks
     * @param from Sender address
     * @param to Recipient address
     * @param amount Amount to transfer
     * @return success True if transfer successful
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override transferAllowed(from, to, amount) returns (bool) {
        _updateHolders(from, to, amount);
        _updateDailyTransfer(from, amount);
        return super.transferFrom(from, to, amount);
    }

    /**
     * @notice Mint new tokens (only for authorized roles)
     * @param to Recipient address
     * @param amount Amount to mint
     */
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        if (to == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }
        if (amount == 0) {
            revert HedVaultErrors.ZeroAmount();
        }

        _mint(to, amount);
        _addHolder(to);
    }

    /**
     * @notice Burn tokens (only for authorized roles)
     * @param from Address to burn from
     * @param amount Amount to burn
     */
    function burn(address from, uint256 amount) external onlyRole(BURNER_ROLE) {
        if (from == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }
        if (amount == 0) {
            revert HedVaultErrors.ZeroAmount();
        }

        _burn(from, amount);
        _updateHolderOnBurn(from);
    }

    /**
     * @notice Enable or disable transfers
     * @param enabled Whether transfers should be enabled
     */
    function setTransfersEnabled(bool enabled) external onlyCreatorOrAdmin {
        transfersEnabled = enabled;
        emit TransfersEnabled(enabled);
    }

    /**
     * @notice Blacklist or unblacklist a user
     * @param user User address
     * @param _blacklisted Whether user should be blacklisted
     */
    function setBlacklisted(
        address user,
        bool _blacklisted
    ) external onlyRole(COMPLIANCE_ROLE) {
        blacklisted[user] = _blacklisted;
        emit UserBlacklisted(user, _blacklisted);
    }

    /**
     * @notice Whitelist or remove from whitelist a user
     * @param user User address
     * @param _whitelisted Whether user should be whitelisted
     */
    function setWhitelisted(
        address user,
        bool _whitelisted
    ) external onlyRole(COMPLIANCE_ROLE) {
        whitelisted[user] = _whitelisted;
        emit UserWhitelisted(user, _whitelisted);
    }

    /**
     * @notice Enable or disable whitelist requirement
     * @param enabled Whether whitelist should be required
     */
    function setWhitelistEnabled(bool enabled) external onlyCreatorOrAdmin {
        whitelistEnabled = enabled;
        emit WhitelistEnabled(enabled);
    }

    /**
     * @notice Update user compliance level
     * @param user User address
     * @param level Compliance level
     */
    function setUserComplianceLevel(
        address user,
        uint8 level
    ) external onlyRole(COMPLIANCE_ROLE) {
        userComplianceLevel[user] = level;
        emit ComplianceLevelUpdated(user, level);
    }

    /**
     * @notice Update required compliance level
     * @param level Required compliance level
     */
    function setRequiredComplianceLevel(
        uint8 level
    ) external onlyCreatorOrAdmin {
        requiredComplianceLevel = level;
        emit RequiredComplianceLevelUpdated(level);
    }

    /**
     * @notice Update transfer limits
     * @param _maxTransferAmount Maximum transfer amount
     * @param _dailyTransferLimit Daily transfer limit
     */
    function setTransferLimits(
        uint256 _maxTransferAmount,
        uint256 _dailyTransferLimit
    ) external onlyCreatorOrAdmin {
        maxTransferAmount = _maxTransferAmount;
        dailyTransferLimit = _dailyTransferLimit;
        emit TransferLimitUpdated(_maxTransferAmount, _dailyTransferLimit);
    }

    /**
     * @notice Distribute dividends to all holders
     * @dev This is a simplified implementation - in practice, you'd want more sophisticated dividend distribution
     */
    function distributeDividends() external payable onlyCreatorOrAdmin {
        if (msg.value == 0) {
            revert HedVaultErrors.ZeroAmount();
        }

        totalDividendsDistributed += msg.value;
        emit DividendDistributed(msg.value, holderCount);
    }

    /**
     * @notice Claim dividends (simplified implementation)
     * @dev In practice, this would calculate proportional dividends based on holdings
     */
    function claimDividends() external nonReentrant {
        if (!isHolder[msg.sender]) {
            revert HedVaultErrors.AssetNotInPortfolio(
                msg.sender,
                address(this)
            );
        }

        // Simplified dividend calculation - in practice, this would be more complex
        uint256 userBalance = balanceOf(msg.sender);
        uint256 totalSupply = totalSupply();
        uint256 dividendShare = (totalDividendsDistributed * userBalance) /
            totalSupply;
        uint256 claimableAmount = dividendShare - dividendsClaimed[msg.sender];

        if (claimableAmount == 0) {
            revert HedVaultErrors.RewardAlreadyClaimed(msg.sender, 0);
        }

        dividendsClaimed[msg.sender] += claimableAmount;

        (bool success, ) = payable(msg.sender).call{value: claimableAmount}("");
        if (!success) {
            revert HedVaultErrors.RewardDistributionFailed("Transfer failed");
        }

        emit DividendClaimed(msg.sender, claimableAmount);
    }

    /**
     * @notice Pause the contract
     */
    function pause() external onlyCreatorOrAdmin {
        _pause();
    }

    /**
     * @notice Unpause the contract
     */
    function unpause() external onlyCreatorOrAdmin {
        _unpause();
    }

    // View functions
    function getHolders() external view returns (address[] memory) {
        return holders;
    }

    function getHolderCount() external view returns (uint256) {
        return holderCount;
    }

    function getDailyTransferred(address user) external view returns (uint256) {
        if (_getCurrentDay() != lastTransferDay[user]) {
            return 0;
        }
        return dailyTransferred[user];
    }

    function getClaimableDividends(
        address user
    ) external view returns (uint256) {
        if (!isHolder[user]) {
            return 0;
        }

        uint256 userBalance = balanceOf(user);
        uint256 _totalSupply = totalSupply();
        uint256 dividendShare = (totalDividendsDistributed * userBalance) /
            _totalSupply;
        return dividendShare - dividendsClaimed[user];
    }

    // Internal functions
    function _checkTransferAllowed(
        address from,
        address to,
        uint256 amount
    ) internal view {
        if (!transfersEnabled) {
            revert HedVaultErrors.OperationNotAllowed("transfers disabled");
        }

        if (blacklisted[from] || blacklisted[to]) {
            revert HedVaultErrors.UserSuspended(blacklisted[from] ? from : to);
        }

        if (whitelistEnabled && (!whitelisted[from] || !whitelisted[to])) {
            revert HedVaultErrors.InsufficientComplianceLevel(
                !whitelisted[from] ? from : to,
                1,
                0
            );
        }

        if (
            userComplianceLevel[from] < requiredComplianceLevel ||
            userComplianceLevel[to] < requiredComplianceLevel
        ) {
            revert HedVaultErrors.InsufficientComplianceLevel(
                userComplianceLevel[from] < requiredComplianceLevel ? from : to,
                requiredComplianceLevel,
                userComplianceLevel[from] < requiredComplianceLevel
                    ? userComplianceLevel[from]
                    : userComplianceLevel[to]
            );
        }

        if (amount > maxTransferAmount) {
            revert HedVaultErrors.TransactionTooLarge(
                amount,
                maxTransferAmount
            );
        }

        // Check daily transfer limit
        uint256 currentDay = _getCurrentDay();
        uint256 dailyAmount = dailyTransferred[from];
        if (currentDay != lastTransferDay[from]) {
            dailyAmount = 0;
        }

        if (dailyAmount + amount > dailyTransferLimit) {
            revert HedVaultErrors.DailyLimitExceeded(
                from,
                dailyAmount + amount,
                dailyTransferLimit
            );
        }
    }

    function _updateHolders(address from, address to, uint256 amount) internal {
        // Add recipient as holder if they don't have tokens
        if (balanceOf(to) == 0 && amount > 0) {
            _addHolder(to);
        }

        // Remove sender as holder if they're transferring all tokens
        if (balanceOf(from) == amount && amount > 0) {
            _removeHolder(from);
        }
    }

    function _updateHolderOnBurn(address from) internal {
        if (balanceOf(from) == 0) {
            _removeHolder(from);
        }
    }

    function _addHolder(address holder) internal {
        if (!isHolder[holder]) {
            isHolder[holder] = true;
            holders.push(holder);
            holderCount++;
        }
    }

    function _removeHolder(address holder) internal {
        if (isHolder[holder]) {
            isHolder[holder] = false;
            holderCount--;

            // Remove from holders array
            for (uint256 i = 0; i < holders.length; i++) {
                if (holders[i] == holder) {
                    holders[i] = holders[holders.length - 1];
                    holders.pop();
                    break;
                }
            }
        }
    }

    function _updateDailyTransfer(address from, uint256 amount) internal {
        uint256 currentDay = _getCurrentDay();
        if (currentDay != lastTransferDay[from]) {
            dailyTransferred[from] = 0;
            lastTransferDay[from] = currentDay;
        }
        dailyTransferred[from] += amount;
    }

    function _getCurrentDay() internal view returns (uint256) {
        return block.timestamp / 1 days;
    }

    // Override required by Solidity for OpenZeppelin v5
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Pausable) {
        if (from != address(0) && to != address(0)) {
            _checkTransferAllowed(from, to, amount);
            _updateDailyTransfer(from, amount);
        }

        super._update(from, to, amount);

        if (from != address(0) || to != address(0)) {
            _updateHolders(from, to, amount);
        }

        if (to == address(0)) {
            _updateHolderOnBurn(from);
        }
    }

    // Support for receiving ETH (for dividends)
    receive() external payable {}
}
