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
        console.log("=== HedVault Contract Verification Commands ===");
        console.log("Set these environment variables first:");
        console.log("");
        
        // Environment variables setup
        console.log("export HED_VAULT_CORE_ADDRESS=0xb0E777c67812A1Bf45d5C2682a2BFB939E194c42");
        console.log("export PRICE_ORACLE_ADDRESS=0x0687C132f0391bcF22F35d44C20E56Fb8A2afBb9");
        console.log("export REWARDS_DISTRIBUTOR_ADDRESS=0xf468b3c575959c17a30B5d261DB51354258b596c");
        console.log("export LENDING_POOL_ADDRESS=0xAAef7859A761386353494dFbD3DF483c2614c5Eb");
        console.log("export MARKETPLACE_ADDRESS=0x07B918dDAC0ee67f12b15a40707eC24d91Eb846d");
        console.log("export RWA_TOKEN_FACTORY_ADDRESS=0x8F6728382a4F08Ac52170854c61001192ba9336c");
        console.log("export SWAP_ENGINE_ADDRESS=0xef0ddD990168b0a7f20A6adAb24f58a4f2957bbE");
        console.log("export COMPLIANCE_MANAGER_ADDRESS=0x7DE6c38D006AFB3883b23779ebdD7387b93E896A");
        console.log("export PORTFOLIO_MANAGER_ADDRESS=0xbE5514f11a4043ba1E19c667cBE3cC671F9079C2");
        console.log("export CROSS_CHAIN_BRIDGE_ADDRESS=0xF4ef41D07Dbcb91bc9679647E6ee18ABC23221CB");
        console.log("export RWA_OFFCHAIN_ORACLE_ADDRESS=0xE7cc1920851e08004593E2AAdD80acff0B499fea");
        console.log("export REWARD_TOKEN_ADDRESS=0x66B7664dB02eF7c5620E0f64f3B904EDf3721784");
        console.log("export FEE_RECIPIENT=0xeeD71459493CDda2d97fBefbd459701e356593f3");
        console.log("");
        console.log("Then run these verification commands:");
        console.log("");
        
        generateVerificationCommands();
        
        console.log("=== Additional Notes ===");
        console.log("1. Replace environment variables with actual contract addresses if different");
        console.log("2. Ensure source code matches deployed bytecode exactly");
        console.log("3. Constructor arguments must match deployment parameters");
        console.log("4. Verification may take several minutes");
        console.log("5. Check Hashscan for verification status");
        console.log("6. Use 'cast abi-encode' to properly encode constructor arguments");
    }
    
    function generateVerificationCommands() internal {
        // 1. HedVaultCore
        console.log("1. Verify HedVaultCore:");
        console.log("forge verify-contract $HED_VAULT_CORE_ADDRESS src/HedVaultCore.sol:HedVaultCore \\");
        console.log("    --chain-id 296 \\");
        console.log("    --verifier sourcify \\");
        console.log("    --constructor-args $(cast abi-encode \"constructor(address)\" $FEE_RECIPIENT)");
        console.log("");
        
        console.log("2. Verify PriceOracle:");
        console.log("forge verify-contract $PRICE_ORACLE_ADDRESS src/PriceOracle.sol:PriceOracle \\");
        console.log("    --chain-id 296 \\");
        console.log("    --verifier sourcify \\");
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