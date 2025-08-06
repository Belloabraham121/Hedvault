/**
 * LendingPool Contract Hooks
 * Custom hooks for interacting with the LendingPool smart contract
 */

import { useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { Address } from 'viem';
import { LendingPoolABI } from '../../lib/abis';
import { CONTRACT_ADDRESSES, HEDERA_TESTNET_CHAIN_ID } from '../../lib/contracts';

// Types
export interface PoolInfo {
  totalDeposits: bigint;
  totalBorrows: bigint;
  totalReserves: bigint;
  lastUpdateTime: bigint;
  isActive: boolean;
  borrowingEnabled: boolean;
  depositsEnabled: boolean;
}

export interface LoanInfo {
  loanId: bigint;
  borrower: string;
  collateralToken: string;
  borrowToken: string;
  collateralAmount: bigint;
  borrowAmount: bigint;
  interestRate: bigint;
  startTime: bigint;
  lastUpdateTime: bigint;
  accruedInterest: bigint;
  status: number;
  liquidationThreshold: bigint;
}

// Read Hooks - Pool Information
export function useGetPoolInfo(token?: Address) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.LendingPool,
    abi: LendingPoolABI,
    functionName: 'getPoolInfo',
    args: token ? [token] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!token,
    },
  }) as { data: PoolInfo | undefined; isLoading: boolean; error: Error | null };
}

export function useGetLoanInfo(loanId?: bigint) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.LendingPool,
    abi: LendingPoolABI,
    functionName: 'getLoanInfo',
    args: loanId ? [loanId] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!loanId,
    },
  }) as { data: LoanInfo | undefined; isLoading: boolean; error: Error | null };
}

export function useGetUserLoans(user?: Address) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.LendingPool,
    abi: LendingPoolABI,
    functionName: 'getUserLoans',
    args: user ? [user] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!user,
    },
  });
}

export function useGetUserBalance(user?: Address, token?: Address) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.LendingPool,
    abi: LendingPoolABI,
    functionName: 'getUserBalance',
    args: user && token ? [user, token] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!user && !!token,
    },
  });
}

export function useGetLoanHealthFactor(loanId?: bigint) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.LendingPool,
    abi: LendingPoolABI,
    functionName: 'getLoanHealthFactor',
    args: loanId ? [loanId] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!loanId,
    },
  });
}

export function useCanBorrow(user?: Address, token?: Address, amount?: bigint) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.LendingPool,
    abi: LendingPoolABI,
    functionName: 'canBorrow',
    args: user && token && amount ? [user, token, amount] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!user && !!token && !!amount,
    },
  });
}

export function useGetUtilizationRate(asset?: Address) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.LendingPool,
    abi: LendingPoolABI,
    functionName: 'getUtilizationRate',
    args: asset ? [asset] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!asset,
    },
  });
}

export function useGetSupplyAPY(token?: Address) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.LendingPool,
    abi: LendingPoolABI,
    functionName: 'getSupplyAPY',
    args: token ? [token] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!token,
    },
  });
}

export function useGetBorrowAPY(token?: Address) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.LendingPool,
    abi: LendingPoolABI,
    functionName: 'getBorrowAPY',
    args: token ? [token] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!token,
    },
  });
}

export function useGetCollateralFactor(token?: Address) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.LendingPool,
    abi: LendingPoolABI,
    functionName: 'collateralFactors',
    args: token ? [token] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!token,
    },
  });
}

export function useGetLiquidationBonus(token?: Address) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.LendingPool,
    abi: LendingPoolABI,
    functionName: 'liquidationBonuses',
    args: token ? [token] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!token,
    },
  });
}

export function useGetNextLoanId() {
  return useReadContract({
    address: CONTRACT_ADDRESSES.LendingPool,
    abi: LendingPoolABI,
    functionName: 'nextLoanId',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
}

// Read Hooks - Protocol State
export function useIsPaused() {
  return useReadContract({
    address: CONTRACT_ADDRESSES.LendingPool,
    abi: LendingPoolABI,
    functionName: 'paused',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
}

export function useGetPriceOracle() {
  return useReadContract({
    address: CONTRACT_ADDRESSES.LendingPool,
    abi: LendingPoolABI,
    functionName: 'priceOracle',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
}

export function useGetHedVaultCore() {
  return useReadContract({
    address: CONTRACT_ADDRESSES.LendingPool,
    abi: LendingPoolABI,
    functionName: 'hedVaultCore',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
}

export function useGetFeeRecipient() {
  return useReadContract({
    address: CONTRACT_ADDRESSES.LendingPool,
    abi: LendingPoolABI,
    functionName: 'feeRecipient',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
}

// Write Hooks - User Actions
export function useDeposit() {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const deposit = (token: Address, amount: bigint) => {
    writeContract({
      address: CONTRACT_ADDRESSES.LendingPool,
      abi: LendingPoolABI,
      functionName: 'deposit',
      args: [token, amount],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    deposit,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  };
}

export function useWithdraw() {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const withdraw = (token: Address, amount: bigint) => {
    writeContract({
      address: CONTRACT_ADDRESSES.LendingPool,
      abi: LendingPoolABI,
      functionName: 'withdraw',
      args: [token, amount],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    withdraw,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  };
}

export function useCreateLoan() {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const createLoan = (collateralToken: Address, borrowToken: Address, collateralAmount: bigint, borrowAmount: bigint) => {
    writeContract({
      address: CONTRACT_ADDRESSES.LendingPool,
      abi: LendingPoolABI,
      functionName: 'createLoan',
      args: [collateralToken, borrowToken, collateralAmount, borrowAmount],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    createLoan,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  };
}

export function useRepayLoan() {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const repayLoan = (loanId: bigint, amount: bigint) => {
    writeContract({
      address: CONTRACT_ADDRESSES.LendingPool,
      abi: LendingPoolABI,
      functionName: 'repayLoan',
      args: [loanId, amount],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    repayLoan,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  };
}

export function useLiquidateLoan() {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const liquidateLoan = (loanId: bigint, repayAmount: bigint) => {
    writeContract({
      address: CONTRACT_ADDRESSES.LendingPool,
      abi: LendingPoolABI,
      functionName: 'liquidateLoan',
      args: [loanId, repayAmount],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    liquidateLoan,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  };
}

// Write Hooks - Admin Functions
export function useAddSupportedToken() {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const addSupportedToken = (token: Address, collateralFactor: bigint, liquidationBonus: bigint) => {
    writeContract({
      address: CONTRACT_ADDRESSES.LendingPool,
      abi: LendingPoolABI,
      functionName: 'addSupportedToken',
      args: [token, collateralFactor, liquidationBonus],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    addSupportedToken,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  };
}

export function useUpdateFeeRecipient() {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const updateFeeRecipient = (newFeeRecipient: Address) => {
    writeContract({
      address: CONTRACT_ADDRESSES.LendingPool,
      abi: LendingPoolABI,
      functionName: 'updateFeeRecipient',
      args: [newFeeRecipient],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    updateFeeRecipient,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  };
}

export function usePause() {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const pause = () => {
    writeContract({
      address: CONTRACT_ADDRESSES.LendingPool,
      abi: LendingPoolABI,
      functionName: 'pause',
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    pause,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  };
}

export function useUnpause() {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const unpause = () => {
    writeContract({
      address: CONTRACT_ADDRESSES.LendingPool,
      abi: LendingPoolABI,
      functionName: 'unpause',
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  });

  return {
    unpause,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  };
}