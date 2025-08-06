"use client";

import { useState } from "react";
import { Eye, EyeOff, TrendingUp, DollarSign, Activity } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { PortfolioCard } from "../ui/portfolio-card";
import { TransactionItem } from "../ui/transaction-item";
import { RWATokenList } from "../ui/rwa-token-list";
import { PredefinedRWATokens } from "../ui/predefined-rwa-tokens";
import { useRWATokenFactoryTokens } from "@/hooks/useRWATokenFactoryTokens";

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

export function DashboardTab() {
  const [showBalance, setShowBalance] = useState(true);
  const { allTokensWithInfo } = useRWATokenFactoryTokens();

  const tokensData = allTokensWithInfo.data || [[], []];
  const assetInfos = Array.from(tokensData[1] || []);

  // Calculate total portfolio value from real RWA tokens
  const totalValue = assetInfos.reduce((sum: number, info) => {
    return sum + Number(info.metadata.valuation);
  }, 0);

  // Mock transactions for now - can be enhanced with real data later
  const recentTransactions = [
    {
      type: "Buy",
      asset: "RET",
      amount: "100.00",
      value: "$10,000",
      time: "2 hours ago",
    },
    {
      type: "Swap",
      asset: "GOLD → INV",
      amount: "5.25",
      value: "$5,250",
      time: "1 day ago",
    },
    {
      type: "Lend",
      asset: "ART",
      amount: "2.00",
      value: "$10,000",
      time: "3 days ago",
    },
    {
      type: "Reward",
      asset: "RET",
      amount: "12.50",
      value: "$1,250",
      time: "1 week ago",
    },
  ];

  return (
    <div className="space-y-8">
      {/* Portfolio Overview */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <PortfolioCard
          title="Total Portfolio Value"
          value={showBalance ? `$${totalValue.toLocaleString()}` : "••••••"}
          change={`${assetInfos.length} RWA tokens`}
          changeType="positive"
          className="lg:col-span-1"
        >
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setShowBalance(!showBalance)}
            className="text-gray-400 hover:text-white"
          >
            {showBalance ? (
              <Eye className="h-4 w-4" />
            ) : (
              <EyeOff className="h-4 w-4" />
            )}
          </Button>
        </PortfolioCard>

        <PortfolioCard
          title="Active Positions"
          value={assetInfos.length.toString()}
          change={`Across ${
            new Set(assetInfos.map((info) => info.metadata.assetType)).size
          } asset classes`}
        />

        <PortfolioCard
          title="Monthly Rewards"
          value="$0"
          change="Coming soon"
          changeType="positive"
        />
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Button className="h-16 bg-green-500/10 hover:bg-green-500/20 border border-green-500/20 text-green-400 hover:text-green-300">
          <TrendingUp className="h-5 w-5 mr-3" />
          Quick Buy
        </Button>
        <Button className="h-16 bg-blue-500/10 hover:bg-blue-500/20 border border-blue-500/20 text-blue-400 hover:text-blue-300">
          <Activity className="h-5 w-5 mr-3" />
          Quick Swap
        </Button>
        <Button className="h-16 bg-purple-500/10 hover:bg-purple-500/20 border border-purple-500/20 text-purple-400 hover:text-purple-300">
          <DollarSign className="h-5 w-5 mr-3" />
          Start Lending
        </Button>
      </div>

      {/* Predefined RWA Tokens */}
      <PredefinedRWATokens className="bg-gray-950/80 backdrop-blur-sm border-gray-800" />

      {/* Factory-Created RWA Tokens */}
      <RWATokenList className="bg-gray-950/80 backdrop-blur-sm border-gray-800" />

      {/* Portfolio Holdings - Simplified placeholder */}
      <Card className="bg-gray-950/80 backdrop-blur-sm border-gray-800">
        <CardHeader className="pb-6">
          <CardTitle className="text-2xl font-bold text-white">
            Portfolio Holdings
          </CardTitle>
          <p className="text-gray-400">
            Your tokenized real-world assets (Legacy View)
          </p>
        </CardHeader>
        <CardContent>
          <div className="space-y-6">
            {assetInfos.length > 0 ? (
              <p className="text-gray-400">
                Real RWA tokens are displayed above. This section will be
                updated with enhanced portfolio features.
              </p>
            ) : (
              <p className="text-gray-400">
                No RWA tokens found. Real-time data will appear once tokens are
                created.
              </p>
            )}
          </div>
        </CardContent>
      </Card>

      {/* Recent Transactions with Bottom Left Card */}
      <div className="relative">
        <Card className="bg-gray-950/80 backdrop-blur-sm border-gray-800">
          <CardHeader className="pb-6">
            <CardTitle className="text-2xl font-bold text-white">
              Recent Activity
            </CardTitle>
            <p className="text-gray-400">
              Your latest transactions and activities
            </p>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {recentTransactions.map((tx, index) => (
                <TransactionItem key={index} {...tx} />
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Small Bottom Left Card */}
      </div>
    </div>
  );
}
