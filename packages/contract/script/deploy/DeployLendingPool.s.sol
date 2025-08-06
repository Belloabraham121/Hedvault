// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../../src/LendingPool.sol";

/**
 * @title DeployLendingPool
 * @notice Individual deployment script for LendingPool contract
 */
contract DeployLendingPool is Script {
    function run() external {
        address hedVaultCore = vm.envAddress("HEDVAULT_CORE_ADDRESS");
        address priceOracle = vm.envAddress("PRICE_ORACLE_ADDRESS");
        address feeRecipient = vm.envOr("FEE_RECIPIENT", msg.sender);
        address rewardsDistributor = vm.envOr("REWARDS_DISTRIBUTOR_ADDRESS", address(0x9E1fe9F241142aB56804FCD69596812099873A2e));

        console.log("=== Deploying LendingPool ===");
        console.log("HedVaultCore Address:", hedVaultCore);
        console.log("PriceOracle Address:", priceOracle);
        console.log("Fee Recipient:", feeRecipient);
        console.log("Rewards Distributor:", rewardsDistributor);
        console.log("Deployer:", msg.sender);

        vm.startBroadcast();

        LendingPool lendingPool = new LendingPool(
            hedVaultCore,
            priceOracle,
            feeRecipient,
            rewardsDistributor
        );

        vm.stopBroadcast();

        console.log("LendingPool deployed at:", address(lendingPool));
        console.log("Constructor args (ABI encoded):");
        console.logBytes(abi.encode(hedVaultCore, priceOracle, feeRecipient, rewardsDistributor));
    }
}
