// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../../src/PortfolioManager.sol";

/**
 * @title DeployPortfolioManager
 * @notice Individual deployment script for PortfolioManager contract
 */
contract DeployPortfolioManager is Script {
    function run() external {
        address hedVaultCore = vm.envAddress("HEDVAULT_CORE_ADDRESS");
        address priceOracle = vm.envAddress("PRICE_ORACLE_ADDRESS");
        
        console.log("=== Deploying PortfolioManager ===");
        console.log("HedVaultCore Address:", hedVaultCore);
        console.log("PriceOracle Address:", priceOracle);
        console.log("Deployer:", msg.sender);
        
        vm.startBroadcast();
        
        PortfolioManager portfolioManager = new PortfolioManager(hedVaultCore, priceOracle);
        
        vm.stopBroadcast();
        
        console.log("PortfolioManager deployed at:", address(portfolioManager));
        console.log("Constructor args (ABI encoded):");
        console.logBytes(abi.encode(hedVaultCore, priceOracle));
    }
}