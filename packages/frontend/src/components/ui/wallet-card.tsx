"use client";

import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useDisconnect } from "wagmi";
import { Bell } from "lucide-react";
import { Button } from "@/components/ui/button";

interface WalletCardProps {
  className?: string;
}

export function WalletCard({ className = "" }: WalletCardProps) {
  const { disconnect } = useDisconnect();
  
  return (
    <div
      className={`bg-gray-900/50 border border-gray-800 rounded-xl p-4 ${className}`}
    >
      <ConnectButton.Custom>
        {({
          account,
          chain,
          openAccountModal,
          openChainModal,
          openConnectModal,
          authenticationStatus,
          mounted,
        }) => {
          const ready = mounted && authenticationStatus !== "loading";
          const connected =
            ready &&
            account &&
            chain &&
            (!authenticationStatus || authenticationStatus === "authenticated");

          return (
            <div
              {...(!ready && {
                "aria-hidden": true,
                style: {
                  opacity: 0,
                  pointerEvents: "none",
                  userSelect: "none",
                },
              })}
            >
              {(() => {
                if (!connected) {
                  return (
                    <div className="text-center">
                      <div className="flex items-center justify-between mb-3">
                        <div className="flex items-center space-x-2">
                          <div className="w-2 h-2 bg-red-400 rounded-full"></div>
                          <span className="text-sm font-medium text-red-400">
                            Wallet Disconnected
                          </span>
                        </div>
                        <Bell className="w-4 h-4 text-gray-400" />
                      </div>
                      <Button
                        onClick={openConnectModal}
                        size="sm"
                        className="w-full text-xs bg-green-500 hover:bg-green-600 text-black font-semibold border-0"
                      >
                        Connect Wallet
                      </Button>
                    </div>
                  );
                }

                if (chain.unsupported) {
                  return (
                    <div className="text-center">
                      <div className="flex items-center justify-between mb-3">
                        <div className="flex items-center space-x-2">
                          <div className="w-2 h-2 bg-yellow-400 rounded-full"></div>
                          <span className="text-sm font-medium text-yellow-400">
                            Wrong Network
                          </span>
                        </div>
                        <Bell className="w-4 h-4 text-gray-400" />
                      </div>
                      <Button
                        onClick={openChainModal}
                        size="sm"
                        className="w-full text-xs bg-yellow-500 hover:bg-yellow-600 text-black font-semibold border-0"
                      >
                        Switch Network
                      </Button>
                    </div>
                  );
                }

                return (
                  <div>
                    <div className="flex items-center justify-between mb-3">
                      <div className="flex items-center space-x-2">
                        <div className="w-2 h-2 bg-green-400 rounded-full"></div>
                        <span className="text-sm font-medium text-green-400">
                          Wallet Connected
                        </span>
                      </div>
                      <Bell className="w-4 h-4 text-gray-400" />
                    </div>

                    <div className="mb-4">
                      <p className="text-xs text-gray-500 mb-1">Address</p>
                      <p className="text-sm font-mono text-gray-300">
                        {account.displayName}
                      </p>
                      <p className="text-xs text-gray-500 mt-1">
                        Network: {chain.name}
                      </p>
                    </div>

                    <div className="space-y-2">
                      <div className="flex gap-2">
                        <Button
                          onClick={openAccountModal}
                          size="sm"
                          className="flex-1 text-xs bg-blue-500 hover:bg-blue-600 text-white font-semibold border-0"
                        >
                          Manage Wallet
                        </Button>
                        <Button
                          onClick={openChainModal}
                          size="sm"
                          className="flex-1 text-xs bg-purple-500 hover:bg-purple-600 text-white font-semibold border-0"
                        >
                          {chain.name}
                        </Button>
                      </div>
                      <Button
                        onClick={() => {
                          disconnect();
                        }}
                        size="sm"
                        className="w-full text-xs bg-red-500 hover:bg-red-600 text-white font-semibold border-0"
                      >
                        Disconnect Wallet
                      </Button>
                    </div>
                  </div>
                );
              })()}
            </div>
          );
        }}
      </ConnectButton.Custom>
    </div>
  );
}
