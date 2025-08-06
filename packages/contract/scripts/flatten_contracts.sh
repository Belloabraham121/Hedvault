#!/bin/bash

# Script to flatten all HedVault contracts for manual verification
# This creates flattened source files that can be easily copied into Hashscan

echo "Creating flattened directory..."
mkdir -p flattened

echo "Flattening HedVault contracts..."

# Core contracts
echo "Flattening HedVaultCore..."
forge flatten src/HedVaultCore.sol > flattened/HedVaultCore_flattened.sol

echo "Flattening PriceOracle..."
forge flatten src/PriceOracle.sol > flattened/PriceOracle_flattened.sol

echo "Flattening RewardsDistributor..."
forge flatten src/RewardsDistributor.sol > flattened/RewardsDistributor_flattened.sol

echo "Flattening LendingPool..."
forge flatten src/LendingPool.sol > flattened/LendingPool_flattened.sol

echo "Flattening Marketplace..."
forge flatten src/Marketplace.sol > flattened/Marketplace_flattened.sol

echo "Flattening RWATokenFactory..."
forge flatten src/RWATokenFactory.sol > flattened/RWATokenFactory_flattened.sol

echo "Flattening SwapEngine..."
forge flatten src/SwapEngine.sol > flattened/SwapEngine_flattened.sol

echo "Flattening ComplianceManager..."
forge flatten src/ComplianceManager.sol > flattened/ComplianceManager_flattened.sol

echo "Flattening PortfolioManager..."
forge flatten src/PortfolioManager.sol > flattened/PortfolioManager_flattened.sol

echo "Flattening CrossChainBridge..."
forge flatten src/CrossChainBridge.sol > flattened/CrossChainBridge_flattened.sol

echo "Flattening RWAOffchainOracle..."
forge flatten src/RWAOffchainOracle.sol > flattened/RWAOffchainOracle_flattened.sol

echo "Flattening MockERC20 (HedVault Token)..."
forge flatten src/MockERC20.sol > flattened/MockERC20_flattened.sol

echo "All contracts flattened successfully!"
echo "Flattened files are available in the 'flattened' directory."
echo ""
echo "Next steps:"
echo "1. Use these flattened files for manual verification on Hashscan"
echo "2. Follow the instructions in MANUAL_VERIFICATION_INSTRUCTIONS.md"
echo "3. Copy the content of each flattened file into Hashscan's verification form"