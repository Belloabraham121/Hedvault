// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/RWAToken.sol";

/**
 * @title DeployFourRWATokens
 * @notice Script to deploy four different RWA tokens for testing
 */
contract DeployFourRWATokens is Script {
    // Token configurations
    struct TokenConfig {
        string name;
        string symbol;
        uint256 totalSupply;
        address creator;
        address factory;
    }

    function run() external {
        // Use Anvil's first account private key
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying four RWA tokens...");
        console.log("Deployer:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy four different RWA tokens
        address goldToken = _deployToken(
            "HedVault Gold Token",
            "HVGOLD",
            10000 * 1e18, // 10,000 tokens
            deployer,
            deployer // Using deployer as factory for simplicity
        );

        address silverToken = _deployToken(
            "HedVault Silver Token",
            "HVSILVER",
            100000 * 1e18, // 100,000 tokens
            deployer,
            deployer
        );

        address realEstateToken = _deployToken(
            "HedVault Real Estate Token",
            "HVRE",
            50000 * 1e18, // 50,000 tokens
            deployer,
            deployer
        );

        address artToken = _deployToken(
            "HedVault Art Token",
            "HVART",
            5000 * 1e18, // 5,000 tokens
            deployer,
            deployer
        );

        vm.stopBroadcast();

        // Log deployment results
        console.log("\n=== Deployment Results ===");
        console.log("Gold Token (HVGOLD):", goldToken);
        // console.log("Silver Token (HVSILVER):", silverToken);
        // console.log("Real Estate Token (HVRE):", realEstateToken);
        // console.log("Art Token (HVART):", artToken);

        // Verify token details
        _verifyToken(goldToken, "HVGOLD", 10000 * 1e18);
        // _verifyToken(silverToken, "HVSILVER", 100000 * 1e18);
        // _verifyToken(realEstateToken, "HVRE", 50000 * 1e18);
        // _verifyToken(artToken, "HVART", 5000 * 1e18);

        console.log("\n[SUCCESS] All four RWA tokens deployed successfully!");
    }

    function _deployToken(
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        address creator,
        address factory
    ) internal returns (address) {
        console.log("\nDeploying:", name);
        console.log("Symbol:", symbol);
        console.log("Total Supply:", totalSupply);

        RWAToken token = new RWAToken(
            name,
            symbol,
            totalSupply,
            creator,
            factory
        );

        console.log("Deployed at:", address(token));
        return address(token);
    }

    function _verifyToken(
        address tokenAddress,
        string memory expectedSymbol,
        uint256 expectedSupply
    ) internal view {
        RWAToken token = RWAToken(payable(tokenAddress));

        console.log("\n--- Verifying", expectedSymbol, "---");
        console.log("Address:", tokenAddress);
        console.log("Name:", token.name());
        console.log("Symbol:", token.symbol());
        console.log("Total Supply:", token.totalSupply());
        console.log("Creator:", token.creator());
        console.log("Factory:", token.factory());
        console.log("Holder Count:", token.getHolderCount());

        // Basic assertions
        require(
            keccak256(abi.encodePacked(token.symbol())) ==
                keccak256(abi.encodePacked(expectedSymbol)),
            "Symbol mismatch"
        );
        require(token.totalSupply() == expectedSupply, "Total supply mismatch");
        require(
            token.getHolderCount() == 1,
            "Should have exactly one holder (creator)"
        );

        console.log("[VERIFIED] Verification passed");
    }

    // Helper function to get deployment info
    function getDeploymentInfo() external pure returns (string memory) {
        return
            "This script deploys four RWA tokens: Gold, Silver, Real Estate, and Art tokens";
    }
}
