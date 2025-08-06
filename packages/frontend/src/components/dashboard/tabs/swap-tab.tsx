"use client";

import { useState } from "react";
import { ArrowLeftRight, Info } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { SwapInput } from "../ui/swap-input";
import { usePredefinedRWATokens } from "@/hooks/usePredefinedRWATokens";

export function SwapTab() {
  const [fromValue, setFromValue] = useState("");
  const [toValue, setToValue] = useState("");
  const [fromAsset, setFromAsset] = useState<string | null>(null);
  const [toAsset, setToAsset] = useState<string | null>(null);
  
  const { tokens } = usePredefinedRWATokens();

  const handleSwapAssets = () => {
    const tempAsset = fromAsset;
    const tempValue = fromValue;
    setFromAsset(toAsset);
    setToAsset(tempAsset);
    setFromValue(toValue);
    setToValue(tempValue);
  };

  const getAssetDisplayName = (assetType: string | null) => {
    if (!assetType) return "Select Asset";
    const token = tokens.find(t => t.type === assetType);
    return token ? token.symbol : "Select Asset";
  };

  const canSwap = fromValue && toValue && fromAsset && toAsset && fromAsset !== toAsset;

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
                    <p className="text-blue-400 font-medium mb-1">Swap Preview</p>
                    <p className="text-blue-300/80">
                      {fromValue} {getAssetDisplayName(fromAsset)} → {toValue} {getAssetDisplayName(toAsset)}
                    </p>
                    <p className="text-xs text-blue-300/60 mt-1">
                      Estimated gas fee: ~$5-15 • Slippage: 0.5%
                    </p>
                  </div>
                </div>
              </div>
            )}

            <Button 
              className={`w-full ${
                canSwap 
                  ? "bg-green-500 hover:bg-green-600 text-black" 
                  : "bg-gray-600 text-gray-400 cursor-not-allowed"
              }`}
              disabled={!canSwap}
            >
              {canSwap ? "Execute Swap" : "Connect Wallet & Select Assets"}
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Available RWA Tokens for Swapping */}
      <Card className="bg-gray-950/80 border-gray-800">
        <CardHeader>
          <CardTitle className="text-white">Available RWA Tokens</CardTitle>
          <p className="text-gray-400">
            Select from these tokenized assets for swapping
          </p>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {tokens.map((token) => (
              <div
                key={token.type}
                className="p-4 bg-gray-900/50 rounded-lg border border-gray-800 hover:border-gray-700 transition-colors cursor-pointer"
                onClick={() => {
                  if (!fromAsset) {
                    setFromAsset(token.type);
                  } else if (!toAsset && token.type !== fromAsset) {
                    setToAsset(token.type);
                  }
                }}
              >
                <div className="text-center">
                  <div className="text-2xl mb-2">
                    {token.type === 'GOLD' ? '🥇' : token.type === 'SILVER' ? '🥈' : '🏢'}
                  </div>
                  <h4 className="font-semibold text-white mb-1">{token.symbol}</h4>
                  <p className="text-xs text-gray-400">{token.category}</p>
                  <div className="text-xs text-gray-500 mt-2 font-mono">
                    {token.address.slice(0, 6)}...{token.address.slice(-4)}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
