// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../../src/ComplianceManager.sol";

/**
 * @title DeployComplianceManager
 * @notice Individual deployment script for ComplianceManager contract
 */
contract DeployComplianceManager is Script {
    function run() external {
        address hedVaultCore = vm.envAddress("HEDVAULT_CORE_ADDRESS");
        address admin = vm.envOr("COMPLIANCE_ADMIN", msg.sender);

        console.log("=== Deploying ComplianceManager ===");
        console.log("HedVaultCore Address:", hedVaultCore);
        console.log("Admin Address:", admin);
        console.log("Deployer:", msg.sender);

        vm.startBroadcast();

        ComplianceManager complianceManager = new ComplianceManager(
            hedVaultCore,
            admin
        );

        vm.stopBroadcast();

        console.log(
            "ComplianceManager deployed at:",
            address(complianceManager)
        );
        console.log("Constructor args (ABI encoded):");
        console.logBytes(abi.encode(hedVaultCore, admin));
    }
}
