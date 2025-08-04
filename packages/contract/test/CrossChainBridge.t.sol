// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/CrossChainBridge.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../src/libraries/HedVaultErrors.sol";

// Mock ERC20 token for testing
contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 * 10**18);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract CrossChainBridgeTest is Test {
    CrossChainBridge public bridge;
    MockERC20 public token;
    
    address public admin = address(0x1);
    address public user = address(0x2);
    address public validator = address(0x3);
    address public operator = address(0x4);
    
    uint256 public constant DESTINATION_CHAIN = 137; // Polygon
    uint256 public constant BRIDGE_FEE = 100; // 1%
    
    event BridgeInitiated(
        bytes32 indexed txHash,
        address indexed user,
        address indexed asset,
        uint256 amount,
        uint256 sourceChain,
        uint256 destinationChain
    );
    
    event BridgeCompleted(
        bytes32 indexed txHash,
        address indexed user,
        address indexed asset,
        uint256 amount
    );
    
    function setUp() public {
        // Deploy contracts
        bridge = new CrossChainBridge(admin);
        token = new MockERC20("Test Token", "TEST");
        
        // Setup roles
        vm.startPrank(admin);
        bridge.grantRole(bridge.VALIDATOR_ROLE(), validator);
        bridge.grantRole(bridge.BRIDGE_OPERATOR_ROLE(), operator);
        vm.stopPrank();
        
        // Configure bridge for destination chain
        vm.prank(admin);
        bridge.configureBridge(
            DESTINATION_CHAIN,
            CrossChainBridge.BridgeConfig({
                isActive: true,
                minTransferAmount: 1 ether,
                maxTransferAmount: 1000 ether,
                dailyLimit: 10000 ether,
                dailyTransferred: 0,
                lastResetTime: block.timestamp,
                confirmationsRequired: 2
            })
        );
        
        // Configure asset
        vm.prank(admin);
        bridge.configureAsset(
            address(token),
            CrossChainBridge.AssetConfig({
                isSupported: true,
                bridgeFee: BRIDGE_FEE,
                minAmount: 1 ether,
                maxAmount: 1000 ether,
                wrappedToken: address(0)
            })
        );
        
        // Mint tokens to user
        token.mint(user, 1000 ether);
    }
    
    function testInitiateBridge() public {
        uint256 amount = 10 ether;
        
        vm.startPrank(user);
        token.approve(address(bridge), amount);
        
        // Don't check the exact event since txHash is calculated dynamically
        bytes32 txHash = bridge.initiateBridge(
            address(token),
            amount,
            DESTINATION_CHAIN,
            user
        );
        
        vm.stopPrank();
        
        // Verify transaction was created
        CrossChainBridge.BridgeTransaction memory transaction = bridge.getBridgeTransaction(txHash);
        assertEq(transaction.user, user);
        assertEq(transaction.asset, address(token));
        assertEq(transaction.amount, amount - (amount * BRIDGE_FEE / 10000));
        assertEq(transaction.sourceChain, block.chainid);
        assertEq(transaction.destinationChain, DESTINATION_CHAIN);
        assertFalse(transaction.isCompleted);
        assertFalse(transaction.isCancelled);
        
        // Verify tokens were transferred
        assertEq(token.balanceOf(user), 1000 ether - amount);
        assertEq(token.balanceOf(address(bridge)), amount);
    }
    
    function testInitiateBridgeWithZeroAmount() public {
        vm.startPrank(user);
        
        vm.expectRevert(HedVaultErrors.ZeroAmount.selector);
        bridge.initiateBridge(
            address(token),
            0,
            DESTINATION_CHAIN,
            user
        );
        
        vm.stopPrank();
    }
    
    function testInitiateBridgeWithZeroAddress() public {
        vm.startPrank(user);
        
        vm.expectRevert(HedVaultErrors.ZeroAddress.selector);
        bridge.initiateBridge(
            address(0),
            10 ether,
            DESTINATION_CHAIN,
            user
        );
        
        vm.stopPrank();
    }
    
    function testInitiateBridgeWithSameChain() public {
        vm.startPrank(user);
        
        vm.expectRevert(abi.encodeWithSelector(HedVaultErrors.InvalidParameter.selector, "destinationChain"));
        bridge.initiateBridge(
            address(token),
            10 ether,
            block.chainid, // Same as current chain
            user
        );
        
        vm.stopPrank();
    }
    
    function testInitiateBridgeWithUnsupportedAsset() public {
        MockERC20 unsupportedToken = new MockERC20("Unsupported", "UNSUP");
        
        vm.startPrank(user);
        
        vm.expectRevert(abi.encodeWithSelector(HedVaultErrors.AssetNotSupported.selector, address(unsupportedToken)));
        bridge.initiateBridge(
            address(unsupportedToken),
            10 ether,
            DESTINATION_CHAIN,
            user
        );
        
        vm.stopPrank();
    }
    
    function testValidatorConfirmation() public {
        uint256 amount = 10 ether;
        
        // Initiate bridge
        vm.startPrank(user);
        token.approve(address(bridge), amount);
        bytes32 txHash = bridge.initiateBridge(
            address(token),
            amount,
            DESTINATION_CHAIN,
            user
        );
        vm.stopPrank();
        
        // Validator confirms
        vm.prank(validator);
        bridge.confirmTransaction(txHash, true);
        
        // Check confirmation
        CrossChainBridge.BridgeTransaction memory transaction = bridge.getBridgeTransaction(txHash);
        assertEq(transaction.confirmations, 1);
    }
    
    function testCompleteBridge() public {
        uint256 amount = 10 ether;
        uint256 transferAmount = amount - (amount * BRIDGE_FEE / 10000);
        
        // Initiate bridge first
        vm.startPrank(user);
        token.approve(address(bridge), amount);
        bytes32 txHash = bridge.initiateBridge(
            address(token),
            amount,
            DESTINATION_CHAIN,
            user
        );
        vm.stopPrank();
        
        // Get two validator confirmations
        vm.prank(validator);
        bridge.confirmTransaction(txHash, true);
        
        // Use existing admin to grant role to another validator
        address validator2 = address(0x5);
        vm.startPrank(admin);
        bridge.grantRole(bridge.VALIDATOR_ROLE(), validator2);
        vm.stopPrank();
        
        vm.prank(validator2);
        bridge.confirmTransaction(txHash, true);
        
        // Verify we have enough confirmations but can't complete on source chain
        CrossChainBridge.BridgeTransaction memory transaction = bridge.getBridgeTransaction(txHash);
        assertEq(transaction.confirmations, 2);
        assertFalse(transaction.isCompleted);
        
        // Note: Actual completion would happen on destination chain with different setup
        // This test verifies the confirmation mechanism works correctly
    }
    
    function testCancelBridge() public {
        uint256 amount = 10 ether;
        
        // Initiate bridge
        vm.startPrank(user);
        token.approve(address(bridge), amount);
        bytes32 txHash = bridge.initiateBridge(
            address(token),
            amount,
            DESTINATION_CHAIN,
            user
        );
        vm.stopPrank();
        
        uint256 userBalanceBefore = token.balanceOf(user);
        
        // Cancel bridge
        vm.prank(operator);
        bridge.cancelBridge(txHash, "Test cancellation");
        
        // Verify cancellation
        CrossChainBridge.BridgeTransaction memory transaction = bridge.getBridgeTransaction(txHash);
        assertTrue(transaction.isCancelled);
        
        // Verify refund (tokens should be returned)
        assertEq(token.balanceOf(user), userBalanceBefore + (amount - (amount * BRIDGE_FEE / 10000)));
    }
    
    function testSendMessage() public {
        bytes memory data = abi.encode("test message");
        
        vm.prank(user);
        bytes32 messageId = bridge.sendMessage(DESTINATION_CHAIN, data);
        
        CrossChainBridge.CrossChainMessage memory message = bridge.getCrossChainMessage(messageId);
        assertEq(message.sender, user);
        assertEq(message.sourceChain, block.chainid);
        assertEq(message.destinationChain, DESTINATION_CHAIN);
        assertEq(message.data, data);
        assertFalse(message.isExecuted);
    }
    
    function testCalculateBridgeFee() public {
        uint256 amount = 100 ether;
        uint256 expectedFee = (amount * BRIDGE_FEE) / 10000;
        
        uint256 actualFee = bridge.calculateBridgeFee(address(token), amount);
        assertEq(actualFee, expectedFee);
    }
    
    function testIsChainSupported() public {
        assertTrue(bridge.isChainSupported(DESTINATION_CHAIN));
        assertFalse(bridge.isChainSupported(999)); // Unsupported chain
    }
    
    function testIsAssetSupported() public {
        assertTrue(bridge.isAssetSupported(address(token)));
        assertFalse(bridge.isAssetSupported(address(0x999))); // Unsupported asset
    }
    
    function testGetUserDailyLimitRemaining() public {
        uint256 remaining = bridge.getUserDailyLimitRemaining(DESTINATION_CHAIN, user);
        assertEq(remaining, 10000 ether); // Full daily limit
    }
    
    function testPauseUnpause() public {
        // Pause contract
        vm.prank(admin);
        bridge.pause();
        
        // Try to initiate bridge while paused
        vm.startPrank(user);
        token.approve(address(bridge), 10 ether);
        
        vm.expectRevert(abi.encodeWithSignature("EnforcedPause()"));
        bridge.initiateBridge(
            address(token),
            10 ether,
            DESTINATION_CHAIN,
            user
        );
        
        vm.stopPrank();
        
        // Unpause and try again
        vm.prank(admin);
        bridge.unpause();
        
        vm.startPrank(user);
        bytes32 txHash = bridge.initiateBridge(
            address(token),
            10 ether,
            DESTINATION_CHAIN,
            user
        );
        vm.stopPrank();
        
        // Should succeed
        CrossChainBridge.BridgeTransaction memory transaction = bridge.getBridgeTransaction(txHash);
        assertEq(transaction.user, user);
    }
}