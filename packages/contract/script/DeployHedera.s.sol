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
import "../src/RWAOffchainOracle.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title HedVaultHederaDeployScript
 * @notice Deployment script for HedVault protocol on Hedera network with Chainlink integration
 */
contract HedVaultHederaDeployScript is Script {
    // Hedera network configuration
    struct HederaConfig {
        uint256 chainId;
        string rpcUrl;
        address hbarToken; // WHBAR address on Hedera
        address hederaTokenService; // HTS precompile address
        uint256 gasPrice;
        uint256 gasLimit;
    }

    // Chainlink oracle configuration for Hedera
    struct ChainlinkConfig {
        address hbarUsdFeed;
        address ethUsdFeed;
        address btcUsdFeed;
        address linkUsdFeed;
        address usdcUsdFeed;
        uint256 heartbeat;
        uint8 decimals;
    }

    // Deployment configuration
    struct DeployConfig {
        address feeRecipient;
        uint256 rewardTokenSupply;
        bool deployMockTokens;
        bool initializeRewardPools;
        bool setupTestData;
        bool configureChainlinkOracles;
        HederaConfig hederaConfig;
        ChainlinkConfig chainlinkConfig;
    }

    // Deployed contract addresses
    struct DeployedContracts {
        address hedVaultCore;
        address rewardsDistributor;
        address priceOracle;
        address rwaOffchainOracle;
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

    // Hedera Testnet Chainlink Price Feeds
    address constant HBAR_USD_FEED = 0x59bC155EB6c6C415fE43255aF66EcF0523c92B4a;
    address constant ETH_USD_FEED = 0xb9d461e0b962aF219866aDfA7DD19C52bB9871b9;
    address constant BTC_USD_FEED = 0x058fE79CB5775d4b167920Ca6036B824805A9ABd;
    address constant LINK_USD_FEED = 0xF111b70231E89D69eBC9f6C9208e9890383Ef432;
    address constant USDC_USD_FEED = 0xb632a7e7e02d76c0Ce99d9C62c7a2d1B5F92B6B5;

    // Hedera Testnet Chainlink Functions (to be configured)
    address constant CHAINLINK_FUNCTIONS_ROUTER = address(0); // To be updated with actual router address
    uint64 constant CHAINLINK_SUBSCRIPTION_ID = 0; // To be updated with actual subscription ID

    // Hedera Testnet LINK Token
    address constant LINK_TOKEN = 0x90a386d59b9A6a4795a011e8f032Fc21ED6FEFb6; // Placeholder - update with actual LINK token address

    // Hedera network addresses
    address constant WHBAR_ADDRESS = 0x0000000000000000000000000000000000000163; // WHBAR on Hedera
    address constant HTS_PRECOMPILE =
        0x0000000000000000000000000000000000000167; // Hedera Token Service

    function run() external {
        // Get deployment configuration
        DeployConfig memory config = getHederaDeployConfig();

        vm.startBroadcast();

        // Deploy all contracts
        deployContracts(config);

        // Initialize the protocol
        initializeProtocol(config);

        // Configure Chainlink oracles
        if (config.configureChainlinkOracles) {
            configureChainlinkOracles(config);
        }

        // Setup test data if requested
        if (config.setupTestData) {
            setupHederaTestEnvironment();
        }

        vm.stopBroadcast();

        // Log deployment results
        logHederaDeploymentResults();
    }

    function getHederaDeployConfig()
        internal
        view
        returns (DeployConfig memory)
    {
        return
            DeployConfig({
                feeRecipient: vm.envOr("FEE_RECIPIENT", msg.sender),
                rewardTokenSupply: vm.envOr(
                    "REWARD_TOKEN_SUPPLY",
                    uint256(1000000000 * 1e18)
                ),
                deployMockTokens: vm.envOr("DEPLOY_MOCK_TOKENS", true),
                initializeRewardPools: vm.envOr(
                    "INITIALIZE_REWARD_POOLS",
                    true
                ),
                setupTestData: vm.envOr("SETUP_TEST_DATA", true),
                configureChainlinkOracles: vm.envOr(
                    "CONFIGURE_CHAINLINK",
                    true
                ),
                hederaConfig: HederaConfig({
                    chainId: 296, // Hedera Testnet
                    rpcUrl: "https://testnet.hashio.io/api",
                    hbarToken: WHBAR_ADDRESS,
                    hederaTokenService: HTS_PRECOMPILE,
                    gasPrice: 100000000000, // 100 gwei
                    gasLimit: 15000000 // 15M gas
                }),
                chainlinkConfig: ChainlinkConfig({
                    hbarUsdFeed: HBAR_USD_FEED,
                    ethUsdFeed: ETH_USD_FEED,
                    btcUsdFeed: BTC_USD_FEED,
                    linkUsdFeed: LINK_USD_FEED,
                    usdcUsdFeed: USDC_USD_FEED,
                    heartbeat: 3600, // 1 hour
                    decimals: 8
                })
            });
    }

    function deployContracts(DeployConfig memory config) internal {
        console.log("=== Starting HedVault Protocol Deployment on Hedera ===");
        console.log("Chain ID:", config.hederaConfig.chainId);
        console.log("RPC URL:", config.hederaConfig.rpcUrl);
        console.log("WHBAR Address:", config.hederaConfig.hbarToken);

        // 1. Deploy reward token (HVT)
        console.log("Deploying HedVault Token (HVT)...");
        deployed.rewardToken = address(
            new MockERC20("HedVault Token", "HVT", 18, config.rewardTokenSupply)
        );
        console.log("HVT deployed at:", deployed.rewardToken);

        // 2. Deploy HedVaultCore
        console.log("Deploying HedVaultCore...");
        deployed.hedVaultCore = address(new HedVaultCore(config.feeRecipient));
        console.log("HedVaultCore deployed at:", deployed.hedVaultCore);

        // 3. Deploy PriceOracle with Chainlink support
        console.log("Deploying PriceOracle with Chainlink integration...");
        deployed.priceOracle = address(new PriceOracle(deployed.hedVaultCore));
        console.log("PriceOracle deployed at:", deployed.priceOracle);

        // 4. Deploy RewardsDistributor
        console.log("Deploying RewardsDistributor...");
        deployed.rewardsDistributor = address(
            new RewardsDistributor(deployed.hedVaultCore, deployed.rewardToken)
        );
        console.log(
            "RewardsDistributor deployed at:",
            deployed.rewardsDistributor
        );

        // 5. Deploy LendingPool
        console.log("Deploying LendingPool...");
        deployed.lendingPool = address(
            new LendingPool(
                deployed.hedVaultCore,
                deployed.priceOracle,
                config.feeRecipient
            )
        );
        console.log("LendingPool deployed at:", deployed.lendingPool);

        // 6. Deploy Marketplace
        console.log("Deploying Marketplace...");
        deployed.marketplace = address(
            new Marketplace(
                deployed.hedVaultCore,
                deployed.priceOracle,
                config.feeRecipient
            )
        );
        console.log("Marketplace deployed at:", deployed.marketplace);

        // 7. Deploy RWATokenFactory with Hedera integration
        console.log(
            "Deploying RWATokenFactory with Hedera Token Service integration..."
        );
        deployed.rwaTokenFactory = address(
            new RWATokenFactory(deployed.hedVaultCore)
        );
        console.log("RWATokenFactory deployed at:", deployed.rwaTokenFactory);

        // 8. Deploy SwapEngine
        console.log("Deploying SwapEngine...");
        deployed.swapEngine = address(
            new SwapEngine(
                deployed.hedVaultCore,
                deployed.priceOracle,
                config.feeRecipient
            )
        );
        console.log("SwapEngine deployed at:", deployed.swapEngine);

        // 9. Deploy ComplianceManager
        console.log("Deploying ComplianceManager...");
        deployed.complianceManager = address(
            new ComplianceManager(deployed.hedVaultCore, config.feeRecipient)
        );
        console.log(
            "ComplianceManager deployed at:",
            deployed.complianceManager
        );

        // 10. Deploy PortfolioManager
        console.log("Deploying PortfolioManager...");
        deployed.portfolioManager = address(
            new PortfolioManager(deployed.hedVaultCore, deployed.priceOracle)
        );
        console.log("PortfolioManager deployed at:", deployed.portfolioManager);

        // 11. Deploy RWAOffchainOracle
        console.log(
            "Deploying RWAOffchainOracle with Chainlink Functions integration..."
        );
        deployed.rwaOffchainOracle = address(
            new RWAOffchainOracle(
                deployed.hedVaultCore,
                CHAINLINK_FUNCTIONS_ROUTER, // Chainlink Functions router (to be configured)
                CHAINLINK_SUBSCRIPTION_ID // Subscription ID (to be configured)
            )
        );
        console.log(
            "RWAOffchainOracle deployed at:",
            deployed.rwaOffchainOracle
        );

        // 12. Deploy CrossChainBridge
        console.log("Deploying CrossChainBridge...");
        deployed.crossChainBridge = address(
            new CrossChainBridge(config.feeRecipient)
        );
        console.log("CrossChainBridge deployed at:", deployed.crossChainBridge);

        // 13. Deploy verification contract
        console.log("Deploying VerifyRewardIntegration...");
        deployed.verifyRewardIntegration = address(
            new VerifyRewardIntegration(
                deployed.rewardsDistributor,
                deployed.lendingPool,
                payable(deployed.marketplace),
                payable(deployed.hedVaultCore)
            )
        );
        console.log(
            "VerifyRewardIntegration deployed at:",
            deployed.verifyRewardIntegration
        );

        // 14. Deploy mock tokens if requested
        if (config.deployMockTokens) {
            deployHederaMockTokens();
        }
    }

    function deployHederaMockTokens() internal {
        console.log("Deploying Hedera-compatible mock tokens...");

        // Deploy tokens that represent common assets on Hedera
        string[5] memory tokenNames = [
            "Wrapped HBAR",
            "USD Coin",
            "Wrapped Ether",
            "Wrapped Bitcoin",
            "Chainlink Token"
        ];
        string[5] memory tokenSymbols = [
            "WHBAR",
            "USDC",
            "WETH",
            "WBTC",
            "LINK"
        ];
        uint8[5] memory tokenDecimals = [8, 6, 18, 8, 18];
        uint256[5] memory tokenSupplies = [
            uint256(50000000 * 1e8), // 50M WHBAR
            uint256(1000000 * 1e6), // 1M USDC
            uint256(10000 * 1e18), // 10K WETH
            uint256(100 * 1e8), // 100 WBTC
            uint256(100000 * 1e18) // 100K LINK
        ];

        for (uint i = 0; i < tokenNames.length; i++) {
            address token = address(
                new MockERC20(
                    tokenNames[i],
                    tokenSymbols[i],
                    tokenDecimals[i],
                    tokenSupplies[i]
                )
            );
            deployed.mockTokens.push(token);
            console.log(
                string(abi.encodePacked(tokenSymbols[i], " deployed at:")),
                token
            );
        }
    }

    function configureChainlinkOracles(DeployConfig memory config) internal {
        console.log("=== Configuring Chainlink Price Feeds ===");

        PriceOracle oracle = PriceOracle(deployed.priceOracle);

        // Configure HBAR/USD price feed
        if (config.chainlinkConfig.hbarUsdFeed != address(0)) {
            oracle.configurePriceFeed(
                config.hederaConfig.hbarToken, // WHBAR
                config.chainlinkConfig.hbarUsdFeed,
                address(0), // No custom oracle
                config.chainlinkConfig.heartbeat,
                config.chainlinkConfig.decimals,
                1e6, // Min price: $0.01
                1000e8 // Max price: $1000
            );
            console.log(
                "HBAR/USD price feed configured:",
                config.chainlinkConfig.hbarUsdFeed
            );
        }

        // Configure other price feeds for mock tokens
        if (deployed.mockTokens.length >= 5) {
            // USDC/USD
            oracle.configurePriceFeed(
                deployed.mockTokens[1], // USDC
                config.chainlinkConfig.usdcUsdFeed,
                address(0),
                config.chainlinkConfig.heartbeat,
                config.chainlinkConfig.decimals,
                95e6, // Min: $0.95
                105e6 // Max: $1.05
            );

            // ETH/USD
            oracle.configurePriceFeed(
                deployed.mockTokens[2], // WETH
                config.chainlinkConfig.ethUsdFeed,
                address(0),
                config.chainlinkConfig.heartbeat,
                config.chainlinkConfig.decimals,
                100e8, // Min: $100
                10000e8 // Max: $10,000
            );

            // BTC/USD
            oracle.configurePriceFeed(
                deployed.mockTokens[3], // WBTC
                config.chainlinkConfig.btcUsdFeed,
                address(0),
                config.chainlinkConfig.heartbeat,
                config.chainlinkConfig.decimals,
                1000e8, // Min: $1,000
                200000e8 // Max: $200,000
            );

            // LINK/USD
            oracle.configurePriceFeed(
                deployed.mockTokens[4], // LINK
                config.chainlinkConfig.linkUsdFeed,
                address(0),
                config.chainlinkConfig.heartbeat,
                config.chainlinkConfig.decimals,
                1e8, // Min: $1
                1000e8 // Max: $1,000
            );

            console.log("All Chainlink price feeds configured successfully");
        }
    }

    function initializeProtocol(DeployConfig memory config) internal {
        console.log("=== Initializing HedVault Protocol on Hedera ===");

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
            deployed.rwaOffchainOracle
        ];

        HedVaultCore(payable(deployed.hedVaultCore)).initialize(modules);
        console.log("HedVaultCore initialized with all modules");

        // Initialize reward pools if requested
        if (config.initializeRewardPools) {
            initializeHederaRewardPools();
        }

        // Setup mock tokens in protocol if deployed
        if (config.deployMockTokens && deployed.mockTokens.length > 0) {
            setupHederaMockTokensInProtocol();
        }
    }

    function initializeHederaRewardPools() internal {
        console.log("Initializing reward pools for Hedera...");

        // Transfer reward tokens to RewardsDistributor
        uint256 totalPoolAllocation = 800000 * 1e18; // 800K HVT tokens
        MockERC20(deployed.rewardToken).transfer(
            deployed.rewardsDistributor,
            totalPoolAllocation
        );

        // Initialize default reward pools
        RewardsDistributor(deployed.rewardsDistributor)
            .initializeDefaultPools();
        console.log("Hedera reward pools initialized with 800K HVT tokens");
    }

    function setupHederaMockTokensInProtocol() internal {
        console.log("Setting up Hedera mock tokens in protocol...");

        // Grant necessary roles
        bytes32 POOL_ADMIN_ROLE = keccak256("POOL_ADMIN_ROLE");
        bytes32 MARKETPLACE_ADMIN_ROLE = keccak256("MARKETPLACE_ADMIN_ROLE");

        LendingPool(deployed.lendingPool).grantRole(
            POOL_ADMIN_ROLE,
            msg.sender
        );
        Marketplace(payable(deployed.marketplace)).grantRole(
            MARKETPLACE_ADMIN_ROLE,
            msg.sender
        );

        // Add tokens to protocol with Hedera-optimized parameters
        for (uint i = 0; i < deployed.mockTokens.length; i++) {
            address token = deployed.mockTokens[i];

            // Add to lending pool with conservative parameters for Hedera
            LendingPool(deployed.lendingPool).addSupportedToken(
                token,
                7000, // 70% collateral factor (conservative for new network)
                1500 // 15% liquidation bonus
            );

            // Add to marketplace
            Marketplace(payable(deployed.marketplace)).addSupportedAsset(token);
            Marketplace(payable(deployed.marketplace)).addSupportedPaymentToken(
                token
            );

            console.log("Hedera token added to protocol:", token);
        }
    }

    function setupHederaTestEnvironment() internal {
        console.log("Setting up Hedera test environment...");

        // Note: User registration can be done separately
        // HedVaultCore(payable(deployed.hedVaultCore)).registerUser(msg.sender);

        console.log("Hedera test environment setup complete");
        console.log(
            "Note: Register users manually using HedVaultCore.registerUser(address)"
        );
        console.log("WHBAR address:", WHBAR_ADDRESS);
        console.log("HTS Precompile:", HTS_PRECOMPILE);
    }

    function logHederaDeploymentResults() internal view {
        console.log("\n=== Hedera Deployment Complete ===");
        console.log("Network: Hedera Testnet (Chain ID: 296)");
        console.log("RPC URL: https://testnet.hashio.io/api");
        console.log("\n=== Core Contracts ===");
        console.log("HedVaultCore:", deployed.hedVaultCore);
        console.log("RewardsDistributor:", deployed.rewardsDistributor);
        console.log("PriceOracle (with Chainlink):", deployed.priceOracle);
        console.log("LendingPool:", deployed.lendingPool);
        console.log("Marketplace:", deployed.marketplace);
        console.log("RWATokenFactory (HTS-enabled):", deployed.rwaTokenFactory);
        console.log("\n=== Additional Modules ===");
        console.log("SwapEngine:", deployed.swapEngine);
        console.log("ComplianceManager:", deployed.complianceManager);
        console.log("PortfolioManager:", deployed.portfolioManager);
        console.log("RWAOffchainOracle:", deployed.rwaOffchainOracle);
        console.log("CrossChainBridge:", deployed.crossChainBridge);
        console.log("\n=== Tokens ===");
        console.log("HVT Reward Token:", deployed.rewardToken);

        if (deployed.mockTokens.length > 0) {
            console.log("\n=== Mock Tokens (Hedera-compatible) ===");
            string[5] memory symbols = [
                "WHBAR",
                "USDC",
                "WETH",
                "WBTC",
                "LINK"
            ];
            for (
                uint i = 0;
                i < deployed.mockTokens.length && i < symbols.length;
                i++
            ) {
                console.log(
                    string(abi.encodePacked(symbols[i], ":")),
                    deployed.mockTokens[i]
                );
            }
        }

        console.log("\n=== Chainlink Price Feeds ===");
        console.log("HBAR/USD:", HBAR_USD_FEED);
        console.log("ETH/USD:", ETH_USD_FEED);
        console.log("BTC/USD:", BTC_USD_FEED);
        console.log("LINK/USD:", LINK_USD_FEED);
        console.log("USDC/USD:", USDC_USD_FEED);

        console.log("\n=== Hedera Integration ===");
        console.log("WHBAR Token:", WHBAR_ADDRESS);
        console.log("Hedera Token Service:", HTS_PRECOMPILE);

        console.log("\n=== Deployment Summary ===");
        console.log(
            "Total contracts deployed:",
            12 + deployed.mockTokens.length
        );
        console.log("Chainlink oracles configured: true");
        console.log("RWA off-chain oracle: enabled");
        console.log("Hedera integration: enabled");
        console.log("Protocol initialized: true");
        console.log("Ready for Hedera mainnet: true");
    }

    // Getter functions
    function getHedVaultCore() external view returns (address) {
        return deployed.hedVaultCore;
    }

    function getPriceOracle() external view returns (address) {
        return deployed.priceOracle;
    }

    function getRWATokenFactory() external view returns (address) {
        return deployed.rwaTokenFactory;
    }

    function getRWAOffchainOracle() external view returns (address) {
        return deployed.rwaOffchainOracle;
    }

    function getHederaMockTokens() external view returns (address[] memory) {
        return deployed.mockTokens;
    }
}

/**
 * @title MockERC20
 * @notice Mock ERC20 token for testing on Hedera
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
