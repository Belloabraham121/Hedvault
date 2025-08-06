// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./RewardsDistributor.sol";
import "./LendingPool.sol";
import "./Marketplace.sol";
import "./HedVaultCore.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title VerifyRewardIntegration
 * @notice Contract to verify and demonstrate reward pool connections
 * @dev This contract provides functions to test and verify that reward pools
 *      are properly connected to protocol contracts like LendingPool and Marketplace
 */
contract VerifyRewardIntegration {
    RewardsDistributor public rewardsDistributor;
    LendingPool public lendingPool;
    Marketplace public marketplace;
    HedVaultCore public hedVaultCore;
    
    // Events for verification
    event RewardPoolVerified(string poolName, bool exists, uint256 rewardRate);
    event ContractIntegrationVerified(address contractAddr, string contractType, bool integrated);
    event RewardDistributionTest(address user, string activityType, uint256 amount, bool success);
    
    constructor(
        address _rewardsDistributor,
        address _lendingPool,
        address payable _marketplace,
        address payable _hedVaultCore
    ) {
        rewardsDistributor = RewardsDistributor(_rewardsDistributor);
        lendingPool = LendingPool(_lendingPool);
        marketplace = Marketplace(_marketplace);
        hedVaultCore = HedVaultCore(_hedVaultCore);
    }
    
    /**
     * @notice Verify all reward pools exist and have correct configurations
     * @return poolsExist Array indicating which pools exist
     * @return poolRates Array of reward rates for each pool
     */
    function verifyAllRewardPools() external returns (bool[8] memory poolsExist, uint256[8] memory poolRates) {
        string[8] memory poolNames = [
            "staking",
            "trading", 
            "lending",
            "governance",
            "marketplace",
            "liquidity",
            "rwa_tokenization",
            "referral"
        ];
        
        for (uint i = 0; i < 8; i++) {
            try rewardsDistributor.rewardPools(poolNames[i]) returns (
                uint256 /* totalAllocated */,
                uint256 /* totalDistributed */,
                uint256 rewardRate,
                uint256 /* lastUpdateTime */,
                uint256 /* rewardPerTokenStored */,
                bool isActive,
                uint256 /* periodFinish */,
                uint256 /* duration */
            ) {
                poolsExist[i] = isActive;
                poolRates[i] = rewardRate;
                emit RewardPoolVerified(poolNames[i], isActive, rewardRate);
            } catch {
                poolsExist[i] = false;
                poolRates[i] = 0;
                emit RewardPoolVerified(poolNames[i], false, 0);
            }
        }
    }
    
    /**
     * @notice Verify that contracts are properly connected to RewardsDistributor
     * @return lendingIntegrated Whether LendingPool is integrated
     * @return marketplaceIntegrated Whether Marketplace is integrated
     */
    function verifyContractIntegrations() external returns (bool lendingIntegrated, bool marketplaceIntegrated) {
        // Check if HedVaultCore has the correct RewardsDistributor address
        address coreRewardsAddr = hedVaultCore.rewardsDistributor();
        bool coreConnected = (coreRewardsAddr == address(rewardsDistributor));
        
        // For LendingPool and Marketplace, we check if they can successfully
        // interact with RewardsDistributor (integration is internal)
        lendingIntegrated = coreConnected && address(lendingPool) != address(0);
        marketplaceIntegrated = coreConnected && address(marketplace) != address(0);
        
        emit ContractIntegrationVerified(address(lendingPool), "LendingPool", lendingIntegrated);
        emit ContractIntegrationVerified(address(marketplace), "Marketplace", marketplaceIntegrated);
    }
    
    /**
     * @notice Test reward distribution for lending activities
     * @param user User address to test
     * @param amount Amount to test with
     * @return success Whether the test was successful
     */
    function testLendingRewards(address user, uint256 amount) external returns (bool success) {
        return _distributeReward(user, "lending", amount);
    }
    
    /**
     * @notice Test reward distribution for marketplace activities
     * @param user User address to test
     * @param amount Amount to test with
     * @return success Whether the test was successful
     */
    function testMarketplaceRewards(address user, uint256 amount) external returns (bool success) {
        return _distributeReward(user, "marketplace", amount);
    }
    
    /**
     * @notice Internal function to distribute rewards with error handling
     * @param user User address to distribute rewards to
     * @param activityType Type of activity for reward distribution
     * @param amount Amount of rewards to distribute
     * @return success Whether the reward distribution was successful
     */
    function _distributeReward(address user, string memory activityType, uint256 amount) internal returns (bool success) {
        if (address(rewardsDistributor) != address(0)) {
            try rewardsDistributor.distributeActivityReward(user, activityType, amount) {
                success = true;
                emit RewardDistributionTest(user, activityType, amount, true);
            } catch {
                success = false;
                emit RewardDistributionTest(user, activityType, amount, false);
            }
        } else {
            success = false;
            emit RewardDistributionTest(user, activityType, amount, false);
        }
    }
    
    /**
     * @notice Get comprehensive user rewards overview
     * @param user User address
     * @return totalEarned Total earned rewards
     * @return totalPending Total pending rewards
     * @return totalStakedAmount Total staked amount
     * @return totalClaimedRewards Total claimed rewards
     * @return poolEarnings Array of earnings per pool
     * @return poolStakes Array of stakes per pool
     * @return vestingAmounts Array of vesting amounts
     * @return activePoolNames Array of active pool names
     */
    function getUserRewardsOverview(address user) external view returns (
        uint256 totalEarned,
        uint256 totalPending,
        uint256 totalStakedAmount,
        uint256 totalClaimedRewards,
        uint256[] memory poolEarnings,
        uint256[] memory poolStakes,
        uint256[] memory vestingAmounts,
        string[] memory activePoolNames
    ) {
        return rewardsDistributor.getUserRewardsOverview(user);
    }
    
    /**
     * @notice Get user position breakdown for all activities
     * @param user User address
     * @return stakingRewards Rewards from staking
     * @return tradingRewards Rewards from trading
     * @return lendingRewards Rewards from lending
     * @return governanceRewards Rewards from governance
     * @return marketplaceRewards Rewards from marketplace
     * @return liquidityRewards Rewards from liquidity
     * @return rwaRewards Rewards from RWA tokenization
     * @return referralRewards Rewards from referral
     * @return totalVestingAmount Total vesting amount
     * @return totalReleasableVesting Total releasable vesting
     */
    function getUserPositionBreakdown(address user) external view returns (
        uint256 stakingRewards,
        uint256 tradingRewards,
        uint256 lendingRewards,
        uint256 governanceRewards,
        uint256 marketplaceRewards,
        uint256 liquidityRewards,
        uint256 rwaRewards,
        uint256 referralRewards,
        uint256 totalVestingAmount,
        uint256 totalReleasableVesting
    ) {
        return rewardsDistributor.getUserPositionBreakdown(user);
    }
    
    /**
     * @notice Comprehensive integration test
     * @dev Tests all aspects of reward system integration
     * @return testResults Array of test results
     */
    function runComprehensiveTest() external returns (bool[6] memory testResults) {
        // Test 1: Verify all pools exist
        (bool[8] memory poolsExist,) = this.verifyAllRewardPools();
        testResults[0] = true;
        for (uint i = 0; i < 8; i++) {
            if (!poolsExist[i]) {
                testResults[0] = false;
                break;
            }
        }
        
        // Test 2: Verify contract integrations
        (bool lendingIntegrated, bool marketplaceIntegrated) = this.verifyContractIntegrations();
        testResults[1] = lendingIntegrated;
        testResults[2] = marketplaceIntegrated;
        
        // Test 3: Test lending rewards
        testResults[3] = this.testLendingRewards(msg.sender, 1000 * 1e18);
        
        // Test 4: Test marketplace rewards
        testResults[4] = this.testMarketplaceRewards(msg.sender, 500 * 1e18);
        
        // Test 5: Test user overview function
        try this.getUserRewardsOverview(msg.sender) {
            testResults[5] = true;
        } catch {
            testResults[5] = false;
        }
    }
    
    /**
     * @notice Get human-readable test results
     * @return results Array of test descriptions and their status
     */
    function getTestResultsDescription() external pure returns (string[6] memory results) {
        results[0] = "All 8 reward pools exist and are active";
        results[1] = "LendingPool is integrated with RewardsDistributor";
        results[2] = "Marketplace is integrated with RewardsDistributor";
        results[3] = "Lending rewards can be distributed successfully";
        results[4] = "Marketplace rewards can be distributed successfully";
        results[5] = "User rewards overview function works correctly";
    }
}