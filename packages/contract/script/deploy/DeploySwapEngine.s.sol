// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../../src/SwapEngine.sol";

/**
 * @title DeploySwapEngine
 * @notice Individual deployment script for SwapEngine contract
 */
contract DeploySwapEngine is Script {
    function run() external {
        address hedVaultCore = vm.envAddress("HEDVAULT_CORE_ADDRESS");
        address priceOracle = vm.envAddress("PRICE_ORACLE_ADDRESS");
        address feeRecipient = vm.envOr("FEE_RECIPIENT", msg.sender);

        console.log("=== Deploying SwapEngine ===");
        console.log("HedVaultCore Address:", hedVaultCore);
        console.log("PriceOracle Address:", priceOracle);
        console.log("Fee Recipient:", feeRecipient);
        console.log("Deployer:", msg.sender);

        vm.startBroadcast();

        SwapEngine swapEngine = new SwapEngine(
            hedVaultCore,
            priceOracle,
            feeRecipient
        );

        vm.stopBroadcast();

        console.log("SwapEngine deployed at:", address(swapEngine));
        console.log("Constructor args (ABI encoded):");
        console.logBytes(abi.encode(hedVaultCore, priceOracle, feeRecipient));
    }
}
