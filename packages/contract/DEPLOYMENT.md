# HedVault Protocol Deployment Guide

This guide explains how to deploy the complete HedVault protocol using the provided deployment scripts.

## Prerequisites

1. **Foundry**: Make sure you have Foundry installed
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Environment Setup**: Copy the example environment file and configure it
   ```bash
   cp script/deploy.env.example .env
   ```

## Deployment Configuration

Edit the `.env` file to configure your deployment:

- `FEE_RECIPIENT`: Address that will receive protocol fees
- `REWARD_TOKEN_SUPPLY`: Total supply of reward tokens (default: 1B tokens)
- `DEPLOY_MOCK_TOKENS`: Whether to deploy test ERC20 tokens
- `INITIALIZE_REWARD_POOLS`: Whether to set up default reward pools
- `SETUP_TEST_DATA`: Whether to configure test environment

## Deployment Commands

### Local Deployment (Anvil)

1. Start a local Anvil node:
   ```bash
   anvil
   ```

2. Deploy the protocol:
   ```bash
   forge script script/Deploy.s.sol:HedVaultDeployScript --rpc-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
   ```

### Testnet Deployment

1. Set your private key and RPC URL in `.env`:
   ```bash
   PRIVATE_KEY=your_private_key_here
   RPC_URL=https://sepolia.infura.io/v3/your_project_id
   ```

2. Deploy to testnet:
   ```bash
   forge script script/Deploy.s.sol:HedVaultDeployScript --rpc-url $RPC_URL --broadcast --private-key $PRIVATE_KEY --verify
   ```

### Mainnet Deployment

⚠️ **WARNING**: Mainnet deployment involves real funds. Double-check all configurations.

1. Configure mainnet settings in `.env`
2. Deploy with verification:
   ```bash
   forge script script/Deploy.s.sol:HedVaultDeployScript --rpc-url $MAINNET_RPC_URL --broadcast --private-key $PRIVATE_KEY --verify --etherscan-api-key $ETHERSCAN_API_KEY
   ```

## Deployed Contracts

The deployment script deploys the following contracts in order:

1. **MockERC20** (Reward Token): HedVault native token for rewards
2. **HedVaultCore**: Main protocol coordinator
3. **RewardsDistributor**: Manages reward distribution and staking
4. **PriceOracle**: Handles asset price feeds
5. **LendingPool**: Manages lending and borrowing
6. **Marketplace**: NFT and asset marketplace
7. **Mock Tokens** (optional): Test ERC20 tokens (USDC, WETH, WBTC, DAI)
8. **VerifyRewardIntegration**: Integration testing contract

## Post-Deployment Setup

After deployment, the script automatically:

1. Initializes HedVaultCore with all module addresses
2. Sets up default reward pools (8 pools for different activities)
3. Configures mock tokens in LendingPool and Marketplace
4. Registers the deployer as the first protocol user

## Verification

To verify the deployment was successful:

1. **Run Integration Tests**:
   ```bash
   forge test --match-contract IntegrationVerificationTest -v
   ```

2. **Check Contract Interactions**:
   ```bash
   # Check if HedVaultCore is initialized
   cast call <HEDVAULT_CORE_ADDRESS> "isInitialized()" --rpc-url $RPC_URL
   
   # Check reward pools
   cast call <REWARDS_DISTRIBUTOR_ADDRESS> "poolNames(uint256)" 0 --rpc-url $RPC_URL
   ```

3. **Verify Reward Integration**:
   ```bash
   # Use the verification contract
   cast call <VERIFY_REWARD_INTEGRATION_ADDRESS> "verifyAllRewardPools()" --rpc-url $RPC_URL
   ```

## Contract Addresses

After deployment, the script will output all contract addresses. Save these for future reference:

```
=== Deployment Complete ===
HedVaultCore: 0x...
RewardsDistributor: 0x...
PriceOracle: 0x...
LendingPool: 0x...
Marketplace: 0x...
Reward Token: 0x...
VerifyRewardIntegration: 0x...
```

## Troubleshooting

### Common Issues

1. **Insufficient Gas**: Increase gas limit in forge script command:
   ```bash
   --gas-limit 10000000
   ```

2. **Nonce Issues**: Reset nonce or wait for pending transactions

3. **Verification Failures**: Ensure Etherscan API key is correct and wait a few minutes before retrying

### Getting Help

- Check the deployment logs for specific error messages
- Verify all environment variables are set correctly
- Ensure sufficient ETH balance for deployment gas costs

## Security Considerations

1. **Private Keys**: Never commit private keys to version control
2. **Fee Recipients**: Ensure fee recipient addresses are controlled by trusted parties
3. **Admin Roles**: The deployer receives admin roles - transfer these to appropriate multisig wallets
4. **Testing**: Always test on testnets before mainnet deployment

## Next Steps

After successful deployment:

1. Transfer admin roles to appropriate governance contracts
2. Configure price oracles with real price feeds
3. Set up monitoring and alerting
4. Conduct security audits before handling significant value
5. Update frontend applications with new contract addresses

## Support

For deployment support or questions, please refer to the project documentation or create an issue in the repository.