"use client"

import { useState } from "react"
import { ArrowUpDown, ArrowRight, AlertTriangle, CheckCircle, Clock, ExternalLink } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"

export function BridgeTab() {
  const [fromChain, setFromChain] = useState("hedera")
  const [toChain, setToChain] = useState("ethereum")
  const [selectedAsset, setSelectedAsset] = useState("")
  const [amount, setAmount] = useState("")

  const chains = [
    {
      id: "hedera",
      name: "Hedera",
      symbol: "HBAR",
      logo: "🌿",
      color: "text-green-400",
      bgColor: "bg-green-500/10",
      borderColor: "border-green-500/20",
    },
    {
      id: "ethereum",
      name: "Ethereum",
      symbol: "ETH",
      logo: "⟠",
      color: "text-blue-400",
      bgColor: "bg-blue-500/10",
      borderColor: "border-blue-500/20",
    },
    {
      id: "polygon",
      name: "Polygon",
      symbol: "MATIC",
      logo: "⬟",
      color: "text-purple-400",
      bgColor: "bg-purple-500/10",
      borderColor: "border-purple-500/20",
    },
    {
      id: "bsc",
      name: "BSC",
      symbol: "BNB",
      logo: "🟡",
      color: "text-yellow-400",
      bgColor: "bg-yellow-500/10",
      borderColor: "border-yellow-500/20",
    },
  ]

  const bridgeableAssets = [
    {
      symbol: "RET",
      name: "Real Estate Token",
      balance: "1,250.00",
      chains: ["hedera", "ethereum", "polygon"],
    },
    {
      symbol: "GOLD",
      name: "Gold Commodity",
      balance: "50.75",
      chains: ["hedera", "ethereum"],
    },
    {
      symbol: "USDC",
      name: "USD Coin",
      balance: "5,000.00",
      chains: ["hedera", "ethereum", "polygon", "bsc"],
    },
    {
      symbol: "HBAR",
      name: "Hedera Token",
      balance: "10,000.00",
      chains: ["hedera"],
    },
  ]

  const recentBridges = [
    {
      asset: "RET",
      amount: "100.00",
      from: "hedera",
      to: "ethereum",
      status: "completed",
      txHash: "0x1234...5678",
      time: "2 hours ago",
    },
    {
      asset: "USDC",
      amount: "1,000.00",
      from: "ethereum",
      to: "hedera",
      status: "pending",
      txHash: "0xabcd...efgh",
      time: "30 minutes ago",
    },
    {
      asset: "GOLD",
      amount: "25.50",
      from: "hedera",
      to: "polygon",
      status: "processing",
      txHash: "0x9876...5432",
      time: "1 hour ago",
    },
  ]

  const getChainInfo = (chainId: string) => {
    return chains.find((chain) => chain.id === chainId) || chains[0]
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "completed":
        return <CheckCircle className="h-4 w-4 text-green-400" />
      case "pending":
        return <Clock className="h-4 w-4 text-yellow-400" />
      case "processing":
        return <ArrowRight className="h-4 w-4 text-blue-400 animate-pulse" />
      default:
        return <AlertTriangle className="h-4 w-4 text-red-400" />
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case "completed":
        return "text-green-400"
      case "pending":
        return "text-yellow-400"
      case "processing":
        return "text-blue-400"
      default:
        return "text-red-400"
    }
  }

  const handleSwapChains = () => {
    const temp = fromChain
    setFromChain(toChain)
    setToChain(temp)
  }

  const filteredAssets = bridgeableAssets.filter(
    (asset) => asset.chains.includes(fromChain) && asset.chains.includes(toChain),
  )

  return (
    <div className="space-y-8">
      {/* Bridge Overview */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card className="bg-gray-950/80 backdrop-blur-sm border-gray-800">
          <CardHeader className="pb-4">
            <CardTitle className="text-sm font-medium text-gray-400 uppercase tracking-wide">Total Bridged</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-white">$2.1M</div>
            <p className="text-sm mt-2 font-medium text-green-400">+15.2% this month</p>
          </CardContent>
        </Card>

        <Card className="bg-gray-950/80 backdrop-blur-sm border-gray-800">
          <CardHeader className="pb-4">
            <CardTitle className="text-sm font-medium text-gray-400 uppercase tracking-wide">Active Bridges</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-white">3</div>
            <p className="text-sm mt-2 font-medium text-gray-400">Across 4 chains</p>
          </CardContent>
        </Card>

        <Card className="bg-gray-950/80 backdrop-blur-sm border-gray-800">
          <CardHeader className="pb-4">
            <CardTitle className="text-sm font-medium text-gray-400 uppercase tracking-wide">Avg. Time</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-white">~12m</div>
            <p className="text-sm mt-2 font-medium text-gray-400">Bridge completion</p>
          </CardContent>
        </Card>
      </div>

      {/* Bridge Interface */}
      <Card className="bg-gray-950/80 backdrop-blur-sm border-gray-800">
        <CardHeader>
          <CardTitle className="text-2xl font-bold text-white">Cross-Chain Bridge</CardTitle>
          <p className="text-gray-400">Transfer your RWA tokens between different blockchain networks</p>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Chain Selection */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 items-center">
            {/* From Chain */}
            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-400">From</label>
              <select
                value={fromChain}
                onChange={(e) => setFromChain(e.target.value)}
                className="w-full p-4 rounded-xl bg-gray-900/70 border border-gray-700 text-white focus:border-green-500 focus:outline-none"
              >
                {chains.map((chain) => (
                  <option key={chain.id} value={chain.id}>
                    {chain.logo} {chain.name}
                  </option>
                ))}
              </select>
            </div>

            {/* Swap Button */}
            <div className="flex justify-center">
              <Button
                variant="ghost"
                size="sm"
                onClick={handleSwapChains}
                className="rounded-full bg-gray-800 hover:bg-gray-700 p-3"
              >
                <ArrowUpDown className="h-5 w-5 text-green-400" />
              </Button>
            </div>

            {/* To Chain */}
            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-400">To</label>
              <select
                value={toChain}
                onChange={(e) => setToChain(e.target.value)}
                className="w-full p-4 rounded-xl bg-gray-900/70 border border-gray-700 text-white focus:border-green-500 focus:outline-none"
              >
                {chains.map((chain) => (
                  <option key={chain.id} value={chain.id}>
                    {chain.logo} {chain.name}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {/* Asset Selection */}
          <div className="space-y-2">
            <label className="text-sm font-medium text-gray-400">Select Asset</label>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {filteredAssets.map((asset) => (
                <button
                  key={asset.symbol}
                  onClick={() => setSelectedAsset(asset.symbol)}
                  className={`p-4 rounded-xl border transition-all duration-200 text-left ${
                    selectedAsset === asset.symbol
                      ? "bg-green-500/10 border-green-500/30 text-green-400"
                      : "bg-gray-800/50 border-gray-700 text-white hover:bg-gray-800/70"
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-semibold">{asset.symbol}</p>
                      <p className="text-sm text-gray-400">{asset.name}</p>
                    </div>
                    <div className="text-right">
                      <p className="font-medium">{asset.balance}</p>
                      <p className="text-xs text-gray-400">Available</p>
                    </div>
                  </div>
                </button>
              ))}
            </div>
          </div>

          {/* Amount Input */}
          <div className="space-y-2">
            <label className="text-sm font-medium text-gray-400">Amount</label>
            <div className="relative">
              <input
                type="text"
                placeholder="0.00"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
                className="w-full p-4 rounded-xl bg-gray-900/70 border border-gray-700 text-white text-xl focus:border-green-500 focus:outline-none pr-20"
              />
              <button className="absolute right-3 top-1/2 -translate-y-1/2 text-green-400 hover:text-green-300 text-sm font-medium">
                MAX
              </button>
            </div>
          </div>

          {/* Bridge Info */}
          {selectedAsset && amount && (
            <div className="p-4 rounded-xl bg-blue-500/10 border border-blue-500/20">
              <div className="flex items-start space-x-3">
                <AlertTriangle className="h-5 w-5 text-blue-400 mt-0.5" />
                <div className="space-y-2 text-sm">
                  <p className="text-blue-400 font-medium">Bridge Information</p>
                  <div className="space-y-1 text-gray-300">
                    <p>• Estimated time: 10-15 minutes</p>
                    <p>• Bridge fee: ~$2.50 (0.1%)</p>
                    <p>• Gas fee: ~$5.00 (varies by network)</p>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Bridge Button */}
          <Button
            className="w-full h-14 bg-green-500 hover:bg-green-600 text-black font-semibold text-lg"
            disabled={!selectedAsset || !amount}
          >
            {!selectedAsset || !amount ? "Select Asset & Amount" : `Bridge ${selectedAsset}`}
          </Button>
        </CardContent>
      </Card>

      {/* Recent Bridge Transactions */}
      <Card className="bg-gray-950/80 backdrop-blur-sm border-gray-800">
        <CardHeader>
          <CardTitle className="text-2xl font-bold text-white">Recent Bridge Transactions</CardTitle>
          <p className="text-gray-400">Track your cross-chain transfers</p>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {recentBridges.map((bridge, index) => {
              const fromChainInfo = getChainInfo(bridge.from)
              const toChainInfo = getChainInfo(bridge.to)

              return (
                <div
                  key={index}
                  className="flex items-center justify-between p-6 rounded-xl bg-gray-900/60 backdrop-blur-sm border border-gray-700/50 px-6 py-1 text-left leading-3 font-thin"
                >
                  <div className="flex items-center space-x-4">
                    <div className="flex items-center space-x-2">
                      <div className={`w-8 h-8 rounded-lg ${fromChainInfo.bgColor} flex items-center justify-center`}>
                        <span className="text-sm">{fromChainInfo.logo}</span>
                      </div>
                      <ArrowRight className="h-4 w-4 text-gray-400" />
                      <div className={`w-8 h-8 rounded-lg ${toChainInfo.bgColor} flex items-center justify-center`}>
                        <span className="text-sm">{toChainInfo.logo}</span>
                      </div>
                    </div>
                    <div>
                      <p className="text-white font-semibold leading-3">
                        {bridge.amount} {bridge.asset}
                      </p>
                      <p className="text-gray-400 text-sm">
                        {fromChainInfo.name} → {toChainInfo.name}
                      </p>
                    </div>
                  </div>

                  <div className="flex items-center space-x-4">
                    <div className="text-right">
                      <div className="flex items-center space-x-2">
                        {getStatusIcon(bridge.status)}
                        <span className={`font-medium capitalize ${getStatusColor(bridge.status)}`}>
                          {bridge.status}
                        </span>
                      </div>
                      <p className="text-gray-400 text-sm">{bridge.time}</p>
                    </div>
                    <Button variant="ghost" size="sm" className="text-gray-400 hover:text-white">
                      <ExternalLink className="h-4 w-4" />
                    </Button>
                  </div>
                </div>
              )
            })}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
