// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;

// import "forge-std/Test.sol";
// import "../src/PortfolioManager.sol";
// import "../src/PriceOracle.sol";
// import "../src/libraries/HedVaultErrors.sol";
// import "../src/libraries/DataTypes.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// // Mock contracts for testing
// contract MockERC20 is ERC20 {
//     constructor(string memory name, string memory symbol) ERC20(name, symbol) {
//         _mint(msg.sender, 1000000 * 10**18);
//     }

//     function mint(address to, uint256 amount) external {
//         _mint(to, amount);
//     }
// }

// contract MockHedVaultCore {
//     function isTokenListed(address) external pure returns (bool) {
//         return true;
//     }
// }

// contract MockPriceOracle {
//     mapping(address => uint256) public prices;
    
//     function setPrice(address asset, uint256 price) external {
//         prices[asset] = price;
//     }
    
//     function getPrice(address asset) external view returns (uint256 price, uint256 timestamp, bool isValid) {
//         price = prices[asset] > 0 ? prices[asset] : 1000 * 10**18; // Default $1000
//         timestamp = block.timestamp;
//         isValid = true;
//     }
    
//     function getPriceUnsafe(address asset) external view returns (uint256 price, uint256 timestamp, uint256 confidence) {
//         price = prices[asset] > 0 ? prices[asset] : 1000 * 10**18; // Default $1000
//         timestamp = block.timestamp;
//         confidence = 10000; // 100% confidence
//     }
// }

// contract PortfolioManagerTest is Test {
//     PortfolioManager public portfolioManager;
//     MockHedVaultCore public hedVaultCore;
//     MockPriceOracle public priceOracle;
//     MockERC20 public tokenA;
//     MockERC20 public tokenB;
//     MockERC20 public tokenC;
    
//     address public admin = address(0x1);
//     address public user1 = address(0x2);
//     address public user2 = address(0x3);
//     address public rebalancer = address(0x4);
    
//     event PortfolioCreated(
//         uint256 indexed portfolioId,
//         address indexed owner,
//         string name,
//         uint8 riskLevel
//     );
    
//     event AssetAdded(
//         uint256 indexed portfolioId,
//         address indexed asset,
//         uint256 amount,
//         uint256 targetAllocation
//     );
    
//     event AssetRemoved(
//         uint256 indexed portfolioId,
//         address indexed asset,
//         uint256 amount
//     );
    
//     function setUp() public {
//         // Deploy mock contracts
//         hedVaultCore = new MockHedVaultCore();
//         priceOracle = new MockPriceOracle();
        
//         // Deploy PortfolioManager
//         vm.prank(admin);
//         portfolioManager = new PortfolioManager(
//             address(hedVaultCore),
//             address(priceOracle)
//         );
        
//         // Deploy test tokens
//         tokenA = new MockERC20("Token A", "TKNA");
//         tokenB = new MockERC20("Token B", "TKNB");
//         tokenC = new MockERC20("Token C", "TKNC");
        
//         // Set up prices
//         priceOracle.setPrice(address(tokenA), 1000 * 10**18); // $1000
//         priceOracle.setPrice(address(tokenB), 2000 * 10**18); // $2000
//         priceOracle.setPrice(address(tokenC), 500 * 10**18);  // $500
        
//         // Add supported assets
//         vm.startPrank(admin);
//         portfolioManager.addSupportedAsset(address(tokenA));
//         portfolioManager.addSupportedAsset(address(tokenB));
//         portfolioManager.addSupportedAsset(address(tokenC));
//         portfolioManager.grantRole(portfolioManager.REBALANCER_ROLE(), rebalancer);
//         vm.stopPrank();
        
//         // Mint tokens to users
//         tokenA.mint(user1, 1000 * 10**18);
//         tokenB.mint(user1, 1000 * 10**18);
//         tokenC.mint(user1, 1000 * 10**18);
        
//         tokenA.mint(user2, 1000 * 10**18);
//         tokenB.mint(user2, 1000 * 10**18);
//         tokenC.mint(user2, 1000 * 10**18);
//     }
    
//     function testCreatePortfolio() public {
//         vm.startPrank(user1);
        
//         vm.expectEmit(true, true, false, true);
//         emit PortfolioCreated(1, user1, "Test Portfolio", 5);
        
//         uint256 portfolioId = portfolioManager.createPortfolio(
//             "Test Portfolio",
//             5, // Risk level
//             500 // 5% rebalance threshold
//         );
        
//         vm.stopPrank();
        
//         // Verify portfolio creation
//         PortfolioManager.Portfolio memory portfolio = portfolioManager.getPortfolio(portfolioId);
//         assertEq(portfolio.owner, user1);
//         assertEq(portfolio.name, "Test Portfolio");
//         assertEq(portfolio.riskLevel, 5);
//         assertEq(portfolio.targetRebalanceThreshold, 500);
//         assertTrue(portfolio.isActive);
        
//         // Check user portfolios
//         uint256[] memory userPortfolios = portfolioManager.getUserPortfolios(user1);
//         assertEq(userPortfolios.length, 1);
//         assertEq(userPortfolios[0], portfolioId);
//     }
    
//     function testCreatePortfolioWithInvalidParams() public {
//         vm.startPrank(user1);
        
//         // Test empty name
//         vm.expectRevert(abi.encodeWithSelector(HedVaultErrors.InvalidConfiguration.selector, "Empty portfolio name"));
//         portfolioManager.createPortfolio("", 5, 500);
        
//         // Test invalid risk level
//         vm.expectRevert(abi.encodeWithSelector(HedVaultErrors.InvalidConfiguration.selector, "Risk level must be 1-10"));
//         portfolioManager.createPortfolio("Test", 0, 500);
        
//         vm.expectRevert(abi.encodeWithSelector(HedVaultErrors.InvalidConfiguration.selector, "Risk level must be 1-10"));
//         portfolioManager.createPortfolio("Test", 11, 500);
        
//         // Test high rebalance threshold
//         vm.expectRevert(abi.encodeWithSelector(HedVaultErrors.InvalidConfiguration.selector, "Rebalance threshold too high"));
//         portfolioManager.createPortfolio("Test", 5, 5001);
        
//         vm.stopPrank();
//     }
    
//     function testAddAsset() public {
//         // Create portfolio
//         vm.prank(user1);
//         uint256 portfolioId = portfolioManager.createPortfolio("Test Portfolio", 5, 500);
        
//         uint256 amount = 10 * 10**18;
//         uint256 targetAllocation = 2500; // 25%
        
//         vm.startPrank(user1);
//         tokenA.approve(address(portfolioManager), amount);
        
//         vm.expectEmit(true, true, false, true);
//         emit AssetAdded(portfolioId, address(tokenA), amount, targetAllocation);
        
//         portfolioManager.addAsset(portfolioId, address(tokenA), amount, targetAllocation);
//         vm.stopPrank();
        
//         // Verify asset addition
//         PortfolioManager.AssetHolding memory holding = portfolioManager.getPortfolioHolding(portfolioId, address(tokenA));
//         assertEq(holding.asset, address(tokenA));
//         assertEq(holding.amount, amount);
//         assertEq(holding.targetAllocation, targetAllocation);
        
//         // Check portfolio assets
//         address[] memory assets = portfolioManager.getPortfolioAssets(portfolioId);
//         assertEq(assets.length, 1);
//         assertEq(assets[0], address(tokenA));
        
//         // Check token transfer
//         assertEq(tokenA.balanceOf(user1), 1000 * 10**18 - amount);
//         assertEq(tokenA.balanceOf(address(portfolioManager)), amount);
//     }
    
//     function testAddAssetWithInvalidParams() public {
//         vm.prank(user1);
//         uint256 portfolioId = portfolioManager.createPortfolio("Test Portfolio", 5, 500);
        
//         vm.startPrank(user1);
        
//         // Test zero amount
//         vm.expectRevert(HedVaultErrors.ZeroAmount.selector);
//         portfolioManager.addAsset(portfolioId, address(tokenA), 0, 2500);
        
//         // Test invalid allocation (too low)
//         tokenA.approve(address(portfolioManager), 10 * 10**18);
//         vm.expectRevert(abi.encodeWithSelector(HedVaultErrors.InvalidAllocation.selector, 50));
//         portfolioManager.addAsset(portfolioId, address(tokenA), 10 * 10**18, 50);
        
//         // Test invalid allocation (too high)
//         vm.expectRevert(abi.encodeWithSelector(HedVaultErrors.InvalidAllocation.selector, 5001));
//         portfolioManager.addAsset(portfolioId, address(tokenA), 10 * 10**18, 5001);
        
//         vm.stopPrank();
//     }
    
//     function testAddMultipleAssets() public {
//         vm.prank(user1);
//         uint256 portfolioId = portfolioManager.createPortfolio("Test Portfolio", 5, 500);
        
//         vm.startPrank(user1);
        
//         // Add first asset
//         tokenA.approve(address(portfolioManager), 10 * 10**18);
//         portfolioManager.addAsset(portfolioId, address(tokenA), 10 * 10**18, 3000); // 30%
        
//         // Add second asset
//         tokenB.approve(address(portfolioManager), 5 * 10**18);
//         portfolioManager.addAsset(portfolioId, address(tokenB), 5 * 10**18, 4000); // 40%
        
//         // Add third asset
//         tokenC.approve(address(portfolioManager), 20 * 10**18);
//         portfolioManager.addAsset(portfolioId, address(tokenC), 20 * 10**18, 3000); // 30%
        
//         vm.stopPrank();
        
//         // Verify all assets
//         address[] memory assets = portfolioManager.getPortfolioAssets(portfolioId);
//         assertEq(assets.length, 3);
        
//         // Check portfolio stats
//         (uint256 totalAssets, uint256 totalAllocation, , ) = portfolioManager.getPortfolioStats(portfolioId);
//         assertEq(totalAssets, 3);
//         assertEq(totalAllocation, 10000); // 100%
//     }
    
//     function testAddAssetExceedingAllocation() public {
//         vm.prank(user1);
//         uint256 portfolioId = portfolioManager.createPortfolio("Test Portfolio", 5, 500);
        
//         vm.startPrank(user1);
        
//         // Add multiple assets that total more than 100%
//         tokenA.approve(address(portfolioManager), 10 * 10**18);
//         portfolioManager.addAsset(portfolioId, address(tokenA), 10 * 10**18, 4000); // 40%
        
//         tokenB.approve(address(portfolioManager), 5 * 10**18);
//         portfolioManager.addAsset(portfolioId, address(tokenB), 5 * 10**18, 4000); // 40%
        
//         tokenC.approve(address(portfolioManager), 20 * 10**18);
        
//         // This should fail as total would be 110% (4000 + 4000 + 3000 = 11000)
//         vm.expectRevert(abi.encodeWithSelector(HedVaultErrors.AllocationExceedsLimit.selector, 11000, 10000));
//         portfolioManager.addAsset(portfolioId, address(tokenC), 20 * 10**18, 3000); // 30%
        
//         vm.stopPrank();
//     }
    
//     function testRemoveAsset() public {
//         // Setup portfolio with asset
//         vm.prank(user1);
//         uint256 portfolioId = portfolioManager.createPortfolio("Test Portfolio", 5, 500);
        
//         uint256 amount = 10 * 10**18;
//         vm.startPrank(user1);
//         tokenA.approve(address(portfolioManager), amount);
//         portfolioManager.addAsset(portfolioId, address(tokenA), amount, 2500);
        
//         uint256 balanceBefore = tokenA.balanceOf(user1);
        
//         // Remove partial amount
//         uint256 removeAmount = 3 * 10**18;
//         vm.expectEmit(true, true, false, true);
//         emit AssetRemoved(portfolioId, address(tokenA), removeAmount);
        
//         portfolioManager.removeAsset(portfolioId, address(tokenA), removeAmount);
//         vm.stopPrank();
        
//         // Verify partial removal
//         PortfolioManager.AssetHolding memory holding = portfolioManager.getPortfolioHolding(portfolioId, address(tokenA));
//         assertEq(holding.amount, amount - removeAmount);
//         assertEq(tokenA.balanceOf(user1), balanceBefore + removeAmount);
//     }
    
//     function testRemoveAllAsset() public {
//         // Setup portfolio with asset
//         vm.prank(user1);
//         uint256 portfolioId = portfolioManager.createPortfolio("Test Portfolio", 5, 500);
        
//         uint256 amount = 10 * 10**18;
//         vm.startPrank(user1);
//         tokenA.approve(address(portfolioManager), amount);
//         portfolioManager.addAsset(portfolioId, address(tokenA), amount, 2500);
        
//         uint256 balanceBefore = tokenA.balanceOf(user1);
        
//         // Remove all (amount = 0 means remove all)
//         portfolioManager.removeAsset(portfolioId, address(tokenA), 0);
//         vm.stopPrank();
        
//         // Verify complete removal
//         PortfolioManager.AssetHolding memory holding = portfolioManager.getPortfolioHolding(portfolioId, address(tokenA));
//         assertEq(holding.amount, 0);
//         assertEq(tokenA.balanceOf(user1), balanceBefore + amount);
        
//         // Asset should be removed from portfolio
//         address[] memory assets = portfolioManager.getPortfolioAssets(portfolioId);
//         assertEq(assets.length, 0);
//     }
    
//     function testUpdateAllocations() public {
//         // Setup portfolio with multiple assets
//         vm.prank(user1);
//         uint256 portfolioId = portfolioManager.createPortfolio("Test Portfolio", 5, 500);
        
//         vm.startPrank(user1);
//         tokenA.approve(address(portfolioManager), 10 * 10**18);
//         portfolioManager.addAsset(portfolioId, address(tokenA), 10 * 10**18, 3000);
        
//         tokenB.approve(address(portfolioManager), 5 * 10**18);
//         portfolioManager.addAsset(portfolioId, address(tokenB), 5 * 10**18, 4000);
        
//         // Update allocations
//         address[] memory assets = new address[](2);
//         assets[0] = address(tokenA);
//         assets[1] = address(tokenB);
        
//         uint256[] memory newAllocations = new uint256[](2);
//         newAllocations[0] = 4000; // 40%
//         newAllocations[1] = 3000; // 30%
        
//         portfolioManager.updateAllocations(portfolioId, assets, newAllocations);
//         vm.stopPrank();
        
//         // Verify updates
//         PortfolioManager.AssetHolding memory holdingA = portfolioManager.getPortfolioHolding(portfolioId, address(tokenA));
//         PortfolioManager.AssetHolding memory holdingB = portfolioManager.getPortfolioHolding(portfolioId, address(tokenB));
        
//         assertEq(holdingA.targetAllocation, 4000);
//         assertEq(holdingB.targetAllocation, 3000);
//     }
    
//     function testUpdateAllocationsWithInvalidParams() public {
//         vm.prank(user1);
//         uint256 portfolioId = portfolioManager.createPortfolio("Test Portfolio", 5, 500);
        
//         vm.startPrank(user1);
//         tokenA.approve(address(portfolioManager), 10 * 10**18);
//         portfolioManager.addAsset(portfolioId, address(tokenA), 10 * 10**18, 3000);
        
//         // Test array length mismatch
//         address[] memory assets = new address[](1);
//         assets[0] = address(tokenA);
        
//         uint256[] memory allocations = new uint256[](2);
//         allocations[0] = 4000;
//         allocations[1] = 3000;
        
//         vm.expectRevert(abi.encodeWithSelector(HedVaultErrors.ArrayLengthMismatch.selector, 1, 2));
//         portfolioManager.updateAllocations(portfolioId, assets, allocations);
        
//         vm.stopPrank();
//     }
    
//     function testBatchUpdateAssets() public {
//         vm.prank(user1);
//         uint256 portfolioId = portfolioManager.createPortfolio("Test Portfolio", 5, 500);
        
//         vm.startPrank(user1);
        
//         // Prepare batch update
//         address[] memory assets = new address[](2);
//         assets[0] = address(tokenA);
//         assets[1] = address(tokenB);
        
//         int256[] memory amounts = new int256[](2);
//         amounts[0] = int256(10 * 10**18); // Add 10 tokenA
//         amounts[1] = int256(5 * 10**18);  // Add 5 tokenB
        
//         uint256[] memory allocations = new uint256[](2);
//         allocations[0] = 4000; // 40%
//         allocations[1] = 3000; // 30%
        
//         // Approve tokens
//         tokenA.approve(address(portfolioManager), 10 * 10**18);
//         tokenB.approve(address(portfolioManager), 5 * 10**18);
        
//         portfolioManager.batchUpdateAssets(portfolioId, assets, amounts, allocations);
//         vm.stopPrank();
        
//         // Verify batch update
//         PortfolioManager.AssetHolding memory holdingA = portfolioManager.getPortfolioHolding(portfolioId, address(tokenA));
//         PortfolioManager.AssetHolding memory holdingB = portfolioManager.getPortfolioHolding(portfolioId, address(tokenB));
        
//         assertEq(holdingA.amount, 10 * 10**18);
//         assertEq(holdingA.targetAllocation, 4000);
//         assertEq(holdingB.amount, 5 * 10**18);
//         assertEq(holdingB.targetAllocation, 3000);
//     }
    
//     function testGetPortfolioBreakdown() public {
//         vm.prank(user1);
//         uint256 portfolioId = portfolioManager.createPortfolio("Test Portfolio", 5, 500);
        
//         vm.startPrank(user1);
//         tokenA.approve(address(portfolioManager), 10 * 10**18);
//         portfolioManager.addAsset(portfolioId, address(tokenA), 10 * 10**18, 4000);
        
//         tokenB.approve(address(portfolioManager), 5 * 10**18);
//         portfolioManager.addAsset(portfolioId, address(tokenB), 5 * 10**18, 3000);
//         vm.stopPrank();
        
//         // Get breakdown
//         (
//             address[] memory assets,
//             uint256[] memory targetAllocations,
//             uint256[] memory currentAllocations,
//             uint256[] memory values
//         ) = portfolioManager.getPortfolioBreakdown(portfolioId);
        
//         assertEq(assets.length, 2);
//         assertEq(targetAllocations[0], 4000);
//         assertEq(targetAllocations[1], 3000);
        
//         // Values should be calculated based on prices
//         // TokenA: 10 * $1000 = $10,000
//         // TokenB: 5 * $2000 = $10,000
//         assertEq(values[0], 10000 * 10**18);
//         assertEq(values[1], 10000 * 10**18);
//     }
    
//     function testAddAndRemoveSupportedAsset() public {
//         address newAsset = address(0x999);
        
//         // Add supported asset
//         vm.prank(admin);
//         portfolioManager.addSupportedAsset(newAsset);
        
//         assertTrue(portfolioManager.supportedAssets(newAsset));
        
//         // Remove supported asset
//         vm.prank(admin);
//         portfolioManager.removeSupportedAsset(newAsset);
        
//         assertFalse(portfolioManager.supportedAssets(newAsset));
//     }
    
//     function testOnlyOwnerCanModifyPortfolio() public {
//         vm.prank(user1);
//         uint256 portfolioId = portfolioManager.createPortfolio("Test Portfolio", 5, 500);
        
//         // User2 tries to add asset to user1's portfolio
//         vm.startPrank(user2);
//         tokenA.approve(address(portfolioManager), 10 * 10**18);
        
//         vm.expectRevert(abi.encodeWithSelector(HedVaultErrors.UnauthorizedAccess.selector, user2, "portfolio owner"));
//         portfolioManager.addAsset(portfolioId, address(tokenA), 10 * 10**18, 2500);
        
//         vm.stopPrank();
//     }
    
//     function testPauseUnpause() public {
//         // Pause contract
//         vm.prank(admin);
//         portfolioManager.pause();
        
//         // Try to create portfolio while paused
//         vm.prank(user1);
//         vm.expectRevert(abi.encodeWithSignature("EnforcedPause()"));
//         portfolioManager.createPortfolio("Test", 5, 500);
        
//         // Unpause and try again
//         vm.prank(admin);
//         portfolioManager.unpause();
        
//         vm.prank(user1);
//         uint256 portfolioId = portfolioManager.createPortfolio("Test", 5, 500);
        
//         // Should succeed
//         PortfolioManager.Portfolio memory portfolio = portfolioManager.getPortfolio(portfolioId);
//         assertEq(portfolio.owner, user1);
//     }
    
//     function testGetPortfolioValue() public {
//         vm.prank(user1);
//         uint256 portfolioId = portfolioManager.createPortfolio("Test Portfolio", 5, 500);
        
//         vm.startPrank(user1);
//         // Add 10 tokenA ($1000 each) = $10,000
//         tokenA.approve(address(portfolioManager), 10 * 10**18);
//         portfolioManager.addAsset(portfolioId, address(tokenA), 10 * 10**18, 4000);
        
//         // Add 5 tokenB ($2000 each) = $10,000
//         tokenB.approve(address(portfolioManager), 5 * 10**18);
//         portfolioManager.addAsset(portfolioId, address(tokenB), 5 * 10**18, 3000);
//         vm.stopPrank();
        
//         uint256 portfolioValue = portfolioManager.getPortfolioValue(portfolioId);
//         // Total should be $20,000
//         assertEq(portfolioValue, 20000 * 10**18);
//     }
// }