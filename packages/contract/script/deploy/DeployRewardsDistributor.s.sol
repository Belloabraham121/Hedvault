// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../../src/RewardsDistributor.sol";

/**
 * @title DeployRewardsDistributor
 * @notice Individual deployment script for RewardsDistributor contract
 */
contract DeployRewardsDistributor is Script {
    function run() external {
        address hedVaultCore = vm.envAddress("HEDVAULT_CORE_ADDRESS");
        address rewardToken = vm.envAddress("REWARD_TOKEN_ADDRESS");

        console.log("=== Deploying RewardsDistributor ===");
        console.log("HedVaultCore Address:", hedVaultCore);
        console.log("Reward Token Address:", rewardToken);
        console.log("Deployer:", msg.sender);

        vm.startBroadcast();

        RewardsDistributor rewardsDistributor = new RewardsDistributor(
            hedVaultCore,
            rewardToken
        );

        vm.stopBroadcast();

        console.log(
            "RewardsDistributor deployed at:",
            address(rewardsDistributor)
        );
        console.log("Constructor args (ABI encoded):");
        console.logBytes(abi.encode(hedVaultCore, rewardToken));
    }
}
