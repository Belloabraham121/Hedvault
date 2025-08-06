# HedVault Smart Contract Integration TODO List

## Contract Information
- **Network**: Hedera Testnet (Chain ID: 296)
- **Deployment Date**: Latest deployment files

### Contract Addresses:
- **ComplianceManager**: `0xcb33193f590227f71423007fe6d41f53da2ef0c8`
- **HedVaultCore**: `0x7718032d7727fc38851ba83b452f5e10208b596f`
- **LendingPool**: `0x98fddd1d8b61b12c0634d52bb3fdb193806e93a5`
- **Marketplace**: `0x8688dc04987ee42671bcffe57c41c22a1704d313`
- **PortfolioManager**: `0x6cdadcad00dc4bad41e5c50ed2b243dae5338fa8`
- **PriceOracle**: `0x6dcbea0fa11b21a6b9f72bccacefeb0b1ed0b444`
- **RewardsDistributor**: `0x9e1fe9f241142ab56804fcd69596812099873a2e`
- **RWAOffchainOracle**: `0x526f1fd7e5e6220c8390c14fcb0b5a1c83d36e8d`

## Integration Tasks

### Phase 1: Setup and Configuration
- [ ] 1. Add Hedera Testnet to Wagmi configuration
- [ ] 2. Create contract constants file with addresses and chain info
- [ ] 3. Extract and organize ABIs from compiled artifacts
- [ ] 4. Create ABI files for each contract

### Phase 2: Contract Integration
- [ ] 5. Create ComplianceManager integration
  - [ ] 5.1. Create ComplianceManager ABI file
  - [ ] 5.2. Create ComplianceManager custom hooks
  - [ ] 5.3. Implement read functions (getUserCompliance, isUserCompliant, etc.)
  - [ ] 5.4. Implement write functions (verifyUser, monitorTransaction, etc.)

- [ ] 6. Create HedVaultCore integration
  - [ ] 6.1. Create HedVaultCore ABI file
  - [ ] 6.2. Create HedVaultCore custom hooks
  - [ ] 6.3. Implement core functionality hooks

- [ ] 7. Create LendingPool integration
  - [ ] 7.1. Create LendingPool ABI file
  - [ ] 7.2. Create LendingPool custom hooks
  - [ ] 7.3. Implement lending/borrowing functionality

- [ ] 8. Create Marketplace integration
  - [ ] 8.1. Create Marketplace ABI file
  - [ ] 8.2. Create Marketplace custom hooks
  - [ ] 8.3. Implement trading functionality

- [ ] 9. Create PortfolioManager integration
  - [ ] 9.1. Create PortfolioManager ABI file
  - [ ] 9.2. Create PortfolioManager custom hooks
  - [ ] 9.3. Implement portfolio management functions

- [ ] 10. Create PriceOracle integration
  - [ ] 10.1. Create PriceOracle ABI file
  - [ ] 10.2. Create PriceOracle custom hooks
  - [ ] 10.3. Implement price fetching functionality

- [ ] 11. Create RewardsDistributor integration
  - [ ] 11.1. Create RewardsDistributor ABI file
  - [ ] 11.2. Create RewardsDistributor custom hooks
  - [ ] 11.3. Implement rewards functionality

- [ ] 12. Create RWAOffchainOracle integration
  - [ ] 12.1. Create RWAOffchainOracle ABI file
  - [ ] 12.2. Create RWAOffchainOracle custom hooks
  - [ ] 12.3. Implement RWA data fetching functionality

### Phase 3: Integration and Testing
- [ ] 13. Create main contracts export file
- [ ] 14. Update Wagmi configuration with all contracts
- [ ] 15. Create integration utilities and helpers
- [ ] 16. Test all contract integrations
- [ ] 17. Create documentation for contract usage

### Phase 4: Advanced Features
- [ ] 18. Implement contract event listeners
- [ ] 19. Create transaction monitoring utilities
- [ ] 20. Implement error handling and retry logic
- [ ] 21. Add contract interaction logging
- [ ] 22. Create contract state management utilities

## Notes
- All contracts are deployed on Hedera Testnet (Chain ID: 296)
- Using Wagmi v2.16.1 for contract interactions
- ABIs extracted from Forge compilation artifacts
- Custom hooks will follow Wagmi patterns and best practices