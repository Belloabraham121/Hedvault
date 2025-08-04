"use client"

import type React from "react"
import {
  Vault,
  LayoutDashboard,
  ArrowLeftRight,
  Shuffle,
  BracketsIcon as Bridge,
  TrendingUp,
  Gift,
  Settings,
  LogOut,
  Bell,
  ChevronLeft,
} from "lucide-react"
import { Button } from "@/components/ui/button"

interface Tab {
  id: string
  label: string
  icon: React.ComponentType<{ className?: string }>
}

interface DashboardSidebarProps {
  activeTab: string
  onTabChange: (tabId: string) => void
  isCollapsed: boolean
  onToggleCollapse: () => void
}

export function DashboardSidebar({ activeTab, onTabChange, isCollapsed, onToggleCollapse }: DashboardSidebarProps) {
  const tabs: Tab[] = [
    { id: "dashboard", label: "Dashboard", icon: LayoutDashboard },
    { id: "blend", label: "Blend", icon: Shuffle },
    { id: "swap", label: "Swap", icon: ArrowLeftRight },
    { id: "bridge", label: "Bridge", icon: Bridge },
    { id: "buysell", label: "Buy/Sell", icon: TrendingUp },
    { id: "rewards", label: "Rewards", icon: Gift },
  ]

  return (
    <aside
      className={`bg-black/95 backdrop-blur-sm border-r border-gray-900 min-h-screen flex flex-col transition-all duration-300 ease-in-out ${
        isCollapsed ? "w-20" : "w-80"
      }`}
    >
      {/* Logo Section with Toggle Button */}
      <div className="p-8 border-b border-gray-900 relative">
        <div
          className={`flex items-center transition-all duration-300 ${isCollapsed ? "justify-center" : "space-x-3"}`}
        >
          <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-green-500 shadow-lg flex-shrink-0">
            <Vault className="h-7 w-7 text-black" />
          </div>
          {!isCollapsed && (
            <div className="transition-opacity duration-300">
              <h1 className="text-2xl font-bold text-white">HedVault</h1>
              <p className="text-sm text-gray-400">RWA DeFi Platform</p>
            </div>
          )}
        </div>

        {/* Toggle Button */}
        <button
          onClick={onToggleCollapse}
          className={`absolute top-1/2 -translate-y-1/2 w-8 h-8 bg-gray-800 hover:bg-gray-700 border border-gray-700 rounded-lg flex items-center justify-center transition-all duration-200 group ${
            isCollapsed ? "-right-4" : "right-4"
          }`}
          title={isCollapsed ? "Expand sidebar" : "Collapse sidebar"}
        >
          <ChevronLeft
            className={`h-4 w-4 text-gray-400 group-hover:text-white transition-all duration-200 ${
              isCollapsed ? "rotate-180" : ""
            }`}
          />
        </button>
      </div>

      {/* Navigation Tabs */}
      <nav className="flex-1 p-6">
        <div className="space-y-2">
          {!isCollapsed && (
            <p className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-4 transition-opacity duration-300">
              Navigation
            </p>
          )}
          {tabs.map((tab) => {
            const Icon = tab.icon
            return (
              <button
                key={tab.id}
                onClick={() => onTabChange(tab.id)}
                className={`w-full flex items-center rounded-xl transition-all duration-200 group ${
                  isCollapsed ? "justify-center px-3 py-4" : "space-x-4 px-4 py-3"
                } ${
                  activeTab === tab.id
                    ? "bg-green-500/15 text-green-400 border border-green-500/20 shadow-lg"
                    : "text-gray-400 hover:text-white hover:bg-gray-900/50"
                }`}
                title={isCollapsed ? tab.label : undefined}
              >
                <Icon
                  className={`h-5 w-5 flex-shrink-0 ${activeTab === tab.id ? "text-green-400" : "text-gray-500 group-hover:text-gray-300"}`}
                />
                {!isCollapsed && (
                  <span className="font-medium text-base transition-opacity duration-300">{tab.label}</span>
                )}
              </button>
            )
          })}
        </div>
      </nav>

      {/* Bottom Section */}
      <div className={`border-t border-gray-900 transition-all duration-300 ${isCollapsed ? "p-3" : "p-6"}`}>
        {!isCollapsed ? (
          <div className="space-y-4">
            {/* Wallet Connection */}
            <div className="p-4 rounded-xl bg-gray-900/50 border border-gray-800 transition-opacity duration-300">
              <div className="flex items-center justify-between mb-3">
                <div className="flex items-center space-x-2">
                  <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                  <span className="text-sm font-medium text-white">Wallet Connected</span>
                </div>
                <Bell className="h-4 w-4 text-gray-400" />
              </div>
              <p className="text-xs text-gray-400 mb-3">0x1234...5678</p>
              <Button size="sm" className="w-full bg-green-500 hover:bg-green-600 text-black font-medium">
                Manage Wallet
              </Button>
            </div>

            {/* Settings & Logout */}
            <div className="flex space-x-2">
              <Button variant="ghost" size="sm" className="flex-1 text-gray-400 hover:text-white hover:bg-gray-900/50">
                <Settings className="h-4 w-4 mr-2" />
                Settings
              </Button>
              <Button variant="ghost" size="sm" className="flex-1 text-gray-400 hover:text-white hover:bg-gray-900/50">
                <LogOut className="h-4 w-4 mr-2" />
                Logout
              </Button>
            </div>
          </div>
        ) : (
          <div className="space-y-3">
            <Button
              variant="ghost"
              size="sm"
              className="w-full p-3 text-gray-400 hover:text-white hover:bg-gray-900/50"
              title="Settings"
            >
              <Settings className="h-4 w-4" />
            </Button>
            <Button
              variant="ghost"
              size="sm"
              className="w-full p-3 text-gray-400 hover:text-white hover:bg-gray-900/50"
              title="Logout"
            >
              <LogOut className="h-4 w-4" />
            </Button>
          </div>
        )}
      </div>
    </aside>
  )
}
