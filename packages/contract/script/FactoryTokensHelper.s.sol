// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/RWATokenFactory.sol";
import "../src/libraries/DataTypes.sol";

/**
 * @title FactoryTokensHelper
 * @notice Helper script for managing factory tokens deployment and verification
 * @dev Provides utilities for batch operations and status checking
 */
contract FactoryTokensHelper is Script {
    address public rwaTokenFactory;
    address public creator;

    uint256 public constant TOKEN_CREATION_FEE = 100 * 1e18;
    uint256 public constant LISTING_FEE = 50 * 1e18;

    function setUp() public {
        rwaTokenFactory = vm.envAddress("RWA_TOKEN_FACTORY_ADDRESS");
        creator = vm.envAddress("CREATOR_ADDRESS");
    }

    /**
     * @notice Check deployment prerequisites
     */
    function checkPrerequisites() external {
        console.log("=== Factory Tokens Deployment Prerequisites ===");
        console.log("RWA Token Factory:", rwaTokenFactory);
        console.log("Creator Address:", creator);

        RWATokenFactory factory = RWATokenFactory(rwaTokenFactory);

        // Check if creator is approved
        bool isApproved = factory.approvedCreators(creator);
        console.log("Creator Approved:", isApproved);

        if (!isApproved) {
            console.log("[ERROR] Creator is NOT approved!");
            console.log(
                "Run: cast send",
                rwaTokenFactory,
                '"approveCreator(address)" ',
                creator
            );
        } else {
            console.log("[OK] Creator is approved");
        }

        // Check creator balance
        uint256 balance = creator.balance;
        uint256 required = getRequiredBalance();
        console.log("Creator Balance:", balance);
        console.log("Required Balance:", required);

        if (balance >= required) {
            console.log("[OK] Sufficient balance");
        } else {
            console.log("[ERROR] Insufficient balance!");
            console.log("Need additional:", required - balance);
        }

        // Check factory status
        bool isPaused = factory.paused();
        console.log("Factory Paused:", isPaused);

        if (isPaused) {
            console.log("[ERROR] Factory is paused!");
        } else {
            console.log("[OK] Factory is active");
        }

        // Check supported asset types
        console.log("\n--- Supported Asset Types ---");
        console.log(
            "PreciousMetals:",
            factory.supportedAssetTypes("PreciousMetals")
        );
        console.log("Bonds:", factory.supportedAssetTypes("Bonds"));
        console.log("Commodities:", factory.supportedAssetTypes("Commodities"));

        console.log("\n--- Summary ---");
        if (isApproved && balance >= required && !isPaused) {
            console.log("[SUCCESS] Ready to deploy factory tokens!");
        } else {
            console.log(
                "[WARNING] Prerequisites not met. Please resolve issues above."
            );
        }
    }

    /**
     * @notice Get total balance required for all token deployments
     */
    function getRequiredBalance() public pure returns (uint256) {
        uint256 totalTokens = 14; // 4 metals + 5 stocks + 3 commodities + 2 bonds
        return totalTokens * (TOKEN_CREATION_FEE + LISTING_FEE);
    }

    /**
     * @notice Check current deployment status
     */
    function checkDeploymentStatus() external {
        console.log("=== Factory Tokens Deployment Status ===");

        RWATokenFactory factory = RWATokenFactory(rwaTokenFactory);

        // Get total tokens created
        uint256 totalTokens = factory.getTotalTokens();
        console.log("Total Tokens Created:", totalTokens);

        // Get creator's tokens
        uint256[] memory creatorTokens = factory.getCreatorTokens(creator);
        console.log("Creator's Tokens:", creatorTokens.length);

        // Check each expected token symbol
        string[14] memory expectedSymbols = [
            "HVGOLD",
            "HVSILVER",
            "HVPLATINUM",
            "HVPALLADIUM",
            "HVAAPL",
            "HVMSFT",
            "HVTSLA",
            "HVAMZN",
            "HVGOOGL",
            "HVOIL",
            "HVGAS",
            "HVWHEAT",
            "HVUST10Y",
            "HVCORP"
        ];

        console.log("\n--- Expected Tokens Status ---");
        for (
            uint i = 0;
            i < creatorTokens.length && i < expectedSymbols.length;
            i++
        ) {
            uint256 tokenId = creatorTokens[i];
            address tokenAddress = factory.tokenById(tokenId);

            if (tokenAddress != address(0)) {
                DataTypes.AssetInfo memory info = factory.getAssetInfo(
                    tokenAddress
                );
                console.log("Token ID:", tokenId);
                console.log("Address:", tokenAddress);
                console.log("Asset Type:", info.metadata.assetType);
                console.log("Listed:", info.isListed);
                console.log("Valuation:", info.metadata.valuation);
                console.log("---");
            }
        }

        // Summary
        if (creatorTokens.length >= 14) {
            console.log("[SUCCESS] All factory tokens appear to be deployed!");
        } else {
            console.log(
                "[WARNING] Only",
                creatorTokens.length,
                "/ 14 tokens deployed"
            );
        }
    }

    /**
     * @notice Deploy only precious metals tokens (batch 1)
     */
    function deployPreciousMetalsOnly() external {
        console.log("=== Deploying Precious Metals Tokens Only ===");

        vm.startBroadcast(creator);

        _createPreciousMetalsTokens();

        vm.stopBroadcast();

        console.log("[SUCCESS] Precious metals tokens deployment complete!");
    }

    /**
     * @notice Deploy only stock tokens (batch 2)
     */
    function deployStocksOnly() external {
        console.log("=== Deploying Stock Tokens Only ===");

        vm.startBroadcast(creator);

        _createStockTokens();

        vm.stopBroadcast();

        console.log("[SUCCESS] Stock tokens deployment complete!");
    }

    /**
     * @notice Deploy only commodity tokens (batch 3)
     */
    function deployCommoditiesOnly() external {
        console.log("=== Deploying Commodity Tokens Only ===");

        vm.startBroadcast(creator);

        _createCommodityTokens();

        vm.stopBroadcast();

        console.log("[SUCCESS] Commodity tokens deployment complete!");
    }

    /**
     * @notice Deploy only bond tokens (batch 4)
     */
    function deployBondsOnly() external {
        console.log("=== Deploying Bond Tokens Only ===");

        vm.startBroadcast(creator);

        _createBondTokens();

        vm.stopBroadcast();

        console.log("[SUCCESS] Bond tokens deployment complete!");
    }

    /**
     * @notice Emergency function to approve creator (admin only)
     */
    function approveCreator() external {
        console.log("=== Approving Creator ===");
        console.log("Creator to approve:", creator);

        vm.startBroadcast();

        RWATokenFactory factory = RWATokenFactory(rwaTokenFactory);
        factory.approveCreator(creator);

        vm.stopBroadcast();

        console.log("[SUCCESS] Creator approved successfully!");
    }

    // Internal functions (copied from main script)
    function _createPreciousMetalsTokens() internal {
        // Gold
        _createToken(
            "HedVault Gold Token",
            "HVGOLD",
            "PreciousMetals",
            "LBMA Certified Vaults, London",
            2000 * 1e18,
            10000 * 1e18,
            100 * 1e18,
            "ipfs://QmGoldCertification123"
        );

        // Silver
        _createToken(
            "HedVault Silver Token",
            "HVSILVER",
            "PreciousMetals",
            "COMEX Certified Vaults, New York",
            25 * 1e18,
            100000 * 1e18,
            50 * 1e18,
            "ipfs://QmSilverCertification456"
        );

        // Platinum
        _createToken(
            "HedVault Platinum Token",
            "HVPLATINUM",
            "PreciousMetals",
            "LPPM Certified Vaults, Zurich",
            1000 * 1e18,
            5000 * 1e18,
            200 * 1e18,
            "ipfs://QmPlatinumCertification789"
        );

        // Palladium
        _createToken(
            "HedVault Palladium Token",
            "HVPALLADIUM",
            "PreciousMetals",
            "LPPM Certified Vaults, London",
            1500 * 1e18,
            3000 * 1e18,
            300 * 1e18,
            "ipfs://QmPalladiumCertification101"
        );
    }

    function _createStockTokens() internal {
        // Apple
        _createToken(
            "HedVault Apple Stock Token",
            "HVAAPL",
            "Bonds",
            "NASDAQ, United States",
            175 * 1e18,
            1000000 * 1e18,
            175 * 1e18,
            "ipfs://QmAppleStockCertification"
        );

        // Microsoft
        _createToken(
            "HedVault Microsoft Stock Token",
            "HVMSFT",
            "Bonds",
            "NASDAQ, United States",
            350 * 1e18,
            800000 * 1e18,
            350 * 1e18,
            "ipfs://QmMicrosoftStockCertification"
        );

        // Tesla
        _createToken(
            "HedVault Tesla Stock Token",
            "HVTSLA",
            "Bonds",
            "NASDAQ, United States",
            200 * 1e18,
            500000 * 1e18,
            200 * 1e18,
            "ipfs://QmTeslaStockCertification"
        );

        // Amazon
        _createToken(
            "HedVault Amazon Stock Token",
            "HVAMZN",
            "Bonds",
            "NASDAQ, United States",
            140 * 1e18,
            600000 * 1e18,
            140 * 1e18,
            "ipfs://QmAmazonStockCertification"
        );

        // Google
        _createToken(
            "HedVault Google Stock Token",
            "HVGOOGL",
            "Bonds",
            "NASDAQ, United States",
            130 * 1e18,
            700000 * 1e18,
            130 * 1e18,
            "ipfs://QmGoogleStockCertification"
        );
    }

    function _createCommodityTokens() internal {
        // Oil
        _createToken(
            "HedVault Crude Oil Token",
            "HVOIL",
            "Commodities",
            "WTI Crude Oil Futures, NYMEX",
            75 * 1e18,
            100000 * 1e18,
            75 * 1e18,
            "ipfs://QmOilCertification"
        );

        // Natural Gas
        _createToken(
            "HedVault Natural Gas Token",
            "HVGAS",
            "Commodities",
            "Henry Hub Natural Gas, NYMEX",
            3 * 1e18,
            1000000 * 1e18,
            30 * 1e18,
            "ipfs://QmGasCertification"
        );

        // Wheat
        _createToken(
            "HedVault Wheat Token",
            "HVWHEAT",
            "Commodities",
            "CBOT Wheat Futures, Chicago",
            6 * 1e18,
            500000 * 1e18,
            60 * 1e18,
            "ipfs://QmWheatCertification"
        );
    }

    function _createBondTokens() internal {
        // US Treasury
        _createToken(
            "HedVault US Treasury Bond Token",
            "HVUST10Y",
            "Bonds",
            "US Treasury, Washington DC",
            1000 * 1e18,
            100000 * 1e18,
            1000 * 1e18,
            "ipfs://QmTreasuryBondCertification"
        );

        // Corporate Bond
        _createToken(
            "HedVault Corporate Bond Token",
            "HVCORP",
            "Bonds",
            "Corporate Bond Market, NYSE",
            1000 * 1e18,
            50000 * 1e18,
            1000 * 1e18,
            "ipfs://QmCorporateBondCertification"
        );
    }

    function _createToken(
        string memory name,
        string memory symbol,
        string memory assetType,
        string memory location,
        uint256 valuation,
        uint256 totalSupply,
        uint256 minInvestment,
        string memory certificationHash
    ) internal {
        console.log("Creating:", name);
        console.log("Symbol:", symbol);

        DataTypes.RWAMetadata memory metadata = DataTypes.RWAMetadata({
            assetType: assetType,
            location: location,
            valuation: valuation,
            lastValuationDate: block.timestamp,
            certificationHash: certificationHash,
            isActive: true,
            oracle: address(0),
            totalSupply: totalSupply,
            minInvestment: minInvestment
        });

        RWATokenFactory factory = RWATokenFactory(rwaTokenFactory);

        address tokenAddress = factory.createRWAToken(
            metadata,
            name,
            symbol,
            totalSupply
        );

        factory.listToken{value: LISTING_FEE}(tokenAddress);

        console.log("[SUCCESS] Created and listed:", tokenAddress);
    }
}
