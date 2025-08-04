import {
  getDefaultConfig,
  getDefaultWallets,
  connectorsForWallets,
} from "@rainbow-me/rainbowkit";
import { rabbyWallet } from "@rainbow-me/rainbowkit/wallets";
import { mainnet, polygon, optimism, arbitrum, base } from "viem/chains";
import { createConfig, http } from "wagmi";

const { wallets } = getDefaultWallets();

const connectors = connectorsForWallets(
  [
    ...wallets,
    {
      groupName: "Other",
      wallets: [rabbyWallet],
    },
  ],
  {
    appName: "HedVault",
    projectId:
      process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID ||
      "2f5a2b1c8d3e4f5a6b7c8d9e0f1a2b3c", // Fallback for development
  }
);

export const config = createConfig({
  connectors,
  chains: [mainnet, polygon, optimism, arbitrum, base],
  transports: {
    [mainnet.id]: http(),
    [polygon.id]: http(),
    [optimism.id]: http(),
    [arbitrum.id]: http(),
    [base.id]: http(),
  },
  ssr: true,
});
