"use client";

import React, { useState, useEffect } from "react";
import { ArrowLeftRight, Info, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { SwapInput } from "../ui/swap-input";
import { usePredefinedRWATokens } from "@/hooks/usePredefinedRWATokens";
import {
  useSwap,
  useGetSwapQuote,
  useGetPoolByTokens,
  useGetNextPoolId,
  useIsSupportedToken,
  useAddSupportedToken,
  useCreatePool,
} from "@/hooks/useSwapEngine";
import { parseUnits, formatUnits, Address } from "viem";
import { useAccount } from "wagmi";
import { toast } from "sonner";

export function SwapTab() {
  const [fromValue, setFromValue] = useState("");
  const [toValue, setToValue] = useState("");
  const [fromAsset, setFromAsset] = useState<string | null>(null);
  const [toAsset, setToAsset] = useState<string | null>(null);
  const [slippage] = useState("0.5");

  const { tokens } = usePredefinedRWATokens();
  const { isConnected } = useAccount();

  // Filter tokens to show all available RWA tokens (HVGOLD, HVSILVER, HVRE)
  const supportedTokens = tokens.filter(
    (token) =>
      token.symbol === "HVGOLD" ||
      token.symbol === "HVSILVER" ||
      token.symbol === "HVRE"
  );

  // Log available tokens for debugging
  useEffect(() => {
    console.log("🪙 Available tokens:", {
      allTokens: tokens.map((t) => ({
        symbol: t.symbol,
        type: t.type,
        address: t.address,
      })),
      supportedTokens: supportedTokens.map((t) => ({
        symbol: t.symbol,
        type: t.type,
        address: t.address,
      })),
      tokenCount: tokens.length,
      supportedCount: supportedTokens.length,
    });
  }, [tokens, supportedTokens]);

  // Get token addresses for swap
  const fromToken = supportedTokens.find((t) => t.type === fromAsset);
  const toToken = supportedTokens.find((t) => t.type === toAsset);

  // Override token addresses with correct ones for swap
  const CORRECT_TOKEN_ADDRESSES = {
    GOLD: "0x0000000000000000000000000000000000636359",
    SILVER: "0x00000000000000000000000000000000006363ad",
  };

  // Get corrected token addresses
  const getCorrectedTokenAddress = (tokenType: string | null) => {
    if (tokenType === "GOLD") return CORRECT_TOKEN_ADDRESSES.GOLD;
    if (tokenType === "SILVER") return CORRECT_TOKEN_ADDRESSES.SILVER;
    return supportedTokens.find((t) => t.type === tokenType)?.address;
  };

  // Use corrected addresses for swap
  const fromTokenAddress = getCorrectedTokenAddress(fromAsset);
  const toTokenAddress = getCorrectedTokenAddress(toAsset);

  // Check if tokens are supported by the SwapEngine
  const { data: isFromTokenSupported } = useIsSupportedToken(
    fromTokenAddress as Address
  );
  const { data: isToTokenSupported } = useIsSupportedToken(
    toTokenAddress as Address
  );
  const {
    addSupportedToken,
    isPending: isAddingToken,
    isConfirmed: tokenAdded,
  } = useAddSupportedToken();
  const {
    createPool,
    isPending: isCreatingPool,
    isConfirmed: poolCreated,
    hash: createPoolHash,
  } = useCreatePool();

  // Types for pool data
  interface PoolData {
    tokenA: string;
    tokenB: string;
    poolId: string;
    timestamp: number;
  }

  // LocalStorage functions for pool data
  const savePoolToLocalStorage = (
    tokenA: string,
    tokenB: string,
    poolId: string
  ) => {
    const poolData: PoolData = {
      tokenA,
      tokenB,
      poolId,
      timestamp: Date.now(),
    };
    const existingPools: PoolData[] = JSON.parse(
      localStorage.getItem("hedvault_pools") || "[]"
    );

    // Remove existing pool data for this pair (in either direction)
    const filteredPools = existingPools.filter(
      (pool: PoolData) =>
        !(
          (pool.tokenA === tokenA && pool.tokenB === tokenB) ||
          (pool.tokenA === tokenB && pool.tokenB === tokenA)
        )
    );

    filteredPools.push(poolData);
    localStorage.setItem("hedvault_pools", JSON.stringify(filteredPools));
    console.log("💾 Pool saved to localStorage:", poolData);
  };

  const getPoolFromLocalStorage = (
    tokenA: string,
    tokenB: string
  ): PoolData | undefined => {
    const existingPools: PoolData[] = JSON.parse(
      localStorage.getItem("hedvault_pools") || "[]"
    );
    return existingPools.find(
      (pool: PoolData) =>
        (pool.tokenA === tokenA && pool.tokenB === tokenB) ||
        (pool.tokenA === tokenB && pool.tokenB === tokenA)
    );
  };

  // Log token support status
  useEffect(() => {
    console.log("🔍 Token support status:", {
      fromTokenAddress,
      toTokenAddress,
      isFromTokenSupported,
      isToTokenSupported,
      bothTokensSupported: isFromTokenSupported && isToTokenSupported,
    });
  }, [
    fromTokenAddress,
    toTokenAddress,
    isFromTokenSupported,
    isToTokenSupported,
  ]);

  // Function to add unsupported tokens
  const handleAddSupportedTokens = async () => {
    try {
      if (fromTokenAddress && !isFromTokenSupported) {
        console.log("➕ Adding support for fromToken:", fromTokenAddress);
        addSupportedToken(fromTokenAddress as Address);
      }
      if (toTokenAddress && !isToTokenSupported) {
        console.log("➕ Adding support for toToken:", toTokenAddress);
        addSupportedToken(toTokenAddress as Address);
      }
    } catch (error) {
      console.error("❌ Error adding token support:", error);
      toast.error("Failed to add token support");
    }
  };

  // Show success message when tokens are added
  useEffect(() => {
    if (tokenAdded) {
      console.log("✅ Token support added successfully!");
      toast.success("Token support added successfully!");
    }
  }, [tokenAdded]);

  // Debug: Check nextPoolId and actual pool existence
  const { data: nextPoolIdData } = useGetNextPoolId();

  // Handle pool creation
  const handleCreatePool = async () => {
    if (!fromTokenAddress || !toTokenAddress || !fromValue) {
      toast.error("Please select tokens and enter an amount");
      return;
    }

    try {
      const amountA = parseUnits(fromValue, 18);
      const amountB = parseUnits(fromValue, 18); // Using same amount for both tokens
      const feeRate = BigInt(300); // 3% fee rate (300 basis points)

      console.log("🏊 Creating pool with:", {
        tokenA: fromTokenAddress,
        tokenB: toTokenAddress,
        amountA: amountA.toString(),
        amountB: amountB.toString(),
        feeRate: feeRate.toString(),
      });

      createPool(
        fromTokenAddress as Address,
        toTokenAddress as Address,
        amountA,
        amountB,
        feeRate
      );

      toast.success("Pool creation initiated!");
    } catch (error) {
      console.error("❌ Error creating pool:", error);
      toast.error("Failed to create pool");
    }
  };

  // Monitor pool creation events and save to localStorage
  useEffect(() => {
    if (poolCreated && createPoolHash && fromTokenAddress && toTokenAddress) {
      console.log("🎉 Pool created successfully! Hash:", createPoolHash);

      // Extract pool ID from transaction logs (this would need to be implemented based on the actual event structure)
      // For now, we'll use the next pool ID as an approximation
      const estimatedPoolId = nextPoolIdData
        ? (nextPoolIdData as bigint).toString()
        : Date.now().toString();

      savePoolToLocalStorage(fromTokenAddress, toTokenAddress, estimatedPoolId);
      toast.success(
        `Pool created successfully! Pool ID: ${estimatedPoolId.slice(0, 10)}...`
      );

      // Log the event details
      console.log("📊 Pool Creation Event:", {
        tokenA: fromTokenAddress,
        tokenB: toTokenAddress,
        poolId: estimatedPoolId,
        transactionHash: createPoolHash,
        timestamp: new Date().toISOString(),
      });
    }
  }, [
    poolCreated,
    createPoolHash,
    fromTokenAddress,
    toTokenAddress,
    savePoolToLocalStorage,
    nextPoolIdData,
  ]);

  // Log token selection for debugging
  useEffect(() => {
    console.log("🎯 Token selection debug:", {
      fromAsset,
      toAsset,
      fromToken: fromToken
        ? {
            symbol: fromToken.symbol,
            address: fromToken.address,
            type: fromToken.type,
          }
        : null,
      toToken: toToken
        ? {
            symbol: toToken.symbol,
            address: toToken.address,
            type: toToken.type,
          }
        : null,
      hasFromToken: !!fromToken,
      hasToToken: !!toToken,
      fromTokenAddress,
      toTokenAddress,
    });
  }, [
    fromAsset,
    toAsset,
    fromToken,
    toToken,
    fromTokenAddress,
    toTokenAddress,
  ]);

  // Get pool information dynamically instead of using hardcoded pool ID
  const {
    data: poolData,
    error: poolError,
    isLoading: poolLoading,
  } = useGetPoolByTokens(
    fromTokenAddress as Address,
    toTokenAddress as Address
  );

  // Check localStorage for existing pool data
  const localPoolData =
    fromTokenAddress && toTokenAddress
      ? getPoolFromLocalStorage(fromTokenAddress, toTokenAddress)
      : null;

  // Use the actual pool ID for HVSILV/HVGOLD pair, fallback to localStorage, then dynamic detection
  const knownPoolId = BigInt(
    "0xf91ed1b328aa7736110334f0687e7904734786118bac577039dd662f566f04e2"
  );
  const poolId = poolData
    ? (poolData as bigint)
    : localPoolData
    ? BigInt(localPoolData.poolId)
    : knownPoolId;

  // Log localStorage pool data
  useEffect(() => {
    if (localPoolData) {
      console.log("💾 Found pool in localStorage:", localPoolData);
    }
  }, [localPoolData]);

  // Log pool data for debugging
  useEffect(() => {
    console.log("🏊 Pool data debug:", {
      fromTokenAddress,
      toTokenAddress,
      poolData,
      poolDataType: typeof poolData,
      poolDataArray: Array.isArray(poolData),
      poolError,
      poolLoading,
      hasTokens: !!(fromTokenAddress && toTokenAddress),
      contractAddress: "0x4536b242ea3d3b5c412f5db159353b7ca6ed003e",
      errorDetails: poolError
        ? {
            name: poolError.name,
            message: poolError.message,
            cause: poolError.cause,
          }
        : null,
    });
  }, [poolData, poolError, poolLoading, fromTokenAddress, toTokenAddress]);

  console.log("🆔 Using dynamic Pool ID:", {
    poolId: poolId.toString(),
    hasValidPool: poolId > BigInt(0),
    originalPoolData:
      poolData && Array.isArray(poolData) && poolData.length > 0
        ? poolData[0].toString()
        : "none",
    poolExists: poolId > BigInt(0),
  });

  // Get swap quote only if we have a valid pool
  const { data: quoteData, error: quoteError } = useGetSwapQuote(
    poolId,
    fromTokenAddress as Address,
    fromValue ? parseUnits(fromValue, 18) : BigInt(0)
  );

  // Log quote data for debugging
  useEffect(() => {
    console.log("💰 Quote data debug:", {
      quoteData,
      quoteDataType: typeof quoteData,
      quoteError,
      fromValue,
      poolIdUsed: poolId.toString(),
      hasValidInputs: !!(fromTokenAddress && fromValue && poolId > BigInt(0)),
      poolExists: poolId > BigInt(0),
      shouldGetQuote: poolId > BigInt(0) && fromValue && fromTokenAddress,
      errorDetails: quoteError
        ? {
            name: quoteError.name,
            message: quoteError.message,
            cause: quoteError.cause,
          }
        : null,
    });
  }, [quoteData, quoteError, fromValue, poolId, fromTokenAddress]);

  // Manual test to check if pools exist with hardcoded addresses
  useEffect(() => {
    const testPoolExists = async () => {
      try {
        console.log("🧪 Manual pool test with corrected addresses:");
        console.log("GOLD:", CORRECT_TOKEN_ADDRESSES.GOLD);
        console.log("SILVER:", CORRECT_TOKEN_ADDRESSES.SILVER);
        console.log("fromTokenAddress:", fromTokenAddress);
        console.log("toTokenAddress:", toTokenAddress);
        console.log("🔢 NextPoolId from contract:", nextPoolIdData?.toString());
        console.log("🆔 Hardcoded poolId:", poolId.toString());
        console.log(
          "❓ Is hardcoded poolId valid?",
          nextPoolIdData
            ? poolId < (nextPoolIdData as bigint) && poolId > BigInt(0)
            : "unknown"
        );
      } catch (error) {
        console.error("❌ Manual test error:", error);
      }
    };
    testPoolExists();
  }, [
    fromTokenAddress,
    toTokenAddress,
    nextPoolIdData,
    poolId,
    CORRECT_TOKEN_ADDRESSES.GOLD,
    CORRECT_TOKEN_ADDRESSES.SILVER,
  ]);

  // Use swap hook
  const { swap, isPending, isConfirming, isConfirmed, error, hash } = useSwap();

  const handleSwapAssets = () => {
    const tempAsset = fromAsset;
    const tempValue = fromValue;
    setFromAsset(toAsset);
    setToAsset(tempAsset);
    setFromValue(toValue);
    setToValue(tempValue);
  };

  // Update toValue when quote changes
  useEffect(() => {
    if (quoteData && fromValue) {
      const quotedAmount = formatUnits(quoteData as bigint, 18);
      setToValue(quotedAmount);
    } else if (fromValue && !quoteData) {
      // If we have fromValue but no quote data, show estimated value
      setToValue("Calculating...");
    } else {
      setToValue("");
    }
  }, [quoteData, fromValue]);

  const getAssetDisplayName = (assetType: string | null) => {
    if (!assetType) return "Select Asset";
    const token = supportedTokens.find((t) => t.type === assetType);
    return token ? token.symbol : "Select Asset";
  };

  // Calculate if swap is possible
  // Note: We don't require quoteData to be truthy since it might fail due to low liquidity
  // but we still want to allow users to attempt the swap if tokens are supported
  const bothTokensSupported = isFromTokenSupported && isToTokenSupported;
  const canSwap =
    fromValue &&
    fromTokenAddress &&
    toTokenAddress &&
    fromAsset !== toAsset &&
    isConnected &&
    poolId > BigInt(0) &&
    bothTokensSupported;
  const canCreatePool =
    fromValue &&
    fromTokenAddress &&
    toTokenAddress &&
    fromAsset !== toAsset &&
    isConnected &&
    bothTokensSupported &&
    poolId === BigInt(0);
  const isLoading =
    isPending || isConfirming || isAddingToken || isCreatingPool;
  const needsTokenSupport =
    fromTokenAddress &&
    toTokenAddress &&
    (!isFromTokenSupported || !isToTokenSupported);

  // Log swap hook state changes
  useEffect(() => {
    console.log("🔧 Swap hook state:", {
      isPending,
      isConfirming,
      isConfirmed,
      hasError: !!error,
      hash: hash?.toString(),
    });
  }, [isPending, isConfirming, isConfirmed, error, hash]);

  // Handle swap execution
  const handleSwap = async () => {
    console.log("🔄 Swap button clicked!");
    console.log("📊 Swap state:", {
      fromToken: fromToken?.symbol,
      toToken: toToken?.symbol,
      fromValue,
      poolData,
      isConnected,
      poolId: poolId.toString(),
      canSwap,
    });

    if (!fromTokenAddress || !toTokenAddress || !fromValue || !isConnected) {
      console.log("❌ Swap validation failed:", {
        hasFromTokenAddress: !!fromTokenAddress,
        hasToTokenAddress: !!toTokenAddress,
        hasFromValue: !!fromValue,
        isConnected,
        poolId: poolId.toString(),
      });
      toast.error("Please connect wallet and select both tokens");
      return;
    }

    try {
      console.log("🚀 Starting swap execution...");
      const amountIn = parseUnits(fromValue, 18);
      // Use quote data if available, otherwise set minAmountOut to 0 (user accepts any amount)
      const minAmountOut = quoteData
        ? ((quoteData as bigint) * BigInt(95)) / BigInt(100)
        : BigInt(0);
      const maxSlippage = parseUnits(slippage, 2); // Convert percentage to basis points

      console.log("📋 Swap parameters:", {
        poolId: poolId.toString(),
        fromTokenAddress: fromTokenAddress,
        amountIn: amountIn.toString(),
        minAmountOut: minAmountOut.toString(),
        maxSlippage: maxSlippage.toString(),
      });

      console.log("📞 Calling swap function...");
      const swapResult = swap(
        poolId,
        fromTokenAddress as Address,
        amountIn,
        minAmountOut,
        maxSlippage
      );
      console.log("📞 Swap function called, result:", swapResult);

      console.log("✅ Swap transaction submitted!");
      toast.success("Swap initiated successfully!");
    } catch (err) {
      console.error("❌ Swap failed:", err);
      console.error("Error details:", {
        message: (err as Error)?.message,
        stack: (err as Error)?.stack,
      });
      toast.error(`Swap failed: ${(err as Error)?.message || "Unknown error"}`);
    }
  };

  // Handle transaction confirmation
  useEffect(() => {
    if (isConfirmed) {
      console.log("✅ Swap transaction confirmed!");
      toast.success("Swap completed successfully!");
      setFromValue("");
      setToValue("");
    }
  }, [isConfirmed]);

  useEffect(() => {
    if (error) {
      console.error("❌ Swap hook error:", error);
      toast.error(`Swap error: ${error.message}`);
    }
  }, [error]);

  // Log comprehensive state for debugging
  useEffect(() => {
    console.log("🔍 Complete component state:", {
      fromToken: fromToken?.symbol,
      toToken: toToken?.symbol,
      fromValue,
      toValue,
      poolData: !!poolData,
      poolId: poolId?.toString(),
      quoteData: quoteData?.toString(),
      isConnected,
      canSwap,
      isLoading,
      slippage,
    });
  }, [
    fromToken,
    toToken,
    fromValue,
    toValue,
    poolData,
    poolId,
    quoteData,
    isConnected,
    canSwap,
    isLoading,
    slippage,
  ]);

  return (
    <div className="space-y-6">
      <Card className="bg-gray-950/80 border-gray-800">
        <CardHeader>
          <CardTitle className="text-white">Swap RWA Tokens</CardTitle>
          <p className="text-gray-400">
            Exchange between different tokenized real-world assets
          </p>
        </CardHeader>
        <CardContent>
          <div className="space-y-6">
            <div className="space-y-4">
              <SwapInput
                label="From"
                value={fromValue}
                onValueChange={setFromValue}
                selectedAsset={getAssetDisplayName(fromAsset)}
                onAssetSelect={() => console.log("Select from asset", tokens)}
                className="bg-gray-900/70"
              />

              <div className="flex justify-center">
                <Button
                  variant="ghost"
                  size="sm"
                  className="rounded-full bg-gray-800 hover:bg-gray-700"
                  onClick={handleSwapAssets}
                  disabled={!fromAsset && !toAsset}
                >
                  <ArrowLeftRight className="h-4 w-4 text-green-400" />
                </Button>
              </div>

              <SwapInput
                label="To"
                value={toValue}
                onValueChange={setToValue}
                selectedAsset={getAssetDisplayName(toAsset)}
                onAssetSelect={() => console.log("Select to asset", tokens)}
                className="bg-gray-900/70"
              />
            </div>

            {fromAsset && toAsset && (
              <div className="p-4 bg-blue-500/10 border border-blue-500/20 rounded-lg">
                <div className="flex items-start gap-3">
                  <Info className="h-4 w-4 text-blue-400 mt-0.5" />
                  <div className="text-sm">
                    <p className="text-blue-400 font-medium mb-1">
                      Swap Preview
                    </p>
                    <p className="text-blue-300/80">
                      {fromValue} {getAssetDisplayName(fromAsset)} →{" "}
                      {toValue || "Calculating..."}{" "}
                      {getAssetDisplayName(toAsset)}
                    </p>
                    <p className="text-xs text-blue-300/60 mt-1">
                      Estimated gas fee: ~$5-15 • Slippage: {slippage}%
                    </p>
                    {poolId > BigInt(0) ? (
                      <p className="text-xs text-green-300/60 mt-1">
                        ✓ Liquidity pool available (Pool ID:{" "}
                        {poolId.toString().slice(0, 10)}...)
                      </p>
                    ) : null}
                    {poolId <= BigInt(0) && fromAsset && toAsset ? (
                      <p className="text-xs text-red-300/60 mt-1">
                        ⚠ No liquidity pool found for this pair
                      </p>
                    ) : null}
                  </div>
                </div>
              </div>
            )}

            {poolId === BigInt(0) &&
            fromTokenAddress &&
            toTokenAddress &&
            bothTokensSupported ? (
              <div className="mb-4 p-3 bg-blue-500/10 border border-blue-500/20 rounded-lg">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm text-blue-400 font-medium mb-1">
                      🏊 No Pool Found
                    </p>
                    <p className="text-xs text-blue-300/80">
                      Create a liquidity pool for{" "}
                      {getAssetDisplayName(fromAsset)} ↔{" "}
                      {getAssetDisplayName(toAsset)}
                    </p>
                  </div>
                  <Button
                    size="sm"
                    className="bg-blue-500 hover:bg-blue-600 text-white"
                    disabled={!canCreatePool || isCreatingPool}
                    onClick={handleCreatePool}
                  >
                    {isCreatingPool ? (
                      <>
                        <Loader2 className="mr-2 h-3 w-3 animate-spin" />
                        Creating...
                      </>
                    ) : (
                      "Create Pool"
                    )}
                  </Button>
                </div>
              </div>
            ) : null}

            {poolId === BigInt(0) &&
            fromTokenAddress &&
            toTokenAddress &&
            !bothTokensSupported ? (
              <div className="mb-4 p-3 bg-yellow-500/10 border border-yellow-500/20 rounded-lg">
                <p className="text-sm text-yellow-400">
                  ⚠️ Add token support first before creating a pool.
                </p>
              </div>
            ) : null}

            {needsTokenSupport && (
              <div className="mb-4 p-3 bg-orange-500/10 border border-orange-500/20 rounded-lg">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm text-orange-400 font-medium mb-1">
                      🔒 Token Support Required
                    </p>
                    <p className="text-xs text-orange-300/80">
                      {!isFromTokenSupported && !isToTokenSupported
                        ? "Both tokens need to be added to the SwapEngine"
                        : !isFromTokenSupported
                        ? `${getAssetDisplayName(
                            fromAsset
                          )} needs to be added to the SwapEngine`
                        : `${getAssetDisplayName(
                            toAsset
                          )} needs to be added to the SwapEngine`}
                    </p>
                  </div>
                  <Button
                    size="sm"
                    className="bg-orange-500 hover:bg-orange-600 text-black"
                    disabled={isAddingToken}
                    onClick={handleAddSupportedTokens}
                  >
                    {isAddingToken ? (
                      <>
                        <Loader2 className="mr-2 h-3 w-3 animate-spin" />
                        Adding...
                      </>
                    ) : (
                      "Add Support"
                    )}
                  </Button>
                </div>
              </div>
            )}

            <Button
              className={`w-full ${
                canSwap
                  ? "bg-green-500 hover:bg-green-600 text-black"
                  : "bg-gray-600 text-gray-400 cursor-not-allowed"
              }`}
              disabled={!canSwap || isLoading}
              onClick={() => {
                console.log("🖱️ Execute Swap button clicked!");
                handleSwap();
              }}
            >
              {isLoading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  {isPending ? "Confirming..." : "Processing..."}
                </>
              ) : !isConnected ? (
                "Connect Wallet"
              ) : needsTokenSupport ? (
                "Add Token Support First"
              ) : poolId === BigInt(0) && bothTokensSupported ? (
                "Create Pool First"
              ) : poolId === BigInt(0) ? (
                "No Pool Available"
              ) : !fromValue ? (
                "Enter Amount"
              ) : !fromAsset || !toAsset ? (
                "Select Assets"
              ) : (
                "Execute Swap"
              )}
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Available RWA Tokens for Swapping */}
      <Card className="bg-gray-950/80 border-gray-800">
        <CardHeader>
          <CardTitle className="text-white">Supported RWA Tokens</CardTitle>
          <p className="text-gray-400">
            💰 HVGOLD and 💰 HVSILVER tokens available for swapping
          </p>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {supportedTokens.map((token) => (
              <div
                key={token.type}
                className="p-4 bg-gray-900/50 rounded-lg border border-gray-800 hover:border-gray-700 transition-colors cursor-pointer"
                onClick={() => {
                  if (fromAsset === token.type) {
                    // Deselect if clicking on already selected from token
                    setFromAsset(null);
                    setFromValue("");
                  } else if (toAsset === token.type) {
                    // Deselect if clicking on already selected to token
                    setToAsset(null);
                    setToValue("");
                  } else if (!fromAsset) {
                    setFromAsset(token.type);
                  } else if (!toAsset && token.type !== fromAsset) {
                    setToAsset(token.type);
                  }
                }}
              >
                <div className="text-center">
                  <div className="text-2xl mb-2">
                    {token.type === "GOLD" ? "💰" : "💰"}
                  </div>
                  <h4 className="font-semibold text-white mb-1">
                    {token.symbol}
                  </h4>
                  <p className="text-xs text-gray-400">{token.category}</p>
                  <div className="text-xs text-gray-500 mt-2 font-mono">
                    {token.address.slice(0, 6)}...{token.address.slice(-4)}
                  </div>
                  {(fromAsset === token.type || toAsset === token.type) && (
                    <div className="text-xs text-green-400 mt-1">
                      ✓ Selected
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
