"use client";

import { useRWATokenFactoryTokens } from "@/hooks/useRWATokenFactoryTokens";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { RefreshCw, ExternalLink, MapPin, DollarSign } from "lucide-react";

interface RWAMetadata {
  assetType: string;
  location: string;
  valuation: bigint;
  oracle: `0x${string}`;
  totalSupply: bigint;
  minInvestment: bigint;
  certificationHash: string;
  additionalData: string;
}

interface AssetInfo {
  tokenAddress: `0x${string}`;
  creator: `0x${string}`;
  creationTime: bigint;
  metadata: RWAMetadata;
  complianceStatus: boolean;
  isListed: boolean;
}

interface RWATokenListProps {
  className?: string;
}

export function RWATokenList({ className }: RWATokenListProps) {
  const { allTokensWithInfo, isLoading, error, refetch } =
    useRWATokenFactoryTokens();

  const data = allTokensWithInfo.data || [[], []];
  const [tokenAddresses, assetInfos] = [
    Array.from(data[0] || []),
    Array.from(data[1] || []),
  ];

  const formatCurrency = (value: bigint) => {
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD",
    }).format(Number(value) / 1e18);
  };

  if (isLoading) {
    return (
      <Card className={className}>
        <CardHeader>
          <CardTitle>Real-World Asset Tokens</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="h-20 bg-gray-800 rounded animate-pulse" />
            ))}
          </div>
        </CardContent>
      </Card>
    );
  }

  if (error) {
    return (
      <Card className={className}>
        <CardHeader>
          <CardTitle>Real-World Asset Tokens</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-red-400 text-center py-8">
            <div className="h-8 w-8 mx-auto mb-2 text-red-400">⚠️</div>
            <p>Error loading RWA tokens</p>
            <Button onClick={() => refetch()} className="mt-4">
              <RefreshCw className="h-4 w-4 mr-2" />
              Retry
            </Button>
          </div>
        </CardContent>
      </Card>
    );
  }

  if (tokenAddresses.length === 0) {
    return (
      <Card className={className}>
        <CardHeader>
          <CardTitle>Real-World Asset Tokens</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-center py-8 text-gray-400">
            <div className="h-12 w-12 mx-auto mb-4 opacity-50">📄</div>
            <p>No RWA tokens found</p>
            <p className="text-sm text-gray-500 mt-2">
              Tokens will appear here once they are created on the factory
            </p>
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className={className}>
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle>Real-World Asset Tokens</CardTitle>
        <Button
          variant="ghost"
          size="sm"
          onClick={() => refetch()}
          disabled={isLoading}
          className="text-gray-400 hover:text-white"
        >
          <RefreshCw className={`h-4 w-4 ${isLoading ? "animate-spin" : ""}`} />
        </Button>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {tokenAddresses.map((address: `0x${string}`, index: number) => {
            const info = assetInfos[index];
            if (!info) return null;

            return (
              <div
                key={address}
                className="p-4 bg-gray-900/50 rounded-lg border border-gray-800 hover:border-gray-700 transition-colors"
              >
                <div className="flex justify-between items-start">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-2">
                      <h4 className="font-semibold text-white">
                        {info.metadata.assetType}
                      </h4>
                      <span className="px-2 py-1 text-xs border border-gray-600 rounded">
                        {info.complianceLevel > 0 ? "Verified" : "Pending"}
                      </span>
                    </div>

                    <div className="text-sm text-gray-400 space-y-1">
                      <div className="flex items-center gap-2">
                        <MapPin className="h-3 w-3" />
                        <span>{info.metadata.location}</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <DollarSign className="h-3 w-3" />
                        <span>
                          Valuation: {formatCurrency(info.metadata.valuation)}
                        </span>
                      </div>
                      <div className="text-xs text-gray-500">
                        Token: {address.slice(0, 6)}...{address.slice(-4)}
                      </div>
                    </div>
                  </div>

                  <Button
                    variant="ghost"
                    size="sm"
                    className="text-blue-400 hover:text-blue-300"
                    onClick={() =>
                      window.open(
                        `https://hashscan.io/testnet/contract/${address}`,
                        "_blank"
                      )
                    }
                  >
                    <ExternalLink className="h-4 w-4" />
                  </Button>
                </div>
              </div>
            );
          })}
        </div>
      </CardContent>
    </Card>
  );
}
