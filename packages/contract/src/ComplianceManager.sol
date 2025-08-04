// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./libraries/DataTypes.sol";
import "./libraries/Events.sol";
import "./libraries/HedVaultErrors.sol";
import "./interfaces/IHedVaultCore.sol";

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
