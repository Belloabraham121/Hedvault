/**
 * HedVault Smart Contract Configuration
 * Contains contract addresses, ABIs, and chain information
 */

import { Address } from "viem";

// Chain Configuration
export const HEDERA_TESTNET_CHAIN_ID = 296;

// Contract Addresses on Hedera Testnet
export const CONTRACT_ADDRESSES = {
  ComplianceManager: "0xcb33193f590227f71423007fe6d41f53da2ef0c8" as Address,
  HedVaultCore: "0x7718032d7727fc38851ba83b452f5e10208b596f" as Address,
  LendingPool: "0x98fddd1d8b61b12c0634d52bb3fdb193806e93a5" as Address,
  Marketplace: "0x8688dc04987ee42671bcffe57c41c22a1704d313" as Address,
  PortfolioManager: "0x6cdadcad00dc4bad41e5c50ed2b243dae5338fa8" as Address,
  PriceOracle: "0x6dcbea0fa11b21a6b9f72bccacefeb0b1ed0b444" as Address,
  RewardsDistributor: "0x9e1fe9f241142ab56804fcd69596812099873a2e" as Address,
  RWAOffchainOracle: "0x526f1fd7e5e6220c8390c14fcb0b5a1c83d36e8d" as Address,
  RWATokenFactory: "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9" as Address,
  SwapEngine: "0x4536b242ea3d3b5c412f5db159353b7ca6ed003e" as Address,
} as const;

// Contract Names for easy reference
export const CONTRACT_NAMES = {
  COMPLIANCE_MANAGER: "ComplianceManager",
  HED_VAULT_CORE: "HedVaultCore",
  LENDING_POOL: "LendingPool",
  MARKETPLACE: "Marketplace",
  PORTFOLIO_MANAGER: "PortfolioManager",
  PRICE_ORACLE: "PriceOracle",
  REWARDS_DISTRIBUTOR: "RewardsDistributor",
  RWA_OFFCHAIN_ORACLE: "RWAOffchainOracle",
  SWAP_ENGINE: "SwapEngine",
} as const;

// Contract Configuration Type
export interface ContractConfig {
  address: Address;
  abi: readonly unknown[];
  chainId: number;
}

// Export individual contract configurations
export const getContractConfig = (
  contractName: keyof typeof CONTRACT_ADDRESSES
): Omit<ContractConfig, "abi"> => ({
  address: CONTRACT_ADDRESSES[contractName],
  chainId: HEDERA_TESTNET_CHAIN_ID,
});

// Utility function to check if address is valid
export const isValidContractAddress = (address: string): address is Address => {
  return /^0x[a-fA-F0-9]{40}$/.test(address);
};

// Contract deployment block numbers (for event filtering)
export const CONTRACT_DEPLOYMENT_BLOCKS = {
  ComplianceManager: 0, // Update with actual deployment block
  HedVaultCore: 0,
  LendingPool: 0,
  Marketplace: 0,
  PortfolioManager: 0,
  PriceOracle: 0,
  RewardsDistributor: 0,
  RWAOffchainOracle: 0,
  SwapEngine: 0,
} as const;
