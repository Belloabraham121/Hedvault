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
 * @title PortfolioManager
 * @notice Manages user portfolios and asset allocations
 * @dev Handles portfolio creation, rebalancing, and performance tracking
 */
contract PortfolioManager is AccessControl, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    // Roles
    bytes32 public constant PORTFOLIO_ADMIN_ROLE =
        keccak256("PORTFOLIO_ADMIN_ROLE");
    bytes32 public constant REBALANCER_ROLE = keccak256("REBALANCER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");

    // Core protocol references
    IHedVaultCore public immutable hedVaultCore;
    PriceOracle public immutable priceOracle;

    // Portfolio structures
    struct Portfolio {
        address owner;
        string name;
        DataTypes.PortfolioAllocation[] allocations;
        uint256 totalValue; // Cached total value in USD
        uint256 lastRebalance;
        uint256 createdAt;
        bool isActive;
        uint8 riskLevel; // 1-10 scale
        uint256 targetRebalanceThreshold; // Basis points (e.g., 500 = 5%)
    }

    struct AssetHolding {
        address asset;
        uint256 amount;
        uint256 targetAllocation; // Basis points (e.g., 2500 = 25%)
        uint256 currentAllocation; // Basis points
        uint256 lastPrice;
        uint256 unrealizedPnL; // Profit/Loss since acquisition
    }

    struct PortfolioPerformance {
        uint256 totalReturn; // Basis points
        uint256 dailyReturn; // Basis points
        uint256 weeklyReturn; // Basis points
        uint256 monthlyReturn; // Basis points
        uint256 yearlyReturn; // Basis points
        uint256 maxDrawdown; // Basis points
        uint256 sharpeRatio; // Scaled by 1000
        uint256 volatility; // Basis points
        uint256 lastUpdated;
    }

    // State variables
    mapping(address => uint256[]) public userPortfolios; // user => portfolio IDs
    mapping(uint256 => Portfolio) public portfolios;
    mapping(uint256 => mapping(address => AssetHolding))
        public portfolioHoldings;
    mapping(uint256 => address[]) public portfolioAssets; // portfolio ID => asset addresses
    mapping(uint256 => PortfolioPerformance) public portfolioPerformance;
    mapping(address => bool) public supportedAssets;

    uint256 public nextPortfolioId = 1;
    uint256 public totalPortfolios;
    uint256 public totalValueLocked;

    // Portfolio limits and settings
    uint256 public constant MAX_ASSETS_PER_PORTFOLIO = 20;
    uint256 public constant MIN_ALLOCATION = 100; // 1%
    uint256 public constant MAX_ALLOCATION = 5000; // 50%
    uint256 public constant REBALANCE_COOLDOWN = 1 days;
    uint256 public constant PERFORMANCE_UPDATE_INTERVAL = 1 hours;

    // Events
    event PortfolioCreated(
        uint256 indexed portfolioId,
        address indexed owner,
        string name,
        uint8 riskLevel
    );
    event AssetAdded(
        uint256 indexed portfolioId,
        address indexed asset,
        uint256 amount,
        uint256 targetAllocation
    );
    event AssetRemoved(
        uint256 indexed portfolioId,
        address indexed asset,
        uint256 amount
    );
    event PortfolioRebalanced(
        uint256 indexed portfolioId,
        uint256 totalValue,
        uint256 timestamp
    );
    event AllocationUpdated(
        uint256 indexed portfolioId,
        address indexed asset,
        uint256 oldAllocation,
        uint256 newAllocation
    );
    event PerformanceUpdated(
        uint256 indexed portfolioId,
        uint256 totalReturn,
        uint256 sharpeRatio
    );

    modifier onlyPortfolioOwner(uint256 portfolioId) {
        if (portfolios[portfolioId].owner != msg.sender) {
            revert HedVaultErrors.UnauthorizedAccess(
                msg.sender,
                "portfolio owner"
            );
        }
        _;
    }

    modifier validPortfolio(uint256 portfolioId) {
        if (portfolioId == 0 || portfolioId >= nextPortfolioId) {
            revert HedVaultErrors.PortfolioNotFound(msg.sender);
        }
        if (!portfolios[portfolioId].isActive) {
            revert HedVaultErrors.InvalidConfiguration("Portfolio not active");
        }
        _;
    }

    modifier supportedAsset(address asset) {
        if (!supportedAssets[asset]) {
            revert HedVaultErrors.TokenNotListed(asset);
        }
        _;
    }

    constructor(address _hedVaultCore, address _priceOracle) {
        if (_hedVaultCore == address(0) || _priceOracle == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        hedVaultCore = IHedVaultCore(_hedVaultCore);
        priceOracle = PriceOracle(_priceOracle);

        // Set up roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PORTFOLIO_ADMIN_ROLE, msg.sender);
        _grantRole(REBALANCER_ROLE, msg.sender);
        _grantRole(EMERGENCY_ROLE, msg.sender);
    }

    /**
     * @notice Create a new portfolio
     * @param name Portfolio name
     * @param riskLevel Risk level (1-10)
     * @param targetRebalanceThreshold Rebalance threshold in basis points
     * @return portfolioId New portfolio ID
     */
    function createPortfolio(
        string calldata name,
        uint8 riskLevel,
        uint256 targetRebalanceThreshold
    ) external whenNotPaused returns (uint256 portfolioId) {
        if (bytes(name).length == 0) {
            revert HedVaultErrors.InvalidConfiguration("Empty portfolio name");
        }
        if (riskLevel == 0 || riskLevel > 10) {
            revert HedVaultErrors.InvalidConfiguration(
                "Risk level must be 1-10"
            );
        }
        if (targetRebalanceThreshold > 5000) {
            // Max 50%
            revert HedVaultErrors.InvalidConfiguration(
                "Rebalance threshold too high"
            );
        }

        portfolioId = nextPortfolioId++;

        portfolios[portfolioId] = Portfolio({
            owner: msg.sender,
            name: name,
            allocations: new DataTypes.PortfolioAllocation[](0),
            totalValue: 0,
            lastRebalance: block.timestamp,
            createdAt: block.timestamp,
            isActive: true,
            riskLevel: riskLevel,
            targetRebalanceThreshold: targetRebalanceThreshold
        });

        userPortfolios[msg.sender].push(portfolioId);
        totalPortfolios++;

        emit PortfolioCreated(portfolioId, msg.sender, name, riskLevel);
    }

    /**
     * @notice Add asset to portfolio
     * @param portfolioId Portfolio ID
     * @param asset Asset address
     * @param amount Amount to add
     * @param targetAllocation Target allocation in basis points
     */
    function addAsset(
        uint256 portfolioId,
        address asset,
        uint256 amount,
        uint256 targetAllocation
    )
        external
        onlyPortfolioOwner(portfolioId)
        validPortfolio(portfolioId)
        supportedAsset(asset)
        nonReentrant
    {
        if (amount == 0) {
            revert HedVaultErrors.ZeroAmount();
        }
        if (
            targetAllocation < MIN_ALLOCATION ||
            targetAllocation > MAX_ALLOCATION
        ) {
            revert HedVaultErrors.InvalidAllocation(targetAllocation);
        }
        if (portfolioAssets[portfolioId].length >= MAX_ASSETS_PER_PORTFOLIO) {
            revert HedVaultErrors.InvalidConfiguration(
                "Too many assets in portfolio"
            );
        }

        // Check if total allocations don't exceed 100%
        uint256 totalAllocation = _getTotalTargetAllocation(portfolioId) +
            targetAllocation;
        if (totalAllocation > 10000) {
            revert HedVaultErrors.AllocationExceedsLimit(
                totalAllocation,
                10000
            );
        }

        // Transfer asset from user
        IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);

        // Add or update holding
        if (portfolioHoldings[portfolioId][asset].amount == 0) {
            portfolioAssets[portfolioId].push(asset);
        }

        AssetHolding storage holding = portfolioHoldings[portfolioId][asset];
        holding.asset = asset;
        holding.amount += amount;
        holding.targetAllocation = targetAllocation;

        // Get current price for valuation
        (uint256 price, , ) = priceOracle.getPrice(asset);
        holding.lastPrice = price;

        // Update portfolio total value
        _updatePortfolioValue(portfolioId);

        // Update total value locked
        uint256 assetValue = (amount * price) / (10 ** 18);
        totalValueLocked += assetValue;

        emit AssetAdded(portfolioId, asset, amount, targetAllocation);
    }

    /**
     * @notice Remove asset from portfolio
     * @param portfolioId Portfolio ID
     * @param asset Asset address
     * @param amount Amount to remove (0 = remove all)
     */
    function removeAsset(
        uint256 portfolioId,
        address asset,
        uint256 amount
    )
        external
        onlyPortfolioOwner(portfolioId)
        validPortfolio(portfolioId)
        nonReentrant
    {
        AssetHolding storage holding = portfolioHoldings[portfolioId][asset];
        if (holding.amount == 0) {
            revert HedVaultErrors.AssetNotInPortfolio(msg.sender, asset);
        }

        uint256 removeAmount = amount == 0 ? holding.amount : amount;
        if (removeAmount > holding.amount) {
            revert HedVaultErrors.InsufficientBalance(
                asset,
                removeAmount,
                holding.amount
            );
        }

        // Transfer asset back to user
        IERC20(asset).safeTransfer(msg.sender, removeAmount);

        holding.amount -= removeAmount;

        // Remove from portfolio if no balance left
        if (holding.amount == 0) {
            _removeAssetFromPortfolio(portfolioId, asset);
        }

        // Update portfolio total value
        uint256 oldValue = portfolios[portfolioId].totalValue;
        _updatePortfolioValue(portfolioId);

        // Update total value locked
        uint256 valueRemoved = oldValue - portfolios[portfolioId].totalValue;
        if (totalValueLocked >= valueRemoved) {
            totalValueLocked -= valueRemoved;
        }

        emit AssetRemoved(portfolioId, asset, removeAmount);
    }

    /**
     * @notice Rebalance portfolio to target allocations
     * @param portfolioId Portfolio ID
     */
    function rebalancePortfolio(
        uint256 portfolioId
    ) external validPortfolio(portfolioId) nonReentrant {
        Portfolio storage portfolio = portfolios[portfolioId];

        // Check cooldown
        if (block.timestamp - portfolio.lastRebalance < REBALANCE_COOLDOWN) {
            revert HedVaultErrors.InvalidTimestamp(
                portfolio.lastRebalance + REBALANCE_COOLDOWN
            );
        }

        // Only owner or authorized rebalancer can rebalance
        if (
            msg.sender != portfolio.owner &&
            !hasRole(REBALANCER_ROLE, msg.sender)
        ) {
            revert HedVaultErrors.UnauthorizedAccess(
                msg.sender,
                "portfolio owner or rebalancer"
            );
        }

        _updatePortfolioValue(portfolioId);

        // Check if rebalancing is needed
        if (!_needsRebalancing(portfolioId)) {
            revert HedVaultErrors.InvalidConfiguration("Rebalance not needed");
        }

        // Perform rebalancing logic
        _performRebalance(portfolioId);

        portfolio.lastRebalance = block.timestamp;

        emit PortfolioRebalanced(
            portfolioId,
            portfolio.totalValue,
            block.timestamp
        );
    }

    /**
     * @notice Update target allocations
     * @param portfolioId Portfolio ID
     * @param assets Asset addresses
     * @param allocations Target allocations in basis points
     */
    function updateAllocations(
        uint256 portfolioId,
        address[] calldata assets,
        uint256[] calldata allocations
    ) external onlyPortfolioOwner(portfolioId) validPortfolio(portfolioId) {
        if (assets.length != allocations.length) {
            revert HedVaultErrors.ArrayLengthMismatch(
                assets.length,
                allocations.length
            );
        }

        uint256 totalAllocation = 0;
        for (uint256 i = 0; i < assets.length; i++) {
            if (portfolioHoldings[portfolioId][assets[i]].amount == 0) {
                revert HedVaultErrors.AssetNotInPortfolio(
                    msg.sender,
                    assets[i]
                );
            }
            if (
                allocations[i] < MIN_ALLOCATION ||
                allocations[i] > MAX_ALLOCATION
            ) {
                revert HedVaultErrors.InvalidAllocation(allocations[i]);
            }

            totalAllocation += allocations[i];

            uint256 oldAllocation = portfolioHoldings[portfolioId][assets[i]]
                .targetAllocation;
            portfolioHoldings[portfolioId][assets[i]]
                .targetAllocation = allocations[i];

            emit AllocationUpdated(
                portfolioId,
                assets[i],
                oldAllocation,
                allocations[i]
            );
        }

        if (totalAllocation > 10000) {
            revert HedVaultErrors.AllocationExceedsLimit(
                totalAllocation,
                10000
            );
        }
    }

    /**
     * @notice Update portfolio performance metrics
     * @param portfolioId Portfolio ID
     */
    function updatePerformance(
        uint256 portfolioId
    ) external validPortfolio(portfolioId) {
        PortfolioPerformance storage performance = portfolioPerformance[
            portfolioId
        ];

        // Check if update is needed
        if (
            block.timestamp - performance.lastUpdated <
            PERFORMANCE_UPDATE_INTERVAL
        ) {
            return;
        }

        _calculatePerformanceMetrics(portfolioId);
        performance.lastUpdated = block.timestamp;

        emit PerformanceUpdated(
            portfolioId,
            performance.totalReturn,
            performance.sharpeRatio
        );
    }

    /**
     * @notice Add supported asset
     * @param asset Asset address
     */
    function addSupportedAsset(
        address asset
    ) external onlyRole(PORTFOLIO_ADMIN_ROLE) {
        if (asset == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }
        supportedAssets[asset] = true;
    }

    /**
     * @notice Remove supported asset
     * @param asset Asset address
     */
    function removeSupportedAsset(
        address asset
    ) external onlyRole(PORTFOLIO_ADMIN_ROLE) {
        supportedAssets[asset] = false;
    }

    // View functions
    function getPortfolio(
        uint256 portfolioId
    ) external view returns (Portfolio memory) {
        return portfolios[portfolioId];
    }

    function getPortfolioAssets(
        uint256 portfolioId
    ) external view returns (address[] memory) {
        return portfolioAssets[portfolioId];
    }

    function getPortfolioHolding(
        uint256 portfolioId,
        address asset
    ) external view returns (AssetHolding memory) {
        return portfolioHoldings[portfolioId][asset];
    }

    function getUserPortfolios(
        address user
    ) external view returns (uint256[] memory) {
        return userPortfolios[user];
    }

    function getPortfolioValue(
        uint256 portfolioId
    ) external view returns (uint256) {
        return _calculatePortfolioValue(portfolioId);
    }

    function getPortfolioPerformance(
        uint256 portfolioId
    ) external view returns (PortfolioPerformance memory) {
        return portfolioPerformance[portfolioId];
    }

    /**
     * @notice Get portfolio statistics
     * @param portfolioId Portfolio ID
     * @return totalAssets Number of assets in portfolio
     * @return totalAllocation Total target allocation
     * @return isBalanced Whether portfolio is balanced
     * @return riskScore Calculated risk score
     */
    function getPortfolioStats(
        uint256 portfolioId
    )
        external
        view
        validPortfolio(portfolioId)
        returns (
            uint256 totalAssets,
            uint256 totalAllocation,
            bool isBalanced,
            uint256 riskScore
        )
    {
        address[] memory assets = portfolioAssets[portfolioId];
        totalAssets = assets.length;
        totalAllocation = _getTotalTargetAllocation(portfolioId);
        isBalanced = !_needsRebalancing(portfolioId);

        // Calculate risk score based on portfolio concentration and volatility
        riskScore = _calculateRiskScore(portfolioId);
    }

    /**
     * @notice Get detailed portfolio allocation breakdown
     * @param portfolioId Portfolio ID
     * @return assets Array of asset addresses
     * @return targetAllocations Array of target allocations
     * @return currentAllocations Array of current allocations
     * @return values Array of current values
     */
    function getPortfolioBreakdown(
        uint256 portfolioId
    )
        external
        view
        validPortfolio(portfolioId)
        returns (
            address[] memory assets,
            uint256[] memory targetAllocations,
            uint256[] memory currentAllocations,
            uint256[] memory values
        )
    {
        assets = portfolioAssets[portfolioId];
        uint256 length = assets.length;

        targetAllocations = new uint256[](length);
        currentAllocations = new uint256[](length);
        values = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            AssetHolding memory holding = portfolioHoldings[portfolioId][
                assets[i]
            ];
            targetAllocations[i] = holding.targetAllocation;
            currentAllocations[i] = holding.currentAllocation;
            values[i] = (holding.amount * holding.lastPrice) / (10 ** 18);
        }
    }

    /**
     * @notice Batch update multiple asset allocations
     * @param portfolioId Portfolio ID
     * @param assets Array of asset addresses
     * @param amounts Array of amounts to add/remove (positive = add, negative = remove)
     * @param newAllocations Array of new target allocations
     */
    function batchUpdateAssets(
        uint256 portfolioId,
        address[] calldata assets,
        int256[] calldata amounts,
        uint256[] calldata newAllocations
    )
        external
        onlyPortfolioOwner(portfolioId)
        validPortfolio(portfolioId)
        nonReentrant
    {
        if (
            assets.length != amounts.length ||
            assets.length != newAllocations.length
        ) {
            revert HedVaultErrors.ArrayLengthMismatch(
                assets.length,
                amounts.length
            );
        }

        // Validate total allocation
        uint256 totalAllocation = 0;
        for (uint256 i = 0; i < newAllocations.length; i++) {
            totalAllocation += newAllocations[i];
        }
        if (totalAllocation > 10000) {
            revert HedVaultErrors.AllocationExceedsLimit(
                totalAllocation,
                10000
            );
        }

        // Process each asset update
        for (uint256 i = 0; i < assets.length; i++) {
            if (!supportedAssets[assets[i]]) {
                revert HedVaultErrors.TokenNotListed(assets[i]);
            }

            AssetHolding storage holding = portfolioHoldings[portfolioId][
                assets[i]
            ];

            // Handle amount changes
            if (amounts[i] > 0) {
                // Add assets
                uint256 addAmount = uint256(amounts[i]);
                IERC20(assets[i]).safeTransferFrom(
                    msg.sender,
                    address(this),
                    addAmount
                );

                if (holding.amount == 0) {
                    portfolioAssets[portfolioId].push(assets[i]);
                    holding.asset = assets[i];
                }
                holding.amount += addAmount;

                // Update total value locked
                (uint256 price, , ) = priceOracle.getPrice(assets[i]);
                uint256 assetValue = (addAmount * price) / (10 ** 18);
                totalValueLocked += assetValue;
            } else if (amounts[i] < 0) {
                // Remove assets
                uint256 removeAmount = uint256(-amounts[i]);
                if (removeAmount > holding.amount) {
                    revert HedVaultErrors.InsufficientBalance(
                        assets[i],
                        removeAmount,
                        holding.amount
                    );
                }

                IERC20(assets[i]).safeTransfer(msg.sender, removeAmount);
                holding.amount -= removeAmount;

                if (holding.amount == 0) {
                    _removeAssetFromPortfolio(portfolioId, assets[i]);
                }
            }

            // Update allocation
            if (holding.amount > 0) {
                holding.targetAllocation = newAllocations[i];
            }
        }

        // Update portfolio value
        _updatePortfolioValue(portfolioId);
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
    function _updatePortfolioValue(uint256 portfolioId) internal {
        uint256 totalValue = _calculatePortfolioValue(portfolioId);
        portfolios[portfolioId].totalValue = totalValue;

        // Update current allocations
        address[] memory assets = portfolioAssets[portfolioId];
        for (uint256 i = 0; i < assets.length; i++) {
            AssetHolding storage holding = portfolioHoldings[portfolioId][
                assets[i]
            ];
            (uint256 price, , ) = priceOracle.getPriceUnsafe(assets[i]);
            uint256 assetValue = (holding.amount * price) / (10 ** 18); // Assuming 18 decimals
            holding.currentAllocation = totalValue > 0
                ? (assetValue * 10000) / totalValue
                : 0;
            holding.lastPrice = price;
        }
    }

    function _calculatePortfolioValue(
        uint256 portfolioId
    ) internal view returns (uint256) {
        uint256 totalValue = 0;
        address[] memory assets = portfolioAssets[portfolioId];

        for (uint256 i = 0; i < assets.length; i++) {
            AssetHolding memory holding = portfolioHoldings[portfolioId][
                assets[i]
            ];
            if (holding.amount > 0) {
                (uint256 price, , ) = priceOracle.getPriceUnsafe(assets[i]);
                totalValue += (holding.amount * price) / (10 ** 18); // Assuming 18 decimals
            }
        }

        return totalValue;
    }

    function _getTotalTargetAllocation(
        uint256 portfolioId
    ) internal view returns (uint256) {
        uint256 totalAllocation = 0;
        address[] memory assets = portfolioAssets[portfolioId];

        for (uint256 i = 0; i < assets.length; i++) {
            totalAllocation += portfolioHoldings[portfolioId][assets[i]]
                .targetAllocation;
        }

        return totalAllocation;
    }

    function _needsRebalancing(
        uint256 portfolioId
    ) internal view returns (bool) {
        Portfolio memory portfolio = portfolios[portfolioId];
        address[] memory assets = portfolioAssets[portfolioId];

        for (uint256 i = 0; i < assets.length; i++) {
            AssetHolding memory holding = portfolioHoldings[portfolioId][
                assets[i]
            ];
            uint256 deviation = holding.currentAllocation >
                holding.targetAllocation
                ? holding.currentAllocation - holding.targetAllocation
                : holding.targetAllocation - holding.currentAllocation;

            if (deviation > portfolio.targetRebalanceThreshold) {
                return true;
            }
        }

        return false;
    }

    struct RebalanceAction {
        address asset;
        bool isSell;
        uint256 amount;
        uint256 value;
    }

    function _performRebalance(uint256 portfolioId) internal {
        Portfolio storage portfolio = portfolios[portfolioId];
        address[] memory assets = portfolioAssets[portfolioId];
        uint256 totalValue = portfolio.totalValue;

        if (totalValue == 0) {
            return; // Nothing to rebalance
        }

        // Track rebalancing operations for events
        uint256 totalRebalanced = 0;
        uint256 assetsRebalanced = 0;

        // First pass: Calculate all adjustments and validate feasibility

        RebalanceAction[] memory actions = new RebalanceAction[](assets.length);
        uint256 actionCount = 0;
        uint256 totalSellValue = 0;
        uint256 totalBuyValue = 0;

        // Calculate required adjustments for each asset
        for (uint256 i = 0; i < assets.length; i++) {
            AssetHolding storage holding = portfolioHoldings[portfolioId][
                assets[i]
            ];

            // Calculate target value for this asset
            uint256 targetValue = (totalValue * holding.targetAllocation) /
                10000;

            // Get current price with validation
            (uint256 price, uint256 timestamp, uint256 confidence) = priceOracle
                .getPrice(assets[i]);

            // Validate price data quality
            if (block.timestamp - timestamp > 3600) {
                // 1 hour staleness check
                continue; // Skip rebalancing for stale prices
            }
            if (confidence < 9000) {
                // 90% confidence threshold
                continue; // Skip rebalancing for low confidence prices
            }

            uint256 currentValue = (holding.amount * price) / (10 ** 18);

            // Calculate unrealized PnL with overflow protection
            if (holding.lastPrice > 0) {
                int256 priceDiff = int256(price) - int256(holding.lastPrice);
                int256 pnlChange = (priceDiff * int256(holding.amount)) /
                    int256(10 ** 18);

                // Safe PnL update with bounds checking
                if (pnlChange >= 0) {
                    holding.unrealizedPnL += uint256(pnlChange);
                } else {
                    uint256 loss = uint256(-pnlChange);
                    if (loss <= holding.unrealizedPnL) {
                        holding.unrealizedPnL -= loss;
                    } else {
                        holding.unrealizedPnL = 0;
                    }
                }
            }

            // Calculate required adjustment
            if (currentValue != targetValue) {
                uint256 deviation = currentValue > targetValue
                    ? currentValue - targetValue
                    : targetValue - currentValue;

                // Only rebalance if deviation exceeds threshold
                uint256 deviationBps = (deviation * 10000) / totalValue;
                if (deviationBps > portfolio.targetRebalanceThreshold) {
                    if (currentValue > targetValue) {
                        // Need to sell some of this asset
                        uint256 excessValue = currentValue - targetValue;
                        uint256 sellAmount = (excessValue * (10 ** 18)) / price;

                        // Apply slippage protection (max 2% slippage)
                        uint256 maxSlippage = (sellAmount * 200) / 10000; // 2%
                        sellAmount = sellAmount > maxSlippage
                            ? sellAmount - maxSlippage
                            : sellAmount;

                        if (sellAmount > 0 && sellAmount <= holding.amount) {
                            actions[actionCount] = RebalanceAction({
                                asset: assets[i],
                                isSell: true,
                                amount: sellAmount,
                                value: excessValue
                            });
                            actionCount++;
                            totalSellValue += excessValue;
                        }
                    } else {
                        // Need to buy more of this asset
                        uint256 deficitValue = targetValue - currentValue;
                        uint256 buyAmount = (deficitValue * (10 ** 18)) / price;

                        // Apply slippage protection (max 2% slippage)
                        uint256 maxSlippage = (buyAmount * 200) / 10000; // 2%
                        buyAmount = buyAmount > maxSlippage
                            ? buyAmount + maxSlippage
                            : buyAmount;

                        if (buyAmount > 0) {
                            actions[actionCount] = RebalanceAction({
                                asset: assets[i],
                                isSell: false,
                                amount: buyAmount,
                                value: deficitValue
                            });
                            actionCount++;
                            totalBuyValue += deficitValue;
                        }
                    }
                }
            }

            // Update current allocation and price
            uint256 newCurrentValue = (holding.amount * price) / (10 ** 18);
            holding.currentAllocation = totalValue > 0
                ? (newCurrentValue * 10000) / totalValue
                : 0;
            holding.lastPrice = price;
        }

        // Validate rebalancing feasibility
        if (totalSellValue < totalBuyValue) {
            // Insufficient liquidity from sells to cover buys
            // Scale down buy orders proportionally
            uint256 scaleFactor = totalSellValue > 0
                ? (totalSellValue * 10000) / totalBuyValue
                : 0;

            for (uint256 i = 0; i < actionCount; i++) {
                if (!actions[i].isSell) {
                    actions[i].amount =
                        (actions[i].amount * scaleFactor) /
                        10000;
                    actions[i].value = (actions[i].value * scaleFactor) / 10000;
                }
            }
        }

        // Execute rebalancing actions
        for (uint256 i = 0; i < actionCount; i++) {
            RebalanceAction memory action = actions[i];
            AssetHolding storage holding = portfolioHoldings[portfolioId][
                action.asset
            ];

            if (action.isSell) {
                // Execute sell order
                if (action.amount <= holding.amount) {
                    holding.amount -= action.amount;
                    totalRebalanced += action.value;
                    assetsRebalanced++;

                    // In production: Execute DEX swap or market order
                    // _executeSwap(action.asset, baseAsset, action.amount);
                }
            } else {
                // Execute buy order
                holding.amount += action.amount;
                totalRebalanced += action.value;
                assetsRebalanced++;

                // In production: Execute DEX swap or market order
                // _executeSwap(baseAsset, action.asset, action.value);
            }
        }

        // Update portfolio allocations array
        delete portfolio.allocations;
        for (uint256 i = 0; i < assets.length; i++) {
            AssetHolding memory holding = portfolioHoldings[portfolioId][
                assets[i]
            ];
            if (holding.amount > 0) {
                portfolio.allocations.push(
                    DataTypes.PortfolioAllocation({
                        tokenAddress: assets[i],
                        allocation: holding.targetAllocation,
                        currentValue: (holding.amount * holding.lastPrice) /
                            (10 ** 18),
                        targetValue: (totalValue * holding.targetAllocation) /
                            10000,
                        lastRebalance: block.timestamp
                    })
                );
            }
        }

        // Update portfolio total value after rebalancing
        _updatePortfolioValue(portfolioId);

        // Emit rebalancing event
        emit PortfolioRebalanced(
            portfolioId,
            portfolio.totalValue,
            block.timestamp
        );
    }

    function _removeAssetFromPortfolio(
        uint256 portfolioId,
        address asset
    ) internal {
        address[] storage assets = portfolioAssets[portfolioId];
        for (uint256 i = 0; i < assets.length; i++) {
            if (assets[i] == asset) {
                assets[i] = assets[assets.length - 1];
                assets.pop();
                break;
            }
        }
        delete portfolioHoldings[portfolioId][asset];
    }

    function _calculatePerformanceMetrics(uint256 portfolioId) internal {
        PortfolioPerformance storage performance = portfolioPerformance[
            portfolioId
        ];
        Portfolio memory portfolio = portfolios[portfolioId];
        address[] memory assets = portfolioAssets[portfolioId];

        uint256 currentValue = portfolio.totalValue;
        uint256 initialValue = 0;
        uint256 totalUnrealizedPnL = 0;

        // Calculate initial investment value and total unrealized PnL
        for (uint256 i = 0; i < assets.length; i++) {
            AssetHolding memory holding = portfolioHoldings[portfolioId][
                assets[i]
            ];
            totalUnrealizedPnL += holding.unrealizedPnL;

            // Estimate initial value (current value minus unrealized PnL)
            uint256 assetCurrentValue = (holding.amount * holding.lastPrice) /
                (10 ** 18);
            initialValue += assetCurrentValue > holding.unrealizedPnL
                ? assetCurrentValue - holding.unrealizedPnL
                : assetCurrentValue;
        }

        // Calculate total return (basis points)
        if (initialValue > 0) {
            performance.totalReturn =
                ((currentValue * 10000) / initialValue) -
                10000;
        } else {
            performance.totalReturn = 0;
        }

        // Calculate time-based returns (simplified)
        uint256 timeSinceCreation = block.timestamp - portfolio.createdAt;

        if (timeSinceCreation >= 1 days) {
            performance.dailyReturn =
                (performance.totalReturn * 1 days) /
                timeSinceCreation;
        }

        if (timeSinceCreation >= 7 days) {
            performance.weeklyReturn =
                (performance.totalReturn * 7 days) /
                timeSinceCreation;
        }

        if (timeSinceCreation >= 30 days) {
            performance.monthlyReturn =
                (performance.totalReturn * 30 days) /
                timeSinceCreation;
        }

        if (timeSinceCreation >= 365 days) {
            performance.yearlyReturn =
                (performance.totalReturn * 365 days) /
                timeSinceCreation;
        }

        // Simplified volatility calculation (based on asset count and allocation spread)
        uint256 volatilityScore = 0;
        for (uint256 i = 0; i < assets.length; i++) {
            AssetHolding memory holding = portfolioHoldings[portfolioId][
                assets[i]
            ];
            // Higher allocation concentration increases volatility
            volatilityScore +=
                (holding.currentAllocation * holding.currentAllocation) /
                10000;
        }
        performance.volatility = volatilityScore;

        // Simplified Sharpe ratio calculation (return / volatility)
        if (performance.volatility > 0) {
            performance.sharpeRatio =
                (performance.totalReturn * 1000) /
                performance.volatility;
        } else {
            performance.sharpeRatio = 0;
        }

        // Calculate max drawdown (simplified - based on current unrealized losses)
        uint256 totalLosses = 0;
        for (uint256 i = 0; i < assets.length; i++) {
            AssetHolding memory holding = portfolioHoldings[portfolioId][
                assets[i]
            ];
            if (holding.unrealizedPnL < 0) {
                totalLosses += uint256(-int256(holding.unrealizedPnL));
            }
        }

        if (currentValue > 0) {
            performance.maxDrawdown = (totalLosses * 10000) / currentValue;
        } else {
            performance.maxDrawdown = 0;
        }
    }

    /**
     * @notice Calculate portfolio risk score
     * @param portfolioId Portfolio ID
     * @return riskScore Risk score (0-1000, higher = riskier)
     */
    function _calculateRiskScore(
        uint256 portfolioId
    ) internal view returns (uint256 riskScore) {
        address[] memory assets = portfolioAssets[portfolioId];
        Portfolio memory portfolio = portfolios[portfolioId];

        if (assets.length == 0) {
            return 0;
        }

        // Base risk from portfolio risk level setting
        riskScore = uint256(portfolio.riskLevel) * 100; // 100-1000 range

        // Concentration risk - higher concentration = higher risk
        uint256 concentrationRisk = 0;
        for (uint256 i = 0; i < assets.length; i++) {
            AssetHolding memory holding = portfolioHoldings[portfolioId][
                assets[i]
            ];
            // Square the allocation to penalize concentration
            concentrationRisk +=
                (holding.currentAllocation * holding.currentAllocation) /
                10000;
        }

        // Diversification bonus - more assets = lower risk
        uint256 diversificationBonus = assets.length > 10
            ? 100
            : assets.length * 10;

        // Combine factors
        riskScore = riskScore + concentrationRisk - diversificationBonus;

        // Cap at reasonable bounds
        if (riskScore > 1000) riskScore = 1000;
        if (riskScore < 0) riskScore = 0;
    }
}
