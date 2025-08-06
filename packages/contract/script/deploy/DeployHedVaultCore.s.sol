// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../../src/HedVaultCore.sol";

/**
 * @title DeployHedVaultCore
 * @notice Individual deployment script for HedVaultCore contract
 */
contract DeployHedVaultCore is Script {
    function run() external {
        address feeRecipient = vm.envOr("FEE_RECIPIENT", msg.sender);
        
        console.log("=== Deploying HedVaultCore ===");
        console.log("Fee Recipient:", feeRecipient);
        console.log("Deployer:", msg.sender);
        
        vm.startBroadcast();
        
        HedVaultCore hedVaultCore = new HedVaultCore(feeRecipient);
        
        vm.stopBroadcast();
        
        console.log("HedVaultCore deployed at:", address(hedVaultCore));
        console.log("Constructor args (ABI encoded):");
        console.logBytes(abi.encode(feeRecipient));
    }
}