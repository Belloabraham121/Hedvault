// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../../src/RWAOffchainOracle.sol";

/**
 * @title DeployRWAOffchainOracle
 * @notice Individual deployment script for RWAOffchainOracle contract
 */
contract DeployRWAOffchainOracle is Script {
    function run() external {
        address hedVaultCore = vm.envAddress("HEDVAULT_CORE_ADDRESS");
        address chainlinkFunctions = vm.envOr("CHAINLINK_FUNCTIONS_ADDRESS", address(0));
        uint64 subscriptionId = uint64(vm.envOr("CHAINLINK_SUBSCRIPTION_ID", uint256(0)));
        
        console.log("=== Deploying RWAOffchainOracle ===");
        console.log("HedVaultCore Address:", hedVaultCore);
        console.log("Chainlink Functions Address:", chainlinkFunctions);
        console.log("Subscription ID:", subscriptionId);
        console.log("Deployer:", msg.sender);
        
        vm.startBroadcast();
        
        RWAOffchainOracle rwaOffchainOracle = new RWAOffchainOracle(hedVaultCore, chainlinkFunctions, subscriptionId);
        
        vm.stopBroadcast();
        
        console.log("RWAOffchainOracle deployed at:", address(rwaOffchainOracle));
        console.log("Constructor args (ABI encoded):");
        console.logBytes(abi.encode(hedVaultCore, chainlinkFunctions, subscriptionId));
    }
}