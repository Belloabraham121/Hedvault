/**
 * ComplianceManager Contract Hooks
 * Custom hooks for interacting with the ComplianceManager smart contract
 */

import { useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { Address } from 'viem';
import { ComplianceManagerABI } from '../../lib/abis';
import { CONTRACT_ADDRESSES, HEDERA_TESTNET_CHAIN_ID } from '../../lib/contracts';

// Types for ComplianceManager
export interface UserCompliance {
  level: number;
  riskLevel: number;
  isVerified: boolean;
  isBlacklisted: boolean;
  isSanctioned: boolean;
  verificationDate: bigint;
  lastReviewDate: bigint;
  dailyTransactionLimit: bigint;
  monthlyTransactionLimit: bigint;
  dailyTransactionVolume: bigint;
  monthlyTransactionVolume: bigint;
  lastTransactionDate: bigint;
  jurisdiction: string;
  kycHash: string;
  verifiedBy: Address;
}

export interface TransactionMonitoring {
  transactionId: bigint;
  user: Address;
  asset: Address;
  amount: bigint;
  timestamp: bigint;
  status: number;
  riskLevel: number;
  transactionType: string;
  flagReason: string;
  reviewedBy: Address;
  reviewDate: bigint;
}

export interface RegulatoryReport {
  reportId: bigint;
  startDate: bigint;
  endDate: bigint;
  totalTransactions: bigint;
  flaggedTransactions: bigint;
  totalVolume: bigint;
  reportType: string;
  jurisdiction: string;
  reportHash: string;
  isSubmitted: boolean;
  submissionDate: bigint;
}

// Read Hooks
export function useGetUserCompliance(userAddress?: Address) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.ComplianceManager,
    abi: ComplianceManagerABI,
    functionName: 'getUserCompliance',
    args: userAddress ? [userAddress] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!userAddress,
    },
  });
}

export function useIsUserCompliant(userAddress?: Address, amount?: bigint) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.ComplianceManager,
    abi: ComplianceManagerABI,
    functionName: 'isUserCompliant',
    args: userAddress && amount ? [userAddress, amount] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!userAddress && amount !== undefined,
    },
  });
}

export function useIsSanctioned(entityAddress?: Address) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.ComplianceManager,
    abi: ComplianceManagerABI,
    functionName: 'isSanctioned',
    args: entityAddress ? [entityAddress] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!entityAddress,
    },
  });
}

export function useGetRemainingDailyLimit(userAddress?: Address) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.ComplianceManager,
    abi: ComplianceManagerABI,
    functionName: 'getRemainingDailyLimit',
    args: userAddress ? [userAddress] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!userAddress,
    },
  });
}

export function useGetTransactionMonitoring(transactionId?: bigint) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.ComplianceManager,
    abi: ComplianceManagerABI,
    functionName: 'getTransactionMonitoring',
    args: transactionId ? [transactionId] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: transactionId !== undefined,
    },
  });
}

export function useGetRegulatoryReport(reportId?: bigint) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.ComplianceManager,
    abi: ComplianceManagerABI,
    functionName: 'getRegulatoryReport',
    args: reportId ? [reportId] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: reportId !== undefined,
    },
  });
}

// Constants Hooks
export function useComplianceConstants() {
  const { data: maxDailyBasic } = useReadContract({
    address: CONTRACT_ADDRESSES.ComplianceManager,
    abi: ComplianceManagerABI,
    functionName: 'MAX_DAILY_TRANSACTION_BASIC',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });

  const { data: maxDailyEnhanced } = useReadContract({
    address: CONTRACT_ADDRESSES.ComplianceManager,
    abi: ComplianceManagerABI,
    functionName: 'MAX_DAILY_TRANSACTION_ENHANCED',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });

  const { data: maxMonthlyBasic } = useReadContract({
    address: CONTRACT_ADDRESSES.ComplianceManager,
    abi: ComplianceManagerABI,
    functionName: 'MAX_MONTHLY_TRANSACTION_BASIC',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });

  const { data: maxMonthlyEnhanced } = useReadContract({
    address: CONTRACT_ADDRESSES.ComplianceManager,
    abi: ComplianceManagerABI,
    functionName: 'MAX_MONTHLY_TRANSACTION_ENHANCED',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });

  const { data: highRiskThreshold } = useReadContract({
    address: CONTRACT_ADDRESSES.ComplianceManager,
    abi: ComplianceManagerABI,
    functionName: 'HIGH_RISK_THRESHOLD',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });

  const { data: suspiciousThreshold } = useReadContract({
    address: CONTRACT_ADDRESSES.ComplianceManager,
    abi: ComplianceManagerABI,
    functionName: 'SUSPICIOUS_TRANSACTION_THRESHOLD',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });

  return {
    maxDailyBasic,
    maxDailyEnhanced,
    maxMonthlyBasic,
    maxMonthlyEnhanced,
    highRiskThreshold,
    suspiciousThreshold,
  };
}

// Write Hooks
export function useVerifyUser() {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const verifyUser = (user: Address, level: number, jurisdiction: string, kycHash: `0x${string}`) => {
    writeContract({
      address: CONTRACT_ADDRESSES.ComplianceManager,
      abi: ComplianceManagerABI,
      functionName: 'verifyUser',
      args: [user, level, jurisdiction, kycHash],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    verifyUser,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  };
}

export function useMonitorTransaction() {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const monitorTransaction = (user: Address, asset: Address, amount: bigint, transactionType: string) => {
    writeContract({
      address: CONTRACT_ADDRESSES.ComplianceManager,
      abi: ComplianceManagerABI,
      functionName: 'monitorTransaction',
      args: [user, asset, amount, transactionType],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    monitorTransaction,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  };
}

export function useBlacklistUser() {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const blacklistUser = (user: Address, reason: string) => {
    writeContract({
      address: CONTRACT_ADDRESSES.ComplianceManager,
      abi: ComplianceManagerABI,
      functionName: 'blacklistUser',
      args: [user, reason],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    blacklistUser,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  };
}

export function useRemoveFromBlacklist() {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const removeFromBlacklist = (user: Address) => {
    writeContract({
      address: CONTRACT_ADDRESSES.ComplianceManager,
      abi: ComplianceManagerABI,
      functionName: 'removeFromBlacklist',
      args: [user],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    removeFromBlacklist,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  };
}

export function useUpdateUserRiskLevel() {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const updateUserRiskLevel = (user: Address, riskLevel: number) => {
    writeContract({
      address: CONTRACT_ADDRESSES.ComplianceManager,
      abi: ComplianceManagerABI,
      functionName: 'updateUserRiskLevel',
      args: [user, riskLevel],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    updateUserRiskLevel,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  };
}

export function useGenerateRegulatoryReport() {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const generateRegulatoryReport = (startDate: bigint, endDate: bigint, reportType: string, jurisdiction: string) => {
    writeContract({
      address: CONTRACT_ADDRESSES.ComplianceManager,
      abi: ComplianceManagerABI,
      functionName: 'generateRegulatoryReport',
      args: [startDate, endDate, reportType, jurisdiction],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    generateRegulatoryReport,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  };
}