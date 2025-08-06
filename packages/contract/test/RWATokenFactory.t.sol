// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;

// import "forge-std/Test.sol";
// import "../src/RWATokenFactory.sol";
// import "../src/HedVaultCore.sol";
// import "../src/RWAToken.sol";
// import "../src/libraries/DataTypes.sol";
// import "../src/libraries/HedVaultErrors.sol";
// import "../src/libraries/Events.sol";

// contract RWATokenFactoryTest is Test {
//     RWATokenFactory public rwaTokenFactory;
//     HedVaultCore public hedVaultCore;

//     address public owner;
//     address public admin;
//     address public creator;
//     address public user1;
//     address public user2;
//     address public oracle;

//     // Mock module addresses
//     address public mockRWATokenFactory;
//     address public mockMarketplace;
//     address public mockSwapEngine;
//     address public mockLendingPool;
//     address public mockRewardsDistributor;
//     address public mockPriceOracle;
//     address public mockComplianceManager;
//     address public mockPortfolioManager;
//     address public mockCrossChainBridge;
//     address public mockAnalyticsEngine;

//     uint256 public constant TOKEN_CREATION_FEE = 100 * 1e18;
//     uint256 public constant LISTING_FEE = 50 * 1e18;

//     function setUp() public {
//         owner = address(this);
//         admin = makeAddr("admin");
//         creator = makeAddr("creator");
//         user1 = makeAddr("user1");
//         user2 = makeAddr("user2");
//         oracle = makeAddr("oracle");

//         // Create mock module addresses
//         mockRWATokenFactory = makeAddr("mockRWATokenFactory");
//         mockMarketplace = makeAddr("mockMarketplace");
//         mockSwapEngine = makeAddr("mockSwapEngine");
//         mockLendingPool = makeAddr("mockLendingPool");
//         mockRewardsDistributor = makeAddr("mockRewardsDistributor");
//         mockPriceOracle = makeAddr("mockPriceOracle");
//         mockComplianceManager = makeAddr("mockComplianceManager");
//         mockPortfolioManager = makeAddr("mockPortfolioManager");
//         mockCrossChainBridge = makeAddr("mockCrossChainBridge");
//         mockAnalyticsEngine = makeAddr("mockAnalyticsEngine");

//         // Deploy HedVaultCore
//         hedVaultCore = new HedVaultCore(makeAddr("feeRecipient"));

//         // Deploy RWATokenFactory
//         rwaTokenFactory = new RWATokenFactory(address(hedVaultCore));

//         // Initialize HedVaultCore
//         address[10] memory modules = [
//             address(rwaTokenFactory),
//             mockMarketplace,
//             mockSwapEngine,
//             mockLendingPool,
//             mockRewardsDistributor,
//             mockPriceOracle,
//             mockComplianceManager,
//             mockPortfolioManager,
//             mockCrossChainBridge,
//             mockAnalyticsEngine
//         ];
//         hedVaultCore.initialize(modules);

//         // Setup roles
//         rwaTokenFactory.grantRole(rwaTokenFactory.ADMIN_ROLE(), admin);
//         rwaTokenFactory.approveCreator(creator);

//         // Fund accounts for fees
//         vm.deal(creator, 1000 ether);
//         vm.deal(user1, 1000 ether);
//         vm.deal(admin, 1000 ether);
//     }

//     function _createSampleMetadata()
//         internal
//         view
//         returns (DataTypes.RWAMetadata memory)
//     {
//         return
//             DataTypes.RWAMetadata({
//                 assetType: "RealEstate",
//                 location: "New York, USA",
//                 valuation: 1000000 * 1e18, // $1M
//                 lastValuationDate: block.timestamp,
//                 certificationHash: "ipfs://sample-documents",
//                 isActive: true,
//                 oracle: oracle,
//                 totalSupply: 1000000 * 1e18,
//                 minInvestment: 1000 * 1e18
//             });
//     }

//     // Constructor tests
//     function test_Constructor() public {
//         RWATokenFactory factory = new RWATokenFactory(address(hedVaultCore));

//         assertEq(address(factory.hedVaultCore()), address(hedVaultCore));
//         assertTrue(
//             factory.hasRole(factory.DEFAULT_ADMIN_ROLE(), address(this))
//         );
//         assertTrue(factory.hasRole(factory.ADMIN_ROLE(), address(this)));
//         assertTrue(factory.hasRole(factory.CREATOR_ROLE(), address(this)));

//         // Check supported asset types
//         assertTrue(factory.supportedAssetTypes("RealEstate"));
//         assertTrue(factory.supportedAssetTypes("PreciousMetals"));
//         assertTrue(factory.supportedAssetTypes("Art"));
//         assertTrue(factory.supportedAssetTypes("Commodities"));
//         assertTrue(factory.supportedAssetTypes("Bonds"));
//     }

//     function test_ConstructorRevertsWithZeroAddress() public {
//         vm.expectRevert(HedVaultErrors.ZeroAddress.selector);
//         new RWATokenFactory(address(0));
//     }

//     // Token creation tests
//     function test_CreateRWAToken() public {
//         DataTypes.RWAMetadata memory metadata = _createSampleMetadata();

//         vm.prank(creator);
//         address tokenAddress = rwaTokenFactory.createRWAToken{
//             value: TOKEN_CREATION_FEE
//         }(metadata, "Real Estate Token", "RET", 1000000 * 1e18);

//         assertTrue(tokenAddress != address(0));
//         assertTrue(rwaTokenFactory.isRWAToken(tokenAddress));

//         // Check asset info
//         DataTypes.AssetInfo memory info = rwaTokenFactory.getAssetInfo(
//             tokenAddress
//         );
//         assertEq(info.creator, creator);
//         assertEq(info.metadata.assetType, "RealEstate");
//         assertEq(info.metadata.valuation, 1000000 * 1e18);
//         assertFalse(info.isListed);
//         assertEq(info.holders, 1);

//         // Check token contract
//         RWAToken token = RWAToken(payable(tokenAddress));
//         assertEq(token.name(), "Real Estate Token");
//         assertEq(token.symbol(), "RET");
//         assertEq(token.totalSupply(), 1000000 * 1e18);
//         assertEq(token.balanceOf(creator), 1000000 * 1e18);
//     }

//     function test_CreateRWATokenRevertsWithInsufficientFee() public {
//         DataTypes.RWAMetadata memory metadata = _createSampleMetadata();

//         vm.prank(creator);
//         vm.expectRevert(
//             abi.encodeWithSelector(
//                 HedVaultErrors.InsufficientFeePayment.selector,
//                 TOKEN_CREATION_FEE - 1,
//                 TOKEN_CREATION_FEE
//             )
//         );
//         rwaTokenFactory.createRWAToken{value: TOKEN_CREATION_FEE - 1}(
//             metadata,
//             "Real Estate Token",
//             "RET",
//             1000000 * 1e18
//         );
//     }

//     function test_CreateRWATokenRevertsWithUnapprovedCreator() public {
//         DataTypes.RWAMetadata memory metadata = _createSampleMetadata();

//         vm.prank(user1);
//         vm.expectRevert(
//             abi.encodeWithSelector(
//                 HedVaultErrors.UnauthorizedAccess.selector,
//                 user1,
//                 "CREATOR_ROLE"
//             )
//         );
//         rwaTokenFactory.createRWAToken{value: TOKEN_CREATION_FEE}(
//             metadata,
//             "Real Estate Token",
//             "RET",
//             1000000 * 1e18
//         );
//     }

//     function test_CreateRWATokenRevertsWithInvalidSupply() public {
//         DataTypes.RWAMetadata memory metadata = _createSampleMetadata();

//         vm.prank(creator);
//         vm.expectRevert(
//             abi.encodeWithSelector(
//                 HedVaultErrors.InvalidAmount.selector,
//                 500 * 1e18,
//                 1000 * 1e18,
//                 1000000000 * 1e18
//             )
//         );
//         rwaTokenFactory.createRWAToken{value: TOKEN_CREATION_FEE}(
//             metadata,
//             "Real Estate Token",
//             "RET",
//             500 * 1e18 // Below minimum
//         );
//     }

//     function test_CreateRWATokenRevertsWithUnsupportedAssetType() public {
//         DataTypes.RWAMetadata memory metadata = _createSampleMetadata();
//         metadata.assetType = "UnsupportedType";

//         vm.prank(creator);
//         vm.expectRevert(
//             abi.encodeWithSelector(
//                 HedVaultErrors.InvalidTokenMetadata.selector,
//                 "assetType"
//             )
//         );
//         rwaTokenFactory.createRWAToken{value: TOKEN_CREATION_FEE}(
//             metadata,
//             "Real Estate Token",
//             "RET",
//             1000000 * 1e18
//         );
//     }

//     // Token listing tests
//     function test_ListToken() public {
//         // Create token first
//         DataTypes.RWAMetadata memory metadata = _createSampleMetadata();

//         vm.prank(creator);
//         address tokenAddress = rwaTokenFactory.createRWAToken{
//             value: TOKEN_CREATION_FEE
//         }(metadata, "Real Estate Token", "RET", 1000000 * 1e18);

//         // List token
//         vm.prank(creator);
//         rwaTokenFactory.listToken{value: LISTING_FEE}(tokenAddress);

//         DataTypes.AssetInfo memory info = rwaTokenFactory.getAssetInfo(
//             tokenAddress
//         );
//         assertTrue(info.isListed);
//     }

//     function test_ListTokenRevertsWithInsufficientFee() public {
//         // Create token first
//         DataTypes.RWAMetadata memory metadata = _createSampleMetadata();

//         vm.prank(creator);
//         address tokenAddress = rwaTokenFactory.createRWAToken{
//             value: TOKEN_CREATION_FEE
//         }(metadata, "Real Estate Token", "RET", 1000000 * 1e18);

//         // Try to list with insufficient fee
//         vm.prank(creator);
//         vm.expectRevert(
//             abi.encodeWithSelector(
//                 HedVaultErrors.InsufficientFeePayment.selector,
//                 LISTING_FEE - 1,
//                 LISTING_FEE
//             )
//         );
//         rwaTokenFactory.listToken{value: LISTING_FEE - 1}(tokenAddress);
//     }

//     function test_ListTokenRevertsIfAlreadyListed() public {
//         // Create and list token
//         DataTypes.RWAMetadata memory metadata = _createSampleMetadata();

//         vm.prank(creator);
//         address tokenAddress = rwaTokenFactory.createRWAToken{
//             value: TOKEN_CREATION_FEE
//         }(metadata, "Real Estate Token", "RET", 1000000 * 1e18);

//         vm.prank(creator);
//         rwaTokenFactory.listToken{value: LISTING_FEE}(tokenAddress);

//         // Try to list again
//         vm.prank(creator);
//         vm.expectRevert(
//             abi.encodeWithSelector(
//                 HedVaultErrors.TokenAlreadyListed.selector,
//                 tokenAddress
//             )
//         );
//         rwaTokenFactory.listToken{value: LISTING_FEE}(tokenAddress);
//     }

//     function test_DelistToken() public {
//         // Create and list token
//         DataTypes.RWAMetadata memory metadata = _createSampleMetadata();

//         vm.prank(creator);
//         address tokenAddress = rwaTokenFactory.createRWAToken{
//             value: TOKEN_CREATION_FEE
//         }(metadata, "Real Estate Token", "RET", 1000000 * 1e18);

//         vm.prank(creator);
//         rwaTokenFactory.listToken{value: LISTING_FEE}(tokenAddress);

//         // Delist token
//         vm.prank(admin);
//         rwaTokenFactory.delistToken(tokenAddress, "Compliance issue");

//         DataTypes.AssetInfo memory info = rwaTokenFactory.getAssetInfo(
//             tokenAddress
//         );
//         assertFalse(info.isListed);
//     }

//     // Creator management tests
//     function test_ApproveCreator() public {
//         vm.prank(admin);
//         rwaTokenFactory.approveCreator(user1);

//         assertTrue(rwaTokenFactory.approvedCreators(user1));
//     }

//     function test_ApproveCreatorRevertsWithZeroAddress() public {
//         vm.prank(admin);
//         vm.expectRevert(HedVaultErrors.ZeroAddress.selector);
//         rwaTokenFactory.approveCreator(address(0));
//     }

//     function test_RevokeCreator() public {
//         vm.prank(admin);
//         rwaTokenFactory.approveCreator(user1);

//         vm.prank(admin);
//         rwaTokenFactory.revokeCreator(user1);

//         assertFalse(rwaTokenFactory.approvedCreators(user1));
//     }

//     // Asset type management tests
//     function test_AddAssetType() public {
//         vm.prank(admin);
//         rwaTokenFactory.addAssetType("NewAssetType");

//         assertTrue(rwaTokenFactory.supportedAssetTypes("NewAssetType"));
//     }

//     function test_RemoveAssetType() public {
//         vm.prank(admin);
//         rwaTokenFactory.removeAssetType("Art");

//         assertFalse(rwaTokenFactory.supportedAssetTypes("Art"));
//     }

//     // Fee management tests
//     function test_UpdateTokenCreationFee() public {
//         uint256 newFee = 200 * 1e18;

//         vm.prank(admin);
//         rwaTokenFactory.updateTokenCreationFee(newFee);

//         assertEq(rwaTokenFactory.tokenCreationFee(), newFee);
//     }

//     function test_UpdateListingFee() public {
//         uint256 newFee = 100 * 1e18;

//         vm.prank(admin);
//         rwaTokenFactory.updateListingFee(newFee);

//         assertEq(rwaTokenFactory.listingFee(), newFee);
//     }

//     // Metadata update tests
//     function test_UpdateTokenMetadata() public {
//         // Create token
//         DataTypes.RWAMetadata memory metadata = _createSampleMetadata();

//         vm.prank(creator);
//         address tokenAddress = rwaTokenFactory.createRWAToken{
//             value: TOKEN_CREATION_FEE
//         }(metadata, "Real Estate Token", "RET", 1000000 * 1e18);

//         // Update metadata
//         DataTypes.RWAMetadata memory newMetadata = metadata;
//         newMetadata.valuation = 1200000 * 1e18;
//         newMetadata.lastValuationDate = block.timestamp + 1 days;

//         vm.prank(creator);
//         rwaTokenFactory.updateTokenMetadata(tokenAddress, newMetadata);

//         DataTypes.AssetInfo memory info = rwaTokenFactory.getAssetInfo(
//             tokenAddress
//         );
//         assertEq(info.metadata.valuation, 1200000 * 1e18);
//     }

//     // View function tests
//     function test_GetTokensByCreator() public {
//         // Create multiple tokens
//         DataTypes.RWAMetadata memory metadata = _createSampleMetadata();

//         vm.startPrank(creator);
//         rwaTokenFactory.createRWAToken{value: TOKEN_CREATION_FEE}(
//             metadata,
//             "Token 1",
//             "TK1",
//             1000000 * 1e18
//         );

//         rwaTokenFactory.createRWAToken{value: TOKEN_CREATION_FEE}(
//             metadata,
//             "Token 2",
//             "TK2",
//             2000000 * 1e18
//         );
//         vm.stopPrank();

//         uint256[] memory tokens = rwaTokenFactory.getCreatorTokens(creator);
//         assertEq(tokens.length, 2);
//     }

//     function test_GetAssetTypeCount() public {
//         DataTypes.RWAMetadata memory metadata = _createSampleMetadata();

//         vm.prank(creator);
//         rwaTokenFactory.createRWAToken{value: TOKEN_CREATION_FEE}(
//             metadata,
//             "Real Estate Token",
//             "RET",
//             1000000 * 1e18
//         );

//         assertEq(rwaTokenFactory.getAssetTypeCount("RealEstate"), 1);
//     }

//     // Pause functionality tests
//     function test_PauseUnpause() public {
//         vm.prank(admin);
//         rwaTokenFactory.pause();
//         assertTrue(rwaTokenFactory.paused());

//         vm.prank(admin);
//         rwaTokenFactory.unpause();
//         assertFalse(rwaTokenFactory.paused());
//     }

//     function test_CreateTokenRevertsWhenPaused() public {
//         vm.prank(admin);
//         rwaTokenFactory.pause();

//         DataTypes.RWAMetadata memory metadata = _createSampleMetadata();

//         vm.prank(creator);
//         vm.expectRevert(
//             abi.encodeWithSelector(Pausable.EnforcedPause.selector)
//         );
//         rwaTokenFactory.createRWAToken{value: TOKEN_CREATION_FEE}(
//             metadata,
//             "Real Estate Token",
//             "RET",
//             1000000 * 1e18
//         );
//     }
// }
