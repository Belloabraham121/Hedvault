// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../../src/PriceOracle.sol";

/**
 * @title DeployPriceOracle
 * @notice Individual deployment script for PriceOracle contract
 */
contract DeployPriceOracle is Script {
    function run() external {
        address hedVaultCore = vm.envAddress("HEDVAULT_CORE_ADDRESS");
        
        console.log("=== Deploying PriceOracle ===");
        console.log("HedVaultCore Address:", hedVaultCore);
        console.log("Deployer:", msg.sender);
        
        vm.startBroadcast();
        
        PriceOracle priceOracle = new PriceOracle(hedVaultCore);
        
        vm.stopBroadcast();
        
        console.log("PriceOracle deployed at:", address(priceOracle));
        console.log("Constructor args (ABI encoded):");
        console.logBytes(abi.encode(hedVaultCore));
    }
}