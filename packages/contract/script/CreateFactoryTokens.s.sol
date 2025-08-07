// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/RWATokenFactory.sol";
import "../src/libraries/DataTypes.sol";

/**
 * @title CreateFactoryTokens
 * @notice Script to create factory tokens for real-world assets like gold, silver, and stocks
 * @dev This script creates multiple RWA tokens representing different asset classes
 */
contract CreateFactoryTokens is Script {
    // Environment variables
    address public rwaTokenFactory;
    address public creator;
    address public priceOracle;

    // Token creation fee (should match factory settings)
    uint256 public constant TOKEN_CREATION_FEE = 100 * 1e18; // 100 HBAR equivalent
    uint256 public constant LISTING_FEE = 50 * 1e18; // 50 HBAR equivalent

    // Asset configurations
    struct AssetConfig {
        string name;
        string symbol;
        string assetType;
        string location;
        uint256 valuation;
        uint256 totalSupply;
        uint256 minInvestment;
        string certificationHash;
    }

    function run() external {
        // Load environment variables
        rwaTokenFactory = vm.envAddress("RWA_TOKEN_FACTORY_ADDRESS");
        creator = vm.envAddress("CREATOR_ADDRESS");
        priceOracle = vm.envAddress("PRICE_ORACLE_ADDRESS");

        console.log("=== Creating Factory Tokens for Real Assets ===");
        console.log("RWA Token Factory:", rwaTokenFactory);
        console.log("Creator Address:", creator);
        console.log("Token Creation Fee:", TOKEN_CREATION_FEE);

        vm.startBroadcast(creator);

        // Create precious metals tokens
        _createPreciousMetalsTokens();

        // Create stock tokens
        _createStockTokens();

        // Create commodity tokens
        _createCommodityTokens();

        // Create bond tokens
        _createBondTokens();

        vm.stopBroadcast();

        console.log("=== Factory Token Creation Complete ===");
    }

    /**
     * @notice Create precious metals tokens (Gold, Silver, Platinum, Palladium)
     */
    function _createPreciousMetalsTokens() internal {
        console.log("\n--- Creating Precious Metals Tokens ---");

        AssetConfig[] memory metals = new AssetConfig[](4);

        // Gold Token
        metals[0] = AssetConfig({
            name: "Gold Token",
            symbol: "HVGOLD",
            assetType: "PreciousMetals",
            location: "LBMA Certified Vaults, London",
            valuation: 2000 * 1e18, // $2000 per ounce
            totalSupply: 10000 * 1e18, // 10,000 tokens (representing ounces)
            minInvestment: 100 * 1e18, // $100 minimum
            certificationHash: "ipfs://QmGoldCertification123"
        });

        // Silver Token
        metals[1] = AssetConfig({
            name: " Silver Token",
            symbol: "HVSILVER",
            assetType: "PreciousMetals",
            location: "COMEX Certified Vaults, New York",
            valuation: 25 * 1e18, // $25 per ounce
            totalSupply: 100000 * 1e18, // 100,000 tokens
            minInvestment: 50 * 1e18, // $50 minimum
            certificationHash: "ipfs://QmSilverCertification456"
        });

        // Platinum Token
        metals[2] = AssetConfig({
            name: " Platinum Token",
            symbol: "HVPLATINUM",
            assetType: "PreciousMetals",
            location: "LPPM Certified Vaults, Zurich",
            valuation: 1000 * 1e18, // $1000 per ounce
            totalSupply: 5000 * 1e18, // 5,000 tokens
            minInvestment: 200 * 1e18, // $200 minimum
            certificationHash: "ipfs://QmPlatinumCertification789"
        });

        // Palladium Token
        metals[3] = AssetConfig({
            name: " Palladium Token",
            symbol: "HVPALLADIUM",
            assetType: "PreciousMetals",
            location: "LPPM Certified Vaults, London",
            valuation: 1500 * 1e18, // $1500 per ounce
            totalSupply: 3000 * 1e18, // 3,000 tokens
            minInvestment: 300 * 1e18, // $300 minimum
            certificationHash: "ipfs://QmPalladiumCertification101"
        });

        for (uint i = 0; i < metals.length; i++) {
            _createAndListToken(metals[i]);
        }
    }

    /**
     * @notice Create stock tokens for major companies
     */
    function _createStockTokens() internal {
        console.log("\n--- Creating Stock Tokens ---");

        AssetConfig[] memory stocks = new AssetConfig[](5);

        // Apple Stock Token
        stocks[0] = AssetConfig({
            name: " Apple Stock Token",
            symbol: "HVAAPL",
            assetType: "Bonds", // Using Bonds as closest supported type for stocks
            location: "NASDAQ, United States",
            valuation: 175 * 1e18, // $175 per share
            totalSupply: 1000000 * 1e18, // 1M tokens
            minInvestment: 175 * 1e18, // $175 minimum (1 share)
            certificationHash: "ipfs://QmAppleStockCertification"
        });

        // Microsoft Stock Token
        stocks[1] = AssetConfig({
            name: "HedVault Microsoft Stock Token",
            symbol: "HVMSFT",
            assetType: "Bonds",
            location: "NASDAQ, United States",
            valuation: 350 * 1e18, // $350 per share
            totalSupply: 800000 * 1e18, // 800K tokens
            minInvestment: 350 * 1e18, // $350 minimum
            certificationHash: "ipfs://QmMicrosoftStockCertification"
        });

        // Tesla Stock Token
        stocks[2] = AssetConfig({
            name: "HedVault Tesla Stock Token",
            symbol: "HVTSLA",
            assetType: "Bonds",
            location: "NASDAQ, United States",
            valuation: 200 * 1e18, // $200 per share
            totalSupply: 500000 * 1e18, // 500K tokens
            minInvestment: 200 * 1e18, // $200 minimum
            certificationHash: "ipfs://QmTeslaStockCertification"
        });

        // Amazon Stock Token
        stocks[3] = AssetConfig({
            name: "HedVault Amazon Stock Token",
            symbol: "HVAMZN",
            assetType: "Bonds",
            location: "NASDAQ, United States",
            valuation: 140 * 1e18, // $140 per share
            totalSupply: 600000 * 1e18, // 600K tokens
            minInvestment: 140 * 1e18, // $140 minimum
            certificationHash: "ipfs://QmAmazonStockCertification"
        });

        // Google Stock Token
        stocks[4] = AssetConfig({
            name: "HedVault Google Stock Token",
            symbol: "HVGOOGL",
            assetType: "Bonds",
            location: "NASDAQ, United States",
            valuation: 130 * 1e18, // $130 per share
            totalSupply: 700000 * 1e18, // 700K tokens
            minInvestment: 130 * 1e18, // $130 minimum
            certificationHash: "ipfs://QmGoogleStockCertification"
        });

        for (uint i = 0; i < stocks.length; i++) {
            _createAndListToken(stocks[i]);
        }
    }

    /**
     * @notice Create commodity tokens
     */
    function _createCommodityTokens() internal {
        console.log("\n--- Creating Commodity Tokens ---");

        AssetConfig[] memory commodities = new AssetConfig[](3);

        // Oil Token
        commodities[0] = AssetConfig({
            name: "Crude Oil Token",
            symbol: "HVOIL",
            assetType: "Commodities",
            location: "WTI Crude Oil Futures, NYMEX",
            valuation: 75 * 1e18, // $75 per barrel
            totalSupply: 100000 * 1e18, // 100K barrels
            minInvestment: 75 * 1e18, // $75 minimum
            certificationHash: "ipfs://QmOilCertification"
        });

        // Natural Gas Token
        commodities[1] = AssetConfig({
            name: "Natural Gas Token",
            symbol: "HVGAS",
            assetType: "Commodities",
            location: "Henry Hub Natural Gas, NYMEX",
            valuation: 3 * 1e18, // $3 per MMBtu
            totalSupply: 1000000 * 1e18, // 1M MMBtu
            minInvestment: 30 * 1e18, // $30 minimum
            certificationHash: "ipfs://QmGasCertification"
        });

        // Wheat Token
        commodities[2] = AssetConfig({
            name: "Wheat Token",
            symbol: "HVWHEAT",
            assetType: "Commodities",
            location: "CBOT Wheat Futures, Chicago",
            valuation: 6 * 1e18, // $6 per bushel
            totalSupply: 500000 * 1e18, // 500K bushels
            minInvestment: 60 * 1e18, // $60 minimum
            certificationHash: "ipfs://QmWheatCertification"
        });

        for (uint i = 0; i < commodities.length; i++) {
            _createAndListToken(commodities[i]);
        }
    }

    /**
     * @notice Create bond tokens
     */
    function _createBondTokens() internal {
        console.log("\n--- Creating Bond Tokens ---");

        AssetConfig[] memory bonds = new AssetConfig[](2);

        // US Treasury Bond Token
        bonds[0] = AssetConfig({
            name: "US Treasury Bond Token",
            symbol: "HVUST10Y",
            assetType: "Bonds",
            location: "US Treasury, Washington DC",
            valuation: 1000 * 1e18, // $1000 par value
            totalSupply: 100000 * 1e18, // 100K bonds
            minInvestment: 1000 * 1e18, // $1000 minimum
            certificationHash: "ipfs://QmTreasuryBondCertification"
        });

        // Corporate Bond Token (AAA Rated)
        bonds[1] = AssetConfig({
            name: "Corporate Bond Token",
            symbol: "HVCORP",
            assetType: "Bonds",
            location: "Corporate Bond Market, NYSE",
            valuation: 1000 * 1e18, // $1000 par value
            totalSupply: 50000 * 1e18, // 50K bonds
            minInvestment: 1000 * 1e18, // $1000 minimum
            certificationHash: "ipfs://QmCorporateBondCertification"
        });

        for (uint i = 0; i < bonds.length; i++) {
            _createAndListToken(bonds[i]);
        }
    }

    /**
     * @notice Create and list a token with given configuration
     * @param config Asset configuration
     */
    function _createAndListToken(AssetConfig memory config) internal {
        console.log("Creating token:", config.name);

        // Create metadata
        DataTypes.RWAMetadata memory metadata = DataTypes.RWAMetadata({
            assetType: config.assetType,
            location: config.location,
            valuation: config.valuation,
            lastValuationDate: block.timestamp,
            certificationHash: config.certificationHash,
            isActive: true,
            oracle: priceOracle,
            totalSupply: config.totalSupply,
            minInvestment: config.minInvestment
        });

        // Create token
        RWATokenFactory factory = RWATokenFactory(rwaTokenFactory);

        address tokenAddress = factory.createRWAToken(
            metadata,
            config.name,
            config.symbol,
            config.totalSupply
        );

        console.log("Token created at:", tokenAddress);
        console.log("Symbol:", config.symbol);
        console.log("Total Supply:", config.totalSupply);
        console.log("Valuation:", config.valuation);

        // List token for trading
        factory.listToken{value: LISTING_FEE}(tokenAddress);

        console.log("Token listed for trading");
        console.log("---");
    }

    /**
     * @notice Helper function to check if creator is approved
     */
    function checkCreatorApproval() external view {
        RWATokenFactory factory = RWATokenFactory(rwaTokenFactory);
        bool isApproved = factory.approvedCreators(creator);
        console.log("Creator approved:", isApproved);

        if (!isApproved) {
            console.log(
                "WARNING: Creator is not approved. Please approve creator first:"
            );
            console.log(
                "cast send",
                rwaTokenFactory,
                '"approveCreator(address)" ',
                creator
            );
        }
    }

    /**
     * @notice Helper function to get required balance for all operations
     */
    function getRequiredBalance() external pure returns (uint256) {
        // 14 tokens total (4 metals + 5 stocks + 3 commodities + 2 bonds)
        uint256 totalTokens = 14;
        uint256 totalFees = totalTokens * (TOKEN_CREATION_FEE + LISTING_FEE);
        return totalFees;
    }
}
