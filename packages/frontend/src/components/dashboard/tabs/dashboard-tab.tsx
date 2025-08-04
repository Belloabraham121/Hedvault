"use client"

import { useState } from "react"
import { Eye, EyeOff, TrendingUp, DollarSign, Activity } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { PortfolioCard } from "../ui/portfolio-card"
import { TransactionItem } from "../ui/transaction-item"

export function DashboardTab() {
  const [showBalance, setShowBalance] = useState(true)

  const portfolioData = [
    {
      asset: "Real Estate Token",
      symbol: "RET",
      category: "Real Estate",
      balance: "1,250.00",
      value: "$125,000",
      change: "+5.2%",
      purchasePrice: "$95.50",
      currentPrice: "$100.00",
      unrealizedPnL: "+$5,625",
      apy: "8.5%",
      lastUpdated: "2 min ago",
      status: "Active",
      location: "New York, USA",
    },
    {
      asset: "Gold Commodity",
      symbol: "GOLD",
      category: "Commodities",
      balance: "50.75",
      value: "$95,250",
      change: "+2.1%",
      purchasePrice: "$1,820.00",
      currentPrice: "$1,878.00",
      unrealizedPnL: "+$2,942",
      apy: "6.2%",
      lastUpdated: "1 min ago",
      status: "Active",
      location: "LBMA Certified",
    },
    {
      asset: "Invoice Token",
      symbol: "INV",
      category: "Trade Finance",
      balance: "2,100.00",
      value: "$42,000",
      change: "+1.8%",
      purchasePrice: "$19.50",
      currentPrice: "$20.00",
      unrealizedPnL: "+$1,050",
      apy: "12.3%",
      lastUpdated: "5 min ago",
      status: "Active",
      location: "Global Supply Chain",
    },
    {
      asset: "Art Collection",
      symbol: "ART",
      category: "Collectibles",
      balance: "15.00",
      value: "$75,000",
      change: "+8.5%",
      purchasePrice: "$4,500.00",
      currentPrice: "$5,000.00",
      unrealizedPnL: "+$7,500",
      apy: "4.2%",
      lastUpdated: "1 hour ago",
      status: "Active",
      location: "Sotheby's Verified",
    },
  ]

  const recentTransactions = [
    { type: "Buy", asset: "RET", amount: "100.00", value: "$10,000", time: "2 hours ago" },
    { type: "Swap", asset: "GOLD → INV", amount: "5.25", value: "$5,250", time: "1 day ago" },
    { type: "Lend", asset: "ART", amount: "2.00", value: "$10,000", time: "3 days ago" },
    { type: "Reward", asset: "RET", amount: "12.50", value: "$1,250", time: "1 week ago" },
  ]

  return (
    <div className="space-y-8">
      {/* Portfolio Overview */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <PortfolioCard
          title="Total Portfolio Value"
          value={showBalance ? "$337,250" : "••••••"}
          change="+4.2% (24h)"
          changeType="positive"
          className="lg:col-span-1"
        >
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setShowBalance(!showBalance)}
            className="text-gray-400 hover:text-white"
          >
            {showBalance ? <Eye className="h-4 w-4" /> : <EyeOff className="h-4 w-4" />}
          </Button>
        </PortfolioCard>

        <PortfolioCard title="Active Positions" value="4" change="Across 4 asset classes" />

        <PortfolioCard title="Monthly Rewards" value="$2,847" change="+12.5% vs last month" changeType="positive" />
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

      {/* Portfolio Holdings */}
      <Card className="bg-gray-950/80 backdrop-blur-sm border-gray-800">
        <CardHeader className="pb-6">
          <CardTitle className="text-2xl font-bold text-white">Portfolio Holdings</CardTitle>
          <p className="text-gray-400">Your tokenized real-world assets</p>
        </CardHeader>
        <CardContent>
          <div className="space-y-6">
            {portfolioData.map((item, index) => (
              <div
                key={index}
                className="p-6 rounded-xl bg-gray-900/60 backdrop-blur-sm border border-gray-700/50 hover:bg-gray-800/60 transition-all duration-200"
              >
                {/* Header Row */}
                <div className="flex items-center justify-between mb-4">
                  <div className="flex items-center space-x-4">
                    <div className="w-12 h-12 rounded-xl bg-green-500/10 border border-green-500/20 flex items-center justify-center">
                      <span className="text-green-400 font-bold text-sm">{item.symbol}</span>
                    </div>
                    <div>
                      <div className="flex items-center space-x-3">
                        <h3 className="text-white font-semibold text-lg">{item.asset}</h3>
                        <span className="px-2 py-1 rounded-full text-xs font-medium bg-blue-500/20 text-blue-400 border border-blue-500/30">
                          {item.category}
                        </span>
                        <span
                          className={`px-2 py-1 rounded-full text-xs font-medium ${
                            item.status === "Active"
                              ? "bg-green-500/20 text-green-400 border border-green-500/30"
                              : "bg-gray-500/20 text-gray-400 border border-gray-500/30"
                          }`}
                        >
                          {item.status}
                        </span>
                      </div>
                      <p className="text-gray-400 text-sm mt-1">
                        {item.balance} {item.symbol} • {item.location}
                      </p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-white font-semibold text-xl">{item.value}</p>
                    <p className="text-green-400 text-sm font-medium">{item.change} (24h)</p>
                  </div>
                </div>

                {/* Details Grid */}
                <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4 mb-4">
                  <div className="space-y-1">
                    <p className="text-gray-400 text-xs uppercase tracking-wide">Current Price</p>
                    <p className="text-white font-semibold">{item.currentPrice}</p>
                  </div>
                  <div className="space-y-1">
                    <p className="text-gray-400 text-xs uppercase tracking-wide">Purchase Price</p>
                    <p className="text-gray-300 font-medium">{item.purchasePrice}</p>
                  </div>
                  <div className="space-y-1">
                    <p className="text-gray-400 text-xs uppercase tracking-wide">Unrealized P&L</p>
                    <p className="text-green-400 font-semibold">{item.unrealizedPnL}</p>
                  </div>
                  <div className="space-y-1">
                    <p className="text-gray-400 text-xs uppercase tracking-wide">APY</p>
                    <p className="text-purple-400 font-semibold">{item.apy}</p>
                  </div>
                  <div className="space-y-1">
                    <p className="text-gray-400 text-xs uppercase tracking-wide">Last Updated</p>
                    <p className="text-gray-300 font-medium">{item.lastUpdated}</p>
                  </div>
                  <div className="space-y-1">
                    <p className="text-gray-400 text-xs uppercase tracking-wide">Holdings</p>
                    <p className="text-white font-semibold">{item.balance}</p>
                  </div>
                </div>

                {/* Action Buttons */}
                <div className="flex flex-wrap gap-3 pt-4 border-t border-gray-700/50">
                  <Button
                    size="sm"
                    className="bg-green-500/10 hover:bg-green-500/20 text-green-400 border border-green-500/30"
                  >
                    Buy More
                  </Button>
                  <Button size="sm" className="bg-red-500/10 hover:bg-red-500/20 text-red-400 border border-red-500/30">
                    Sell
                  </Button>
                  <Button
                    size="sm"
                    className="bg-blue-500/10 hover:bg-blue-500/20 text-blue-400 border border-blue-500/30"
                  >
                    Swap
                  </Button>
                  <Button
                    size="sm"
                    className="bg-purple-500/10 hover:bg-purple-500/20 text-purple-400 border border-purple-500/30"
                  >
                    Lend
                  </Button>
                  <Button
                    size="sm"
                    variant="outline"
                    className="border-gray-600 text-gray-300 bg-transparent hover:bg-gray-800/50"
                  >
                    View Details
                  </Button>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Recent Transactions with Bottom Left Card */}
      <div className="relative">
        <Card className="bg-gray-950/80 backdrop-blur-sm border-gray-800">
          <CardHeader className="pb-6">
            <CardTitle className="text-2xl font-bold text-white">Recent Activity</CardTitle>
            <p className="text-gray-400">Your latest transactions and activities</p>
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
  )
}
