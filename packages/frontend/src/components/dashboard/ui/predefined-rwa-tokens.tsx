"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { ExternalLink, MapPin, DollarSign, Coins } from "lucide-react";
import { RWA_TOKEN_ADDRESSES, getRWATokenAddress, type RWATokenType } from "@/config/rwaTokenFactory";

interface PredefinedToken {
  type: RWATokenType;
  name: string;
  symbol: string;
  description: string;
  location: string;
  estimatedValue: string;
  icon: string;
}

const PREDEFINED_TOKENS: PredefinedToken[] = [
  {
    type: "GOLD",
    name: "HedVault Gold Token",
    symbol: "HVGOLD",
    description: "Tokenized gold reserves with verified authenticity",
    location: "Secure Vault, Switzerland",
    estimatedValue: "$2,000/oz",
    icon: "🥇",
  },
  {
    type: "SILVER",
    name: "HedVault Silver Token",
    symbol: "HVSILVER",
    description: "Premium silver bullion backed tokens",
    location: "Certified Depository, London",
    estimatedValue: "$25/oz",
    icon: "🥈",
  },
  {
    type: "REAL_ESTATE",
    name: "HedVault Real Estate Token",
    symbol: "HVRE",
    description: "Fractionalized commercial real estate portfolio",
    location: "Prime Locations, Global",
    estimatedValue: "$500/sqft",
    icon: "🏢",
  },
];

interface PredefinedRWATokensProps {
  className?: string;
}

export function PredefinedRWATokens({ className }: PredefinedRWATokensProps) {
  const handleViewOnExplorer = (tokenType: RWATokenType) => {
    const address = getRWATokenAddress(tokenType);
    // Using HashScan (Hedera's official explorer) for contract viewing
    window.open(`https://hashscan.io/testnet/contract/${address}`, "_blank");
  };

  return (
    <Card className={className}>
      <CardHeader className="flex flex-row items-center justify-between">
        <div>
          <CardTitle className="flex items-center gap-2">
            <Coins className="h-5 w-5 text-yellow-500" />
            Predefined RWA Tokens
          </CardTitle>
          <p className="text-sm text-gray-400 mt-1">
            Ready-to-use tokenized real-world assets
          </p>
        </div>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {PREDEFINED_TOKENS.map((token) => {
            const address = getRWATokenAddress(token.type);
            
            return (
              <div
                key={token.type}
                className="p-4 bg-gray-900/50 rounded-lg border border-gray-800 hover:border-gray-700 transition-colors"
              >
                <div className="flex justify-between items-start">
                  <div className="flex-1">
                    <div className="flex items-center gap-3 mb-2">
                      <span className="text-2xl">{token.icon}</span>
                      <div>
                        <h4 className="font-semibold text-white">
                          {token.name}
                        </h4>
                        <span className="text-sm text-gray-400">
                          {token.symbol}
                        </span>
                      </div>
                      <span className="px-2 py-1 text-xs bg-green-500/20 text-green-400 border border-green-500/30 rounded">
                        Active
                      </span>
                    </div>

                    <p className="text-sm text-gray-300 mb-3">
                      {token.description}
                    </p>

                    <div className="text-sm text-gray-400 space-y-1">
                      <div className="flex items-center gap-2">
                        <MapPin className="h-3 w-3" />
                        <span>{token.location}</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <DollarSign className="h-3 w-3" />
                        <span>Est. Value: {token.estimatedValue}</span>
                      </div>
                      <div className="text-xs text-gray-500 font-mono">
                        {address}
                      </div>
                    </div>
                  </div>

                  <div className="flex flex-col gap-2">
                    <Button
                      variant="ghost"
                      size="sm"
                      className="text-blue-400 hover:text-blue-300"
                      onClick={() => handleViewOnExplorer(token.type)}
                    >
                      <ExternalLink className="h-4 w-4" />
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      className="text-green-400 border-green-500/30 hover:bg-green-500/10"
                    >
                      Trade
                    </Button>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
        
        <div className="mt-6 p-4 bg-blue-500/10 border border-blue-500/20 rounded-lg">
          <div className="flex items-start gap-3">
            <div className="text-blue-400 text-lg">ℹ️</div>
            <div>
              <h5 className="text-blue-400 font-medium mb-1">
                Integration Ready
              </h5>
              <p className="text-sm text-blue-300/80">
                These tokens are configured for frontend integration and ready for trading, 
                swapping, and other DeFi operations.
              </p>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}