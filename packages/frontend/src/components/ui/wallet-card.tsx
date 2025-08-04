"use client";

import { Bell } from "lucide-react";
import { Button } from "@/components/ui/button";

interface WalletCardProps {
  isConnected?: boolean;
  walletAddress?: string;
  onManageWallet?: () => void;
  className?: string;
}

export function WalletCard({
  isConnected = true,
  walletAddress = "0x1234...5678",
  onManageWallet,
  className = ""
}: WalletCardProps) {
  return (
    <div className={`p-4 rounded-xl bg-gray-900/50 border border-gray-800 transition-opacity duration-300 ${className}`}>
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center space-x-2">
          <div className={`w-2 h-2 rounded-full ${
            isConnected ? "bg-green-500" : "bg-red-500"
          }`}></div>
          <span className="text-sm font-medium text-white">
            {isConnected ? "Wallet Connected" : "Wallet Disconnected"}
          </span>
        </div>
        <Bell className="h-4 w-4 text-gray-400" />
      </div>
      <p className="text-xs text-gray-400 mb-3">{walletAddress}</p>
      <Button
        size="sm"
        className="w-full bg-green-500 hover:bg-green-600 text-black font-medium"
        onClick={onManageWallet}
      >
        Manage Wallet
      </Button>
    </div>
  );
}