// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// import "forge-std/Test.sol";
// import "forge-std/console.sol";
// import "../src/Marketplace.sol";
// import "../src/HedVaultCore.sol";
// import "../src/PriceOracle.sol";
// import "../src/RWATokenFactory.sol";
// import "../src/ComplianceManager.sol";
// import "../src/libraries/HedVaultErrors.sol";
// import "../src/libraries/DataTypes.sol";
// import "../src/libraries/Events.sol";
// import "../src/RWAToken.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// contract MockERC20 is ERC20 {
//     constructor(string memory name, string memory symbol) ERC20(name, symbol) {
//         _mint(msg.sender, 1000000 * 10**18);
//     }

//     function mint(address to, uint256 amount) external {
//         _mint(to, amount);
//     }
// }

// contract MockChainlinkAggregator {
//     int256 private _price;
//     uint8 private _decimals;
//     uint256 private _timestamp;
//     uint80 private _roundId;

//     constructor() {
//         _price = 100000000; // $1.00
//         _decimals = 8;
//         _timestamp = block.timestamp;
//         _roundId = 1;
//     }

//     function decimals() external view returns (uint8) {
//         return _decimals;
//     }

//     function description() external pure returns (string memory) {
//         return "Mock Chainlink Aggregator";
//     }

//     function version() external pure returns (uint256) {
//         return 1;
//     }

//     function getRoundData(uint80 _roundId_)
//         external
//         view
//         returns (
//             uint80 roundId,
//             int256 answer,
//             uint256 startedAt,
//             uint256 updatedAt,
//             uint80 answeredInRound
//         )
//     {
//         return (_roundId_, _price, _timestamp, _timestamp, _roundId_);
//     }

//     function latestRoundData()
//         external
//         view
//         returns (
//             uint80 roundId,
//             int256 answer,
//             uint256 startedAt,
//             uint256 updatedAt,
//             uint80 answeredInRound
//         )
//     {
//         return (_roundId, _price, _timestamp, _timestamp, _roundId);
//     }

//     function updatePrice(int256 newPrice) external {
//         _price = newPrice;
//         _timestamp = block.timestamp;
//         _roundId++;
//     }
// }

// contract MarketplaceTest is Test {
//     Marketplace public marketplace;
//     HedVaultCore public hedVaultCore;
//     PriceOracle public priceOracle;
//     RWATokenFactory public tokenFactory;
//     ComplianceManager public complianceManager;
//     MockERC20 public paymentToken;
//     MockERC20 public rwaToken;
//     address public admin = address(0x1);
//     address public user1 = address(0x2);
//     address public user2 = address(0x3);
//     address public feeRecipient = address(0x4);
//     address public creator = address(0x5);

//     uint256 constant INITIAL_SUPPLY = 1000000 * 10**18;
//     uint256 constant ORDER_AMOUNT = 100 * 10**18;
//     uint256 constant ORDER_PRICE = 10 * 10**18; // 10 payment tokens per RWA token

//     function setUp() public {
//         vm.startPrank(admin);

//         // Deploy payment token
//         paymentToken = new MockERC20("USDC", "USDC");

//         // Deploy PriceOracle
//         priceOracle = new PriceOracle(admin);

//         // Deploy HedVaultCore first
//         hedVaultCore = new HedVaultCore(feeRecipient);
        
//         // Deploy ComplianceManager
//         complianceManager = new ComplianceManager(address(hedVaultCore), admin);

//         // Deploy RWATokenFactory
//         tokenFactory = new RWATokenFactory(address(hedVaultCore));

//         // Deploy Marketplace
//         marketplace = new Marketplace(
//             address(hedVaultCore),
//             address(priceOracle),
//             feeRecipient
//         );

//         // Setup roles and permissions
//         // Note: HedVaultCore doesn't use role-based access for marketplace
        
//         // Add asset type and approve creator
//         tokenFactory.addAssetType("RealEstate");
//         tokenFactory.approveCreator(creator);
        
//         // Setup ComplianceManager and verify creator
//         complianceManager.grantRole(complianceManager.KYC_OFFICER_ROLE(), admin);
//         complianceManager.verifyUser(
//             creator,
//             ComplianceManager.ComplianceLevel.BASIC,
//             "US",
//             keccak256("test-kyc-hash")
//         );

//         vm.stopPrank();

//         // Create RWA token
//         vm.startPrank(creator);
//         vm.deal(creator, 1000 * 10**18); // Give creator enough ETH
        
//         DataTypes.RWAMetadata memory metadata = DataTypes.RWAMetadata({
//             assetType: "RealEstate",
//             location: "Test City",
//             valuation: 1000000 * 10**18,
//             lastValuationDate: block.timestamp,
//             certificationHash: "ipfs://test",
//             isActive: true,
//             oracle: address(priceOracle),
//             totalSupply: INITIAL_SUPPLY,
//             minInvestment: 1000 * 10**18
//         });
        
//         address tokenAddress = tokenFactory.createRWAToken{value: 100 * 10**18}(
//             metadata,
//             "Test RWA",
//             "TRWA",
//             INITIAL_SUPPLY
//         );
//         rwaToken = MockERC20(tokenAddress);
        
//         // Set compliance levels for all users in the RWA token
//         // The factory has COMPLIANCE_ROLE, so we need to call from factory context
//         vm.stopPrank();
//         vm.startPrank(address(tokenFactory));
//         RWAToken(payable(tokenAddress)).setUserComplianceLevel(creator, 1); // Set to level 1 (BASIC)
//         RWAToken(payable(tokenAddress)).setUserComplianceLevel(user1, 1); // Set to level 1 (BASIC)
//         RWAToken(payable(tokenAddress)).setUserComplianceLevel(user2, 1); // Set to level 1 (BASIC)
//         RWAToken(payable(tokenAddress)).setUserComplianceLevel(address(marketplace), 1); // Set marketplace compliance level
//         vm.stopPrank();
        
//         // Increase transfer limits to allow token distribution
//         vm.startPrank(creator);
//         RWAToken(payable(tokenAddress)).setTransferLimits(
//             INITIAL_SUPPLY / 2, // 50% max transfer
//             INITIAL_SUPPLY / 2  // 50% daily limit
//         );
//         vm.stopPrank();

//         // Setup marketplace
//         vm.startPrank(admin);
//         marketplace.addSupportedAsset(address(rwaToken));
//         marketplace.addSupportedPaymentToken(address(paymentToken));
//         marketplace.setAssetTradingEnabled(address(rwaToken), true); // Enable trading
//         vm.stopPrank();

//         // Distribute tokens
//         vm.startPrank(creator);
//         rwaToken.transfer(user1, 10000 * 10**18);
//         rwaToken.transfer(user2, 10000 * 10**18);
//         vm.stopPrank();

//         vm.startPrank(admin);
//         paymentToken.transfer(user1, 100000 * 10**18);
//         paymentToken.transfer(user2, 100000 * 10**18);
//         vm.stopPrank();
//     }

//     function test_Constructor() public {
//         assertEq(address(marketplace.hedVaultCore()), address(hedVaultCore));
//         assertEq(address(marketplace.priceOracle()), address(priceOracle));
//         assertEq(marketplace.feeRecipient(), feeRecipient);
//         assertEq(marketplace.nextOrderId(), 1);
//         assertEq(marketplace.nextTradeId(), 1);
//         assertEq(marketplace.nextAuctionId(), 1);
//         assertFalse(marketplace.emergencyStop());
//     }

//     function test_ConstructorRevertsWithZeroAddress() public {
//         vm.expectRevert(HedVaultErrors.ZeroAddress.selector);
//         new Marketplace(address(0), address(priceOracle), feeRecipient);

//         vm.expectRevert(HedVaultErrors.ZeroAddress.selector);
//         new Marketplace(address(hedVaultCore), address(0), feeRecipient);

//         vm.expectRevert(HedVaultErrors.ZeroAddress.selector);
//         new Marketplace(address(hedVaultCore), address(priceOracle), address(0));
//     }

//     function test_AddSupportedAsset() public {
//         address newAsset = address(0x123);
        
//         vm.prank(admin);
//         marketplace.addSupportedAsset(newAsset);
        
//         assertTrue(marketplace.supportedAssets(newAsset));
//     }

//     function test_AddSupportedAssetRevertsForNonAdmin() public {
//         address newAsset = address(0x123);
        
//         vm.prank(user1);
//         vm.expectRevert();
//         marketplace.addSupportedAsset(newAsset);
//     }

//     function test_AddSupportedPaymentToken() public {
//         address newToken = address(0x123);
        
//         vm.prank(admin);
//         marketplace.addSupportedPaymentToken(newToken);
        
//         assertTrue(marketplace.supportedPaymentTokens(newToken));
//     }

//     function test_AssetTradingEnabled() public {
//         // Asset trading is enabled by default when added as supported asset
//         assertTrue(marketplace.supportedAssets(address(rwaToken)));
//     }

//     function test_CreateSellOrder() public {
//         vm.startPrank(user1);
//         rwaToken.approve(address(marketplace), ORDER_AMOUNT);
        
//         uint256 orderId = marketplace.createOrder(
//             address(rwaToken),
//             address(paymentToken),
//             ORDER_AMOUNT,
//             ORDER_PRICE,
//             1, // SELL
//             block.timestamp + 1 days
//         );
        
//         assertEq(orderId, 1);
//         assertEq(marketplace.nextOrderId(), 2);
//         assertEq(marketplace.userActiveOrders(user1), 1);
        
//         (uint256 id, address maker, address asset, address payment, uint256 amount, uint256 price, uint256 filled, uint256 expiry, uint8 orderType, uint8 status, uint256 createdAt, uint256 fee) = marketplace.orders(orderId);
//         assertEq(id, orderId);
//         assertEq(maker, user1);
//         assertEq(asset, address(rwaToken));
//         assertEq(payment, address(paymentToken));
//         assertEq(amount, ORDER_AMOUNT);
//         assertEq(price, ORDER_PRICE);
//         assertEq(filled, 0);
//         assertEq(orderType, 1);
//         assertEq(status, 0); // ACTIVE
        
//         vm.stopPrank();
//     }

//     function test_CreateBuyOrder() public {
//         uint256 totalCost = (ORDER_AMOUNT * ORDER_PRICE) / 1e18;
//         uint256 fee = (ORDER_AMOUNT * ORDER_PRICE * marketplace.makerFee()) / (10000 * 1e18);
        
//         vm.startPrank(user2);
//         paymentToken.approve(address(marketplace), totalCost + fee);
        
//         uint256 orderId = marketplace.createOrder(
//             address(rwaToken),
//             address(paymentToken),
//             ORDER_AMOUNT,
//             ORDER_PRICE,
//             0, // BUY
//             block.timestamp + 1 days
//         );
        
//         assertEq(orderId, 1);
//         assertEq(marketplace.userActiveOrders(user2), 1);
        
//         (,,,,,,,, uint8 orderType,,,) = marketplace.orders(orderId);
//         assertEq(orderType, 0); // BUY
        
//         // Clean up: Cancel the order to prevent interference with other tests
//         marketplace.cancelOrder(orderId);
//         assertEq(marketplace.userActiveOrders(user2), 0);
        
//         vm.stopPrank();
//     }

//     function test_CreateOrderRevertsWithInvalidAmount() public {
//         vm.startPrank(user1);
//         rwaToken.approve(address(marketplace), ORDER_AMOUNT);
        
//         // Amount too small
//         vm.expectRevert();
//         marketplace.createOrder(
//             address(rwaToken),
//             address(paymentToken),
//             0.5e18, // Below minOrderSize
//             ORDER_PRICE,
//             1,
//             block.timestamp + 1 days
//         );
        
//         // Amount too large
//         vm.expectRevert();
//         marketplace.createOrder(
//             address(rwaToken),
//             address(paymentToken),
//             2000000e18, // Above maxOrderSize
//             ORDER_PRICE,
//             1,
//             block.timestamp + 1 days
//         );
        
//         vm.stopPrank();
//     }

//     function test_CreateOrderRevertsWithZeroPrice() public {
//         vm.startPrank(user1);
//         rwaToken.approve(address(marketplace), ORDER_AMOUNT);
        
//         vm.expectRevert(HedVaultErrors.ZeroAmount.selector);
//         marketplace.createOrder(
//             address(rwaToken),
//             address(paymentToken),
//             ORDER_AMOUNT,
//             0, // Zero price
//             1,
//             block.timestamp + 1 days
//         );
        
//         vm.stopPrank();
//     }

//     function test_CreateOrderRevertsWithInvalidExpiry() public {
//         vm.startPrank(user1);
//         rwaToken.approve(address(marketplace), ORDER_AMOUNT);
        
//         // Expiry in the past
//         vm.expectRevert();
//         marketplace.createOrder(
//             address(rwaToken),
//             address(paymentToken),
//             ORDER_AMOUNT,
//             ORDER_PRICE,
//             1,
//             block.timestamp - 1
//         );
        
//         // Expiry too far in the future
//         vm.expectRevert();
//         marketplace.createOrder(
//             address(rwaToken),
//             address(paymentToken),
//             ORDER_AMOUNT,
//             ORDER_PRICE,
//             1,
//             block.timestamp + 31 days
//         );
        
//         vm.stopPrank();
//     }

//     function test_CreateOrderRevertsWithUnsupportedAsset() public {
//         address unsupportedAsset = address(0x999);
        
//         vm.startPrank(user1);
//         vm.expectRevert();
//         marketplace.createOrder(
//             unsupportedAsset,
//             address(paymentToken),
//             ORDER_AMOUNT,
//             ORDER_PRICE,
//             1,
//             block.timestamp + 1 days
//         );
//         vm.stopPrank();
//     }

//     function test_CancelOrder() public {
//         // Deploy a fresh marketplace to avoid any existing orders
//         Marketplace freshMarketplace = new Marketplace(
//             address(hedVaultCore),
//             address(priceOracle),
//             feeRecipient
//         );
        
//         // Set up the fresh marketplace
//         // The test contract is the deployer, so it has admin roles
//         freshMarketplace.grantRole(freshMarketplace.MARKETPLACE_ADMIN_ROLE(), admin);
//         vm.startPrank(admin);
//         freshMarketplace.addSupportedAsset(address(rwaToken));
//         freshMarketplace.addSupportedPaymentToken(address(paymentToken));
//         freshMarketplace.setAssetTradingEnabled(address(rwaToken), true);
        
//         // Set compliance levels for the fresh marketplace
//         vm.stopPrank();
//         vm.startPrank(address(tokenFactory));
//         RWAToken(payable(address(rwaToken))).setUserComplianceLevel(address(freshMarketplace), 1);
//         vm.stopPrank();
//         vm.startPrank(admin);
//         vm.stopPrank();
        
//         // Create order in fresh marketplace
//         vm.startPrank(user1);
//         rwaToken.approve(address(freshMarketplace), ORDER_AMOUNT);
        
//         // Debug: Check if there are any existing orders
//         console.log("Next order ID before creating order:", freshMarketplace.nextOrderId());
//         uint256[] memory existingBuyOrders = freshMarketplace.getAssetOrders(address(rwaToken), 0); // BUY orders
//         uint256[] memory existingSellOrders = freshMarketplace.getAssetOrders(address(rwaToken), 1); // SELL orders
//         console.log("Existing BUY orders:", existingBuyOrders.length);
//         console.log("Existing SELL orders:", existingSellOrders.length);
        
//         uint256 orderId = freshMarketplace.createOrder(
//             address(rwaToken),
//             address(paymentToken),
//             ORDER_AMOUNT,
//             ORDER_PRICE,
//             1, // SELL
//             block.timestamp + 1 days
//         );
        
//         // Check order status and details immediately after creation
//         (uint256 id, address maker, address asset, address payment, uint256 amount, uint256 price, uint256 filled, uint256 expiry, uint8 orderType, uint8 statusAfterCreation, uint256 createdAt, uint256 fee) = freshMarketplace.orders(orderId);
//         console.log("Order status after creation in fresh marketplace:", statusAfterCreation);
//         console.log("Order filled amount:", filled);
//         console.log("Order total amount:", amount);
//         console.log("Order ID created:", orderId);
        
//         // Check if order was added to asset orders
//         uint256[] memory sellOrdersAfter = freshMarketplace.getAssetOrders(address(rwaToken), 1);
//         console.log("SELL orders after creation:", sellOrdersAfter.length);
        
//         require(statusAfterCreation == 0, "Order should be ACTIVE after creation");
        
//         uint256 balanceBefore = rwaToken.balanceOf(user1);
        
//         // Cancel order
//         freshMarketplace.cancelOrder(orderId);
        
//         // Check order status after cancellation
//         (,,,,,,,,, uint8 status,,) = freshMarketplace.orders(orderId);
//         assertEq(status, 2); // CANCELLED
//         assertEq(freshMarketplace.userActiveOrders(user1), 0);
        
//         // Check tokens returned
//         uint256 balanceAfter = rwaToken.balanceOf(user1);
//         assertEq(balanceAfter, balanceBefore + ORDER_AMOUNT);
        
//         vm.stopPrank();
//     }

//     function test_CancelOrderRevertsForNonMaker() public {
//         // Create order
//         vm.startPrank(user1);
//         rwaToken.approve(address(marketplace), ORDER_AMOUNT);
        
//         uint256 orderId = marketplace.createOrder(
//             address(rwaToken),
//             address(paymentToken),
//             ORDER_AMOUNT,
//             ORDER_PRICE,
//             1,
//             block.timestamp + 1 days
//         );
//         vm.stopPrank();
        
//         // Try to cancel from different user
//         vm.prank(user2);
//         vm.expectRevert();
//         marketplace.cancelOrder(orderId);
//     }

//     function test_UpdateFees() public {
//         vm.prank(admin);
//         marketplace.updateFees(30, 60, 300);
        
//         assertEq(marketplace.makerFee(), 30);
//         assertEq(marketplace.takerFee(), 60);
//         assertEq(marketplace.auctionFee(), 300);
//     }

//     function test_UpdateFeesRevertsForNonAdmin() public {
//         vm.prank(user1);
//         vm.expectRevert();
//         marketplace.updateFees(30, 60, 300);
//     }

//     function test_Pause() public {
//         vm.prank(admin);
//         marketplace.pause();
        
//         assertTrue(marketplace.paused());
        
//         // Test unpause
//         vm.prank(admin);
//         marketplace.unpause();
        
//         assertFalse(marketplace.paused());
//     }

//     function test_CreateOrderRevertsWhenPaused() public {
//         vm.prank(admin);
//         marketplace.pause();
        
//         vm.startPrank(user1);
//         rwaToken.approve(address(marketplace), ORDER_AMOUNT);
        
//         vm.expectRevert();
//         marketplace.createOrder(
//             address(rwaToken),
//             address(paymentToken),
//             ORDER_AMOUNT,
//             ORDER_PRICE,
//             1,
//             block.timestamp + 1 days
//         );
        
//         vm.stopPrank();
//     }

//     function test_PauseAndUnpause() public {
//         vm.prank(admin);
//         marketplace.pause();
        
//         assertTrue(marketplace.paused());
        
//         vm.startPrank(user1);
//         rwaToken.approve(address(marketplace), ORDER_AMOUNT);
        
//         vm.expectRevert();
//         marketplace.createOrder(
//             address(rwaToken),
//             address(paymentToken),
//             ORDER_AMOUNT,
//             ORDER_PRICE,
//             1,
//             block.timestamp + 1 days
//         );
//         vm.stopPrank();
        
//         vm.prank(admin);
//         marketplace.unpause();
        
//         assertFalse(marketplace.paused());
//     }

//     function test_GetUserOrders() public {
//         vm.startPrank(user1);
//         rwaToken.approve(address(marketplace), ORDER_AMOUNT * 2);
        
//         uint256 orderId1 = marketplace.createOrder(
//             address(rwaToken),
//             address(paymentToken),
//             ORDER_AMOUNT,
//             ORDER_PRICE,
//             1,
//             block.timestamp + 1 days
//         );
        
//         uint256 orderId2 = marketplace.createOrder(
//             address(rwaToken),
//             address(paymentToken),
//             ORDER_AMOUNT,
//             ORDER_PRICE + 1e18,
//             1,
//             block.timestamp + 1 days
//         );
        
//         vm.stopPrank();
        
//         uint256[] memory userOrderIds = marketplace.getUserOrders(user1);
//         assertEq(userOrderIds.length, 2);
//         assertEq(userOrderIds[0], orderId1);
//         assertEq(userOrderIds[1], orderId2);
//     }

//     function test_GetAssetOrders() public {
//         vm.startPrank(user1);
//         rwaToken.approve(address(marketplace), ORDER_AMOUNT);
        
//         uint256 orderId = marketplace.createOrder(
//             address(rwaToken),
//             address(paymentToken),
//             ORDER_AMOUNT,
//             ORDER_PRICE,
//             1, // SELL
//             block.timestamp + 1 days
//         );
        
//         vm.stopPrank();
        
//         uint256[] memory sellOrders = marketplace.getAssetOrders(address(rwaToken), 1);
//         assertEq(sellOrders.length, 1);
//         assertEq(sellOrders[0], orderId);
//     }

//     function test_Constants() public {
//         assertEq(marketplace.makerFee(), 25);
//         assertEq(marketplace.takerFee(), 50);
//         assertEq(marketplace.auctionFee(), 250);
//         assertEq(marketplace.protocolFee(), 10);
//         assertEq(marketplace.minOrderSize(), 1e18);
//         assertEq(marketplace.maxOrderSize(), 1000000e18);
//         assertEq(marketplace.maxOrderDuration(), 30 days);
//         assertEq(marketplace.maxActiveOrdersPerUser(), 100);
//         assertEq(marketplace.maxSlippageAllowed(), 1000);
//     }
// }