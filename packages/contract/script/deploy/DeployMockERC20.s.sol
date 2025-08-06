// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// MockERC20 contract definition
contract MockERC20 is ERC20 {
    uint8 private _decimals;
    
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals_,
        uint256 totalSupply
    ) ERC20(name, symbol) {
        _decimals = decimals_;
        _mint(msg.sender, totalSupply);
    }
    
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
    
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

/**
 * @title DeployMockERC20
 * @notice Individual deployment script for MockERC20 token
 */
contract DeployMockERC20 is Script {
    function run() external {
        string memory name = vm.envOr("TOKEN_NAME", string("HedVault Token"));
        string memory symbol = vm.envOr("TOKEN_SYMBOL", string("HVT"));
        uint8 decimals = uint8(vm.envOr("TOKEN_DECIMALS", uint256(18)));
        uint256 totalSupply = vm.envOr("REWARD_TOKEN_SUPPLY", uint256(1_000_000_000 ether));
        
        console.log("=== Deploying MockERC20 ===");
        console.log("Name:", name);
        console.log("Symbol:", symbol);
        console.log("Decimals:", decimals);
        console.log("Total Supply:", totalSupply);
        console.log("Deployer:", msg.sender);
        
        vm.startBroadcast();
        
        MockERC20 token = new MockERC20(name, symbol, decimals, totalSupply);
        
        vm.stopBroadcast();
        
        console.log("MockERC20 deployed at:", address(token));
        console.log("Constructor args (ABI encoded):");
        console.logBytes(abi.encode(name, symbol, decimals, totalSupply));
    }
}