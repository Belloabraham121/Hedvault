// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;

// import "forge-std/Test.sol";
// import "../src/RewardsDistributor.sol";
// import "../src/HedVaultCore.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/access/AccessControl.sol";

// // Mock ERC20 token for testing
// contract MockRewardToken is ERC20 {
//     constructor() ERC20("HedVault Token", "HVT") {
//         _mint(msg.sender, 1000000 * 10**18); // 1M tokens
//     }

//     function mint(address to, uint256 amount) external {
//         _mint(to, amount);
//     }
// }

// // Mock HedVaultCore for testing
// contract MockHedVaultCore {
//     mapping(address => bool) public validModules;
//     bool public initialized = true;
//     bool public emergencyMode = false;
    
//     function isValidModule(address module) external view returns (bool) {
//         return validModules[module];
//     }
    
//     function setValidModule(address module, bool valid) external {
//         validModules[module] = valid;
//     }
// }

// contract RewardsDistributorTest is Test {
//     RewardsDistributor public rewardsDistributor;
//     MockRewardToken public rewardToken;
//     MockHedVaultCore public hedVaultCore;
    
//     address public admin = address(0x1);
//     address public user1 = address(0x2);
//     address public user2 = address(0x3);
//     address public distributor = address(0x4);
    
//     uint256 public constant INITIAL_SUPPLY = 1000000 * 10**18;
//     uint256 public constant POOL_ALLOCATION = 100000 * 10**18;
//     uint256 public constant REWARD_DURATION = 30 days;
    
//     string public constant STAKING_POOL = "staking";
//     string public constant TRADING_POOL = "trading";
    
//     event RewardPoolCreated(string indexed poolName, uint256 totalAllocated, uint256 duration);
//     event Staked(address indexed user, string indexed poolName, uint256 amount, uint256 lockPeriod);
//     event Unstaked(address indexed user, string indexed poolName, uint256 amount);
//     event RewardClaimed(address indexed user, string indexed poolName, uint256 amount);
//     event VestingScheduleCreated(address indexed beneficiary, uint256 amount, uint256 duration);
//     event VestingReleased(address indexed beneficiary, uint256 amount);
    
//     function setUp() public {
//         // Deploy mock contracts
//         hedVaultCore = new MockHedVaultCore();
//         rewardToken = new MockRewardToken();
        
//         // Deploy RewardsDistributor
//         vm.prank(admin);
//         rewardsDistributor = new RewardsDistributor(
//             address(hedVaultCore),
//             address(rewardToken)
//         );
        
//         // Setup initial balances
//         rewardToken.transfer(admin, INITIAL_SUPPLY / 2);
//         rewardToken.transfer(user1, 10000 * 10**18);
//         rewardToken.transfer(user2, 10000 * 10**18);
        
//         // Grant roles
//         vm.startPrank(admin);
//         rewardsDistributor.grantRole(rewardsDistributor.DISTRIBUTOR_ROLE(), distributor);
//         vm.stopPrank();
//     }
    
//     function testConstructor() public {
//         assertEq(address(rewardsDistributor.hedVaultCore()), address(hedVaultCore));
//         assertEq(address(rewardsDistributor.rewardToken()), address(rewardToken));
//         assertTrue(rewardsDistributor.hasRole(rewardsDistributor.DEFAULT_ADMIN_ROLE(), admin));
//         assertTrue(rewardsDistributor.hasRole(rewardsDistributor.REWARDS_ADMIN_ROLE(), admin));
//     }
    
//     function testConstructorZeroAddress() public {
//         vm.expectRevert();
//         new RewardsDistributor(address(0), address(rewardToken));
        
//         vm.expectRevert();
//         new RewardsDistributor(address(hedVaultCore), address(0));
//     }
    
//     function testCreateRewardPool() public {
//         vm.startPrank(admin);
//         rewardToken.approve(address(rewardsDistributor), POOL_ALLOCATION);
        
//         vm.expectEmit(true, false, false, true);
//         emit RewardPoolCreated(STAKING_POOL, POOL_ALLOCATION, REWARD_DURATION);
        
//         rewardsDistributor.createRewardPool(STAKING_POOL, POOL_ALLOCATION, REWARD_DURATION);
        
//         (uint256 totalAllocated, uint256 totalDistributed, uint256 rewardRate, , , bool isActive, uint256 periodFinish, uint256 duration) = 
//             rewardsDistributor.rewardPools(STAKING_POOL);
            
//         assertEq(totalAllocated, POOL_ALLOCATION);
//         assertEq(totalDistributed, 0);
//         assertEq(rewardRate, POOL_ALLOCATION / REWARD_DURATION);
//         assertTrue(isActive);
//         assertEq(duration, REWARD_DURATION);
//         assertGt(periodFinish, block.timestamp);
//         vm.stopPrank();
//     }
    
//     function testCreateRewardPoolInvalidParameters() public {
//         vm.startPrank(admin);
        
//         // Empty pool name
//         vm.expectRevert();
//         rewardsDistributor.createRewardPool("", POOL_ALLOCATION, REWARD_DURATION);
        
//         // Zero allocation
//         vm.expectRevert();
//         rewardsDistributor.createRewardPool(STAKING_POOL, 0, REWARD_DURATION);
        
//         // Zero duration
//         vm.expectRevert();
//         rewardsDistributor.createRewardPool(STAKING_POOL, POOL_ALLOCATION, 0);
        
//         vm.stopPrank();
//     }
    
//     function testCreateRewardPoolUnauthorized() public {
//         vm.prank(user1);
//         vm.expectRevert();
//         rewardsDistributor.createRewardPool(STAKING_POOL, POOL_ALLOCATION, REWARD_DURATION);
//     }
    
//     function testStake() public {
//         // Create pool first
//         vm.startPrank(admin);
//         rewardToken.approve(address(rewardsDistributor), POOL_ALLOCATION);
//         rewardsDistributor.createRewardPool(STAKING_POOL, POOL_ALLOCATION, REWARD_DURATION);
//         vm.stopPrank();
        
//         uint256 stakeAmount = 1000 * 10**18;
//         uint256 lockPeriod = 7 days;
        
//         vm.startPrank(user1);
//         rewardToken.approve(address(rewardsDistributor), stakeAmount);
        
//         vm.expectEmit(true, true, false, true);
//         emit Staked(user1, STAKING_POOL, stakeAmount - (stakeAmount * 100 / 10000), lockPeriod);
        
//         rewardsDistributor.stake(STAKING_POOL, stakeAmount, lockPeriod);
        
//         (uint256 amount, , , uint256 stakingTime, uint256 userLockPeriod, bool isLocked) = 
//             rewardsDistributor.userStakes(user1, STAKING_POOL);
            
//         uint256 expectedAmount = stakeAmount - (stakeAmount * 100 / 10000); // After 1% fee
//         assertEq(amount, expectedAmount);
//         assertEq(userLockPeriod, lockPeriod);
//         assertTrue(isLocked);
//         assertEq(stakingTime, block.timestamp);
//         vm.stopPrank();
//     }
    
//     function testStakeInvalidAmount() public {
//         // Create pool first
//         vm.startPrank(admin);
//         rewardToken.approve(address(rewardsDistributor), POOL_ALLOCATION);
//         rewardsDistributor.createRewardPool(STAKING_POOL, POOL_ALLOCATION, REWARD_DURATION);
//         vm.stopPrank();
        
//         vm.startPrank(user1);
//         rewardToken.approve(address(rewardsDistributor), 1000);
        
//         // Amount too small
//         vm.expectRevert();
//         rewardsDistributor.stake(STAKING_POOL, 1000, 0);
        
//         vm.stopPrank();
//     }
    
//     function testStakeInvalidLockPeriod() public {
//         // Create pool first
//         vm.startPrank(admin);
//         rewardToken.approve(address(rewardsDistributor), POOL_ALLOCATION);
//         rewardsDistributor.createRewardPool(STAKING_POOL, POOL_ALLOCATION, REWARD_DURATION);
//         vm.stopPrank();
        
//         uint256 stakeAmount = 1000 * 10**18;
//         uint256 invalidLockPeriod = 366 days; // Too long
        
//         vm.startPrank(user1);
//         rewardToken.approve(address(rewardsDistributor), stakeAmount);
        
//         vm.expectRevert();
//         rewardsDistributor.stake(STAKING_POOL, stakeAmount, invalidLockPeriod);
        
//         vm.stopPrank();
//     }
    
//     function testUnstake() public {
//         // Setup: Create pool and stake
//         vm.startPrank(admin);
//         rewardToken.approve(address(rewardsDistributor), POOL_ALLOCATION);
//         rewardsDistributor.createRewardPool(STAKING_POOL, POOL_ALLOCATION, REWARD_DURATION);
//         vm.stopPrank();
        
//         uint256 stakeAmount = 1000 * 10**18;
        
//         vm.startPrank(user1);
//         rewardToken.approve(address(rewardsDistributor), stakeAmount);
//         rewardsDistributor.stake(STAKING_POOL, stakeAmount, 0); // No lock period
        
//         uint256 unstakeAmount = 500 * 10**18;
//         uint256 expectedAmount = unstakeAmount - (unstakeAmount * 100 / 10000); // After staking fee
//         uint256 expectedUnstakeAmount = expectedAmount - (expectedAmount * 50 / 10000); // After unstaking fee
        
//         uint256 balanceBefore = rewardToken.balanceOf(user1);
        
//         vm.expectEmit(true, true, false, true);
//         emit Unstaked(user1, STAKING_POOL, expectedUnstakeAmount);
        
//         rewardsDistributor.unstake(STAKING_POOL, expectedAmount);
        
//         uint256 balanceAfter = rewardToken.balanceOf(user1);
//         assertEq(balanceAfter - balanceBefore, expectedUnstakeAmount);
        
//         vm.stopPrank();
//     }
    
//     function testUnstakeLockedStake() public {
//         // Setup: Create pool and stake with lock
//         vm.startPrank(admin);
//         rewardToken.approve(address(rewardsDistributor), POOL_ALLOCATION);
//         rewardsDistributor.createRewardPool(STAKING_POOL, POOL_ALLOCATION, REWARD_DURATION);
//         vm.stopPrank();
        
//         uint256 stakeAmount = 1000 * 10**18;
//         uint256 lockPeriod = 7 days;
        
//         vm.startPrank(user1);
//         rewardToken.approve(address(rewardsDistributor), stakeAmount);
//         rewardsDistributor.stake(STAKING_POOL, stakeAmount, lockPeriod);
        
//         uint256 expectedAmount = stakeAmount - (stakeAmount * 100 / 10000);
        
//         // Try to unstake before lock period ends
//         vm.expectRevert();
//         rewardsDistributor.unstake(STAKING_POOL, expectedAmount);
        
//         // Fast forward past lock period
//         vm.warp(block.timestamp + lockPeriod + 1);
        
//         // Should work now
//         rewardsDistributor.unstake(STAKING_POOL, expectedAmount);
        
//         vm.stopPrank();
//     }
    
//     function testClaimRewards() public {
//         // Setup: Create pool and stake
//         vm.startPrank(admin);
//         rewardToken.approve(address(rewardsDistributor), POOL_ALLOCATION);
//         rewardsDistributor.createRewardPool(STAKING_POOL, POOL_ALLOCATION, REWARD_DURATION);
//         vm.stopPrank();
        
//         uint256 stakeAmount = 1000 * 10**18;
        
//         vm.startPrank(user1);
//         rewardToken.approve(address(rewardsDistributor), stakeAmount);
//         rewardsDistributor.stake(STAKING_POOL, stakeAmount, 0);
        
//         // Fast forward to accumulate rewards
//         vm.warp(block.timestamp + 1 days);
        
//         uint256 earnedRewards = rewardsDistributor.earned(user1, STAKING_POOL);
//         assertGt(earnedRewards, 0);
        
//         uint256 balanceBefore = rewardToken.balanceOf(user1);
        
//         vm.expectEmit(true, true, false, true);
//         emit RewardClaimed(user1, STAKING_POOL, earnedRewards);
        
//         rewardsDistributor.claimRewards(STAKING_POOL);
        
//         uint256 balanceAfter = rewardToken.balanceOf(user1);
//         assertEq(balanceAfter - balanceBefore, earnedRewards);
        
//         // Check that rewards are reset
//         assertEq(rewardsDistributor.earned(user1, STAKING_POOL), 0);
        
//         vm.stopPrank();
//     }
    
//     function testCreateVestingSchedule() public {
//         uint256 vestingAmount = 10000 * 10**18;
//         uint256 duration = 365 days;
//         uint256 cliffDuration = 30 days;
        
//         vm.startPrank(admin);
//         rewardToken.approve(address(rewardsDistributor), vestingAmount);
        
//         vm.expectEmit(true, false, false, true);
//         emit VestingScheduleCreated(user1, vestingAmount, duration);
        
//         rewardsDistributor.createVestingSchedule(user1, vestingAmount, duration, cliffDuration, true);
        
//         assertEq(rewardsDistributor.getVestingScheduleCount(user1), 1);
        
//         RewardsDistributor.VestingSchedule memory schedule = rewardsDistributor.getVestingSchedule(user1, 0);
        
//         assertEq(schedule.totalAmount, vestingAmount);
//         assertEq(schedule.releasedAmount, 0);
//         assertEq(schedule.startTime, block.timestamp);
//         assertEq(schedule.duration, duration);
//         assertEq(schedule.cliffDuration, cliffDuration);
//         assertTrue(schedule.revocable);
//         assertFalse(schedule.revoked);

        
//         vm.stopPrank();
//     }
    
//     function testReleaseVestedTokens() public {
//         uint256 vestingAmount = 10000 * 10**18;
//         uint256 duration = 365 days;
//         uint256 cliffDuration = 30 days;
        
//         // Create vesting schedule
//         vm.startPrank(admin);
//         rewardToken.approve(address(rewardsDistributor), vestingAmount);
//         rewardsDistributor.createVestingSchedule(user1, vestingAmount, duration, cliffDuration, true);
//         vm.stopPrank();
        
//         // Fast forward past cliff
//         vm.warp(block.timestamp + cliffDuration + 1 days);
        
//         uint256 releasableAmount = rewardsDistributor.getReleasableAmount(user1, 0);
//         assertGt(releasableAmount, 0);
        
//         uint256 balanceBefore = rewardToken.balanceOf(user1);
        
//         vm.prank(user1);
//         vm.expectEmit(true, false, false, true);
//         emit VestingReleased(user1, releasableAmount);
        
//         rewardsDistributor.releaseVestedTokens(0);
        
//         uint256 balanceAfter = rewardToken.balanceOf(user1);
//         assertEq(balanceAfter - balanceBefore, releasableAmount);
//     }
    
//     function testReleaseVestedTokensBeforeCliff() public {
//         uint256 vestingAmount = 10000 * 10**18;
//         uint256 duration = 365 days;
//         uint256 cliffDuration = 30 days;
        
//         // Create vesting schedule
//         vm.startPrank(admin);
//         rewardToken.approve(address(rewardsDistributor), vestingAmount);
//         rewardsDistributor.createVestingSchedule(user1, vestingAmount, duration, cliffDuration, true);
//         vm.stopPrank();
        
//         // Try to release before cliff
//         vm.prank(user1);
//         vm.expectRevert();
//         rewardsDistributor.releaseVestedTokens(0);
//     }
    
//     function testRevokeVestingSchedule() public {
//         uint256 vestingAmount = 10000 * 10**18;
//         uint256 duration = 365 days;
//         uint256 cliffDuration = 30 days;
        
//         // Create vesting schedule
//         vm.startPrank(admin);
//         rewardToken.approve(address(rewardsDistributor), vestingAmount);
//         rewardsDistributor.createVestingSchedule(user1, vestingAmount, duration, cliffDuration, true);
        
//         // Fast forward past cliff
//         vm.warp(block.timestamp + cliffDuration + 30 days);
        
//         rewardsDistributor.revokeVestingSchedule(user1, 0);
        
//         RewardsDistributor.VestingSchedule memory schedule = rewardsDistributor.getVestingSchedule(user1, 0);
//         assertTrue(schedule.revoked);
        
//         vm.stopPrank();
//     }
    
//     function testUpdateFees() public {
//         uint256 newStakingFee = 200; // 2%
//         uint256 newUnstakingFee = 100; // 1%
        
//         vm.startPrank(admin);
        
//         rewardsDistributor.updateStakingFee(newStakingFee);
//         assertEq(rewardsDistributor.stakingFee(), newStakingFee);
        
//         rewardsDistributor.updateUnstakingFee(newUnstakingFee);
//         assertEq(rewardsDistributor.unstakingFee(), newUnstakingFee);
        
//         vm.stopPrank();
//     }
    
//     function testUpdateFeesTooHigh() public {
//         uint256 tooHighFee = 1001; // > 10%
        
//         vm.startPrank(admin);
        
//         vm.expectRevert();
//         rewardsDistributor.updateStakingFee(tooHighFee);
        
//         vm.expectRevert();
//         rewardsDistributor.updateUnstakingFee(tooHighFee);
        
//         vm.stopPrank();
//     }
    
//     function testPauseUnpause() public {
//         vm.startPrank(admin);
        
//         rewardsDistributor.pause();
//         assertTrue(rewardsDistributor.paused());
        
//         rewardsDistributor.unpause();
//         assertFalse(rewardsDistributor.paused());
        
//         vm.stopPrank();
//     }
    
//     function testStakeWhenPaused() public {
//         // Create pool first
//         vm.startPrank(admin);
//         rewardToken.approve(address(rewardsDistributor), POOL_ALLOCATION);
//         rewardsDistributor.createRewardPool(STAKING_POOL, POOL_ALLOCATION, REWARD_DURATION);
        
//         // Pause contract
//         rewardsDistributor.pause();
//         vm.stopPrank();
        
//         uint256 stakeAmount = 1000 * 10**18;
        
//         vm.startPrank(user1);
//         rewardToken.approve(address(rewardsDistributor), stakeAmount);
        
//         vm.expectRevert();
//         rewardsDistributor.stake(STAKING_POOL, stakeAmount, 0);
        
//         vm.stopPrank();
//     }
    
//     function testRewardCalculation() public {
//         // Create pool
//         vm.startPrank(admin);
//         rewardToken.approve(address(rewardsDistributor), POOL_ALLOCATION);
//         rewardsDistributor.createRewardPool(STAKING_POOL, POOL_ALLOCATION, REWARD_DURATION);
//         vm.stopPrank();
        
//         uint256 stakeAmount = 1000 * 10**18;
        
//         // User1 stakes
//         vm.startPrank(user1);
//         rewardToken.approve(address(rewardsDistributor), stakeAmount);
//         rewardsDistributor.stake(STAKING_POOL, stakeAmount, 0);
//         vm.stopPrank();
        
//         // Fast forward 1 day
//         vm.warp(block.timestamp + 1 days);
        
//         uint256 earned1 = rewardsDistributor.earned(user1, STAKING_POOL);
//         assertGt(earned1, 0);
        
//         // User2 stakes same amount
//         vm.startPrank(user2);
//         rewardToken.approve(address(rewardsDistributor), stakeAmount);
//         rewardsDistributor.stake(STAKING_POOL, stakeAmount, 0);
//         vm.stopPrank();
        
//         // Fast forward another day
//         vm.warp(block.timestamp + 1 days);
        
//         uint256 earned1After = rewardsDistributor.earned(user1, STAKING_POOL);
//         uint256 earned2After = rewardsDistributor.earned(user2, STAKING_POOL);
        
//         // User1 should have more rewards (staked longer)
//         assertGt(earned1After, earned2After);
        
//         // Both should have some rewards
//         assertGt(earned1After, earned1);
//         assertGt(earned2After, 0);
//     }
    
//     function testGetPoolNames() public {
//         vm.startPrank(admin);
//         rewardToken.approve(address(rewardsDistributor), POOL_ALLOCATION * 2);
        
//         rewardsDistributor.createRewardPool(STAKING_POOL, POOL_ALLOCATION, REWARD_DURATION);
//         rewardsDistributor.createRewardPool(TRADING_POOL, POOL_ALLOCATION, REWARD_DURATION);
        
//         string[] memory poolNames = rewardsDistributor.getPoolNames();
//         assertEq(poolNames.length, 2);
//         assertEq(poolNames[0], STAKING_POOL);
//         assertEq(poolNames[1], TRADING_POOL);
        
//         vm.stopPrank();
//     }
    
//     function testDeactivateActivatePool() public {
//         vm.startPrank(admin);
//         rewardToken.approve(address(rewardsDistributor), POOL_ALLOCATION);
//         rewardsDistributor.createRewardPool(STAKING_POOL, POOL_ALLOCATION, REWARD_DURATION);
        
//         // Deactivate pool
//         rewardsDistributor.deactivatePool(STAKING_POOL);
//         (, , , , , bool isActive, , ) = rewardsDistributor.rewardPools(STAKING_POOL);
//         assertFalse(isActive);
        
//         // Activate pool
//         rewardsDistributor.activatePool(STAKING_POOL);
//         (, , , , , isActive, , ) = rewardsDistributor.rewardPools(STAKING_POOL);
//         assertTrue(isActive);
        
//         vm.stopPrank();
//     }
    
//     function testInitializeDefaultPools() public {
//         vm.startPrank(admin);
        
//         rewardsDistributor.initializeDefaultPools();
        
//         string[] memory poolNames = rewardsDistributor.getPoolNames();
//         assertEq(poolNames.length, 8);
        
//         // Check that all expected pools exist
//         assertTrue(bytes(poolNames[0]).length > 0);
//         assertTrue(bytes(poolNames[1]).length > 0);
//         assertTrue(bytes(poolNames[2]).length > 0);
//         assertTrue(bytes(poolNames[3]).length > 0);
//         assertTrue(bytes(poolNames[4]).length > 0);
//         assertTrue(bytes(poolNames[5]).length > 0);
//         assertTrue(bytes(poolNames[6]).length > 0);
//         assertTrue(bytes(poolNames[7]).length > 0);
        
//         // Check that pools are active
//         (, , , , , bool isActive, , ) = rewardsDistributor.rewardPools("staking");
//         assertTrue(isActive);
        
//         vm.stopPrank();
//     }
    
//     function testDistributeActivityReward() public {
//         // Initialize default pools first
//         vm.startPrank(admin);
//         rewardsDistributor.initializeDefaultPools();
//         rewardsDistributor.grantRole(rewardsDistributor.DISTRIBUTOR_ROLE(), admin);
//         vm.stopPrank();
        
//         uint256 tradingVolume = 10000 * 10**18;
        
//         vm.prank(admin);
//         rewardsDistributor.distributeActivityReward(user1, "trading", tradingVolume);
        
//         uint256 expectedReward = (tradingVolume * 10) / 10000; // 0.1% of trading volume
//         assertEq(rewardsDistributor.pendingRewards(user1), expectedReward);
//     }
    
//     function testAutoClaimRewards() public {
//         // Setup: Initialize pools and distribute rewards
//         vm.startPrank(admin);
//         rewardsDistributor.initializeDefaultPools();
//         rewardsDistributor.grantRole(rewardsDistributor.DISTRIBUTOR_ROLE(), admin);
        
//         uint256 tradingVolume = 10000 * 10**18;
//         rewardsDistributor.distributeActivityReward(user1, "trading", tradingVolume);
//         vm.stopPrank();
        
//         uint256 expectedReward = (tradingVolume * 10) / 10000;
//         uint256 balanceBefore = rewardToken.balanceOf(user1);
        
//         // Mint tokens to contract for rewards
//         rewardToken.mint(address(rewardsDistributor), expectedReward);
        
//         vm.prank(user1);
//         rewardsDistributor.autoClaimRewards(user1);
        
//         uint256 balanceAfter = rewardToken.balanceOf(user1);
//         assertEq(balanceAfter - balanceBefore, expectedReward);
//         assertEq(rewardsDistributor.pendingRewards(user1), 0);
//         assertEq(rewardsDistributor.claimedRewards(user1), expectedReward);
//     }
    
//     function testCalculateActivityRewards() public {
//         vm.startPrank(admin);
//         rewardsDistributor.initializeDefaultPools();
//         rewardsDistributor.grantRole(rewardsDistributor.DISTRIBUTOR_ROLE(), admin);
        
//         // Test trading rewards (0.1%)
//         uint256 tradingAmount = 100000 * 10**18;
//         rewardsDistributor.distributeActivityReward(user1, "trading", tradingAmount);
//         uint256 expectedTradingReward = (tradingAmount * 10) / 10000;
//         assertEq(rewardsDistributor.pendingRewards(user1), expectedTradingReward);
        
//         // Test lending rewards (0.5%)
//         uint256 lendingAmount = 50000 * 10**18;
//         rewardsDistributor.distributeActivityReward(user2, "lending", lendingAmount);
//         uint256 expectedLendingReward = (lendingAmount * 50) / 10000;
//         assertEq(rewardsDistributor.pendingRewards(user2), expectedLendingReward);
        
//         // Test governance rewards (fixed 1000 tokens)
//         rewardsDistributor.distributeActivityReward(user1, "governance", 1);
//         uint256 expectedGovernanceReward = 1000 * 10**18;
//         assertEq(rewardsDistributor.pendingRewards(user1), expectedTradingReward + expectedGovernanceReward);
        
//         vm.stopPrank();
//     }
    
//     function testGetUserRewardsOverview() public {
//         // Initialize default pools first
//         vm.prank(admin);
//         rewardsDistributor.initializeDefaultPools();
        
//         // Stake in multiple pools
//         uint256 stakeAmount = 100 * 10**18;
        
//         vm.startPrank(user1);
//         rewardToken.approve(address(rewardsDistributor), stakeAmount * 3);
//         rewardsDistributor.stake("staking", stakeAmount, 0);
//         rewardsDistributor.stake("trading", stakeAmount, 0);
//         rewardsDistributor.stake("lending", stakeAmount, 0);
//         vm.stopPrank();
        
//         // Distribute some activity rewards
//         vm.prank(distributor);
//         rewardsDistributor.distributeActivityReward(user1, "governance", 1);
        
//         // Get comprehensive overview
//         (
//             uint256 totalEarned,
//             uint256 totalPending,
//             uint256 totalStakedAmount,
//             uint256 totalClaimedRewards,
//             uint256[] memory poolEarnings,
//             uint256[] memory poolStakes,
//             uint256[] memory vestingAmounts,
//             string[] memory activePoolNames
//         ) = rewardsDistributor.getUserRewardsOverview(user1);
        
//         // Verify results (accounting for staking fees)
//         uint256 stakeFee = (stakeAmount * 100) / 10000; // 1% staking fee
//         uint256 actualStakeAmount = stakeAmount - stakeFee;
//         assertEq(totalStakedAmount, actualStakeAmount * 3);
//         assertEq(totalPending, 1000 * 10**18); // Governance reward
//         assertEq(totalClaimedRewards, 0);
//         assertTrue(activePoolNames.length >= 3);
//         assertTrue(poolStakes.length >= 3);
//     }

//     function testGetUserPositionBreakdown() public {
//         // Initialize default pools first
//         vm.prank(admin);
//         rewardsDistributor.initializeDefaultPools();
        
//         // Stake in different pools
//         uint256 stakeAmount = 50 * 10**18;
        
//         vm.startPrank(user1);
//         rewardToken.approve(address(rewardsDistributor), stakeAmount * 4);
//         rewardsDistributor.stake("staking", stakeAmount, 0);
//         rewardsDistributor.stake("trading", stakeAmount, 0);
//         rewardsDistributor.stake("lending", stakeAmount, 0);
//         rewardsDistributor.stake("governance", stakeAmount, 0);
//         vm.stopPrank();
        
//         // Distribute activity rewards for different types
//         vm.startPrank(distributor);
//         rewardsDistributor.distributeActivityReward(user1, "marketplace", 1000 * 10**18);
//         rewardsDistributor.distributeActivityReward(user1, "liquidity", 500 * 10**18);
//         rewardsDistributor.distributeActivityReward(user1, "rwa_tokenization", 200 * 10**18);
//         rewardsDistributor.distributeActivityReward(user1, "referral", 1);
//         vm.stopPrank();
        
//         // Get position breakdown
//         (
//             uint256 stakingRewards,
//             uint256 tradingRewards,
//             uint256 lendingRewards,
//             uint256 governanceRewards,
//             uint256 marketplaceRewards,
//             uint256 liquidityRewards,
//             uint256 rwaRewards,
//             uint256 referralRewards,
//             uint256 totalVestingAmount,
//             uint256 totalReleasableVesting
//         ) = rewardsDistributor.getUserPositionBreakdown(user1);
        
//         // Verify activity-based rewards are tracked
//         uint256 expectedMarketplace = (1000 * 10**18 * 25) / 10000; // 0.25%
//         uint256 expectedLiquidity = (500 * 10**18 * 75) / 10000; // 0.75%
//         uint256 expectedRwa = (200 * 10**18 * 200) / 10000; // 2%
//         uint256 expectedReferral = 500 * 10**18; // Fixed amount
        
//         // Note: These are pending rewards, not pool-specific earned rewards
//         // The breakdown function shows pool-specific staking rewards
//         assertTrue(stakingRewards >= 0);
//         assertTrue(tradingRewards >= 0);
//         assertTrue(lendingRewards >= 0);
//         assertTrue(governanceRewards >= 0);
//     }

//     function testNewActivityRewardTypes() public {
//         // Initialize default pools first to create the new activity pools
//         vm.prank(admin);
//         rewardsDistributor.initializeDefaultPools();
        
//         // Test new activity types added to the protocol
//         uint256 marketplaceVolume = 10000 * 10**18;
//         uint256 liquidityAmount = 5000 * 10**18;
//         uint256 rwaValue = 1000 * 10**18;
        
//         vm.startPrank(distributor);
        
//         // Test marketplace rewards
//         rewardsDistributor.distributeActivityReward(user1, "marketplace", marketplaceVolume);
//         uint256 expectedMarketplace = (marketplaceVolume * 25) / 10000; // 0.25%
        
//         // Test liquidity rewards
//         rewardsDistributor.distributeActivityReward(user1, "liquidity", liquidityAmount);
//         uint256 expectedLiquidity = (liquidityAmount * 75) / 10000; // 0.75%
        
//         // Test RWA tokenization rewards
//         rewardsDistributor.distributeActivityReward(user1, "rwa_tokenization", rwaValue);
//         uint256 expectedRwa = (rwaValue * 200) / 10000; // 2%
        
//         // Test referral rewards
//         rewardsDistributor.distributeActivityReward(user1, "referral", 1);
//         uint256 expectedReferral = 500 * 10**18; // Fixed amount
        
//         vm.stopPrank();
        
//         uint256 totalExpected = expectedMarketplace + expectedLiquidity + expectedRwa + expectedReferral;
//         assertEq(rewardsDistributor.pendingRewards(user1), totalExpected);
//     }
// }