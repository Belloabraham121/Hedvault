// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/HedVaultCore.sol";
import "../src/RewardsDistributor.sol";
import "../src/PriceOracle.sol";
import "../src/LendingPool.sol";
import "../src/Marketplace.sol";
import "../src/VerifyRewardIntegration.sol";
import "../src/RWATokenFactory.sol";
import "../src/SwapEngine.sol";
import "../src/ComplianceManager.sol";
import "../src/PortfolioManager.sol";
import "../src/CrossChainBridge.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title MockERC20
 * @notice Mock ERC20 token for testing purposes
 */
contract MockERC20 is ERC20 {
    uint8 private _decimals;
    
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals_,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _decimals = decimals_;
        _mint(msg.sender, initialSupply);
    }
    
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
    
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

/**
 * @title HedVaultDeployScript
 * @notice Deployment script for the complete HedVault protocol
 */
contract HedVaultDeployScript is Script {
    // Deployment configuration
    struct DeployConfig {
        address feeRecipient;
        uint256 rewardTokenSupply;
        bool deployMockTokens;
        bool initializeRewardPools;
        bool setupTestData;
    }
    
    // Deployed contract addresses
    struct DeployedContracts {
        address hedVaultCore;
        address rewardsDistributor;
        address priceOracle;
        address lendingPool;
        address marketplace;
        address rewardToken;
        address verifyRewardIntegration;
        address rwaTokenFactory;
        address swapEngine;
        address complianceManager;
        address portfolioManager;
        address crossChainBridge;
        address[] mockTokens;
    }
    
    DeployedContracts public deployed;
    
    function run() external {
        // Get deployment configuration
        DeployConfig memory config = getDeployConfig();
        
        vm.startBroadcast();
        
        // Deploy all contracts
        deployContracts(config);
        
        // Initialize the protocol
        initializeProtocol(config);
        
        // Setup test data if requested
        if (config.setupTestData) {
            setupTestEnvironment();
        }
        
        vm.stopBroadcast();
        
        // Log deployment results
        logDeploymentResults();
    }
    
    function getDeployConfig() internal view returns (DeployConfig memory) {
        return DeployConfig({
            feeRecipient: vm.envOr("FEE_RECIPIENT", msg.sender),
            rewardTokenSupply: vm.envOr("REWARD_TOKEN_SUPPLY", uint256(1000000000 * 1e18)), // 1B tokens
            deployMockTokens: vm.envOr("DEPLOY_MOCK_TOKENS", true),
            initializeRewardPools: vm.envOr("INITIALIZE_REWARD_POOLS", true),
            setupTestData: vm.envOr("SETUP_TEST_DATA", true)
        });
    }
    
    function deployContracts(DeployConfig memory config) internal {
        console.log("=== Starting HedVault Protocol Deployment ===");
        
        // 1. Deploy reward token first
        console.log("Deploying reward token...");
        deployed.rewardToken = address(new MockERC20(
            "HedVault Token",
            "HVT",
            18,
            config.rewardTokenSupply
        ));
        console.log("Reward Token deployed at:", deployed.rewardToken);
        
        // 2. Deploy HedVaultCore
        console.log("Deploying HedVaultCore...");
        deployed.hedVaultCore = address(new HedVaultCore(config.feeRecipient));
        console.log("HedVaultCore deployed at:", deployed.hedVaultCore);
        
        // 3. Deploy RewardsDistributor
        console.log("Deploying RewardsDistributor...");
        deployed.rewardsDistributor = address(new RewardsDistributor(
            deployed.hedVaultCore,
            deployed.rewardToken
        ));
        console.log("RewardsDistributor deployed at:", deployed.rewardsDistributor);
        
        // 4. Deploy PriceOracle
        console.log("Deploying PriceOracle...");
        deployed.priceOracle = address(new PriceOracle(deployed.hedVaultCore));
        console.log("PriceOracle deployed at:", deployed.priceOracle);
        
        // 5. Deploy LendingPool
        console.log("Deploying LendingPool...");
        deployed.lendingPool = address(new LendingPool(
            deployed.hedVaultCore,
            deployed.priceOracle,
            config.feeRecipient
        ));
        console.log("LendingPool deployed at:", deployed.lendingPool);
        
        // 6. Deploy Marketplace
        console.log("Deploying Marketplace...");
        deployed.marketplace = address(new Marketplace(
            deployed.hedVaultCore,
            deployed.priceOracle,
            config.feeRecipient
        ));
        console.log("Marketplace deployed at:", deployed.marketplace);
        
        // 7. Deploy mock tokens if requested
        if (config.deployMockTokens) {
            deployMockTokens();
        }
        
        // 8. Deploy additional modules
         console.log("Deploying RWATokenFactory...");
         RWATokenFactory rwaTokenFactory = new RWATokenFactory(deployed.hedVaultCore);
         deployed.rwaTokenFactory = address(rwaTokenFactory);
         
         console.log("Deploying SwapEngine...");
         SwapEngine swapEngine = new SwapEngine(
             deployed.hedVaultCore,
             deployed.priceOracle,
             config.feeRecipient
         );
         deployed.swapEngine = address(swapEngine);
         
         console.log("Deploying ComplianceManager...");
         ComplianceManager complianceManager = new ComplianceManager(
             deployed.hedVaultCore,
             config.feeRecipient
         );
         deployed.complianceManager = address(complianceManager);
         
         console.log("Deploying PortfolioManager...");
         PortfolioManager portfolioManager = new PortfolioManager(
             deployed.hedVaultCore,
             deployed.priceOracle
         );
         deployed.portfolioManager = address(portfolioManager);
         
         console.log("Deploying CrossChainBridge...");
         CrossChainBridge crossChainBridge = new CrossChainBridge(config.feeRecipient);
         deployed.crossChainBridge = address(crossChainBridge);
        
        // 9. Deploy verification contract
        console.log("Deploying VerifyRewardIntegration...");
        deployed.verifyRewardIntegration = address(new VerifyRewardIntegration(
            deployed.rewardsDistributor,
            deployed.lendingPool,
            payable(deployed.marketplace),
            payable(deployed.hedVaultCore)
        ));
        console.log("VerifyRewardIntegration deployed at:", deployed.verifyRewardIntegration);
    }
    
    function deployMockTokens() internal {
        console.log("Deploying mock tokens...");
        
        // Deploy common test tokens
        string[4] memory tokenNames = ["USD Coin", "Wrapped Ether", "Wrapped Bitcoin", "Dai Stablecoin"];
        string[4] memory tokenSymbols = ["USDC", "WETH", "WBTC", "DAI"];
        uint8[4] memory tokenDecimals = [6, 18, 8, 18];
        uint256[4] memory tokenSupplies = [
            uint256(1000000 * 1e6),  // 1M USDC
            uint256(10000 * 1e18),   // 10K WETH
            uint256(100 * 1e8),      // 100 WBTC
            uint256(1000000 * 1e18)  // 1M DAI
        ];
        
        for (uint i = 0; i < tokenNames.length; i++) {
            address token = address(new MockERC20(
                tokenNames[i],
                tokenSymbols[i],
                tokenDecimals[i],
                tokenSupplies[i]
            ));
            deployed.mockTokens.push(token);
            console.log(string(abi.encodePacked(tokenSymbols[i], " deployed at:")), token);
        }
    }
    
    function initializeProtocol(DeployConfig memory config) internal {
        console.log("=== Initializing Protocol ===");
        
        // Initialize HedVaultCore with module addresses
        address[10] memory modules = [
            deployed.rwaTokenFactory,
            deployed.marketplace,
            deployed.swapEngine,
            deployed.lendingPool,
            deployed.rewardsDistributor,
            deployed.priceOracle,
            deployed.complianceManager,
            deployed.portfolioManager,
            deployed.crossChainBridge,
            address(this)  // analyticsEngine - not implemented yet
        ];
        
        HedVaultCore(payable(deployed.hedVaultCore)).initialize(modules);
        console.log("HedVaultCore initialized with modules");
        
        // Initialize reward pools if requested
        if (config.initializeRewardPools) {
            initializeRewardPools();
        }
        
        // Setup mock tokens in protocol if deployed
        if (config.deployMockTokens && deployed.mockTokens.length > 0) {
            setupMockTokensInProtocol();
        }
    }
    
    function initializeRewardPools() internal {
        console.log("Initializing reward pools...");
        
        // Transfer reward tokens to RewardsDistributor for pool initialization
        uint256 totalPoolAllocation = 800000 * 1e18; // 800K tokens for pools
        MockERC20(deployed.rewardToken).transfer(deployed.rewardsDistributor, totalPoolAllocation);
        
        // Initialize default reward pools
        RewardsDistributor(deployed.rewardsDistributor).initializeDefaultPools();
        console.log("Default reward pools initialized");
    }
    
    function setupMockTokensInProtocol() internal {
        console.log("Setting up mock tokens in protocol...");
        
        // Grant necessary roles to deployer for setup
        bytes32 POOL_ADMIN_ROLE = keccak256("POOL_ADMIN_ROLE");
        bytes32 MARKETPLACE_ADMIN_ROLE = keccak256("MARKETPLACE_ADMIN_ROLE");
        
        LendingPool(deployed.lendingPool).grantRole(POOL_ADMIN_ROLE, msg.sender);
        Marketplace(payable(deployed.marketplace)).grantRole(MARKETPLACE_ADMIN_ROLE, msg.sender);
        
        // Add tokens to LendingPool
        for (uint i = 0; i < deployed.mockTokens.length; i++) {
            address token = deployed.mockTokens[i];
            
            // Add token to lending pool with reasonable parameters
            LendingPool(deployed.lendingPool).addSupportedToken(
                token,
                7500, // 75% collateral factor
                1000  // 10% liquidation bonus
            );
            
            // Add token to marketplace as supported asset
            Marketplace(payable(deployed.marketplace)).addSupportedAsset(token);
            
            // Add token as supported payment token
            Marketplace(payable(deployed.marketplace)).addSupportedPaymentToken(token);
            
            console.log("Token added to protocol:", token);
        }
    }
    
    function setupTestEnvironment() internal {
        console.log("Setting up test environment...");
        
        // Note: User registration can be done separately after deployment
        // HedVaultCore(payable(deployed.hedVaultCore)).registerUser(msg.sender);
        
        // Distribute some mock tokens to deployer for testing
        if (deployed.mockTokens.length > 0) {
            for (uint i = 0; i < deployed.mockTokens.length; i++) {
                // Tokens are already minted to deployer in constructor
                console.log("Mock tokens available for testing:", deployed.mockTokens[i]);
            }
        }
        
        console.log("Test environment setup complete");
        console.log("Note: Register users manually using HedVaultCore.registerUser(address)");
    }
    
    function logDeploymentResults() internal view {
        console.log("\n=== Deployment Complete ===");
        console.log("HedVaultCore:", deployed.hedVaultCore);
        console.log("RewardsDistributor:", deployed.rewardsDistributor);
        console.log("PriceOracle:", deployed.priceOracle);
        console.log("LendingPool:", deployed.lendingPool);
        console.log("Marketplace:", deployed.marketplace);
        console.log("Reward Token:", deployed.rewardToken);
        console.log("VerifyRewardIntegration:", deployed.verifyRewardIntegration);
        
        if (deployed.mockTokens.length > 0) {
            console.log("\nMock Tokens:");
            for (uint i = 0; i < deployed.mockTokens.length; i++) {
                console.log("Token", i, ":", deployed.mockTokens[i]);
            }
        }
        
        console.log("\n=== Deployment Summary ===");
        console.log("Total contracts deployed:", 6 + deployed.mockTokens.length + 1); // +1 for verification
        console.log("Protocol initialized: true");
        console.log("Ready for testing: true");
    }
    
    // Getter functions for deployed addresses
    function getHedVaultCore() external view returns (address) {
        return deployed.hedVaultCore;
    }
    
    function getRewardsDistributor() external view returns (address) {
        return deployed.rewardsDistributor;
    }
    
    function getPriceOracle() external view returns (address) {
        return deployed.priceOracle;
    }
    
    function getLendingPool() external view returns (address) {
        return deployed.lendingPool;
    }
    
    function getMarketplace() external view returns (address) {
        return deployed.marketplace;
    }
    
    function getRewardToken() external view returns (address) {
        return deployed.rewardToken;
    }
    
    function getVerifyRewardIntegration() external view returns (address) {
        return deployed.verifyRewardIntegration;
    }
    
    function getMockTokens() external view returns (address[] memory) {
        return deployed.mockTokens;
    }
}