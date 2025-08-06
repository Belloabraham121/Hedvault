// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";

/**
 * @title VerifyHederaDeployment
 * @notice Script to generate verification commands for HedVault contracts on Hedera Hashscan
 * @dev Run this script to get the forge verify-contract commands for all deployed contracts
 */
contract VerifyHederaDeployment is Script {
    
    function run() external {
        console.log("=== HedVault Hedera Contract Verification Commands ===");
        console.log("");
        console.log("Set your contract addresses as environment variables, then use these commands:");
        console.log("");
        
        generateVerificationCommands();
        
        console.log("=== Environment Variables Setup ===");
        console.log("export HED_VAULT_CORE_ADDRESS=<your_contract_address>");
        console.log("export PRICE_ORACLE_ADDRESS=<your_contract_address>");
        console.log("export REWARDS_DISTRIBUTOR_ADDRESS=<your_contract_address>");
        console.log("export LENDING_POOL_ADDRESS=<your_contract_address>");
        console.log("export MARKETPLACE_ADDRESS=<your_contract_address>");
        console.log("export RWA_TOKEN_FACTORY_ADDRESS=<your_contract_address>");
        console.log("export SWAP_ENGINE_ADDRESS=<your_contract_address>");
        console.log("export COMPLIANCE_MANAGER_ADDRESS=<your_contract_address>");
        console.log("export PORTFOLIO_MANAGER_ADDRESS=<your_contract_address>");
        console.log("export CROSS_CHAIN_BRIDGE_ADDRESS=<your_contract_address>");
        console.log("export RWA_OFFCHAIN_ORACLE_ADDRESS=<your_contract_address>");
        console.log("export REWARD_TOKEN_ADDRESS=<your_contract_address>");
        console.log("export FEE_RECIPIENT=<your_fee_recipient_address>");
    }
    
    function generateVerificationCommands() internal pure {
        
        console.log("1. Verify HedVaultCore:");
        console.log("forge verify-contract $HED_VAULT_CORE_ADDRESS src/HedVaultCore.sol:HedVaultCore \\");
        console.log("    --chain-id 296 \\");
        console.log("    --verifier sourcify \\");
        console.log("    --verifier-url \"https://server-verify.hashscan.io/\" \\");
        console.log("    --constructor-args $(cast abi-encode \"constructor(address)\" $FEE_RECIPIENT)");
        console.log("");
        
        console.log("2. Verify PriceOracle:");
        console.log("forge verify-contract $PRICE_ORACLE_ADDRESS src/PriceOracle.sol:PriceOracle \\");
        console.log("    --chain-id 296 \\");
        console.log("    --verifier sourcify \\");
        console.log("    --verifier-url \"https://server-verify.hashscan.io/\" \\");
        console.log("    --constructor-args $(cast abi-encode \"constructor(address)\" $HED_VAULT_CORE_ADDRESS)");
        console.log("");
        
        console.log("3. Verify RewardsDistributor:");
        console.log("forge verify-contract $REWARDS_DISTRIBUTOR_ADDRESS src/RewardsDistributor.sol:RewardsDistributor \\");
        console.log("    --chain-id 296 \\");
        console.log("    --verifier sourcify \\");
        console.log("    --verifier-url \"https://server-verify.hashscan.io/\" \\");
        console.log("    --constructor-args $(cast abi-encode \"constructor(address,address)\" $HED_VAULT_CORE_ADDRESS $REWARD_TOKEN_ADDRESS)");
        console.log("");
        
        console.log("4. Verify LendingPool:");
        console.log("forge verify-contract $LENDING_POOL_ADDRESS src/LendingPool.sol:LendingPool \\");
        console.log("    --chain-id 296 \\");
        console.log("    --verifier sourcify \\");
        console.log("    --verifier-url \"https://server-verify.hashscan.io/\" \\");
        console.log("    --constructor-args $(cast abi-encode \"constructor(address,address,address)\" $HED_VAULT_CORE_ADDRESS $PRICE_ORACLE_ADDRESS $FEE_RECIPIENT)");
        console.log("");
        
        console.log("5. Verify Marketplace:");
        console.log("forge verify-contract $MARKETPLACE_ADDRESS src/Marketplace.sol:Marketplace \\");
        console.log("    --chain-id 296 \\");
        console.log("    --verifier sourcify \\");
        console.log("    --verifier-url \"https://server-verify.hashscan.io/\" \\");
        console.log("    --constructor-args $(cast abi-encode \"constructor(address,address,address)\" $HED_VAULT_CORE_ADDRESS $PRICE_ORACLE_ADDRESS $FEE_RECIPIENT)");
        console.log("");
        
        console.log("6. Verify RWATokenFactory:");
        console.log("forge verify-contract $RWA_TOKEN_FACTORY_ADDRESS src/RWATokenFactory.sol:RWATokenFactory \\");
        console.log("    --chain-id 296 \\");
        console.log("    --verifier sourcify \\");
        console.log("    --verifier-url \"https://server-verify.hashscan.io/\" \\");
        console.log("    --constructor-args $(cast abi-encode \"constructor(address)\" $HED_VAULT_CORE_ADDRESS)");
        console.log("");
        
        console.log("7. Verify SwapEngine:");
        console.log("forge verify-contract $SWAP_ENGINE_ADDRESS src/SwapEngine.sol:SwapEngine \\");
        console.log("    --chain-id 296 \\");
        console.log("    --verifier sourcify \\");
        console.log("    --verifier-url \"https://server-verify.hashscan.io/\" \\");
        console.log("    --constructor-args $(cast abi-encode \"constructor(address,address,address)\" $HED_VAULT_CORE_ADDRESS $PRICE_ORACLE_ADDRESS $FEE_RECIPIENT)");
        console.log("");
        
        console.log("8. Verify ComplianceManager:");
        console.log("forge verify-contract $COMPLIANCE_MANAGER_ADDRESS src/ComplianceManager.sol:ComplianceManager \\");
        console.log("    --chain-id 296 \\");
        console.log("    --verifier sourcify \\");
        console.log("    --verifier-url \"https://server-verify.hashscan.io/\" \\");
        console.log("    --constructor-args $(cast abi-encode \"constructor(address,address)\" $HED_VAULT_CORE_ADDRESS $FEE_RECIPIENT)");
        console.log("");
        
        console.log("9. Verify PortfolioManager:");
        console.log("forge verify-contract $PORTFOLIO_MANAGER_ADDRESS src/PortfolioManager.sol:PortfolioManager \\");
        console.log("    --chain-id 296 \\");
        console.log("    --verifier sourcify \\");
        console.log("    --verifier-url \"https://server-verify.hashscan.io/\" \\");
        console.log("    --constructor-args $(cast abi-encode \"constructor(address,address)\" $HED_VAULT_CORE_ADDRESS $PRICE_ORACLE_ADDRESS)");
        console.log("");
        
        console.log("10. Verify CrossChainBridge:");
        console.log("forge verify-contract $CROSS_CHAIN_BRIDGE_ADDRESS src/CrossChainBridge.sol:CrossChainBridge \\");
        console.log("    --chain-id 296 \\");
        console.log("    --verifier sourcify \\");
        console.log("    --verifier-url \"https://server-verify.hashscan.io/\" \\");
        console.log("    --constructor-args $(cast abi-encode \"constructor(address)\" $FEE_RECIPIENT)");
        console.log("");
        
        console.log("11. Verify RWAOffchainOracle:");
        console.log("forge verify-contract $RWA_OFFCHAIN_ORACLE_ADDRESS src/RWAOffchainOracle.sol:RWAOffchainOracle \\");
        console.log("    --chain-id 296 \\");
        console.log("    --verifier sourcify \\");
        console.log("    --verifier-url \"https://server-verify.hashscan.io/\" \\");
        console.log("    --constructor-args $(cast abi-encode \"constructor(address,address,uint64)\" $HED_VAULT_CORE_ADDRESS 0x0000000000000000000000000000000000000000 0)");
        console.log("");
        
        console.log("12. Verify HedVault Token (HVT):");
        console.log("forge verify-contract $REWARD_TOKEN_ADDRESS src/MockERC20.sol:MockERC20 \\");
        console.log("    --chain-id 296 \\");
        console.log("    --verifier sourcify \\");
        console.log("    --verifier-url \"https://server-verify.hashscan.io/\" \\");
        console.log("    --constructor-args $(cast abi-encode \"constructor(string,string,uint8,uint256)\" \"HedVault Token\" \"HVT\" 18 1000000000000000000000000000)");
        console.log("");
        
        console.log("=== Additional Notes ===");
        console.log("1. Replace environment variables with actual contract addresses");
        console.log("2. Ensure source code matches deployed bytecode exactly");
        console.log("3. Constructor arguments must match deployment parameters");
        console.log("4. Verification may take several minutes");
        console.log("5. Check Hashscan for verification status");
        console.log("6. Use 'cast abi-encode' to properly encode constructor arguments");
    }
}