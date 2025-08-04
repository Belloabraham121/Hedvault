"use client"

import type React from "react"

interface DashboardMainProps {
  activeTab: string
  children: React.ReactNode
}

export function DashboardMain({ activeTab, children }: DashboardMainProps) {
  const getTabInfo = (tab: string) => {
    const tabInfo = {
      dashboard: {
        title: "Portfolio Dashboard",
        description: "Overview of your RWA portfolio and activities",
      },
      blend: {
        title: "Blend Strategies",
        description: "Lending, borrowing, and yield strategies for your RWAs",
      },
      swap: {
        title: "Asset Swap",
        description: "Exchange between different tokenized assets",
      },
      bridge: {
        title: "Cross-Chain Bridge",
        description: "Transfer assets across networks",
      },
      buysell: {
        title: "Buy & Sell",
        description: "Buy and sell tokenized real-world assets",
      },
      rewards: {
        title: "Rewards Center",
        description: "Manage your staking rewards and yields",
      },
    }
    return tabInfo[tab as keyof typeof tabInfo] || { title: tab, description: "" }
  }

  const { title, description } = getTabInfo(activeTab)

  return (
    <main className="flex-1 bg-black min-h-screen">
      <div className="p-8 lg:p-12">
        <div className="max-w-7xl mx-auto">
          {/* Page Header */}
          <div className="mb-8">
            <h1 className="text-4xl lg:text-5xl font-bold text-white mb-3">{title}</h1>
            <p className="text-lg text-gray-400 max-w-2xl">{description}</p>
          </div>

          {/* Main Content */}
          <div className="space-y-8">{children}</div>
        </div>
      </div>
    </main>
  )
}
