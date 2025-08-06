// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IHedVaultCore.sol";
import "./libraries/DataTypes.sol";
import "./libraries/HedVaultErrors.sol";
import "./libraries/Events.sol";

/**
 * @title RewardsDistributor
 * @notice Manages reward distribution, staking, and vesting for the HedVault protocol
 * @dev Handles multiple reward types including staking, trading, lending, and governance rewards
 */
contract RewardsDistributor is AccessControl, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    // Role definitions
    bytes32 public constant REWARDS_ADMIN_ROLE = keccak256("REWARDS_ADMIN_ROLE");
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");

    // Core contracts
    IHedVaultCore public immutable hedVaultCore;
    IERC20 public immutable rewardToken; // HedVault native token

    // Reward pools for different activities
    struct RewardPool {
        uint256 totalAllocated;
        uint256 totalDistributed;
        uint256 rewardRate; // Rewards per second
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
        bool isActive;
        uint256 periodFinish;
        uint256 duration; // Reward period duration
    }

    // User staking information
    struct UserStake {
        uint256 amount;
        uint256 rewardPerTokenPaid;
        uint256 rewards;
        uint256 stakingTime;
        uint256 lockPeriod; // Lock period in seconds
        bool isLocked;
    }

    // Vesting schedule
    struct VestingSchedule {
        uint256 totalAmount;
        uint256 releasedAmount;
        uint256 startTime;
        uint256 duration;
        uint256 cliffDuration;
        bool revocable;
        bool revoked;
    }

    // State variables
    mapping(string => RewardPool) public rewardPools; // Pool name => RewardPool
    mapping(address => mapping(string => UserStake)) public userStakes; // User => Pool => Stake
    mapping(address => uint256) public totalStaked;
    mapping(string => uint256) public poolTotalStaked;
    mapping(address => VestingSchedule[]) public vestingSchedules;
    mapping(address => uint256) public pendingRewards;
    mapping(address => uint256) public claimedRewards;
    
    string[] public poolNames;
    uint256 public totalRewardsDistributed;
    uint256 public stakingFee = 100; // 1% in basis points
    uint256 public unstakingFee = 50; // 0.5% in basis points
    uint256 public constant MAX_FEE = 1000; // 10% max fee
    uint256 public constant BASIS_POINTS = 10000;
    uint256 public constant MIN_STAKE_AMOUNT = 1e18; // 1 token minimum
    uint256 public constant MAX_LOCK_PERIOD = 365 days;

    // Events
    event RewardPoolCreated(string indexed poolName, uint256 totalAllocated, uint256 duration);
    event RewardPoolUpdated(string indexed poolName, uint256 newRewardRate, uint256 newDuration);
    event Staked(address indexed user, string indexed poolName, uint256 amount, uint256 lockPeriod);
    event Unstaked(address indexed user, string indexed poolName, uint256 amount);
    event RewardClaimed(address indexed user, string indexed poolName, uint256 amount);
    event VestingScheduleCreated(address indexed beneficiary, uint256 amount, uint256 duration);
    event VestingReleased(address indexed beneficiary, uint256 amount);
    event VestingRevoked(address indexed beneficiary, uint256 scheduleId);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    modifier validPool(string memory poolName) {
        if (!rewardPools[poolName].isActive) {
            revert HedVaultErrors.InvalidConfiguration("Pool not active");
        }
        _;
    }

    modifier updateReward(address account, string memory poolName) {
        RewardPool storage pool = rewardPools[poolName];
        pool.rewardPerTokenStored = rewardPerToken(poolName);
        pool.lastUpdateTime = lastTimeRewardApplicable(poolName);
        
        if (account != address(0)) {
            UserStake storage userStake = userStakes[account][poolName];
            userStake.rewards = earned(account, poolName);
            userStake.rewardPerTokenPaid = pool.rewardPerTokenStored;
        }
        _;
    }

    constructor(
        address _hedVaultCore,
        address _rewardToken
    ) {
        if (_hedVaultCore == address(0) || _rewardToken == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        hedVaultCore = IHedVaultCore(_hedVaultCore);
        rewardToken = IERC20(_rewardToken);

        // Set up roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(REWARDS_ADMIN_ROLE, msg.sender);
        _grantRole(DISTRIBUTOR_ROLE, msg.sender);
        _grantRole(EMERGENCY_ROLE, msg.sender);
    }

    /**
     * @notice Create a new reward pool (automatically called by protocol)
     * @param poolName Name of the reward pool
     * @param totalAllocated Total tokens allocated to this pool
     * @param duration Duration of the reward period
     */
    function createRewardPool(
        string calldata poolName,
        uint256 totalAllocated,
        uint256 duration
    ) external onlyRole(REWARDS_ADMIN_ROLE) {
        if (bytes(poolName).length == 0) {
            revert HedVaultErrors.InvalidConfiguration("Empty pool name");
        }
        if (totalAllocated == 0 || duration == 0) {
            revert HedVaultErrors.InvalidConfiguration("Invalid parameters");
        }
        if (rewardPools[poolName].isActive) {
            revert HedVaultErrors.InvalidConfiguration("Pool already exists");
        }

        uint256 rewardRate = totalAllocated / duration;
        
        rewardPools[poolName] = RewardPool({
            totalAllocated: totalAllocated,
            totalDistributed: 0,
            rewardRate: rewardRate,
            lastUpdateTime: block.timestamp,
            rewardPerTokenStored: 0,
            isActive: true,
            periodFinish: block.timestamp + duration,
            duration: duration
        });

        poolNames.push(poolName);

        // Transfer tokens to contract
        rewardToken.safeTransferFrom(msg.sender, address(this), totalAllocated);

        emit RewardPoolCreated(poolName, totalAllocated, duration);
    }

    /**
     * @notice Initialize default reward pools automatically
     * @dev Called during contract deployment to set up all protocol reward pools
     */
    function initializeDefaultPools() external onlyRole(REWARDS_ADMIN_ROLE) {
        uint256 poolDuration = 365 days; // 1 year reward cycles
        uint256 baseAllocation = 100000 * 10**18; // 100k tokens per pool
        
        // Auto-create all protocol reward pools
        string[8] memory defaultPools = [
            "staking",           // Staking rewards
            "trading",          // Trading volume rewards
            "lending",          // Lending protocol rewards
            "governance",       // Governance participation
            "marketplace",      // NFT marketplace activity
            "liquidity",        // Liquidity provision
            "rwa_tokenization", // RWA tokenization rewards
            "referral"          // Referral program rewards
        ];
        
        for (uint i = 0; i < defaultPools.length; i++) {
            if (!rewardPools[defaultPools[i]].isActive) {
                rewardPools[defaultPools[i]] = RewardPool({
                    totalAllocated: baseAllocation,
                    totalDistributed: 0,
                    rewardRate: baseAllocation / poolDuration,
                    lastUpdateTime: block.timestamp,
                    rewardPerTokenStored: 0,
                    isActive: true,
                    periodFinish: block.timestamp + poolDuration,
                    duration: poolDuration
                });
                
                poolNames.push(defaultPools[i]);
                emit RewardPoolCreated(defaultPools[i], baseAllocation, poolDuration);
            }
        }
    }

    /**
     * @notice Automatically distribute rewards based on user activity
     * @param user User address to reward
     * @param activityType Type of activity ("trading", "lending", "staking", "governance")
     * @param amount Activity amount (volume, stake, etc.)
     */
    function distributeActivityReward(
        address user,
        string calldata activityType,
        uint256 amount
    ) external onlyRole(DISTRIBUTOR_ROLE) {
        if (!rewardPools[activityType].isActive) {
            return; // Skip if pool doesn't exist
        }
        
        // Calculate reward based on activity
        uint256 rewardAmount = _calculateActivityReward(activityType, amount);
        
        if (rewardAmount > 0) {
            pendingRewards[user] += rewardAmount;
            rewardPools[activityType].totalDistributed += rewardAmount;
            
            emit RewardClaimed(user, activityType, rewardAmount);
        }
    }

    /**
     * @notice Auto-claim all pending rewards for a user
     * @param user User address
     */
    function autoClaimRewards(address user) external nonReentrant {
        uint256 totalPending = pendingRewards[user];
        
        if (totalPending > 0) {
            pendingRewards[user] = 0;
            claimedRewards[user] += totalPending;
            totalRewardsDistributed += totalPending;
            
            rewardToken.safeTransfer(user, totalPending);
            
            emit RewardClaimed(user, "auto-claim", totalPending);
        }
    }

    /**
     * @notice Stake tokens in a reward pool
     * @param poolName Name of the pool to stake in
     * @param amount Amount to stake
     * @param lockPeriod Lock period in seconds (0 for no lock)
     */
    function stake(
        string calldata poolName,
        uint256 amount,
        uint256 lockPeriod
    ) external validPool(poolName) updateReward(msg.sender, poolName) whenNotPaused nonReentrant {
        if (amount < MIN_STAKE_AMOUNT) {
            revert HedVaultErrors.InvalidConfiguration("Amount too small");
        }
        if (lockPeriod > MAX_LOCK_PERIOD) {
            revert HedVaultErrors.InvalidConfiguration("Lock period too long");
        }

        UserStake storage userStake = userStakes[msg.sender][poolName];
        
        // Calculate staking fee
        uint256 fee = (amount * stakingFee) / BASIS_POINTS;
        uint256 stakeAmount = amount - fee;

        userStake.amount += stakeAmount;
        userStake.stakingTime = block.timestamp;
        userStake.lockPeriod = lockPeriod;
        userStake.isLocked = lockPeriod > 0;

        totalStaked[msg.sender] += stakeAmount;
        poolTotalStaked[poolName] += stakeAmount;

        // Transfer tokens from user
        rewardToken.safeTransferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, poolName, stakeAmount, lockPeriod);
    }

    /**
     * @notice Unstake tokens from a reward pool
     * @param poolName Name of the pool to unstake from
     * @param amount Amount to unstake
     */
    function unstake(
        string calldata poolName,
        uint256 amount
    ) external validPool(poolName) updateReward(msg.sender, poolName) nonReentrant {
        UserStake storage userStake = userStakes[msg.sender][poolName];
        
        if (amount > userStake.amount) {
            revert HedVaultErrors.InvalidConfiguration("Insufficient stake");
        }
        
        // Check lock period
        if (userStake.isLocked && block.timestamp < userStake.stakingTime + userStake.lockPeriod) {
            revert HedVaultErrors.InvalidConfiguration("Stake is locked");
        }

        // Calculate unstaking fee
        uint256 fee = (amount * unstakingFee) / BASIS_POINTS;
        uint256 withdrawAmount = amount - fee;

        userStake.amount -= amount;
        totalStaked[msg.sender] -= amount;
        poolTotalStaked[poolName] -= amount;

        // Transfer tokens to user
        rewardToken.safeTransfer(msg.sender, withdrawAmount);

        emit Unstaked(msg.sender, poolName, withdrawAmount);
    }

    /**
     * @notice Claim rewards from a pool
     * @param poolName Name of the pool to claim from
     */
    function claimRewards(
        string calldata poolName
    ) external validPool(poolName) updateReward(msg.sender, poolName) nonReentrant {
        UserStake storage userStake = userStakes[msg.sender][poolName];
        uint256 reward = userStake.rewards;
        
        if (reward > 0) {
            userStake.rewards = 0;
            claimedRewards[msg.sender] += reward;
            totalRewardsDistributed += reward;
            
            rewardPools[poolName].totalDistributed += reward;
            
            rewardToken.safeTransfer(msg.sender, reward);
            
            emit RewardClaimed(msg.sender, poolName, reward);
        }
    }

    /**
     * @notice Create a vesting schedule for a beneficiary
     * @param beneficiary Address of the beneficiary
     * @param amount Total amount to vest
     * @param duration Vesting duration
     * @param cliffDuration Cliff period before vesting starts
     * @param revocable Whether the schedule can be revoked
     */
    function createVestingSchedule(
        address beneficiary,
        uint256 amount,
        uint256 duration,
        uint256 cliffDuration,
        bool revocable
    ) external onlyRole(REWARDS_ADMIN_ROLE) {
        if (beneficiary == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }
        if (amount == 0 || duration == 0) {
            revert HedVaultErrors.InvalidConfiguration("Invalid parameters");
        }
        if (cliffDuration > duration) {
            revert HedVaultErrors.InvalidConfiguration("Cliff too long");
        }

        vestingSchedules[beneficiary].push(VestingSchedule({
            totalAmount: amount,
            releasedAmount: 0,
            startTime: block.timestamp,
            duration: duration,
            cliffDuration: cliffDuration,
            revocable: revocable,
            revoked: false
        }));

        // Transfer tokens to contract
        rewardToken.safeTransferFrom(msg.sender, address(this), amount);

        emit VestingScheduleCreated(beneficiary, amount, duration);
    }

    /**
     * @notice Release vested tokens
     * @param scheduleId ID of the vesting schedule
     */
    function releaseVestedTokens(uint256 scheduleId) external nonReentrant {
        VestingSchedule[] storage schedules = vestingSchedules[msg.sender];
        
        if (scheduleId >= schedules.length) {
            revert HedVaultErrors.InvalidConfiguration("Invalid schedule ID");
        }

        VestingSchedule storage schedule = schedules[scheduleId];
        
        if (schedule.revoked) {
            revert HedVaultErrors.InvalidConfiguration("Schedule revoked");
        }

        uint256 releasableAmount = _getReleasableAmount(schedule);
        
        if (releasableAmount == 0) {
            revert HedVaultErrors.InvalidConfiguration("No tokens to release");
        }

        schedule.releasedAmount += releasableAmount;
        
        rewardToken.safeTransfer(msg.sender, releasableAmount);
        
        emit VestingReleased(msg.sender, releasableAmount);
    }

    /**
     * @notice Revoke a vesting schedule (admin only)
     * @param beneficiary Address of the beneficiary
     * @param scheduleId ID of the schedule to revoke
     */
    function revokeVestingSchedule(
        address beneficiary,
        uint256 scheduleId
    ) external onlyRole(REWARDS_ADMIN_ROLE) {
        VestingSchedule[] storage schedules = vestingSchedules[beneficiary];
        
        if (scheduleId >= schedules.length) {
            revert HedVaultErrors.InvalidConfiguration("Invalid schedule ID");
        }

        VestingSchedule storage schedule = schedules[scheduleId];
        
        if (!schedule.revocable) {
            revert HedVaultErrors.InvalidConfiguration("Schedule not revocable");
        }
        if (schedule.revoked) {
            revert HedVaultErrors.InvalidConfiguration("Already revoked");
        }

        // Release any vested amount first
        uint256 releasableAmount = _getReleasableAmount(schedule);
        if (releasableAmount > 0) {
            schedule.releasedAmount += releasableAmount;
            rewardToken.safeTransfer(beneficiary, releasableAmount);
        }

        schedule.revoked = true;
        
        emit VestingRevoked(beneficiary, scheduleId);
    }

    /**
     * @notice Emergency withdraw for users (admin only)
     * @param user User address
     * @param amount Amount to withdraw
     */
    function emergencyWithdraw(
        address user,
        uint256 amount
    ) external onlyRole(EMERGENCY_ROLE) {
        if (totalStaked[user] < amount) {
            revert HedVaultErrors.InvalidConfiguration("Insufficient balance");
        }

        totalStaked[user] -= amount;
        rewardToken.safeTransfer(user, amount);
        
        emit EmergencyWithdraw(user, amount);
    }

    // View functions
    function lastTimeRewardApplicable(string memory poolName) public view returns (uint256) {
        RewardPool memory pool = rewardPools[poolName];
        return block.timestamp < pool.periodFinish ? block.timestamp : pool.periodFinish;
    }

    function rewardPerToken(string memory poolName) public view returns (uint256) {
        RewardPool memory pool = rewardPools[poolName];
        uint256 totalStakedInPool = poolTotalStaked[poolName];
        
        if (totalStakedInPool == 0) {
            return pool.rewardPerTokenStored;
        }
        
        return pool.rewardPerTokenStored + 
            (((lastTimeRewardApplicable(poolName) - pool.lastUpdateTime) * pool.rewardRate * 1e18) / totalStakedInPool);
    }

    function earned(address account, string memory poolName) public view returns (uint256) {
        UserStake memory userStake = userStakes[account][poolName];
        return (userStake.amount * (rewardPerToken(poolName) - userStake.rewardPerTokenPaid)) / 1e18 + userStake.rewards;
    }

    function getVestingScheduleCount(address beneficiary) external view returns (uint256) {
        return vestingSchedules[beneficiary].length;
    }

    function getVestingSchedule(address beneficiary, uint256 scheduleId) external view returns (VestingSchedule memory) {
        return vestingSchedules[beneficiary][scheduleId];
    }

    function getReleasableAmount(address beneficiary, uint256 scheduleId) external view returns (uint256) {
        VestingSchedule memory schedule = vestingSchedules[beneficiary][scheduleId];
        return _getReleasableAmount(schedule);
    }

    function getPoolNames() external view returns (string[] memory) {
        return poolNames;
    }

    function getUserStakeInfo(address user, string memory poolName) external view returns (UserStake memory) {
        return userStakes[user][poolName];
    }

    /**
     * @notice Get comprehensive user rewards data across all pools and activities
     * @param user User address to query
     * @return totalEarned Total rewards earned across all pools
     * @return totalPending Total pending rewards from activities
     * @return totalStakedAmount Total amount staked across all pools
     * @return totalClaimedRewards Total rewards already claimed
     * @return poolEarnings Array of earnings per active pool
     * @return poolStakes Array of stake amounts per active pool
     * @return vestingAmounts Array of releasable vesting amounts
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
        // Initialize return arrays
        poolEarnings = new uint256[](poolNames.length);
        poolStakes = new uint256[](poolNames.length);
        activePoolNames = new string[](poolNames.length);
        
        uint256 activePoolCount = 0;
        
        // Calculate totals across all pools
        for (uint256 i = 0; i < poolNames.length; i++) {
            string memory poolName = poolNames[i];
            
            if (rewardPools[poolName].isActive) {
                UserStake memory userStake = userStakes[user][poolName];
                uint256 poolEarned = earned(user, poolName);
                
                poolEarnings[activePoolCount] = poolEarned;
                poolStakes[activePoolCount] = userStake.amount;
                activePoolNames[activePoolCount] = poolName;
                
                totalEarned += poolEarned;
                totalStakedAmount += userStake.amount;
                activePoolCount++;
            }
        }
        
        // Resize arrays to actual active pool count
        assembly {
            mstore(poolEarnings, activePoolCount)
            mstore(poolStakes, activePoolCount)
            mstore(activePoolNames, activePoolCount)
        }
        
        // Add pending rewards from activity-based rewards
        totalPending = pendingRewards[user];
        totalEarned += totalPending;
        
        // Get claimed rewards
        totalClaimedRewards = claimedRewards[user];
        
        // Calculate vesting amounts
        VestingSchedule[] memory schedules = vestingSchedules[user];
        vestingAmounts = new uint256[](schedules.length);
        
        for (uint256 i = 0; i < schedules.length; i++) {
            if (!schedules[i].revoked) {
                vestingAmounts[i] = _getReleasableAmount(schedules[i]);
                totalEarned += vestingAmounts[i];
            }
        }
        
        return (
            totalEarned,
            totalPending,
            totalStakedAmount,
            totalClaimedRewards,
            poolEarnings,
            poolStakes,
            vestingAmounts,
            activePoolNames
        );
    }

    /**
     * @notice Get detailed breakdown of user's position across all protocol activities
     * @param user User address to query
     * @return stakingRewards Rewards from staking activities
     * @return tradingRewards Rewards from trading activities
     * @return lendingRewards Rewards from lending activities
     * @return governanceRewards Rewards from governance participation
     * @return marketplaceRewards Rewards from marketplace activities
     * @return liquidityRewards Rewards from liquidity provision
     * @return rwaRewards Rewards from RWA tokenization
     * @return referralRewards Rewards from referral program
     * @return totalVestingAmount Total amount in vesting schedules
     * @return totalReleasableVesting Total releasable vesting amount
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
        // Get rewards from each specific pool
        stakingRewards = earned(user, "staking");
        tradingRewards = earned(user, "trading");
        lendingRewards = earned(user, "lending");
        governanceRewards = earned(user, "governance");
        marketplaceRewards = earned(user, "marketplace");
        liquidityRewards = earned(user, "liquidity");
        rwaRewards = earned(user, "rwa_tokenization");
        referralRewards = earned(user, "referral");
        
        // Calculate vesting totals
        VestingSchedule[] memory schedules = vestingSchedules[user];
        for (uint256 i = 0; i < schedules.length; i++) {
            if (!schedules[i].revoked) {
                totalVestingAmount += schedules[i].totalAmount - schedules[i].releasedAmount;
                totalReleasableVesting += _getReleasableAmount(schedules[i]);
            }
        }
        
        return (
            stakingRewards,
            tradingRewards,
            lendingRewards,
            governanceRewards,
            marketplaceRewards,
            liquidityRewards,
            rwaRewards,
            referralRewards,
            totalVestingAmount,
            totalReleasableVesting
        );
    }

    // Internal functions
    function _getReleasableAmount(VestingSchedule memory schedule) internal view returns (uint256) {
        if (schedule.revoked) {
            return 0;
        }
        
        uint256 currentTime = block.timestamp;
        
        if (currentTime < schedule.startTime + schedule.cliffDuration) {
            return 0;
        }
        
        if (currentTime >= schedule.startTime + schedule.duration) {
            return schedule.totalAmount - schedule.releasedAmount;
        }
        
        uint256 timeFromStart = currentTime - schedule.startTime;
        uint256 vestedAmount = (schedule.totalAmount * timeFromStart) / schedule.duration;
        
        return vestedAmount - schedule.releasedAmount;
    }

    /**
     * @notice Calculate reward amount based on activity type and amount
     * @param activityType Type of activity
     * @param amount Activity amount
     * @return Calculated reward amount
     */
    function _calculateActivityReward(string memory activityType, uint256 amount) internal pure returns (uint256) {
        // Different reward rates for different activities
        if (keccak256(bytes(activityType)) == keccak256(bytes("trading"))) {
            return (amount * 10) / BASIS_POINTS; // 0.1% of trading volume
        } else if (keccak256(bytes(activityType)) == keccak256(bytes("lending"))) {
            return (amount * 50) / BASIS_POINTS; // 0.5% of lending amount
        } else if (keccak256(bytes(activityType)) == keccak256(bytes("staking"))) {
            return (amount * 100) / BASIS_POINTS; // 1% of staking amount
        } else if (keccak256(bytes(activityType)) == keccak256(bytes("governance"))) {
            return 1000 * 10**18; // Fixed 1000 tokens for governance participation
        } else if (keccak256(bytes(activityType)) == keccak256(bytes("marketplace"))) {
            return (amount * 25) / BASIS_POINTS; // 0.25% of marketplace transaction value
        } else if (keccak256(bytes(activityType)) == keccak256(bytes("liquidity"))) {
            return (amount * 75) / BASIS_POINTS; // 0.75% of liquidity provided
        } else if (keccak256(bytes(activityType)) == keccak256(bytes("rwa_tokenization"))) {
            return (amount * 200) / BASIS_POINTS; // 2% of RWA tokenization value
        } else if (keccak256(bytes(activityType)) == keccak256(bytes("referral"))) {
            return 500 * 10**18; // Fixed 500 tokens for successful referral
        }
        
        return 0;
    }

    // Admin functions
    function updateStakingFee(uint256 newFee) external onlyRole(REWARDS_ADMIN_ROLE) {
        if (newFee > MAX_FEE) {
            revert HedVaultErrors.InvalidConfiguration("Fee too high");
        }
        stakingFee = newFee;
    }

    function updateUnstakingFee(uint256 newFee) external onlyRole(REWARDS_ADMIN_ROLE) {
        if (newFee > MAX_FEE) {
            revert HedVaultErrors.InvalidConfiguration("Fee too high");
        }
        unstakingFee = newFee;
    }

    function updateRewardPool(
        string calldata poolName,
        uint256 newRewardRate,
        uint256 newDuration
    ) external onlyRole(REWARDS_ADMIN_ROLE) updateReward(address(0), poolName) {
        RewardPool storage pool = rewardPools[poolName];
        
        if (!pool.isActive) {
            revert HedVaultErrors.InvalidConfiguration("Pool not active");
        }

        pool.rewardRate = newRewardRate;
        pool.duration = newDuration;
        pool.periodFinish = block.timestamp + newDuration;
        
        emit RewardPoolUpdated(poolName, newRewardRate, newDuration);
    }

    function pause() external onlyRole(EMERGENCY_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(EMERGENCY_ROLE) {
        _unpause();
    }

    function deactivatePool(string calldata poolName) external onlyRole(REWARDS_ADMIN_ROLE) {
        rewardPools[poolName].isActive = false;
    }

    function activatePool(string calldata poolName) external onlyRole(REWARDS_ADMIN_ROLE) {
        rewardPools[poolName].isActive = true;
    }
}