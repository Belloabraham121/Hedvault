// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../RewardsDistributor.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title AutoRewardExample
 * @notice Example contract showing how to automatically distribute ERC-20 rewards
 * @dev This demonstrates integration with RewardsDistributor for automatic reward distribution
 */
contract AutoRewardExample {
    RewardsDistributor public immutable rewardsDistributor;
    IERC20 public immutable tradingToken;
    
    mapping(address => uint256) public userTradingVolume;
    mapping(address => uint256) public userLendingAmount;
    
    event TradeExecuted(address indexed user, uint256 volume);
    event LoanCreated(address indexed user, uint256 amount);
    event RewardsDistributed(address indexed user, string activityType, uint256 amount);
    
    constructor(address _rewardsDistributor, address _tradingToken) {
        rewardsDistributor = RewardsDistributor(_rewardsDistributor);
        tradingToken = IERC20(_tradingToken);
    }
    
    /**
     * @notice Execute a trade and automatically distribute rewards
     * @param amount Trading volume
     */
    function executeTrade(uint256 amount) external {
        // Simulate trade execution
        userTradingVolume[msg.sender] += amount;
        
        // Automatically distribute trading rewards (0.1% of volume)
        rewardsDistributor.distributeActivityReward(msg.sender, "trading", amount);
        
        emit TradeExecuted(msg.sender, amount);
        emit RewardsDistributed(msg.sender, "trading", amount);
    }
    
    /**
     * @notice Create a loan and automatically distribute rewards
     * @param amount Loan amount
     */
    function createLoan(uint256 amount) external {
        // Simulate loan creation
        userLendingAmount[msg.sender] += amount;
        
        // Automatically distribute lending rewards (0.5% of loan amount)
        rewardsDistributor.distributeActivityReward(msg.sender, "lending", amount);
        
        emit LoanCreated(msg.sender, amount);
        emit RewardsDistributed(msg.sender, "lending", amount);
    }
    
    /**
     * @notice Participate in governance and get rewards
     */
    function participateInGovernance() external {
        // Automatically distribute governance rewards (fixed 1000 tokens)
        rewardsDistributor.distributeActivityReward(msg.sender, "governance", 1);
        
        emit RewardsDistributed(msg.sender, "governance", 1);
    }
    
    /**
     * @notice Claim all pending rewards automatically
     */
    function claimMyRewards() external {
        rewardsDistributor.autoClaimRewards(msg.sender);
    }
    
    /**
     * @notice Get user's pending rewards
     * @param user User address
     * @return Pending reward amount
     */
    function getPendingRewards(address user) external view returns (uint256) {
        return rewardsDistributor.pendingRewards(user);
    }
    
    /**
     * @notice Get user's total claimed rewards
     * @param user User address
     * @return Total claimed rewards
     */
    function getClaimedRewards(address user) external view returns (uint256) {
        return rewardsDistributor.claimedRewards(user);
    }
}