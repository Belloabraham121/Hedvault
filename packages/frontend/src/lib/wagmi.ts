import {
  getDefaultWallets,
  connectorsForWallets,
} from "@rainbow-me/rainbowkit";
import { rabbyWallet } from "@rainbow-me/rainbowkit/wallets";
import { mainnet, polygon, optimism, arbitrum, base } from "viem/chains";
import { createConfig, http } from "wagmi";
import { defineChain } from "viem";

// Define Hedera Testnet
const hederaTestnet = defineChain({
  id: 296,
  name: "Hedera Testnet",
  nativeCurrency: {
    decimals: 18,
    name: "HBAR",
    symbol: "HBAR",
  },
  rpcUrls: {
    default: {
      http: ["https://testnet.hashio.io/api"],
    },
  },
  blockExplorers: {
    default: {
      name: "HashScan",
      url: "https://hashscan.io/testnet",
    },
  },
  testnet: true,
});

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
  chains: [hederaTestnet, mainnet, polygon, optimism, arbitrum, base],
  transports: {
    [hederaTestnet.id]: http(),
    [mainnet.id]: http(),
    [polygon.id]: http(),
    [optimism.id]: http(),
    [arbitrum.id]: http(),
    [base.id]: http(),
  },
  ssr: true,
});
