#!/bin/bash

# Factory Tokens Deployment Script
# This script helps deploy factory tokens for real-world assets

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
HELPER_SCRIPT="script/FactoryTokensHelper.s.sol:FactoryTokensHelper"
MAIN_SCRIPT="script/CreateFactoryTokens.s.sol:CreateFactoryTokens"

echo -e "${BLUE}=== HedVault Factory Tokens Deployment ===${NC}"
echo

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo "Please copy .env.factory-tokens.example to .env and configure it."
    echo "cp script/.env.factory-tokens.example script/.env"
    exit 1
fi

# Load environment variables
source "$ENV_FILE"

# Validate required environment variables
if [ -z "$RWA_TOKEN_FACTORY_ADDRESS" ] || [ -z "$CREATOR_ADDRESS" ] || [ -z "$RPC_URL" ] || [ -z "$PRIVATE_KEY" ]; then
    echo -e "${RED}Error: Missing required environment variables!${NC}"
    echo "Please ensure the following are set in .env:"
    echo "- RWA_TOKEN_FACTORY_ADDRESS"
    echo "- CREATOR_ADDRESS"
    echo "- RPC_URL"
    echo "- PRIVATE_KEY"
    exit 1
fi

echo -e "${GREEN}Configuration loaded successfully${NC}"
echo "RWA Token Factory: $RWA_TOKEN_FACTORY_ADDRESS"
echo "Creator Address: $CREATOR_ADDRESS"
echo "RPC URL: $RPC_URL"
echo

# Function to run forge script
run_forge_script() {
    local script_name="$1"
    local function_sig="$2"
    local broadcast="$3"
    
    local cmd="forge script $script_name"
    
    if [ -n "$function_sig" ]; then
        cmd="$cmd --sig \"$function_sig\""
    fi
    
    cmd="$cmd --rpc-url $RPC_URL --private-key $PRIVATE_KEY"
    
    if [ "$broadcast" = "true" ]; then
        cmd="$cmd --broadcast"
    fi
    
    echo -e "${BLUE}Running: $cmd${NC}"
    eval $cmd
}

# Step 1: Check prerequisites
echo -e "${YELLOW}Step 1: Checking prerequisites...${NC}"
run_forge_script "$HELPER_SCRIPT" "checkPrerequisites()" "false"
echo

# Ask user if they want to continue
read -p "Do you want to continue with deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

# Step 2: Check current deployment status
echo -e "${YELLOW}Step 2: Checking current deployment status...${NC}"
run_forge_script "$HELPER_SCRIPT" "checkDeploymentStatus()" "false"
echo

# Step 3: Choose deployment option
echo -e "${YELLOW}Step 3: Choose deployment option:${NC}"
echo "1) Deploy all tokens at once (recommended)"
echo "2) Deploy in batches"
echo "3) Deploy specific asset type only"
echo "4) Exit"
read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo -e "${GREEN}Deploying all factory tokens...${NC}"
        run_forge_script "$MAIN_SCRIPT" "" "true"
        ;;
    2)
        echo -e "${GREEN}Deploying in batches...${NC}"
        echo "Batch 1: Precious Metals"
        run_forge_script "$HELPER_SCRIPT" "deployPreciousMetalsOnly()" "true"
        echo
        echo "Batch 2: Stock Tokens"
        run_forge_script "$HELPER_SCRIPT" "deployStocksOnly()" "true"
        echo
        echo "Batch 3: Commodities"
        run_forge_script "$HELPER_SCRIPT" "deployCommoditiesOnly()" "true"
        echo
        echo "Batch 4: Bonds"
        run_forge_script "$HELPER_SCRIPT" "deployBondsOnly()" "true"
        ;;
    3)
        echo "Choose asset type:"
        echo "1) Precious Metals (Gold, Silver, Platinum, Palladium)"
        echo "2) Stocks (Apple, Microsoft, Tesla, Amazon, Google)"
        echo "3) Commodities (Oil, Gas, Wheat)"
        echo "4) Bonds (Treasury, Corporate)"
        read -p "Enter choice (1-4): " asset_choice
        
        case $asset_choice in
            1)
                echo -e "${GREEN}Deploying precious metals tokens...${NC}"
                run_forge_script "$HELPER_SCRIPT" "deployPreciousMetalsOnly()" "true"
                ;;
            2)
                echo -e "${GREEN}Deploying stock tokens...${NC}"
                run_forge_script "$HELPER_SCRIPT" "deployStocksOnly()" "true"
                ;;
            3)
                echo -e "${GREEN}Deploying commodity tokens...${NC}"
                run_forge_script "$HELPER_SCRIPT" "deployCommoditiesOnly()" "true"
                ;;
            4)
                echo -e "${GREEN}Deploying bond tokens...${NC}"
                run_forge_script "$HELPER_SCRIPT" "deployBondsOnly()" "true"
                ;;
            *)
                echo -e "${RED}Invalid choice${NC}"
                exit 1
                ;;
        esac
        ;;
    4)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

# Step 4: Verify deployment
echo
echo -e "${YELLOW}Step 4: Verifying deployment...${NC}"
run_forge_script "$HELPER_SCRIPT" "checkDeploymentStatus()" "false"

echo
echo -e "${GREEN}=== Deployment Complete ===${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo "1. Register tokens with RWAOffchainOracle for price feeds"
echo "2. Set up Chainlink price feeds for each asset"
echo "3. Update IPFS certification hashes with real documents"
echo "4. Configure trading pairs in the marketplace"
echo "5. Add initial liquidity for trading"
echo
echo -e "${GREEN}Factory tokens are now ready for use!${NC}"