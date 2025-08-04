// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IHedVaultCore.sol";
import "./PriceOracle.sol";
import "./libraries/DataTypes.sol";
import "./libraries/Events.sol";
import "./libraries/HedVaultErrors.sol";

/**
 * @title SwapEngine
 * @notice Automated Market Maker for RWA-to-RWA token swaps
 * @dev Implements constant product formula with dynamic fees and slippage protection
 */
contract SwapEngine is AccessControl, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    // Roles
    bytes32 public constant SWAP_ADMIN_ROLE = keccak256("SWAP_ADMIN_ROLE");
    bytes32 public constant LIQUIDITY_MANAGER_ROLE =
        keccak256("LIQUIDITY_MANAGER_ROLE");
    bytes32 public constant FEE_MANAGER_ROLE = keccak256("FEE_MANAGER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");

    // Core protocol references
    IHedVaultCore public immutable hedVaultCore;
    PriceOracle public immutable priceOracle;

    // Pool structures
    struct LiquidityPool {
        address tokenA;
        address tokenB;
        uint256 reserveA;
        uint256 reserveB;
        uint256 totalLiquidity;
        uint256 feeRate; // Basis points
        uint256 lastUpdate;
        bool isActive;
        uint256 minLiquidity;
        uint256 maxSlippage; // Basis points
    }

    struct LiquidityPosition {
        address provider;
        uint256 poolId;
        uint256 liquidity;
        uint256 tokenADeposited;
        uint256 tokenBDeposited;
        uint256 createdAt;
        uint256 lastRewardClaim;
        uint256 accumulatedFees;
    }

    struct SwapInfo {
        uint256 swapId;
        address user;
        uint256 poolId;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 amountOut;
        uint256 fee;
        uint256 slippage;
        uint256 timestamp;
        uint256 priceImpact;
    }

    struct PoolStats {
        uint256 totalVolume;
        uint256 totalSwaps;
        uint256 totalFeesCollected;
        uint256 apy; // Annual Percentage Yield for LPs
        uint256 utilization; // Pool utilization rate
        uint256 lastStatsUpdate;
    }

    // State variables
    mapping(uint256 => LiquidityPool) public pools;
    mapping(bytes32 => uint256) public poolIds; // keccak256(tokenA, tokenB) => poolId
    mapping(uint256 => LiquidityPosition[]) public poolPositions;
    mapping(address => uint256[]) public userPositions; // user => position IDs
    mapping(uint256 => SwapInfo) public swaps;
    mapping(uint256 => PoolStats) public poolStats;
    mapping(address => bool) public supportedTokens;

    uint256 public nextPoolId = 1;
    uint256 public nextSwapId = 1;
    uint256 public totalPools;

    // Protocol settings
    uint256 public constant MIN_LIQUIDITY = 1000; // Minimum liquidity to prevent division by zero
    uint256 public constant MAX_FEE_RATE = 1000; // 10% maximum fee
    uint256 public constant MAX_SLIPPAGE = 5000; // 50% maximum slippage
    uint256 public defaultFeeRate = 30; // 0.3% default fee
    uint256 public protocolFeeShare = 1000; // 10% of swap fees go to protocol

    address public feeRecipient;
    uint256 public totalProtocolFees;

    // Events
    event PoolCreated(
        uint256 indexed poolId,
        address indexed tokenA,
        address indexed tokenB,
        uint256 initialLiquidityA,
        uint256 initialLiquidityB
    );
    event LiquidityAdded(
        uint256 indexed poolId,
        address indexed provider,
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );
    event LiquidityRemoved(
        uint256 indexed poolId,
        address indexed provider,
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );
    event SwapExecuted(
        uint256 indexed swapId,
        uint256 indexed poolId,
        address indexed user,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        uint256 fee
    );
    event FeesUpdated(uint256 poolId, uint256 oldFeeRate, uint256 newFeeRate);
    event PoolStatsUpdated(
        uint256 indexed poolId,
        uint256 apy,
        uint256 utilization
    );

    modifier validPool(uint256 poolId) {
        if (poolId == 0 || poolId >= nextPoolId) {
            revert HedVaultErrors.InvalidConfiguration("Pool not found");
        }
        if (!pools[poolId].isActive) {
            revert HedVaultErrors.InvalidConfiguration("Pool not active");
        }
        _;
    }

    modifier supportedToken(address token) {
        if (!supportedTokens[token]) {
            revert HedVaultErrors.TokenNotListed(token);
        }
        _;
    }

    constructor(
        address _hedVaultCore,
        address _priceOracle,
        address _feeRecipient
    ) {
        if (
            _hedVaultCore == address(0) ||
            _priceOracle == address(0) ||
            _feeRecipient == address(0)
        ) {
            revert HedVaultErrors.ZeroAddress();
        }

        hedVaultCore = IHedVaultCore(_hedVaultCore);
        priceOracle = PriceOracle(_priceOracle);
        feeRecipient = _feeRecipient;

        // Set up roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SWAP_ADMIN_ROLE, msg.sender);
        _grantRole(LIQUIDITY_MANAGER_ROLE, msg.sender);
        _grantRole(FEE_MANAGER_ROLE, msg.sender);
        _grantRole(EMERGENCY_ROLE, msg.sender);
    }

    /**
     * @notice Create a new liquidity pool
     * @param tokenA First token address
     * @param tokenB Second token address
     * @param amountA Initial amount of tokenA
     * @param amountB Initial amount of tokenB
     * @param feeRate Pool fee rate in basis points
     * @return poolId New pool ID
     */
    function createPool(
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        uint256 feeRate
    )
        external
        supportedToken(tokenA)
        supportedToken(tokenB)
        whenNotPaused
        nonReentrant
        returns (uint256 poolId)
    {
        if (tokenA == tokenB) {
            revert HedVaultErrors.InvalidConfiguration(
                "Cannot create pool with same token"
            );
        }
        if (amountA == 0 || amountB == 0) {
            revert HedVaultErrors.ZeroAmount();
        }
        if (feeRate > MAX_FEE_RATE) {
            revert HedVaultErrors.FeeTooHigh(feeRate, MAX_FEE_RATE);
        }

        // Ensure consistent token ordering
        if (tokenA > tokenB) {
            (tokenA, tokenB) = (tokenB, tokenA);
            (amountA, amountB) = (amountB, amountA);
        }

        bytes32 poolKey = keccak256(abi.encodePacked(tokenA, tokenB));
        if (poolIds[poolKey] != 0) {
            revert HedVaultErrors.InvalidConfiguration("Pool already exists");
        }

        poolId = nextPoolId++;
        poolIds[poolKey] = poolId;

        // Calculate initial liquidity (geometric mean)
        uint256 initialLiquidity = _sqrt(amountA * amountB);
        if (initialLiquidity <= MIN_LIQUIDITY) {
            revert HedVaultErrors.InvalidAmount(
                initialLiquidity,
                MIN_LIQUIDITY,
                type(uint256).max
            );
        }

        pools[poolId] = LiquidityPool({
            tokenA: tokenA,
            tokenB: tokenB,
            reserveA: amountA,
            reserveB: amountB,
            totalLiquidity: initialLiquidity,
            feeRate: feeRate == 0 ? defaultFeeRate : feeRate,
            lastUpdate: block.timestamp,
            isActive: true,
            minLiquidity: MIN_LIQUIDITY,
            maxSlippage: MAX_SLIPPAGE
        });

        // Transfer tokens from creator
        IERC20(tokenA).safeTransferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).safeTransferFrom(msg.sender, address(this), amountB);

        // Create initial liquidity position
        poolPositions[poolId].push(
            LiquidityPosition({
                provider: msg.sender,
                poolId: poolId,
                liquidity: initialLiquidity,
                tokenADeposited: amountA,
                tokenBDeposited: amountB,
                createdAt: block.timestamp,
                lastRewardClaim: block.timestamp,
                accumulatedFees: 0
            })
        );

        userPositions[msg.sender].push(poolPositions[poolId].length - 1);
        totalPools++;

        emit PoolCreated(poolId, tokenA, tokenB, amountA, amountB);
    }

    /**
     * @notice Add liquidity to an existing pool
     * @param poolId Pool ID
     * @param amountA Amount of tokenA to add
     * @param amountB Amount of tokenB to add
     * @param minLiquidity Minimum liquidity tokens to receive
     * @return liquidity Liquidity tokens received
     */
    function addLiquidity(
        uint256 poolId,
        uint256 amountA,
        uint256 amountB,
        uint256 minLiquidity
    )
        external
        validPool(poolId)
        whenNotPaused
        nonReentrant
        returns (uint256 liquidity)
    {
        LiquidityPool storage pool = pools[poolId];

        if (amountA == 0 || amountB == 0) {
            revert HedVaultErrors.ZeroAmount();
        }

        // Calculate optimal amounts based on current pool ratio
        uint256 optimalAmountB = (amountA * pool.reserveB) / pool.reserveA;
        uint256 optimalAmountA = (amountB * pool.reserveA) / pool.reserveB;

        uint256 finalAmountA;
        uint256 finalAmountB;

        if (optimalAmountB <= amountB) {
            finalAmountA = amountA;
            finalAmountB = optimalAmountB;
        } else {
            finalAmountA = optimalAmountA;
            finalAmountB = amountB;
        }

        // Calculate liquidity tokens to mint
        liquidity = _min(
            (finalAmountA * pool.totalLiquidity) / pool.reserveA,
            (finalAmountB * pool.totalLiquidity) / pool.reserveB
        );

        if (liquidity < minLiquidity) {
            revert HedVaultErrors.InvalidAmount(
                liquidity,
                1,
                type(uint256).max
            );
        }

        // Update pool reserves
        pool.reserveA += finalAmountA;
        pool.reserveB += finalAmountB;
        pool.totalLiquidity += liquidity;
        pool.lastUpdate = block.timestamp;

        // Transfer tokens from user
        IERC20(pool.tokenA).safeTransferFrom(
            msg.sender,
            address(this),
            finalAmountA
        );
        IERC20(pool.tokenB).safeTransferFrom(
            msg.sender,
            address(this),
            finalAmountB
        );

        // Create liquidity position
        poolPositions[poolId].push(
            LiquidityPosition({
                provider: msg.sender,
                poolId: poolId,
                liquidity: liquidity,
                tokenADeposited: finalAmountA,
                tokenBDeposited: finalAmountB,
                createdAt: block.timestamp,
                lastRewardClaim: block.timestamp,
                accumulatedFees: 0
            })
        );

        userPositions[msg.sender].push(poolPositions[poolId].length - 1);

        emit LiquidityAdded(
            poolId,
            msg.sender,
            finalAmountA,
            finalAmountB,
            liquidity
        );
    }

    /**
     * @notice Remove liquidity from a pool
     * @param poolId Pool ID
     * @param positionIndex Position index in the pool
     * @param liquidity Amount of liquidity to remove
     * @param minAmountA Minimum amount of tokenA to receive
     * @param minAmountB Minimum amount of tokenB to receive
     * @return amountA Amount of tokenA received
     * @return amountB Amount of tokenB received
     */
    function removeLiquidity(
        uint256 poolId,
        uint256 positionIndex,
        uint256 liquidity,
        uint256 minAmountA,
        uint256 minAmountB
    )
        external
        validPool(poolId)
        nonReentrant
        returns (uint256 amountA, uint256 amountB)
    {
        LiquidityPool storage pool = pools[poolId];

        if (positionIndex >= poolPositions[poolId].length) {
            revert HedVaultErrors.InvalidConfiguration(
                "Invalid position index"
            );
        }

        LiquidityPosition storage position = poolPositions[poolId][
            positionIndex
        ];

        if (position.provider != msg.sender) {
            revert HedVaultErrors.UnauthorizedAccess(
                msg.sender,
                "position owner"
            );
        }
        if (liquidity > position.liquidity) {
            revert HedVaultErrors.InsufficientBalance(
                address(this),
                position.liquidity,
                liquidity
            );
        }

        // Calculate amounts to return
        amountA = (liquidity * pool.reserveA) / pool.totalLiquidity;
        amountB = (liquidity * pool.reserveB) / pool.totalLiquidity;

        if (amountA < minAmountA || amountB < minAmountB) {
            revert HedVaultErrors.SlippageExceeded(0, 1);
        }

        // Check minimum liquidity requirement
        if (pool.totalLiquidity - liquidity < pool.minLiquidity) {
            revert HedVaultErrors.InvalidAmount(
                pool.totalLiquidity - liquidity,
                1,
                type(uint256).max
            );
        }

        // Update pool and position
        pool.reserveA -= amountA;
        pool.reserveB -= amountB;
        pool.totalLiquidity -= liquidity;
        pool.lastUpdate = block.timestamp;

        position.liquidity -= liquidity;

        // Remove position if empty
        if (position.liquidity == 0) {
            _removePosition(poolId, positionIndex);
        }

        // Transfer tokens to user
        IERC20(pool.tokenA).safeTransfer(msg.sender, amountA);
        IERC20(pool.tokenB).safeTransfer(msg.sender, amountB);

        emit LiquidityRemoved(poolId, msg.sender, amountA, amountB, liquidity);
    }

    /**
     * @notice Execute a token swap
     * @param poolId Pool ID
     * @param tokenIn Input token address
     * @param amountIn Input amount
     * @param minAmountOut Minimum output amount
     * @param maxSlippage Maximum acceptable slippage in basis points
     * @return amountOut Output amount received
     */
    function swap(
        uint256 poolId,
        address tokenIn,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 maxSlippage
    )
        external
        validPool(poolId)
        whenNotPaused
        nonReentrant
        returns (uint256 amountOut)
    {
        LiquidityPool storage pool = pools[poolId];

        if (amountIn == 0) {
            revert HedVaultErrors.ZeroAmount();
        }
        if (tokenIn != pool.tokenA && tokenIn != pool.tokenB) {
            revert HedVaultErrors.TokenNotListed(tokenIn);
        }
        if (maxSlippage > pool.maxSlippage) {
            revert HedVaultErrors.SlippageExceeded(
                maxSlippage,
                pool.maxSlippage
            );
        }

        address tokenOut = tokenIn == pool.tokenA ? pool.tokenB : pool.tokenA;
        bool isTokenAIn = tokenIn == pool.tokenA;

        // Calculate output amount using constant product formula
        (amountOut, ) = _getAmountOut(poolId, tokenIn, amountIn);

        if (amountOut < minAmountOut) {
            revert HedVaultErrors.SlippageExceeded(amountOut, minAmountOut);
        }

        // Calculate and validate slippage
        uint256 slippage = _calculateSlippage(
            poolId,
            tokenIn,
            amountIn,
            amountOut
        );
        if (slippage > maxSlippage) {
            revert HedVaultErrors.SlippageExceeded(slippage, maxSlippage);
        }

        // Calculate fee
        uint256 fee = (amountIn * pool.feeRate) / 10000;
        uint256 amountInAfterFee = amountIn - fee;

        // Update reserves
        if (isTokenAIn) {
            pool.reserveA += amountInAfterFee;
            pool.reserveB -= amountOut;
        } else {
            pool.reserveB += amountInAfterFee;
            pool.reserveA -= amountOut;
        }

        pool.lastUpdate = block.timestamp;

        // Transfer tokens
        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenOut).safeTransfer(msg.sender, amountOut);

        // Handle fees
        uint256 protocolFee = (fee * protocolFeeShare) / 10000;
        uint256 lpFee = fee - protocolFee;

        if (protocolFee > 0) {
            IERC20(tokenIn).safeTransfer(feeRecipient, protocolFee);
            totalProtocolFees += protocolFee;
        }

        // Distribute LP fees to liquidity providers
        _distributeLPFees(poolId, lpFee, tokenIn);

        // Record swap
        uint256 swapId = nextSwapId++;
        swaps[swapId] = SwapInfo({
            swapId: swapId,
            user: msg.sender,
            poolId: poolId,
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            amountIn: amountIn,
            amountOut: amountOut,
            fee: fee,
            slippage: slippage,
            timestamp: block.timestamp,
            priceImpact: _calculatePriceImpact(poolId, tokenIn, amountIn)
        });

        // Update pool stats
        _updatePoolStats(poolId, amountIn, fee);

        emit SwapExecuted(
            swapId,
            poolId,
            msg.sender,
            tokenIn,
            tokenOut,
            amountIn,
            amountOut,
            fee
        );
    }

    /**
     * @notice Get swap quote
     * @param poolId Pool ID
     * @param tokenIn Input token address
     * @param amountIn Input amount
     * @return amountOut Expected output amount
     * @return fee Swap fee
     */
    function getSwapQuote(
        uint256 poolId,
        address tokenIn,
        uint256 amountIn
    ) external view validPool(poolId) returns (uint256 amountOut, uint256 fee) {
        return _getAmountOut(poolId, tokenIn, amountIn);
    }

    /**
     * @notice Add supported token
     * @param token Token address
     */
    function addSupportedToken(
        address token
    ) external onlyRole(SWAP_ADMIN_ROLE) {
        if (token == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }
        supportedTokens[token] = true;
    }

    /**
     * @notice Update pool fee rate
     * @param poolId Pool ID
     * @param newFeeRate New fee rate in basis points
     */
    function updatePoolFeeRate(
        uint256 poolId,
        uint256 newFeeRate
    ) external onlyRole(FEE_MANAGER_ROLE) validPool(poolId) {
        if (newFeeRate > MAX_FEE_RATE) {
            revert HedVaultErrors.FeeTooHigh(newFeeRate, MAX_FEE_RATE);
        }

        uint256 oldFeeRate = pools[poolId].feeRate;
        pools[poolId].feeRate = newFeeRate;

        emit FeesUpdated(poolId, oldFeeRate, newFeeRate);
    }

    // View functions
    function getPool(
        uint256 poolId
    ) external view returns (LiquidityPool memory) {
        return pools[poolId];
    }

    function getPoolByTokens(
        address tokenA,
        address tokenB
    ) external view returns (uint256 poolId) {
        if (tokenA > tokenB) {
            (tokenA, tokenB) = (tokenB, tokenA);
        }
        bytes32 poolKey = keccak256(abi.encodePacked(tokenA, tokenB));
        return poolIds[poolKey];
    }

    function getPoolPositions(
        uint256 poolId
    ) external view returns (LiquidityPosition[] memory) {
        return poolPositions[poolId];
    }

    function getUserPositions(
        address user
    ) external view returns (uint256[] memory) {
        return userPositions[user];
    }

    function getPoolStats(
        uint256 poolId
    ) external view returns (PoolStats memory) {
        return poolStats[poolId];
    }

    /**
     * @notice Pause the contract
     */
    function pause() external onlyRole(EMERGENCY_ROLE) {
        _pause();
    }

    /**
     * @notice Unpause the contract
     */
    function unpause() external onlyRole(EMERGENCY_ROLE) {
        _unpause();
    }

    // Internal functions
    function _getAmountOut(
        uint256 poolId,
        address tokenIn,
        uint256 amountIn
    ) internal view returns (uint256 amountOut, uint256 fee) {
        LiquidityPool memory pool = pools[poolId];

        fee = (amountIn * pool.feeRate) / 10000;
        uint256 amountInAfterFee = amountIn - fee;

        bool isTokenAIn = tokenIn == pool.tokenA;
        uint256 reserveIn = isTokenAIn ? pool.reserveA : pool.reserveB;
        uint256 reserveOut = isTokenAIn ? pool.reserveB : pool.reserveA;

        // Constant product formula: x * y = k
        // amountOut = (amountInAfterFee * reserveOut) / (reserveIn + amountInAfterFee)
        amountOut =
            (amountInAfterFee * reserveOut) /
            (reserveIn + amountInAfterFee);
    }

    function _calculateSlippage(
        uint256 poolId,
        address tokenIn,
        uint256 amountIn,
        uint256 amountOut
    ) internal view returns (uint256) {
        // Get oracle prices for slippage calculation
        LiquidityPool memory pool = pools[poolId];
        address tokenOut = tokenIn == pool.tokenA ? pool.tokenB : pool.tokenA;

        try priceOracle.getPrice(tokenIn) returns (
            uint256 priceIn,
            uint256,
            uint256
        ) {
            try priceOracle.getPrice(tokenOut) returns (
                uint256 priceOut,
                uint256,
                uint256
            ) {
                uint256 expectedOut = (amountIn * priceIn) / priceOut;
                if (expectedOut == 0) return 0;

                uint256 slippage = expectedOut > amountOut
                    ? ((expectedOut - amountOut) * 10000) / expectedOut
                    : 0;

                return slippage;
            } catch {
                return 0;
            }
        } catch {
            return 0;
        }
    }

    function _calculatePriceImpact(
        uint256 poolId,
        address tokenIn,
        uint256 amountIn
    ) internal view returns (uint256) {
        LiquidityPool memory pool = pools[poolId];
        bool isTokenAIn = tokenIn == pool.tokenA;
        uint256 reserveIn = isTokenAIn ? pool.reserveA : pool.reserveB;

        // Price impact = amountIn / (reserveIn + amountIn) * 10000
        return (amountIn * 10000) / (reserveIn + amountIn);
    }

    function _distributeLPFees(
        uint256 poolId,
        uint256 feeAmount,
        address
    ) internal {
        LiquidityPosition[] storage positions = poolPositions[poolId];
        LiquidityPool memory pool = pools[poolId];

        for (uint256 i = 0; i < positions.length; i++) {
            uint256 share = (positions[i].liquidity * feeAmount) /
                pool.totalLiquidity;
            positions[i].accumulatedFees += share;
        }
    }

    function _updatePoolStats(
        uint256 poolId,
        uint256 volume,
        uint256 fees
    ) internal {
        PoolStats storage stats = poolStats[poolId];

        stats.totalVolume += volume;
        stats.totalSwaps++;
        stats.totalFeesCollected += fees;
        stats.lastStatsUpdate = block.timestamp;

        // Calculate APY and utilization (simplified)
        // In a real implementation, this would be more sophisticated
        LiquidityPool memory pool = pools[poolId];
        uint256 totalLiquidity = pool.reserveA + pool.reserveB;
        stats.utilization = totalLiquidity > 0
            ? (volume * 10000) / totalLiquidity
            : 0;

        emit PoolStatsUpdated(poolId, stats.apy, stats.utilization);
    }

    function _removePosition(uint256 poolId, uint256 positionIndex) internal {
        LiquidityPosition[] storage positions = poolPositions[poolId];

        if (positionIndex < positions.length - 1) {
            positions[positionIndex] = positions[positions.length - 1];
        }
        positions.pop();
    }

    function _sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }

    function _min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}
