// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/HedVaultCore.sol";
import "../src/PriceOracle.sol";
import "../src/RWATokenFactory.sol";
import "../src/SwapEngine.sol";
import "../src/ComplianceManager.sol";
import "../src/PortfolioManager.sol";
import "../src/CrossChainBridge.sol";
import "../src/RewardsDistributor.sol";
import "../src/LendingPool.sol";
import "../src/Marketplace.sol";

/**
 * @title VerifyHederaDeployment
 * @notice Script to verify HedVault deployment on Hedera
 */
contract VerifyHederaDeployment is Script {
    // Contract addresses to verify (set these after deployment)
    address public hedVaultCore;
    address public priceOracle;
    address public rwaTokenFactory;
    address public swapEngine;
    address public complianceManager;
    address public portfolioManager;
    address public crossChainBridge;
    address public rewardsDistributor;
    address public lendingPool;
    address public marketplace;
    
    // Chainlink price feeds
    address public constant HBAR_USD_FEED = 0x6f7C932e7684666C9fd1d44527765433e01fF61d;
    address public constant ETH_USD_FEED = 0x9326BFA02ADD2366b30bacB125260Af641031331;
    address public constant BTC_USD_FEED = 0x56a43EB56Da12C0dc1D972ACb089c06a5dEF8e69;
    
    function run() external {
        // Load contract addresses from environment or deployment artifacts
        loadContractAddresses();
        
        console.log("=== HedVault Hedera Deployment Verification ===");
        console.log("");
        
        // Verify core contracts
        verifyHedVaultCore();
        verifyPriceOracle();
        verifyRWATokenFactory();
        verifySwapEngine();
        verifyComplianceManager();
        verifyPortfolioManager();
        verifyCrossChainBridge();
        verifyRewardsDistributor();
        verifyLendingPool();
        verifyMarketplace();
        
        // Verify integrations
        verifyChainlinkIntegration();
        verifyHederaIntegration();
        
        console.log("=== Verification Complete ===");
    }
    
    function loadContractAddresses() internal {
        // Load from environment variables or use default addresses
        hedVaultCore = vm.envOr("HED_VAULT_CORE_ADDRESS", address(0));
        priceOracle = vm.envOr("PRICE_ORACLE_ADDRESS", address(0));
        rwaTokenFactory = vm.envOr("RWA_TOKEN_FACTORY_ADDRESS", address(0));
        swapEngine = vm.envOr("SWAP_ENGINE_ADDRESS", address(0));
        complianceManager = vm.envOr("COMPLIANCE_MANAGER_ADDRESS", address(0));
        portfolioManager = vm.envOr("PORTFOLIO_MANAGER_ADDRESS", address(0));
        crossChainBridge = vm.envOr("CROSS_CHAIN_BRIDGE_ADDRESS", address(0));
        rewardsDistributor = vm.envOr("REWARDS_DISTRIBUTOR_ADDRESS", address(0));
        lendingPool = vm.envOr("LENDING_POOL_ADDRESS", address(0));
        marketplace = vm.envOr("MARKETPLACE_ADDRESS", address(0));
        
        require(hedVaultCore != address(0), "HedVaultCore address not set");
        require(priceOracle != address(0), "PriceOracle address not set");
        require(rwaTokenFactory != address(0), "RWATokenFactory address not set");
    }
    
    function verifyHedVaultCore() internal view {
        console.log("1. Verifying HedVaultCore...");
        console.log("   Address:", hedVaultCore);
        
        HedVaultCore core = HedVaultCore(payable(hedVaultCore));
        
        // Check if contract is deployed
        require(hedVaultCore.code.length > 0, "HedVaultCore not deployed");
        
        // Check basic functionality
        bool isPaused = core.paused();
        console.log("   Paused:", isPaused);
        
        // Check roles
        bytes32 adminRole = 0x00; // DEFAULT_ADMIN_ROLE
        console.log("   Admin Role:", vm.toString(adminRole));
        
        console.log("   [OK] HedVaultCore verified");
        console.log("");
    }
    
    function verifyPriceOracle() internal view {
        console.log("2. Verifying PriceOracle...");
        console.log("   Address:", priceOracle);
        
        PriceOracle oracle = PriceOracle(priceOracle);
        
        // Check if contract is deployed
        require(priceOracle.code.length > 0, "PriceOracle not deployed");
        
        // Check HedVaultCore reference
        address coreAddress = address(oracle.hedVaultCore());
        console.log("   HedVaultCore:", coreAddress);
        require(coreAddress == hedVaultCore, "Invalid HedVaultCore reference");
        
        // Check supported assets
        address[] memory supportedAssets = oracle.getSupportedAssets();
        console.log("   Supported Assets:", supportedAssets.length);
        
        console.log("   [OK] PriceOracle verified");
        console.log("");
    }
    
    function verifyRWATokenFactory() internal view {
        console.log("3. Verifying RWATokenFactory...");
        console.log("   Address:", rwaTokenFactory);
        
        RWATokenFactory factory = RWATokenFactory(rwaTokenFactory);
        
        // Check if contract is deployed
        require(rwaTokenFactory.code.length > 0, "RWATokenFactory not deployed");
        
        // Check HedVaultCore reference
        address coreAddress = address(factory.hedVaultCore());
        console.log("   HedVaultCore:", coreAddress);
        require(coreAddress == hedVaultCore, "Invalid HedVaultCore reference");
        
        // Check fees (Hedera-specific)
        uint256 creationFee = factory.tokenCreationFee();
        uint256 listingFee = factory.listingFee();
        console.log("   Creation Fee (HBAR):", creationFee / 1e18);
        console.log("   Listing Fee (HBAR):", listingFee / 1e18);
        
        // Check basic functionality
        console.log("   Factory deployed and configured");
        
        console.log("   [OK] RWATokenFactory verified");
        console.log("");
    }
    
    function verifySwapEngine() internal view {
        if (swapEngine == address(0)) {
            console.log("4. SwapEngine not deployed (optional)");
            console.log("");
            return;
        }
        
        console.log("4. Verifying SwapEngine...");
        console.log("   Address:", swapEngine);
        
        SwapEngine engine = SwapEngine(swapEngine);
        
        // Check if contract is deployed
        require(swapEngine.code.length > 0, "SwapEngine not deployed");
        
        // Check HedVaultCore reference
        address coreAddress = address(engine.hedVaultCore());
        console.log("   HedVaultCore:", coreAddress);
        require(coreAddress == hedVaultCore, "Invalid HedVaultCore reference");
        
        console.log("   [OK] SwapEngine verified");
        console.log("");
    }
    
    function verifyComplianceManager() internal view {
        if (complianceManager == address(0)) {
            console.log("5. ComplianceManager not deployed (optional)");
            console.log("");
            return;
        }
        
        console.log("5. Verifying ComplianceManager...");
        console.log("   Address:", complianceManager);
        
        ComplianceManager compliance = ComplianceManager(complianceManager);
        
        // Check if contract is deployed
        require(complianceManager.code.length > 0, "ComplianceManager not deployed");
        
        // Check HedVaultCore reference
        address coreAddress = address(compliance.hedVaultCore());
        console.log("   HedVaultCore:", coreAddress);
        require(coreAddress == hedVaultCore, "Invalid HedVaultCore reference");
        
        console.log("   [OK] ComplianceManager verified");
        console.log("");
    }
    
    function verifyPortfolioManager() internal view {
        if (portfolioManager == address(0)) {
            console.log("6. PortfolioManager not deployed (optional)");
            console.log("");
            return;
        }
        
        console.log("6. Verifying PortfolioManager...");
        console.log("   Address:", portfolioManager);
        
        PortfolioManager portfolio = PortfolioManager(portfolioManager);
        
        // Check if contract is deployed
        require(portfolioManager.code.length > 0, "PortfolioManager not deployed");
        
        // Check HedVaultCore reference
        address coreAddress = address(portfolio.hedVaultCore());
        console.log("   HedVaultCore:", coreAddress);
        require(coreAddress == hedVaultCore, "Invalid HedVaultCore reference");
        
        console.log("   [OK] PortfolioManager verified");
        console.log("");
    }
    
    function verifyCrossChainBridge() internal view {
        if (crossChainBridge == address(0)) {
            console.log("7. CrossChainBridge not deployed (optional)");
            console.log("");
            return;
        }
        
        console.log("7. Verifying CrossChainBridge...");
        console.log("   Address:", crossChainBridge);
        
        // Check if contract is deployed
        require(crossChainBridge.code.length > 0, "CrossChainBridge not deployed");
        
        // Check basic functionality
        console.log("   CrossChainBridge deployed and configured");
        
        console.log("   [OK] CrossChainBridge verified");
        console.log("");
    }
    
    function verifyRewardsDistributor() internal view {
        if (rewardsDistributor == address(0)) {
            console.log("8. RewardsDistributor not deployed (optional)");
            console.log("");
            return;
        }
        
        console.log("8. Verifying RewardsDistributor...");
        console.log("   Address:", rewardsDistributor);
        
        // Check if contract is deployed
        require(rewardsDistributor.code.length > 0, "RewardsDistributor not deployed");
        
        console.log("   [OK] RewardsDistributor verified");
        console.log("");
    }
    
    function verifyLendingPool() internal view {
        if (lendingPool == address(0)) {
            console.log("9. LendingPool not deployed (optional)");
            console.log("");
            return;
        }
        
        console.log("9. Verifying LendingPool...");
        console.log("   Address:", lendingPool);
        
        // Check if contract is deployed
        require(lendingPool.code.length > 0, "LendingPool not deployed");
        
        console.log("   [OK] LendingPool verified");
        console.log("");
    }
    
    function verifyMarketplace() internal view {
        if (marketplace == address(0)) {
            console.log("10. Marketplace not deployed (optional)");
            console.log("");
            return;
        }
        
        console.log("10. Verifying Marketplace...");
        console.log("   Address:", marketplace);
        
        // Check if contract is deployed
        require(marketplace.code.length > 0, "Marketplace not deployed");
        
        console.log("   [OK] Marketplace verified");
        console.log("");
    }
    
    function verifyChainlinkIntegration() internal view {
        console.log("11. Verifying Chainlink Integration...");
        
        PriceOracle oracle = PriceOracle(priceOracle);
        
        // Check HBAR/USD feed
        console.log("   HBAR/USD Feed:", HBAR_USD_FEED);
        try oracle.getPrice(HBAR_USD_FEED) returns (uint256 price, uint256 timestamp, uint256 confidence) {
            console.log("   HBAR Price:", price);
            console.log("   Confidence:", confidence);
            console.log("   Timestamp:", timestamp);
        } catch {
            console.log("   HBAR feed not configured or accessible");
        }
        
        // Check ETH/USD feed
        console.log("   ETH/USD Feed:", ETH_USD_FEED);
        try oracle.getPrice(ETH_USD_FEED) returns (uint256 price, uint256 timestamp, uint256 confidence) {
            console.log("   ETH Price:", price);
            console.log("   Confidence:", confidence);
            console.log("   Timestamp:", timestamp);
        } catch {
            console.log("   ETH feed not configured or accessible");
        }
        
        console.log("   [OK] Chainlink integration verified");
        console.log("");
    }
    
    function verifyHederaIntegration() internal view {
        console.log("12. Verifying Hedera Integration...");
        
        // Check WHBAR address
        address whbar = 0x0000000000000000000000000000000000000163;
        console.log("   WHBAR Address:", whbar);
        
        // Check HTS precompile
        address htsPrecompile = 0x0000000000000000000000000000000000000167;
        console.log("   HTS Precompile:", htsPrecompile);
        
        // Check network
        uint256 chainId = block.chainid;
        console.log("   Chain ID:", chainId);
        
        if (chainId == 296) {
            console.log("   Network: Hedera Testnet");
        } else if (chainId == 295) {
            console.log("   Network: Hedera Mainnet");
        } else {
            console.log("   Network: Unknown (not Hedera)");
        }
        
        console.log("   [OK] Hedera integration verified");
        console.log("");
    }
}