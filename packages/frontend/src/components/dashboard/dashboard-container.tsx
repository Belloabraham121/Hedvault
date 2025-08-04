"use client"

import { useState } from "react"
import { DashboardSidebar } from "./layout/dashboard-sidebar"
import { DashboardMain } from "./layout/dashboard-main"
import { DashboardTab } from "./tabs/dashboard-tab"
import { BlendTab } from "./tabs/blend-tab"
import { SwapTab } from "./tabs/swap-tab"
import { BridgeTab } from "./tabs/bridge-tab"
import { BuySellTab } from "./tabs/buysell-tab"
import { RewardsTab } from "./tabs/rewards-tab"

export function DashboardContainer() {
  const [activeTab, setActiveTab] = useState("dashboard")
  const [isCollapsed, setIsCollapsed] = useState(false)

  const handleToggleCollapse = () => {
    setIsCollapsed(!isCollapsed)
  }

  const renderTabContent = () => {
    switch (activeTab) {
      case "dashboard":
        return <DashboardTab />
      case "blend":
        return <BlendTab />
      case "swap":
        return <SwapTab />
      case "bridge":
        return <BridgeTab />
      case "buysell":
        return <BuySellTab />
      case "rewards":
        return <RewardsTab />
      default:
        return <DashboardTab />
    }
  }

  return (
    <div className="min-h-screen bg-black text-white flex">
      <DashboardSidebar
        activeTab={activeTab}
        onTabChange={setActiveTab}
        isCollapsed={isCollapsed}
        onToggleCollapse={handleToggleCollapse}
      />
      <DashboardMain activeTab={activeTab}>{renderTabContent()}</DashboardMain>
    </div>
  )
}
