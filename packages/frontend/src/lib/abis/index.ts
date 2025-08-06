/**
 * HedVault Contract ABIs
 * Auto-generated from Forge compilation artifacts
 */

import { ComplianceManagerABI } from './ComplianceManager';
import { HedVaultCoreABI } from './HedVaultCore';
import { LendingPoolABI } from './LendingPool';
import { MarketplaceABI } from './Marketplace';
import { PortfolioManagerABI } from './PortfolioManager';
import { PriceOracleABI } from './PriceOracle';
import { RewardsDistributorABI } from './RewardsDistributor';
import { RWAOffchainOracleABI } from './RWAOffchainOracle';

// Export individual ABIs
export { ComplianceManagerABI, HedVaultCoreABI, LendingPoolABI, MarketplaceABI, PortfolioManagerABI, PriceOracleABI, RewardsDistributorABI, RWAOffchainOracleABI };

// Re-export all ABIs as a single object for convenience
export const HEDVAULT_ABIS = {
  ComplianceManager: ComplianceManagerABI,
  HedVaultCore: HedVaultCoreABI,
  LendingPool: LendingPoolABI,
  Marketplace: MarketplaceABI,
  PortfolioManager: PortfolioManagerABI,
  PriceOracle: PriceOracleABI,
  RewardsDistributor: RewardsDistributorABI,
  RWAOffchainOracle: RWAOffchainOracleABI,
} as const;