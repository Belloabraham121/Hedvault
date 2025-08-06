// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../../src/RWATokenFactory.sol";

/**
 * @title DeployRWATokenFactory
 * @notice Individual deployment script for RWATokenFactory contract
 */
contract DeployRWATokenFactory is Script {
    function run() external {
        address hedVaultCore = vm.envAddress("HEDVAULT_CORE_ADDRESS");

        console.log("=== Deploying RWATokenFactory ===");
        console.log("HedVaultCore Address:", hedVaultCore);
        console.log("Deployer:", msg.sender);

        vm.startBroadcast();

        RWATokenFactory rwaTokenFactory = new RWATokenFactory(hedVaultCore);

        vm.stopBroadcast();

        console.log("RWATokenFactory deployed at:", address(rwaTokenFactory));
        console.log("Constructor args (ABI encoded):");
        console.logBytes(abi.encode(hedVaultCore));
    }
}
