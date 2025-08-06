// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../../src/RWAToken.sol";

/**
 * @title DeployRWAToken
 * @notice Individual deployment script for RWAToken contract
 */
contract DeployRWAToken is Script {
    function run() external {
        string memory name = vm.envOr("RWA_TOKEN_NAME", string("RWA Token"));
        string memory symbol = vm.envOr("RWA_TOKEN_SYMBOL", string("RWA"));
        uint256 totalSupply = vm.envOr("RWA_TOKEN_TOTAL_SUPPLY", uint256(1000000 * 10**18));
        address creator = vm.envOr("RWA_TOKEN_CREATOR", address(msg.sender));
        address factory = vm.envAddress("RWA_TOKEN_FACTORY_ADDRESS");
        
        console.log("=== Deploying RWAToken ===");
        console.log("Token Name:", name);
        console.log("Token Symbol:", symbol);
        console.log("Total Supply:", totalSupply);
        console.log("Creator:", creator);
        console.log("Factory:", factory);
        console.log("Deployer:", msg.sender);
        
        vm.startBroadcast();
        
        RWAToken rwaToken = new RWAToken(name, symbol, totalSupply, creator, factory);
        
        vm.stopBroadcast();
        
        console.log("RWAToken deployed at:", address(rwaToken));
        console.log("Constructor args (ABI encoded):");
        console.logBytes(abi.encode(name, symbol, totalSupply, creator, factory));
    }
}