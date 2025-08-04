// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title DataTypes
 * @notice Common data structures used throughout the HedVault protocol
 */
library DataTypes {
    /**
     * @notice Real World Asset metadata structure
     * @param assetType Type of RWA (real estate, precious metals, art, etc.)
     * @param location Physical location of the asset
     * @param valuation Current valuation in USD
     * @param lastValuationDate Timestamp of last valuation
     * @param certificationHash IPFS hash of certification documents
     * @param isActive Whether the asset is currently active
     */
    struct RWAMetadata {
        string assetType;
        string location;
        uint256 valuation;
        uint256 lastValuationDate;
        string certificationHash;
        bool isActive;
        address oracle;
        uint256 totalSupply;
        uint256 minInvestment;
    }

    /**
     * @notice Asset information structure
     * @param tokenAddress Address of the RWA token
     * @param creator Address of the asset creator
     * @param creationTime Timestamp when asset was tokenized
     * @param metadata RWA metadata
     * @param complianceLevel KYC/AML compliance level required
     */
    struct AssetInfo {
        address tokenAddress;
        address creator;
        uint256 creationTime;
        RWAMetadata metadata;
        uint8 complianceLevel;
        bool isListed;
        uint256 tradingVolume;
        uint256 holders;
    }

    /**
     * @notice User profile structure
     * @param isVerified KYC verification status
     * @param complianceLevel User's compliance level
     * @param registrationDate When user registered
     * @param totalInvested Total amount invested by user
     * @param portfolioValue Current portfolio value
     */
    struct UserProfile {
        bool isVerified;
        uint8 complianceLevel;
        uint256 registrationDate;
        uint256 totalInvested;
        uint256 portfolioValue;
        uint256 rewardsClaimed;
        address[] ownedAssets;
    }

    /**
     * @notice Loan information structure
     * @param borrower Address of the borrower
     * @param collateralToken Address of collateral token
     * @param collateralAmount Amount of collateral
     * @param borrowAmount Amount borrowed
     * @param interestRate Interest rate (basis points)
     * @param duration Loan duration in seconds
     * @param startTime Loan start timestamp
     * @param isActive Whether loan is active
     */
    struct LoanInfo {
        address borrower;
        address collateralToken;
        uint256 collateralAmount;
        uint256 borrowAmount;
        uint256 interestRate;
        uint256 duration;
        uint256 startTime;
        bool isActive;
        uint256 repaidAmount;
        bool isLiquidated;
    }

    /**
     * @notice Reward information structure
     * @param user Address of the user
     * @param rewardType Type of reward (staking, trading, etc.)
     * @param amount Reward amount
     * @param timestamp When reward was earned
     * @param isClaimed Whether reward has been claimed
     */
    struct RewardInfo {
        address user;
        string rewardType;
        uint256 amount;
        uint256 timestamp;
        bool isClaimed;
        uint256 vestingPeriod;
        uint256 claimableDate;
    }

    /**
     * @notice Order structure for marketplace
     * @param orderId Unique order identifier
     * @param seller Address of the seller
     * @param buyer Address of the buyer (0x0 for open orders)
     * @param tokenAddress Address of the token being traded
     * @param amount Amount of tokens
     * @param price Price per token
     * @param orderType 0 = buy, 1 = sell
     * @param status Order status (0 = open, 1 = filled, 2 = cancelled)
     * @param createdAt Order creation timestamp
     */
    struct Order {
        uint256 orderId;
        address seller;
        address buyer;
        address tokenAddress;
        uint256 amount;
        uint256 price;
        uint8 orderType;
        uint8 status;
        uint256 createdAt;
        uint256 filledAmount;
    }

    /**
     * @notice Swap information structure
     * @param user Address initiating the swap
     * @param tokenIn Input token address
     * @param tokenOut Output token address
     * @param amountIn Input amount
     * @param amountOut Output amount
     * @param slippageTolerance Maximum slippage allowed (basis points)
     * @param deadline Swap deadline timestamp
     */
    struct SwapInfo {
        address user;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 amountOut;
        uint256 slippageTolerance;
        uint256 deadline;
        uint256 executedAt;
        bool isCompleted;
    }

    /**
     * @notice Price feed information
     * @param oracle Oracle address
     * @param price Current price
     * @param timestamp Last update timestamp
     * @param decimals Price decimals
     * @param isActive Whether feed is active
     */
    struct PriceFeed {
        address oracle;
        uint256 price;
        uint256 timestamp;
        uint8 decimals;
        bool isActive;
        uint256 heartbeat;
        uint256 deviation;
    }

    /**
     * @notice Portfolio allocation structure
     * @param tokenAddress Address of the asset token
     * @param allocation Percentage allocation (basis points)
     * @param currentValue Current value in USD
     * @param targetValue Target value in USD
     */
    struct PortfolioAllocation {
        address tokenAddress;
        uint256 allocation;
        uint256 currentValue;
        uint256 targetValue;
        uint256 lastRebalance;
    }

    // Enums for better type safety
    enum AssetType {
        RealEstate,
        PreciousMetals,
        Art,
        Commodities,
        Bonds,
        Other
    }

    enum OrderStatus {
        Open,
        Filled,
        Cancelled,
        PartiallyFilled
    }

    enum LoanStatus {
        Active,
        Repaid,
        Liquidated,
        Defaulted
    }

    enum ComplianceLevel {
        None,
        Basic,
        Intermediate,
        Advanced,
        Institutional
    }

    // Constants
    uint256 public constant BASIS_POINTS = 10000;
    uint256 public constant MAX_SLIPPAGE = 1000; // 10%
    uint256 public constant MIN_LOAN_DURATION = 1 days;
    uint256 public constant MAX_LOAN_DURATION = 365 days;
    uint256 public constant PRICE_STALENESS_THRESHOLD = 1 hours;
}
