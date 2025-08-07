/**
 * SwapEngine Contract Hooks
 * Custom hooks for interacting with the SwapEngine smart contract
 */

import {
  useReadContract,
  useWriteContract,
  useWaitForTransactionReceipt,
} from "wagmi";
import { Address } from "viem";
import { CONTRACT_ADDRESSES, HEDERA_TESTNET_CHAIN_ID } from "@/lib/contracts";
import SwapEngineABI from "@/lib/abis/SwapEngine.json";

// Types based on SwapEngine contract
export interface LiquidityPool {
  tokenA: Address;
  tokenB: Address;
  reserveA: bigint;
  reserveB: bigint;
  totalLiquidity: bigint;
  feeRate: bigint;
  lastUpdate: bigint;
  isActive: boolean;
  minLiquidity: bigint;
  maxSlippage: bigint;
}

export interface LiquidityPosition {
  provider: Address;
  poolId: bigint;
  liquidity: bigint;
  tokenADeposited: bigint;
  tokenBDeposited: bigint;
  createdAt: bigint;
  lastRewardClaim: bigint;
  accumulatedFees: bigint;
}

export interface SwapInfo {
  swapId: bigint;
  user: Address;
  poolId: bigint;
  tokenIn: Address;
  tokenOut: Address;
  amountIn: bigint;
  amountOut: bigint;
  fee: bigint;
  slippage: bigint;
  timestamp: bigint;
  priceImpact: bigint;
}

export interface PoolStats {
  totalVolume: bigint;
  totalSwaps: bigint;
  totalFeesCollected: bigint;
  apy: bigint;
  utilization: bigint;
  lastStatsUpdate: bigint;
}

// Read Hooks
export const useGetPool = (poolId: bigint) => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "getPool",
    args: [poolId],
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useGetPoolByTokens = (tokenA: Address, tokenB: Address) => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "getPoolByTokens",
    args: [tokenA, tokenB],
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useGetPoolPositions = (poolId: bigint) => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "getPoolPositions",
    args: [poolId],
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useGetUserPositions = (user: Address) => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "getUserPositions",
    args: [user],
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useGetPoolStats = (poolId: bigint) => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "getPoolStats",
    args: [poolId],
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useGetSwapQuote = (
  poolId: bigint,
  tokenIn: Address,
  amountIn: bigint
) => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "getSwapQuote",
    args: [poolId, tokenIn, amountIn],
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: poolId > BigInt(0) && tokenIn && amountIn > BigInt(0),
    },
  });
};

export const useIsPaused = () => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "paused",
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useGetHedVaultCore = () => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "hedVaultCore",
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useGetPriceOracle = () => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "priceOracle",
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useGetFeeRecipient = () => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "feeRecipient",
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useGetDefaultFeeRate = () => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "defaultFeeRate",
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useGetProtocolFeeShare = () => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "protocolFeeShare",
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useGetTotalProtocolFees = () => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "totalProtocolFees",
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useGetNextPoolId = () => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "nextPoolId",
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useGetNextSwapId = () => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "nextSwapId",
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useGetTotalPools = () => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "totalPools",
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useIsSupportedToken = (token: Address) => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "supportedTokens",
    args: [token],
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

// Constant Hooks
export const useSwapAdminRole = () => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "SWAP_ADMIN_ROLE",
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useLiquidityManagerRole = () => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "LIQUIDITY_MANAGER_ROLE",
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useFeeManagerRole = () => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "FEE_MANAGER_ROLE",
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useEmergencyRole = () => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "EMERGENCY_ROLE",
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useDefaultAdminRole = () => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "DEFAULT_ADMIN_ROLE",
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useMinLiquidity = () => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "MIN_LIQUIDITY",
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useMaxFeeRate = () => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "MAX_FEE_RATE",
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useMaxSlippage = () => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "MAX_SLIPPAGE",
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

// Write Hooks
export const useCreatePool = () => {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const createPool = (
    tokenA: Address,
    tokenB: Address,
    amountA: bigint,
    amountB: bigint,
    feeRate: bigint
  ) => {
    writeContract({
      address: CONTRACT_ADDRESSES.SwapEngine,
      abi: SwapEngineABI,
      functionName: "createPool",
      args: [tokenA, tokenB, amountA, amountB, feeRate],
      chainId: HEDERA_TESTNET_CHAIN_ID,
      gas: BigInt(10000000), // Set high gas limit to prevent INSUFFICIENT_GAS errors
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } =
    useWaitForTransactionReceipt({
      hash,
    });

  return {
    createPool,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  };
};

export const useAddLiquidity = () => {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const addLiquidity = (
    poolId: bigint,
    amountA: bigint,
    amountB: bigint,
    minLiquidity: bigint
  ) => {
    writeContract({
      address: CONTRACT_ADDRESSES.SwapEngine,
      abi: SwapEngineABI,
      functionName: "addLiquidity",
      args: [poolId, amountA, amountB, minLiquidity],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } =
    useWaitForTransactionReceipt({
      hash,
    });

  return {
    addLiquidity,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  };
};

export const useRemoveLiquidity = () => {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const removeLiquidity = (
    poolId: bigint,
    positionIndex: bigint,
    liquidity: bigint,
    minAmountA: bigint,
    minAmountB: bigint
  ) => {
    writeContract({
      address: CONTRACT_ADDRESSES.SwapEngine,
      abi: SwapEngineABI,
      functionName: "removeLiquidity",
      args: [poolId, positionIndex, liquidity, minAmountA, minAmountB],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } =
    useWaitForTransactionReceipt({
      hash,
    });

  return {
    removeLiquidity,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  };
};

export const useSwap = () => {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const swap = (
    poolId: bigint,
    tokenIn: Address,
    amountIn: bigint,
    minAmountOut: bigint,
    maxSlippage: bigint
  ) => {
    writeContract({
      address: CONTRACT_ADDRESSES.SwapEngine,
      abi: SwapEngineABI,
      functionName: "swap",
      args: [poolId, tokenIn, amountIn, minAmountOut, maxSlippage],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } =
    useWaitForTransactionReceipt({
      hash,
    });

  return {
    swap,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  };
};

export const useAddSupportedToken = () => {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const addSupportedToken = (token: Address) => {
    writeContract({
      address: CONTRACT_ADDRESSES.SwapEngine,
      abi: SwapEngineABI,
      functionName: "addSupportedToken",
      args: [token],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } =
    useWaitForTransactionReceipt({
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
};

export const useUpdatePoolFeeRate = () => {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const updatePoolFeeRate = (poolId: bigint, newFeeRate: bigint) => {
    writeContract({
      address: CONTRACT_ADDRESSES.SwapEngine,
      abi: SwapEngineABI,
      functionName: "updatePoolFeeRate",
      args: [poolId, newFeeRate],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } =
    useWaitForTransactionReceipt({
      hash,
    });

  return {
    updatePoolFeeRate,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  };
};

export const usePause = () => {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const pause = () => {
    writeContract({
      address: CONTRACT_ADDRESSES.SwapEngine,
      abi: SwapEngineABI,
      functionName: "pause",
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } =
    useWaitForTransactionReceipt({
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
};

export const useUnpause = () => {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const unpause = () => {
    writeContract({
      address: CONTRACT_ADDRESSES.SwapEngine,
      abi: SwapEngineABI,
      functionName: "unpause",
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } =
    useWaitForTransactionReceipt({
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
};

// Role Management Hooks
export const useGrantRole = () => {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const grantRole = (role: string, account: Address) => {
    writeContract({
      address: CONTRACT_ADDRESSES.SwapEngine,
      abi: SwapEngineABI,
      functionName: "grantRole",
      args: [role, account],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } =
    useWaitForTransactionReceipt({
      hash,
    });

  return {
    grantRole,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  };
};

export const useRevokeRole = () => {
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const revokeRole = (role: string, account: Address) => {
    writeContract({
      address: CONTRACT_ADDRESSES.SwapEngine,
      abi: SwapEngineABI,
      functionName: "revokeRole",
      args: [role, account],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } =
    useWaitForTransactionReceipt({
      hash,
    });

  return {
    revokeRole,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  };
};

export const useHasRole = (role: string, account: Address) => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "hasRole",
    args: [role, account],
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};

export const useGetRoleAdmin = (role: string) => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.SwapEngine,
    abi: SwapEngineABI,
    functionName: "getRoleAdmin",
    args: [role],
    chainId: HEDERA_TESTNET_CHAIN_ID,
  });
};
