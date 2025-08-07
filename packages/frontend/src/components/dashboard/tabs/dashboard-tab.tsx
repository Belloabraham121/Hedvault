"use client";

import { useState } from "react";
import { Eye, EyeOff, TrendingUp, DollarSign, Activity } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { PortfolioCard } from "../ui/portfolio-card";
import { TransactionItem } from "../ui/transaction-item";
import { PredefinedRWATokens } from "../ui/predefined-rwa-tokens";
import { useRWATokenFactoryTokens } from "@/hooks/useRWATokenFactoryTokens";
import { useTokenBalance } from "@/hooks/contracts/useLendingPool";
import { useAccount } from "wagmi";
import { formatEther } from "viem";
import { ALL_RWA_TOKEN_ADDRESSES, RWA_TOKEN_ADDRESSES, type RWATokenType } from "@/config/rwaTokenFactory";

// Format large numbers with abbreviations and commas
const formatLargeNumber = (num: number) => {
  if (num >= 1e9) {
    const billions = (num / 1e9);
    return billions.toLocaleString('en-US', { minimumFractionDigits: 1, maximumFractionDigits: 1 }) + 'B';
  } else if (num >= 1e6) {
    const millions = (num / 1e6);
    return millions.toLocaleString('en-US', { minimumFractionDigits: 1, maximumFractionDigits: 1 }) + 'M';
  } else if (num >= 1e3) {
    const thousands = (num / 1e3);
    return thousands.toLocaleString('en-US', { minimumFractionDigits: 1, maximumFractionDigits: 1 }) + 'K';
  }
  return num.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
};

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
  complianceLevel: number;
  isListed: boolean;
  tradingVolume: bigint;
  holders: bigint;
}

interface TokenBalanceRowProps {
  tokenAddress: `0x${string}`;
  assetInfo: AssetInfo;
  userAddress: `0x${string}` | undefined;
  showBalance: boolean;
}

function TokenBalanceRow({ tokenAddress, assetInfo, userAddress, showBalance }: TokenBalanceRowProps) {
  const tokenBalance = useTokenBalance(tokenAddress);
  
  const formatCurrency = (value: bigint) => {
    return Number(value) / 1e18;
  };
  
  const userTokenBalance = tokenBalance.data || BigInt(0);
  const tokenValue = formatCurrency(assetInfo.metadata.valuation);
  const userBalanceFormatted = Number(formatEther(userTokenBalance));
  const userValueUSD = userBalanceFormatted * (tokenValue / Number(formatEther(assetInfo.metadata.totalSupply)));
  
  return (
    <div className="p-4 bg-gray-900/50 rounded-lg border border-gray-800 hover:border-gray-700 transition-colors">
      <div className="flex justify-between items-center">
        <div className="flex-1">
          <div className="flex items-center gap-3 mb-2">
            <h4 className="font-semibold text-white text-lg">
              {assetInfo.metadata.assetType}
            </h4>
            <span className="px-2 py-1 text-xs bg-blue-500/20 text-blue-400 rounded">
              {assetInfo.metadata.location}
            </span>
          </div>
          
          <div className="grid grid-cols-2 gap-4 text-sm">
            <div>
              <p className="text-gray-400">Your Balance</p>
              <p className="text-white font-medium">
                {showBalance ? `${formatLargeNumber(userBalanceFormatted)} tokens` : "••••••"}
              </p>
            </div>
            <div>
              <p className="text-gray-400">Value (USD)</p>
              <p className="text-green-400 font-medium">
                {showBalance ? `$${formatLargeNumber(userValueUSD)}` : "••••••"}
              </p>
            </div>
            <div>
              <p className="text-gray-400">Token Price</p>
              <p className="text-white">
                ${formatLargeNumber(tokenValue / Number(formatEther(assetInfo.metadata.totalSupply)))}
              </p>
            </div>
            <div>
              <p className="text-gray-400">Total Supply</p>
              <p className="text-white">
                {formatLargeNumber(Number(formatEther(assetInfo.metadata.totalSupply)))} tokens
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export function DashboardTab() {
  const [showBalance, setShowBalance] = useState(true);
  const { allTokensWithInfo } = useRWATokenFactoryTokens();
  const { address: userAddress } = useAccount();

  const tokensData = allTokensWithInfo.data || [[], []];
  const [tokenAddresses, assetInfos] = [
    Array.from(tokensData[0] || []),
    Array.from(tokensData[1] || [])
  ];

  // Get balances for predefined RWA tokens
  const goldBalance = useTokenBalance(RWA_TOKEN_ADDRESSES.GOLD as `0x${string}`);
  const silverBalance = useTokenBalance(RWA_TOKEN_ADDRESSES.SILVER as `0x${string}`);
  const realEstateBalance = useTokenBalance(RWA_TOKEN_ADDRESSES.REAL_ESTATE as `0x${string}`);

  // Format currency helper function
  const formatCurrency = (value: bigint) => {
    return Number(value) / 1e18;
  };

  // Calculate total portfolio value from user's actual token holdings
  const calculateUserPortfolioValue = () => {
    let totalValue = 0;
    
    // Add predefined token values (assuming $1 per token for now)
    const goldValue = goldBalance.data ? Number(formatEther(goldBalance.data)) * 2000 : 0; // $2000 per gold token
    const silverValue = silverBalance.data ? Number(formatEther(silverBalance.data)) * 25 : 0; // $25 per silver token  
    const realEstateValue = realEstateBalance.data ? Number(formatEther(realEstateBalance.data)) * 500 : 0; // $500 per RE token
    
    totalValue += goldValue + silverValue + realEstateValue;
    
    // Add factory-created token values
    tokenAddresses.forEach((address: `0x${string}`, index: number) => {
      const info = assetInfos[index];
      if (!info) return;
      
      const tokenValue = formatCurrency(info.metadata.valuation);
      const pricePerToken = tokenValue / Number(formatEther(info.metadata.totalSupply));
      // We would need individual balance hooks for each token to calculate actual value
    });
    
    return totalValue;
  };

  const totalValue = calculateUserPortfolioValue();
  const totalTokenCount = tokenAddresses.length + (goldBalance.data && goldBalance.data > 0 ? 1 : 0) + (silverBalance.data && silverBalance.data > 0 ? 1 : 0) + (realEstateBalance.data && realEstateBalance.data > 0 ? 1 : 0);

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
           value={showBalance ? `$${formatLargeNumber(totalValue)}` : "••••••"}
           change={`${totalTokenCount} RWA tokens`}
           changeType="positive"
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

      {/* Portfolio Holdings with User Balances */}
      <Card className="bg-gray-950/80 backdrop-blur-sm border-gray-800">
        <CardHeader className="pb-6">
          <CardTitle className="text-2xl font-bold text-white">
            My Portfolio Holdings
          </CardTitle>
          <p className="text-gray-400">
            Your RWA token balances and values
          </p>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {/* Predefined RWA Tokens */}
            {goldBalance.data && goldBalance.data > 0 && (
              <div className="p-4 bg-gray-900/50 rounded-lg border border-gray-800 hover:border-gray-700 transition-colors">
                <div className="flex justify-between items-center">
                  <div className="flex-1">
                    <div className="flex items-center gap-3 mb-2">
                      <h4 className="font-semibold text-white text-lg">Gold Token</h4>
                      <span className="px-2 py-1 text-xs bg-yellow-500/20 text-yellow-400 rounded">Physical Gold</span>
                    </div>
                    <div className="grid grid-cols-2 gap-4 text-sm">
                      <div>
                        <p className="text-gray-400">Your Balance</p>
                        <p className="text-white font-medium">
                           {showBalance ? `${formatLargeNumber(Number(formatEther(goldBalance.data)))} GOLD` : "••••••"}
                         </p>
                      </div>
                      <div>
                        <p className="text-gray-400">Value (USD)</p>
                        <p className="text-green-400 font-medium">
                           {showBalance ? `$${formatLargeNumber(Number(formatEther(goldBalance.data)) * 2000)}` : "••••••"}
                         </p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}
            {silverBalance.data && silverBalance.data > 0 && (
              <div className="p-4 bg-gray-900/50 rounded-lg border border-gray-800 hover:border-gray-700 transition-colors">
                <div className="flex justify-between items-center">
                  <div className="flex-1">
                    <div className="flex items-center gap-3 mb-2">
                      <h4 className="font-semibold text-white text-lg">Silver Token</h4>
                      <span className="px-2 py-1 text-xs bg-gray-500/20 text-gray-400 rounded">Physical Silver</span>
                    </div>
                    <div className="grid grid-cols-2 gap-4 text-sm">
                      <div>
                        <p className="text-gray-400">Your Balance</p>
                        <p className="text-white font-medium">
                           {showBalance ? `${formatLargeNumber(Number(formatEther(silverBalance.data)))} SILVER` : "••••••"}
                         </p>
                      </div>
                      <div>
                        <p className="text-gray-400">Value (USD)</p>
                        <p className="text-green-400 font-medium">
                           {showBalance ? `$${formatLargeNumber(Number(formatEther(silverBalance.data)) * 25)}` : "••••••"}
                         </p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}
            {realEstateBalance.data && realEstateBalance.data > 0 && (
              <div className="p-4 bg-gray-900/50 rounded-lg border border-gray-800 hover:border-gray-700 transition-colors">
                <div className="flex justify-between items-center">
                  <div className="flex-1">
                    <div className="flex items-center gap-3 mb-2">
                      <h4 className="font-semibold text-white text-lg">Real Estate Token</h4>
                      <span className="px-2 py-1 text-xs bg-green-500/20 text-green-400 rounded">Real Estate</span>
                    </div>
                    <div className="grid grid-cols-2 gap-4 text-sm">
                      <div>
                        <p className="text-gray-400">Your Balance</p>
                        <p className="text-white font-medium">
                           {showBalance ? `${formatLargeNumber(Number(formatEther(realEstateBalance.data)))} RE` : "••••••"}
                         </p>
                      </div>
                      <div>
                        <p className="text-gray-400">Value (USD)</p>
                        <p className="text-green-400 font-medium">
                           {showBalance ? `$${formatLargeNumber(Number(formatEther(realEstateBalance.data)) * 500)}` : "••••••"}
                         </p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}
            
            {/* Factory-created RWA Tokens */}
            {tokenAddresses.length > 0 ? (
              tokenAddresses.map((address: `0x${string}`, index: number) => {
                const info = assetInfos[index];
                if (!info) return null;
                
                return (
                  <TokenBalanceRow 
                    key={address}
                    tokenAddress={address}
                    assetInfo={info}
                    userAddress={userAddress}
                    showBalance={showBalance}
                  />
                );
              })
            ) : null}
            
            {totalTokenCount === 0 && (
              <p className="text-gray-400 text-center py-8">
                No RWA tokens found. Your token balances will appear here once you acquire RWA tokens.
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
