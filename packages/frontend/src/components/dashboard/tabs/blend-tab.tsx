"use client"

import { useState } from "react"
import { TrendingUp, ArrowUpRight, ArrowDownRight } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"

export function BlendTab() {
  const [activeStrategy, setActiveStrategy] = useState("lend")

  const lendingOpportunities = [
    {
      asset: "Real Estate Token",
      symbol: "RET",
      apy: "8.5%",
      totalLent: "$125,000",
      available: "$2.5M",
      risk: "Low",
    },
    {
      asset: "Gold Commodity",
      symbol: "GOLD",
      apy: "6.2%",
      totalLent: "$95,250",
      available: "$1.8M",
      risk: "Low",
    },
    {
      asset: "Invoice Token",
      symbol: "INV",
      apy: "12.3%",
      totalLent: "$42,000",
      available: "$850K",
      risk: "Medium",
    },
  ]

  const borrowingOptions = [
    {
      asset: "USDC",
      collateral: "Real Estate Token",
      ltv: "75%",
      interestRate: "5.8%",
      borrowed: "$93,750",
      available: "$31,250",
    },
    {
      asset: "HBAR",
      collateral: "Gold Commodity",
      ltv: "70%",
      interestRate: "7.2%",
      borrowed: "$66,675",
      available: "$28,575",
    },
  ]

  const yieldStrategies = [
    {
      name: "Conservative RWA Portfolio",
      description: "Low-risk lending across diversified real-world assets",
      apy: "7.8%",
      tvl: "$2.1M",
      assets: ["RET", "GOLD", "BONDS"],
      risk: "Low",
    },
    {
      name: "High-Yield Invoice Strategy",
      description: "Higher returns through invoice factoring and trade finance",
      apy: "14.2%",
      tvl: "$850K",
      assets: ["INV", "TRADE", "SUPPLY"],
      risk: "Medium",
    },
    {
      name: "Balanced Growth Strategy",
      description: "Mixed lending and borrowing for optimized returns",
      apy: "11.5%",
      tvl: "$1.5M",
      assets: ["RET", "GOLD", "INV", "USDC"],
      risk: "Medium",
    },
  ]

  const renderLendingContent = () => (
    <div className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <div className="p-4 rounded-lg bg-gray-900/70 text-center">
          <p className="text-gray-400 text-sm">Total Lent</p>
          <p className="text-2xl font-bold text-green-400">$262,250</p>
        </div>
        <div className="p-4 rounded-lg bg-gray-900/70 text-center">
          <p className="text-gray-400 text-sm">Average APY</p>
          <p className="text-2xl font-bold text-white">9.0%</p>
        </div>
        <div className="p-4 rounded-lg bg-gray-900/70 text-center">
          <p className="text-gray-400 text-sm">Monthly Earnings</p>
          <p className="text-2xl font-bold text-green-400">$1,967</p>
        </div>
      </div>

      <div className="space-y-4">
        {lendingOpportunities.map((opportunity, index) => (
          <div key={index} className="p-6 rounded-lg bg-gray-900/60 border border-gray-700">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center space-x-3">
                <div className="w-10 h-10 rounded-full bg-green-500/10 flex items-center justify-center">
                  <span className="text-green-400 font-semibold text-sm">{opportunity.symbol}</span>
                </div>
                <div>
                  <h3 className="text-white font-semibold">{opportunity.asset}</h3>
                  <p className="text-gray-400 text-sm">Available: {opportunity.available}</p>
                </div>
              </div>
              <div className="text-right">
                <p className="text-2xl font-bold text-green-400">{opportunity.apy}</p>
                <p className="text-gray-400 text-sm">APY</p>
              </div>
            </div>

            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4">
              <div>
                <p className="text-gray-400 text-xs">Your Lending</p>
                <p className="text-white font-medium">{opportunity.totalLent}</p>
              </div>
              <div>
                <p className="text-gray-400 text-xs">Risk Level</p>
                <p className={`font-medium ${opportunity.risk === "Low" ? "text-green-400" : "text-yellow-400"}`}>
                  {opportunity.risk}
                </p>
              </div>
            </div>

            <div className="flex gap-3">
              <Button className="flex-1 bg-green-500 hover:bg-green-600 text-black">Lend More</Button>
              <Button variant="outline" className="flex-1 border-gray-600 text-white bg-transparent">
                Withdraw
              </Button>
            </div>
          </div>
        ))}
      </div>
    </div>
  )

  const renderBorrowingContent = () => (
    <div className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <div className="p-4 rounded-lg bg-gray-900/70 text-center">
          <p className="text-gray-400 text-sm">Total Borrowed</p>
          <p className="text-2xl font-bold text-blue-400">$160,425</p>
        </div>
        <div className="p-4 rounded-lg bg-gray-900/70 text-center">
          <p className="text-gray-400 text-sm">Available to Borrow</p>
          <p className="text-2xl font-bold text-white">$59,825</p>
        </div>
        <div className="p-4 rounded-lg bg-gray-900/70 text-center">
          <p className="text-gray-400 text-sm">Health Factor</p>
          <p className="text-2xl font-bold text-green-400">2.1</p>
        </div>
      </div>

      <div className="space-y-4">
        {borrowingOptions.map((option, index) => (
          <div key={index} className="p-6 rounded-lg bg-gray-900/60 border border-gray-700">
            <div className="flex items-center justify-between mb-4">
              <div>
                <h3 className="text-white font-semibold">Borrow {option.asset}</h3>
                <p className="text-gray-400 text-sm">Collateral: {option.collateral}</p>
              </div>
              <div className="text-right">
                <p className="text-2xl font-bold text-blue-400">{option.interestRate}</p>
                <p className="text-gray-400 text-sm">Interest Rate</p>
              </div>
            </div>

            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4">
              <div>
                <p className="text-gray-400 text-xs">Currently Borrowed</p>
                <p className="text-white font-medium">{option.borrowed}</p>
              </div>
              <div>
                <p className="text-gray-400 text-xs">Available</p>
                <p className="text-white font-medium">{option.available}</p>
              </div>
              <div>
                <p className="text-gray-400 text-xs">Max LTV</p>
                <p className="text-white font-medium">{option.ltv}</p>
              </div>
            </div>

            <div className="flex gap-3">
              <Button className="flex-1 bg-blue-500 hover:bg-blue-600 text-white">Borrow More</Button>
              <Button variant="outline" className="flex-1 border-gray-600 text-white bg-transparent">
                Repay
              </Button>
            </div>
          </div>
        ))}
      </div>
    </div>
  )

  const renderYieldContent = () => (
    <div className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <div className="p-4 rounded-lg bg-gray-900/70 text-center">
          <p className="text-gray-400 text-sm">Active Strategies</p>
          <p className="text-2xl font-bold text-purple-400">2</p>
        </div>
        <div className="p-4 rounded-lg bg-gray-900/70 text-center">
          <p className="text-gray-400 text-sm">Total Value</p>
          <p className="text-2xl font-bold text-white">$185,000</p>
        </div>
        <div className="p-4 rounded-lg bg-gray-900/70 text-center">
          <p className="text-gray-400 text-sm">Avg. APY</p>
          <p className="text-2xl font-bold text-green-400">10.2%</p>
        </div>
      </div>

      <div className="space-y-4">
        {yieldStrategies.map((strategy, index) => (
          <div key={index} className="p-6 rounded-lg bg-gray-900/60 border border-gray-700">
            <div className="flex items-center justify-between mb-4">
              <div>
                <h3 className="text-white font-semibold text-lg">{strategy.name}</h3>
                <p className="text-gray-400 text-sm">{strategy.description}</p>
              </div>
              <div className="text-right">
                <p className="text-2xl font-bold text-green-400">{strategy.apy}</p>
                <p className="text-gray-400 text-sm">APY</p>
              </div>
            </div>

            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4">
              <div>
                <p className="text-gray-400 text-xs">Total Value Locked</p>
                <p className="text-white font-medium">{strategy.tvl}</p>
              </div>
              <div>
                <p className="text-gray-400 text-xs">Risk Level</p>
                <p className={`font-medium ${strategy.risk === "Low" ? "text-green-400" : "text-yellow-400"}`}>
                  {strategy.risk}
                </p>
              </div>
              <div>
                <p className="text-gray-400 text-xs">Assets</p>
                <p className="text-white font-medium">{strategy.assets.join(", ")}</p>
              </div>
            </div>

            <div className="flex gap-3">
              <Button className="flex-1 bg-purple-500 hover:bg-purple-600 text-white">Join Strategy</Button>
              <Button variant="outline" className="flex-1 border-gray-600 text-white bg-transparent">
                Learn More
              </Button>
            </div>
          </div>
        ))}
      </div>
    </div>
  )

  return (
    <div className="space-y-6">
      <Card className="bg-gray-950/80 border-gray-800">
        <CardHeader>
          <CardTitle className="text-white">Blend - DeFi Strategies</CardTitle>
          <p className="text-gray-400">Lending, borrowing, and yield optimization for your RWA portfolio</p>
        </CardHeader>
        <CardContent>
          {/* Strategy Tabs */}
          <div className="flex space-x-1 mb-6 bg-gray-900/70 p-1 rounded-lg">
            <button
              onClick={() => setActiveStrategy("lend")}
              className={`flex-1 flex items-center justify-center gap-2 px-4 py-2 rounded-md transition-colors ${
                activeStrategy === "lend" ? "bg-green-500/20 text-green-400" : "text-gray-400 hover:text-white"
              }`}
            >
              <ArrowUpRight className="h-4 w-4" />
              Lending
            </button>
            <button
              onClick={() => setActiveStrategy("borrow")}
              className={`flex-1 flex items-center justify-center gap-2 px-4 py-2 rounded-md transition-colors ${
                activeStrategy === "borrow" ? "bg-blue-500/20 text-blue-400" : "text-gray-400 hover:text-white"
              }`}
            >
              <ArrowDownRight className="h-4 w-4" />
              Borrowing
            </button>
            <button
              onClick={() => setActiveStrategy("yield")}
              className={`flex-1 flex items-center justify-center gap-2 px-4 py-2 rounded-md transition-colors ${
                activeStrategy === "yield" ? "bg-purple-500/20 text-purple-400" : "text-gray-400 hover:text-white"
              }`}
            >
              <TrendingUp className="h-4 w-4" />
              Yield Strategies
            </button>
          </div>

          {/* Content based on active strategy */}
          {activeStrategy === "lend" && renderLendingContent()}
          {activeStrategy === "borrow" && renderBorrowingContent()}
          {activeStrategy === "yield" && renderYieldContent()}
        </CardContent>
      </Card>
    </div>
  )
}
