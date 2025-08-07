"use client";

import { useState } from "react";
import {
  TrendingUp,
  Gift,
  Zap,
  BarChart3,
  Settings,
  History,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

interface DetailedReward {
  asset: string;
  symbol: string;
  category: string;
  type: string;
  amount: string;
  pendingAmount: string;
  apy: string;
  frequency: string;
  nextReward: string;
  totalStaked: string;
  rewardToken: string;
  autoCompound: boolean;
  lastClaimed: string;
  claimableAmount: string;
  performance30d: string;
  location: string;
}

interface RewardHistoryItem {
  date: string;
  asset: string;
  type: string;
  amount: string;
  token: string;
  txHash: string;
}

export function RewardsTab() {
  const [activeRewardType, setActiveRewardType] = useState("all");

  const rewardCategories = [
    {
      id: "lending",
      name: "Lending Interest",
      icon: TrendingUp,
      totalEarned: "$0",
      pendingRewards: "$0",
      apy: "0%",
      color: "text-blue-400",
      bgColor: "bg-blue-500/10",
      borderColor: "border-blue-500/20",
    },
    {
      id: "yield",
      name: "Yield Farming",
      icon: BarChart3,
      totalEarned: "$0",
      pendingRewards: "$0",
      apy: "0%",
      color: "text-purple-400",
      bgColor: "bg-purple-500/10",
      borderColor: "border-purple-500/20",
    },
  ];

  const detailedRewards: DetailedReward[] = [];

  const rewardHistory: RewardHistoryItem[] = [];

  const filteredRewards: DetailedReward[] = [];

  const totalStats = {
    totalEarned: 0,
    totalPending: 0,
    avgApy: 0,
  };

  return (
    <div className="space-y-8">
      {/* Rewards Overview */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card className="bg-gray-950/80 backdrop-blur-sm border-gray-800">
          <CardHeader className="pb-4">
            <CardTitle className="text-sm font-medium text-gray-400 uppercase tracking-wide">
              Total Earned
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-green-400">
              ${totalStats.totalEarned.toLocaleString()}
            </div>
            <p className="text-sm mt-2 font-medium text-gray-400">
              Coming soon
            </p>
          </CardContent>
        </Card>

        <Card className="bg-gray-950/80 backdrop-blur-sm border-gray-800">
          <CardHeader className="pb-4">
            <CardTitle className="text-sm font-medium text-gray-400 uppercase tracking-wide">
              Pending Rewards
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-yellow-400">
              ${totalStats.totalPending.toLocaleString()}
            </div>
            <p className="text-sm mt-2 font-medium text-gray-400">
              Coming soon
            </p>
          </CardContent>
        </Card>

        <Card className="bg-gray-950/80 backdrop-blur-sm border-gray-800">
          <CardHeader className="pb-4">
            <CardTitle className="text-sm font-medium text-gray-400 uppercase tracking-wide">
              Average APY
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-white">
              {totalStats.avgApy.toFixed(1)}%
            </div>
            <p className="text-sm mt-2 font-medium text-gray-400">
              Coming soon
            </p>
          </CardContent>
        </Card>

        <Card className="bg-gray-950/80 backdrop-blur-sm border-gray-800">
          <CardHeader className="pb-4">
            <CardTitle className="text-sm font-medium text-gray-400 uppercase tracking-wide">
              Active Positions
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-white">
              {detailedRewards.length}
            </div>
            <p className="text-sm mt-2 font-medium text-gray-400">
              Coming soon
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Reward Categories */}
      <Card className="bg-gray-950/80 backdrop-blur-sm border-gray-800">
        <CardHeader>
          <CardTitle className="text-2xl font-bold text-white">
            Reward Categories
          </CardTitle>
          <p className="text-gray-400">Performance breakdown by reward type</p>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {rewardCategories.map((category) => {
              const IconComponent = category.icon;
              return (
                <div
                  key={category.id}
                  className={`p-6 rounded-xl border transition-all duration-200 cursor-pointer ${
                    activeRewardType === category.id
                      ? `${category.bgColor} ${category.borderColor} ${category.color}`
                      : "bg-gray-900/60 border-gray-700 text-white hover:bg-gray-800/60"
                  }`}
                  onClick={() => setActiveRewardType(category.id)}
                >
                  <div className="flex items-center space-x-3 mb-4">
                    <div
                      className={`w-10 h-10 rounded-lg ${category.bgColor} flex items-center justify-center`}
                    >
                      <IconComponent className={`w-5 h-5 ${category.color}`} />
                    </div>
                    <h3 className="font-semibold text-lg">{category.name}</h3>
                  </div>
                  <div className="grid grid-cols-3 gap-4 text-sm">
                    <div>
                      <p className="text-gray-400">Earned</p>
                      <p className="font-semibold">{category.totalEarned}</p>
                    </div>
                    <div>
                      <p className="text-gray-400">Pending</p>
                      <p className="font-semibold">{category.pendingRewards}</p>
                    </div>
                    <div>
                      <p className="text-gray-400">APY</p>
                      <p className="font-semibold">{category.apy}</p>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>

      {/* Filter Tabs */}
      <div className="flex space-x-1 bg-gray-900/70 p-1 rounded-lg w-fit">
        <button
          onClick={() => setActiveRewardType("all")}
          className={`px-4 py-2 rounded-md transition-colors ${
            activeRewardType === "all"
              ? "bg-green-500/20 text-green-400"
              : "text-gray-400 hover:text-white"
          }`}
        >
          All Rewards
        </button>
        <button
          onClick={() => setActiveRewardType("lending")}
          className={`px-4 py-2 rounded-md transition-colors ${
            activeRewardType === "lending"
              ? "bg-blue-500/20 text-blue-400"
              : "text-gray-400 hover:text-white"
          }`}
        >
          Lending
        </button>
        <button
          onClick={() => setActiveRewardType("yield")}
          className={`px-4 py-2 rounded-md transition-colors ${
            activeRewardType === "yield"
              ? "bg-purple-500/20 text-purple-400"
              : "text-gray-400 hover:text-white"
          }`}
        >
          Yield Farming
        </button>
      </div>

      {/* Detailed Rewards */}
      <Card className="bg-gray-950/80 backdrop-blur-sm border-gray-800">
        <CardHeader>
          <CardTitle className="text-2xl font-bold text-white">
            Detailed Rewards
          </CardTitle>
          <p className="text-gray-400">
            Comprehensive breakdown of your reward positions
          </p>
        </CardHeader>
        <CardContent>
          <div className="space-y-6">
            {filteredRewards.length === 0 ? (
              <div className="text-center py-12">
                <p className="text-gray-400 text-lg mb-2">No rewards available yet</p>
                <p className="text-gray-500">Coming soon</p>
              </div>
            ) : (
              filteredRewards.map((reward, index) => (
                <div
                  key={index}
                  className="p-6 rounded-xl bg-gray-900/60 backdrop-blur-sm border border-gray-700/50 hover:bg-gray-800/60 transition-all duration-200"
                >
                {/* Header Row */}
                <div className="flex items-center justify-between mb-6">
                  <div className="flex items-center space-x-4">
                    <div className="w-12 h-12 rounded-xl bg-green-500/10 border border-green-500/20 flex items-center justify-center">
                      <span className="text-green-400 font-bold text-sm">
                        {reward.symbol}
                      </span>
                    </div>
                    <div>
                      <div className="flex items-center space-x-3">
                        <h3 className="text-white font-semibold text-lg">
                          {reward.asset}
                        </h3>
                        <span className="px-2 py-1 rounded-full text-xs font-medium bg-blue-500/20 text-blue-400 border border-blue-500/30">
                          {reward.type}
                        </span>
                        {reward.autoCompound && (
                          <span className="px-2 py-1 rounded-full text-xs font-medium bg-purple-500/20 text-purple-400 border border-purple-500/30">
                            Auto-Compound
                          </span>
                        )}
                      </div>
                      <p className="text-gray-400 text-sm mt-1">
                        {reward.totalStaked} • {reward.location}
                      </p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-white font-semibold text-xl">
                      {reward.amount}
                    </p>
                    <p className="text-green-400 text-sm font-medium">
                      Total Earned
                    </p>
                  </div>
                </div>

                {/* Details Grid */}
                <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4 mb-6">
                  <div className="space-y-1">
                    <p className="text-gray-400 text-xs uppercase tracking-wide">
                      Claimable
                    </p>
                    <p className="text-yellow-400 font-semibold">
                      {reward.claimableAmount}
                    </p>
                  </div>
                  <div className="space-y-1">
                    <p className="text-gray-400 text-xs uppercase tracking-wide">
                      APY
                    </p>
                    <p className="text-green-400 font-semibold">{reward.apy}</p>
                  </div>
                  <div className="space-y-1">
                    <p className="text-gray-400 text-xs uppercase tracking-wide">
                      Frequency
                    </p>
                    <p className="text-white font-medium">{reward.frequency}</p>
                  </div>
                  <div className="space-y-1">
                    <p className="text-gray-400 text-xs uppercase tracking-wide">
                      Next Reward
                    </p>
                    <p className="text-blue-400 font-medium">
                      {reward.nextReward}
                    </p>
                  </div>
                  <div className="space-y-1">
                    <p className="text-gray-400 text-xs uppercase tracking-wide">
                      30d Performance
                    </p>
                    <p className="text-green-400 font-semibold">
                      {reward.performance30d}
                    </p>
                  </div>
                  <div className="space-y-1">
                    <p className="text-gray-400 text-xs uppercase tracking-wide">
                      Reward Token
                    </p>
                    <p className="text-white font-medium">
                      {reward.rewardToken}
                    </p>
                  </div>
                </div>

                {/* Progress Bar */}
                <div className="mb-6">
                  <div className="flex justify-between text-sm mb-2">
                    <span className="text-gray-400">Next reward progress</span>
                    <span className="text-white">75%</span>
                  </div>
                  <div className="w-full bg-gray-700 rounded-full h-2">
                    <div
                      className="bg-green-500 h-2 rounded-full"
                      style={{ width: "75%" }}
                    ></div>
                  </div>
                </div>

                {/* Action Buttons */}
                <div className="flex flex-wrap gap-3 pt-4 border-t border-gray-700/50">
                  <Button
                    size="sm"
                    className="bg-green-500 hover:bg-green-600 text-black"
                    disabled={
                      Number.parseFloat(
                        reward.claimableAmount.replace("$", "")
                      ) === 0
                    }
                  >
                    <Gift className="h-4 w-4 mr-2" />
                    Claim Rewards
                  </Button>
                  <Button
                    size="sm"
                    className="bg-blue-500/10 hover:bg-blue-500/20 text-blue-400 border border-blue-500/30"
                  >
                    <Zap className="h-4 w-4 mr-2" />
                    Stake More
                  </Button>
                  <Button
                    size="sm"
                    className="bg-purple-500/10 hover:bg-purple-500/20 text-purple-400 border border-purple-500/30"
                  >
                    <Settings className="h-4 w-4 mr-2" />
                    {reward.autoCompound ? "Disable" : "Enable"} Auto-Compound
                  </Button>
                  <Button
                    size="sm"
                    variant="outline"
                    className="border-gray-600 text-gray-300 bg-transparent hover:bg-gray-800/50"
                  >
                    <BarChart3 className="h-4 w-4 mr-2" />
                    View Analytics
                  </Button>
                </div>
              </div>
              ))
            )}
          </div>
        </CardContent>
      </Card>

      {/* Reward History */}
      <Card className="bg-gray-950/80 backdrop-blur-sm border-gray-800">
        <CardHeader>
          <CardTitle className="text-2xl font-bold text-white flex items-center">
            <History className="h-6 w-6 mr-3" />
            Recent Reward Claims
          </CardTitle>
          <p className="text-gray-400">Your latest reward claim history</p>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {rewardHistory.length === 0 ? (
              <div className="text-center py-12">
                <p className="text-gray-400 text-lg mb-2">No reward history yet</p>
                <p className="text-gray-500">Coming soon</p>
              </div>
            ) : (
              rewardHistory.map((claim, index) => (
                <div
                  key={index}
                  className="flex items-center justify-between p-4 rounded-xl bg-gray-900/60 backdrop-blur-sm border border-gray-700/50"
                >
                <div className="flex items-center space-x-4">
                  <div className="w-10 h-10 rounded-xl bg-green-500/10 border border-green-500/20 flex items-center justify-center">
                    <Gift className="h-5 w-5 text-green-400" />
                  </div>
                  <div>
                    <p className="text-white font-semibold">
                      {claim.asset} {claim.type} Reward
                    </p>
                    <p className="text-gray-400 text-sm">
                      {claim.date} • Paid in {claim.token}
                    </p>
                  </div>
                </div>
                <div className="text-right">
                  <p className="text-green-400 font-semibold text-lg">
                    {claim.amount}
                  </p>
                  <p className="text-gray-400 text-xs">{claim.txHash}</p>
                </div>
              </div>
              ))
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
