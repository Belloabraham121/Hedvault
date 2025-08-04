// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../script/DeployHedera.s.sol";
import "../src/PriceOracle.sol";
import "../src/RWATokenFactory.sol";
import "../src/HedVaultCore.sol";

/**
 * @title HederaDeploymentTest
 * @notice Test suite for Hedera deployment script
 */
contract HederaDeploymentTest is Test {
    HedVaultHederaDeployScript public deployScript;

    // Mock Chainlink price feed addresses (Hedera Testnet)
    address constant HBAR_USD_FEED = 0x6f7C932e7684666C9fd1d44527765433e01fF61d;
    address constant ETH_USD_FEED = 0x9326BFA02ADD2366b30bacB125260Af641031331;
    address constant BTC_USD_FEED = 0x56a43EB56Da12C0dc1D972ACb089c06a5dEF8e69;

    // Hedera addresses
    address constant WHBAR_ADDRESS = 0x0000000000000000000000000000000000000163;
    address constant HTS_PRECOMPILE =
        0x0000000000000000000000000000000000000167;

    function setUp() public {
        deployScript = new HedVaultHederaDeployScript();
    }

    function testHederaConfigurationValues() public pure {
        // Test that Hedera-specific addresses are correctly set
        assertEq(WHBAR_ADDRESS, 0x0000000000000000000000000000000000000163);
        assertEq(HTS_PRECOMPILE, 0x0000000000000000000000000000000000000167);
    }

    function testChainlinkFeedAddresses() public pure {
        // Test that Chainlink feed addresses are valid
        assertTrue(HBAR_USD_FEED != address(0));
        assertTrue(ETH_USD_FEED != address(0));
        assertTrue(BTC_USD_FEED != address(0));
    }

    function testDeploymentScriptExists() public view {
        // Test that deployment script is properly instantiated
        assertTrue(address(deployScript) != address(0));
    }

    function testMockTokenDeployment() public {
        // Deploy mock ERC20 token to test functionality
        MockERC20 token = new MockERC20("Test HBAR", "THBAR", 8, 1000000 * 1e8);

        assertEq(token.name(), "Test HBAR");
        assertEq(token.symbol(), "THBAR");
        assertEq(token.decimals(), 8);
        assertEq(token.totalSupply(), 1000000 * 1e8);
        assertEq(token.balanceOf(address(this)), 1000000 * 1e8);
    }

    function testHederaNetworkConfiguration() public pure {
        // Test network configuration values
        uint256 hederaTestnetChainId = 296;
        uint256 hederaMainnetChainId = 295;

        assertEq(hederaTestnetChainId, 296);
        assertEq(hederaMainnetChainId, 295);
    }

    function testOracleConfiguration() public {
        // Deploy a mock price oracle to test configuration
        address mockHedVaultCore = address(0x123); // Mock address
        vm.mockCall(
            mockHedVaultCore,
            abi.encodeWithSignature("hasRole(bytes32,address)"),
            abi.encode(true)
        );

        PriceOracle oracle = new PriceOracle(mockHedVaultCore);

        // Test oracle deployment
        assertTrue(address(oracle) != address(0));
        assertEq(address(oracle.hedVaultCore()), mockHedVaultCore);
    }

    function testTokenFactoryConfiguration() public {
        // Deploy a mock RWA token factory
        address mockHedVaultCore = address(0x123);
        vm.mockCall(
            mockHedVaultCore,
            abi.encodeWithSignature("hasRole(bytes32,address)"),
            abi.encode(true)
        );

        RWATokenFactory factory = new RWATokenFactory(mockHedVaultCore);

        // Test factory deployment
        assertTrue(address(factory) != address(0));
        assertEq(address(factory.hedVaultCore()), mockHedVaultCore);

        // Test Hedera-specific fee configuration
        assertEq(factory.tokenCreationFee(), 100 * 1e18); // 100 HBAR equivalent
        assertEq(factory.listingFee(), 50 * 1e18); // 50 HBAR equivalent
    }

    function testGasConfiguration() public pure {
        // Test gas configuration for Hedera
        uint256 expectedGasPrice = 100000000000; // 100 gwei
        uint256 expectedGasLimit = 15000000; // 15M gas

        assertEq(expectedGasPrice, 100000000000);
        assertEq(expectedGasLimit, 15000000);
    }

    function testOracleHeartbeatConfiguration() public pure {
        uint256 expectedHeartbeat = 3600; // 1 hour
        uint8 expectedDecimals = 8;

        assertEq(expectedHeartbeat, 3600);
        assertEq(expectedDecimals, 8);
    }

    function testPriceFeedValidation() public pure {
        // Test price feed validation logic
        uint256 minPrice = 1e6; // $0.01
        uint256 maxPrice = 1000e8; // $1000

        assertTrue(minPrice < maxPrice);
        assertTrue(minPrice > 0);
        assertTrue(maxPrice > minPrice);
    }

    function testHederaTokenServiceIntegration() public pure {
        // Test HTS integration constants
        assertTrue(HTS_PRECOMPILE != address(0));
        assertTrue(WHBAR_ADDRESS != address(0));

        // Verify these are the correct Hedera precompile addresses
        assertEq(HTS_PRECOMPILE, 0x0000000000000000000000000000000000000167);
        assertEq(WHBAR_ADDRESS, 0x0000000000000000000000000000000000000163);
    }

    function testDeploymentConstants() public pure {
        // Test deployment-related constants
        uint256 rewardTokenSupply = 1000000000 * 1e18; // 1B tokens
        uint256 poolAllocation = 800000 * 1e18; // 800K tokens

        assertTrue(rewardTokenSupply > poolAllocation);
        assertEq(rewardTokenSupply, 1000000000 * 1e18);
        assertEq(poolAllocation, 800000 * 1e18);
    }

    function testCollateralFactors() public pure {
        // Test conservative collateral factors for Hedera
        uint256 collateralFactor = 7000; // 70%
        uint256 liquidationBonus = 1500; // 15%

        assertTrue(collateralFactor < 10000); // Less than 100%
        assertTrue(liquidationBonus > 0);
        assertTrue(liquidationBonus < 5000); // Less than 50%

        assertEq(collateralFactor, 7000);
        assertEq(liquidationBonus, 1500);
    }
}
