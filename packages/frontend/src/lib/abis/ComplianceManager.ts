export const ComplianceManagerABI = [
  {
    "type": "constructor",
    "inputs": [
      {
        "name": "_hedVaultCore",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "_admin",
        "type": "address",
        "internalType": "address"
      }
    ],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "AML_OFFICER_ROLE",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "COMPLIANCE_ADMIN_ROLE",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "DEFAULT_ADMIN_ROLE",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "HIGH_RISK_THRESHOLD",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "KYC_OFFICER_ROLE",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "MAX_DAILY_TRANSACTION_BASIC",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "MAX_DAILY_TRANSACTION_ENHANCED",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "MAX_MONTHLY_TRANSACTION_BASIC",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "MAX_MONTHLY_TRANSACTION_ENHANCED",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "REGULATORY_ROLE",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "SUSPICIOUS_TRANSACTION_THRESHOLD",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "addJurisdiction",
    "inputs": [
      {
        "name": "jurisdiction",
        "type": "string",
        "internalType": "string"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "addToSanctionsList",
    "inputs": [
      {
        "name": "entity",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "reason",
        "type": "string",
        "internalType": "string"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "approveTransaction",
    "inputs": [
      {
        "name": "transactionId",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "authorizeReporter",
    "inputs": [
      {
        "name": "reporter",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "authorizedReporters",
    "inputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "blacklistUser",
    "inputs": [
      {
        "name": "user",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "reason",
        "type": "string",
        "internalType": "string"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "generateRegulatoryReport",
    "inputs": [
      {
        "name": "startDate",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "endDate",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "reportType",
        "type": "string",
        "internalType": "string"
      },
      {
        "name": "jurisdiction",
        "type": "string",
        "internalType": "string"
      }
    ],
    "outputs": [
      {
        "name": "reportId",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "getRegulatoryReport",
    "inputs": [
      {
        "name": "reportId",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [
      {
        "name": "report",
        "type": "tuple",
        "internalType": "struct ComplianceManager.RegulatoryReport",
        "components": [
          {
            "name": "reportId",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "startDate",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "endDate",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "totalTransactions",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "flaggedTransactions",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "totalVolume",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "reportType",
            "type": "string",
            "internalType": "string"
          },
          {
            "name": "jurisdiction",
            "type": "string",
            "internalType": "string"
          },
          {
            "name": "reportHash",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "isSubmitted",
            "type": "bool",
            "internalType": "bool"
          },
          {
            "name": "submissionDate",
            "type": "uint256",
            "internalType": "uint256"
          }
        ]
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getRemainingDailyLimit",
    "inputs": [
      {
        "name": "user",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "remainingLimit",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getRoleAdmin",
    "inputs": [
      {
        "name": "role",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getTransactionMonitoring",
    "inputs": [
      {
        "name": "transactionId",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [
      {
        "name": "monitoring",
        "type": "tuple",
        "internalType": "struct ComplianceManager.TransactionMonitoring",
        "components": [
          {
            "name": "transactionId",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "user",
            "type": "address",
            "internalType": "address"
          },
          {
            "name": "asset",
            "type": "address",
            "internalType": "address"
          },
          {
            "name": "amount",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "timestamp",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "status",
            "type": "uint8",
            "internalType": "enum ComplianceManager.TransactionStatus"
          },
          {
            "name": "riskLevel",
            "type": "uint8",
            "internalType": "enum ComplianceManager.RiskLevel"
          },
          {
            "name": "transactionType",
            "type": "string",
            "internalType": "string"
          },
          {
            "name": "flagReason",
            "type": "string",
            "internalType": "string"
          },
          {
            "name": "reviewedBy",
            "type": "address",
            "internalType": "address"
          },
          {
            "name": "reviewDate",
            "type": "uint256",
            "internalType": "uint256"
          }
        ]
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getUserCompliance",
    "inputs": [
      {
        "name": "user",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "compliance",
        "type": "tuple",
        "internalType": "struct ComplianceManager.UserCompliance",
        "components": [
          {
            "name": "level",
            "type": "uint8",
            "internalType": "enum ComplianceManager.ComplianceLevel"
          },
          {
            "name": "riskLevel",
            "type": "uint8",
            "internalType": "enum ComplianceManager.RiskLevel"
          },
          {
            "name": "isVerified",
            "type": "bool",
            "internalType": "bool"
          },
          {
            "name": "isBlacklisted",
            "type": "bool",
            "internalType": "bool"
          },
          {
            "name": "isSanctioned",
            "type": "bool",
            "internalType": "bool"
          },
          {
            "name": "verificationDate",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "lastReviewDate",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "dailyTransactionLimit",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "monthlyTransactionLimit",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "dailyTransactionVolume",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "monthlyTransactionVolume",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "lastTransactionDate",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "jurisdiction",
            "type": "string",
            "internalType": "string"
          },
          {
            "name": "kycHash",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "verifiedBy",
            "type": "address",
            "internalType": "address"
          }
        ]
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "grantRole",
    "inputs": [
      {
        "name": "role",
        "type": "bytes32",
        "internalType": "bytes32"
      },
      {
        "name": "account",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "hasRole",
    "inputs": [
      {
        "name": "role",
        "type": "bytes32",
        "internalType": "bytes32"
      },
      {
        "name": "account",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "hedVaultCore",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "contract IHedVaultCore"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "isSanctioned",
    "inputs": [
      {
        "name": "entity",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "sanctioned",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "isUserCompliant",
    "inputs": [
      {
        "name": "user",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "amount",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [
      {
        "name": "isCompliant",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "monitorTransaction",
    "inputs": [
      {
        "name": "user",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "asset",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "amount",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "transactionType",
        "type": "string",
        "internalType": "string"
      }
    ],
    "outputs": [
      {
        "name": "isApproved",
        "type": "bool",
        "internalType": "bool"
      },
      {
        "name": "transactionId",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "nextReportId",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "nextTransactionId",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "pause",
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "paused",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "postTransactionHook",
    "inputs": [
      {
        "name": "user",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "asset",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "amount",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "transactionType",
        "type": "string",
        "internalType": "string"
      },
      {
        "name": "success",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "preTransactionHook",
    "inputs": [
      {
        "name": "user",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "amount",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "transactionType",
        "type": "string",
        "internalType": "string"
      }
    ],
    "outputs": [
      {
        "name": "isAllowed",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "regulatoryReports",
    "inputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [
      {
        "name": "reportId",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "startDate",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "endDate",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "totalTransactions",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "flaggedTransactions",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "totalVolume",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "reportType",
        "type": "string",
        "internalType": "string"
      },
      {
        "name": "jurisdiction",
        "type": "string",
        "internalType": "string"
      },
      {
        "name": "reportHash",
        "type": "bytes32",
        "internalType": "bytes32"
      },
      {
        "name": "isSubmitted",
        "type": "bool",
        "internalType": "bool"
      },
      {
        "name": "submissionDate",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "rejectTransaction",
    "inputs": [
      {
        "name": "transactionId",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "reason",
        "type": "string",
        "internalType": "string"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "removeFromBlacklist",
    "inputs": [
      {
        "name": "user",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "removeFromSanctionsList",
    "inputs": [
      {
        "name": "entity",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "removeJurisdiction",
    "inputs": [
      {
        "name": "jurisdiction",
        "type": "string",
        "internalType": "string"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "renounceRole",
    "inputs": [
      {
        "name": "role",
        "type": "bytes32",
        "internalType": "bytes32"
      },
      {
        "name": "callerConfirmation",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "revokeReporter",
    "inputs": [
      {
        "name": "reporter",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "revokeRole",
    "inputs": [
      {
        "name": "role",
        "type": "bytes32",
        "internalType": "bytes32"
      },
      {
        "name": "account",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "sanctionsList",
    "inputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "entity",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "reason",
        "type": "string",
        "internalType": "string"
      },
      {
        "name": "addedDate",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "isActive",
        "type": "bool",
        "internalType": "bool"
      },
      {
        "name": "addedBy",
        "type": "address",
        "internalType": "address"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "submitRegulatoryReport",
    "inputs": [
      {
        "name": "reportId",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "supportedJurisdictions",
    "inputs": [
      {
        "name": "",
        "type": "string",
        "internalType": "string"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "supportsInterface",
    "inputs": [
      {
        "name": "interfaceId",
        "type": "bytes4",
        "internalType": "bytes4"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "transactionMonitoring",
    "inputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [
      {
        "name": "transactionId",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "user",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "asset",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "amount",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "timestamp",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "status",
        "type": "uint8",
        "internalType": "enum ComplianceManager.TransactionStatus"
      },
      {
        "name": "riskLevel",
        "type": "uint8",
        "internalType": "enum ComplianceManager.RiskLevel"
      },
      {
        "name": "transactionType",
        "type": "string",
        "internalType": "string"
      },
      {
        "name": "flagReason",
        "type": "string",
        "internalType": "string"
      },
      {
        "name": "reviewedBy",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "reviewDate",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "unpause",
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "updateUserRiskLevel",
    "inputs": [
      {
        "name": "user",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "riskLevel",
        "type": "uint8",
        "internalType": "enum ComplianceManager.RiskLevel"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "userCompliance",
    "inputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "level",
        "type": "uint8",
        "internalType": "enum ComplianceManager.ComplianceLevel"
      },
      {
        "name": "riskLevel",
        "type": "uint8",
        "internalType": "enum ComplianceManager.RiskLevel"
      },
      {
        "name": "isVerified",
        "type": "bool",
        "internalType": "bool"
      },
      {
        "name": "isBlacklisted",
        "type": "bool",
        "internalType": "bool"
      },
      {
        "name": "isSanctioned",
        "type": "bool",
        "internalType": "bool"
      },
      {
        "name": "verificationDate",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "lastReviewDate",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "dailyTransactionLimit",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "monthlyTransactionLimit",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "dailyTransactionVolume",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "monthlyTransactionVolume",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "lastTransactionDate",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "jurisdiction",
        "type": "string",
        "internalType": "string"
      },
      {
        "name": "kycHash",
        "type": "bytes32",
        "internalType": "bytes32"
      },
      {
        "name": "verifiedBy",
        "type": "address",
        "internalType": "address"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "verifyUser",
    "inputs": [
      {
        "name": "user",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "level",
        "type": "uint8",
        "internalType": "enum ComplianceManager.ComplianceLevel"
      },
      {
        "name": "jurisdiction",
        "type": "string",
        "internalType": "string"
      },
      {
        "name": "kycHash",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "event",
    "name": "ComplianceLevelUpdated",
    "inputs": [
      {
        "name": "user",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "oldLevel",
        "type": "uint8",
        "indexed": false,
        "internalType": "enum ComplianceManager.ComplianceLevel"
      },
      {
        "name": "newLevel",
        "type": "uint8",
        "indexed": false,
        "internalType": "enum ComplianceManager.ComplianceLevel"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "JurisdictionAdded",
    "inputs": [
      {
        "name": "jurisdiction",
        "type": "string",
        "indexed": false,
        "internalType": "string"
      },
      {
        "name": "addedBy",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "JurisdictionRemoved",
    "inputs": [
      {
        "name": "jurisdiction",
        "type": "string",
        "indexed": false,
        "internalType": "string"
      },
      {
        "name": "removedBy",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "Paused",
    "inputs": [
      {
        "name": "account",
        "type": "address",
        "indexed": false,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "RegulatoryReportGenerated",
    "inputs": [
      {
        "name": "reportId",
        "type": "uint256",
        "indexed": true,
        "internalType": "uint256"
      },
      {
        "name": "reportType",
        "type": "string",
        "indexed": false,
        "internalType": "string"
      },
      {
        "name": "jurisdiction",
        "type": "string",
        "indexed": false,
        "internalType": "string"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "RoleAdminChanged",
    "inputs": [
      {
        "name": "role",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      },
      {
        "name": "previousAdminRole",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      },
      {
        "name": "newAdminRole",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "RoleGranted",
    "inputs": [
      {
        "name": "role",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      },
      {
        "name": "account",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "sender",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "RoleRevoked",
    "inputs": [
      {
        "name": "role",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      },
      {
        "name": "account",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "sender",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "SanctionAdded",
    "inputs": [
      {
        "name": "entity",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "reason",
        "type": "string",
        "indexed": false,
        "internalType": "string"
      },
      {
        "name": "addedBy",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "SanctionRemoved",
    "inputs": [
      {
        "name": "entity",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "removedBy",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "TransactionApproved",
    "inputs": [
      {
        "name": "transactionId",
        "type": "uint256",
        "indexed": true,
        "internalType": "uint256"
      },
      {
        "name": "reviewedBy",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "TransactionFlagged",
    "inputs": [
      {
        "name": "transactionId",
        "type": "uint256",
        "indexed": true,
        "internalType": "uint256"
      },
      {
        "name": "user",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "reason",
        "type": "string",
        "indexed": false,
        "internalType": "string"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "TransactionRejected",
    "inputs": [
      {
        "name": "transactionId",
        "type": "uint256",
        "indexed": true,
        "internalType": "uint256"
      },
      {
        "name": "reviewedBy",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "reason",
        "type": "string",
        "indexed": false,
        "internalType": "string"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "Unpaused",
    "inputs": [
      {
        "name": "account",
        "type": "address",
        "indexed": false,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "UserBlacklisted",
    "inputs": [
      {
        "name": "user",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "reason",
        "type": "string",
        "indexed": false,
        "internalType": "string"
      },
      {
        "name": "addedBy",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "UserRemovedFromBlacklist",
    "inputs": [
      {
        "name": "user",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "removedBy",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "UserVerified",
    "inputs": [
      {
        "name": "user",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "level",
        "type": "uint8",
        "indexed": false,
        "internalType": "enum ComplianceManager.ComplianceLevel"
      },
      {
        "name": "verifiedBy",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "error",
    "name": "AccessControlBadConfirmation",
    "inputs": []
  },
  {
    "type": "error",
    "name": "AccessControlUnauthorizedAccount",
    "inputs": [
      {
        "name": "account",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "neededRole",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ]
  },
  {
    "type": "error",
    "name": "EnforcedPause",
    "inputs": []
  },
  {
    "type": "error",
    "name": "ExpectedPause",
    "inputs": []
  },
  {
    "type": "error",
    "name": "InvalidConfiguration",
    "inputs": [
      {
        "name": "parameter",
        "type": "string",
        "internalType": "string"
      }
    ]
  },
  {
    "type": "error",
    "name": "ReentrancyGuardReentrantCall",
    "inputs": []
  },
  {
    "type": "error",
    "name": "UnauthorizedAccess",
    "inputs": [
      {
        "name": "caller",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "requiredRole",
        "type": "string",
        "internalType": "string"
      }
    ]
  },
  {
    "type": "error",
    "name": "ZeroAddress",
    "inputs": []
  }
] as const;
