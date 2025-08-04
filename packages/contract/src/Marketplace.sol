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
 * @title Marketplace
 * @notice Decentralized marketplace for buying and selling RWA tokens
 * @dev Supports limit orders, market orders, and auction mechanisms
 */
contract Marketplace is AccessControl, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    // Roles
    bytes32 public constant MARKETPLACE_ADMIN_ROLE =
        keccak256("MARKETPLACE_ADMIN_ROLE");
    bytes32 public constant FEE_MANAGER_ROLE = keccak256("FEE_MANAGER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");

    // Core protocol references
    IHedVaultCore public immutable hedVaultCore;
    PriceOracle public immutable priceOracle;

    // Order structures
    struct Order {
        uint256 orderId;
        address maker;
        address asset;
        address paymentToken;
        uint256 amount;
        uint256 price;
        uint256 filled;
        uint256 expiry;
        uint8 orderType;
        uint8 status;
        uint256 createdAt;
        uint256 fee;
    }

    struct Trade {
        uint256 tradeId;
        uint256 buyOrderId;
        uint256 sellOrderId;
        address buyer;
        address seller;
        address asset;
        uint256 amount;
        uint256 price;
        uint256 timestamp;
        uint256 buyerFee;
        uint256 sellerFee;
    }

    struct MarketData {
        address asset;
        uint256 lastPrice;
        uint256 volume24h;
        uint256 high24h;
        uint256 low24h;
        uint256 priceChange24h;
        uint256 totalTrades;
        uint256 lastTradeTime;
    }

    struct AuctionData {
        uint256 auctionId;
        address seller;
        address asset;
        uint256 amount;
        uint256 startPrice;
        uint256 reservePrice;
        uint256 currentBid;
        address highestBidder;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
        bool isSettled;
    }

    // State variables
    mapping(uint256 => Order) public orders;
    mapping(address => uint256[]) public userOrders; // user => order IDs
    mapping(address => mapping(uint8 => uint256[])) public assetOrders; // asset => order type => order IDs
    mapping(uint256 => Trade) public trades;
    mapping(address => MarketData) public marketData;
    mapping(uint256 => AuctionData) public auctions;
    mapping(address => bool) public supportedAssets;
    mapping(address => bool) public supportedPaymentTokens;

    // Enhanced order book management
    mapping(address => mapping(uint256 => uint256[])) public priceToOrders; // asset => price => order IDs
    mapping(address => uint256[]) public activePrices; // asset => sorted price levels
    mapping(address => uint256) public bestBidPrice; // asset => best bid price
    mapping(address => uint256) public bestAskPrice; // asset => best ask price

    // User trading statistics
    mapping(address => uint256) public userTotalVolume;
    mapping(address => uint256) public userTotalTrades;
    mapping(address => uint256) public userLastActivity;

    // Asset trading statistics
    mapping(address => uint256) public assetTotalVolume;
    mapping(address => uint256) public assetTotalTrades;
    mapping(address => bool) public assetTradingEnabled;

    // Order matching and execution
    mapping(uint256 => bool) public orderInMatching; // Prevent reentrancy in matching
    mapping(address => uint256) public userActiveOrders; // Count of active orders per user

    uint256 public nextOrderId = 1;
    uint256 public nextTradeId = 1;
    uint256 public nextAuctionId = 1;

    // Fee structure (in basis points)
    uint256 public makerFee = 25; // 0.25%
    uint256 public takerFee = 50; // 0.5%
    uint256 public auctionFee = 250; // 2.5%
    uint256 public protocolFee = 10; // 0.1% additional protocol fee

    // Trading limits
    uint256 public minOrderSize = 1e18; // 1 token minimum
    uint256 public maxOrderSize = 1000000e18; // 1M tokens maximum
    uint256 public maxOrderDuration = 30 days;
    uint256 public maxActiveOrdersPerUser = 100; // Limit active orders per user
    uint256 public maxSlippageAllowed = 1000; // 10% max slippage

    // Protocol settings
    address public feeRecipient;
    uint256 public totalFeesCollected;
    uint256 public totalVolumeTraded;
    uint256 public totalTradesExecuted;
    bool public emergencyStop = false;

    // Events
    event OrderCreated(
        uint256 indexed orderId,
        address indexed maker,
        address indexed asset,
        uint8 orderType,
        uint256 amount,
        uint256 price
    );
    event OrderCancelled(uint256 indexed orderId, address indexed maker);
    event OrderFilled(
        uint256 indexed orderId,
        address indexed taker,
        uint256 amount,
        uint256 price
    );
    event TradeExecuted(
        uint256 indexed tradeId,
        uint256 indexed buyOrderId,
        uint256 indexed sellOrderId,
        address buyer,
        address seller,
        address asset,
        uint256 amount,
        uint256 price
    );
    event AuctionCreated(
        uint256 indexed auctionId,
        address indexed seller,
        address indexed asset,
        uint256 amount,
        uint256 startPrice,
        uint256 endTime
    );
    event BidPlaced(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 amount
    );
    event AuctionSettled(
        uint256 indexed auctionId,
        address indexed winner,
        uint256 finalPrice
    );
    event FeesUpdated(uint256 makerFee, uint256 takerFee, uint256 auctionFee);

    modifier validAsset(address asset) {
        if (!supportedAssets[asset]) {
            revert HedVaultErrors.TokenNotListed(asset);
        }
        if (!assetTradingEnabled[asset]) {
            revert HedVaultErrors.TradingPaused(asset);
        }
        _;
    }

    modifier validPaymentToken(address token) {
        if (!supportedPaymentTokens[token]) {
            revert HedVaultErrors.TokenNotListed(token);
        }
        _;
    }

    modifier validOrder(uint256 orderId) {
        if (orderId == 0 || orderId >= nextOrderId) {
            revert HedVaultErrors.OrderDoesNotExist(orderId);
        }
        _;
    }

    modifier onlyOrderMaker(uint256 orderId) {
        if (orders[orderId].maker != msg.sender) {
            revert HedVaultErrors.UnauthorizedAccess(msg.sender, "order maker");
        }
        _;
    }

    modifier notInEmergency() {
        if (emergencyStop) {
            revert HedVaultErrors.EmergencyModeActive();
        }
        _;
    }

    modifier validUserOrderLimit() {
        if (userActiveOrders[msg.sender] >= maxActiveOrdersPerUser) {
            revert HedVaultErrors.TooManyActiveOrders(
                msg.sender,
                maxActiveOrdersPerUser
            );
        }
        _;
    }

    modifier notInMatching(uint256 orderId) {
        if (orderInMatching[orderId]) {
            revert HedVaultErrors.OrderInMatching(orderId);
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
        _grantRole(MARKETPLACE_ADMIN_ROLE, msg.sender);
        _grantRole(FEE_MANAGER_ROLE, msg.sender);
        _grantRole(EMERGENCY_ROLE, msg.sender);

        // Initialize protocol statistics
        totalFeesCollected = 0;
        totalVolumeTraded = 0;
        totalTradesExecuted = 0;
        emergencyStop = false;
    }

    /**
     * @notice Create a buy or sell order
     * @param asset Asset to trade
     * @param paymentToken Payment token address
     * @param amount Amount of asset
     * @param price Price per token
     * @param orderType Order type (BUY or SELL)
     * @param expiry Order expiry timestamp
     * @return orderId New order ID
     */
    function createOrder(
        address asset,
        address paymentToken,
        uint256 amount,
        uint256 price,
        uint8 orderType,
        uint256 expiry
    )
        external
        validAsset(asset)
        validPaymentToken(paymentToken)
        whenNotPaused
        nonReentrant
        notInEmergency
        validUserOrderLimit
        returns (uint256 orderId)
    {
        if (amount < minOrderSize || amount > maxOrderSize) {
            revert HedVaultErrors.InvalidAmount(
                amount,
                minOrderSize,
                maxOrderSize
            );
        }
        if (price == 0) {
            revert HedVaultErrors.ZeroAmount();
        }
        if (
            expiry <= block.timestamp ||
            expiry > block.timestamp + maxOrderDuration
        ) {
            revert HedVaultErrors.InvalidTimestamp(expiry);
        }

        orderId = nextOrderId++;

        // Calculate fee
        uint256 fee = (amount * price * makerFee) / (10000 * 1e18);

        orders[orderId] = Order({
            orderId: orderId,
            maker: msg.sender,
            asset: asset,
            paymentToken: paymentToken,
            amount: amount,
            price: price,
            filled: 0,
            expiry: expiry,
            orderType: orderType,
            status: 0, // ACTIVE
            createdAt: block.timestamp,
            fee: fee
        });

        // Handle collateral based on order type
        if (orderType == 1) {
            // SELL
            // For sell orders, lock the asset
            IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);
        } else {
            // For buy orders, lock the payment token
            uint256 totalCost = (amount * price) / 1e18 + fee;
            IERC20(paymentToken).safeTransferFrom(
                msg.sender,
                address(this),
                totalCost
            );
        }

        // Add to user orders and asset orders
        userOrders[msg.sender].push(orderId);
        assetOrders[asset][orderType].push(orderId);

        // Update order book management
        priceToOrders[asset][price].push(orderId);
        _updatePriceLevels(asset, price, orderType);

        // Update user statistics
        userActiveOrders[msg.sender]++;
        userLastActivity[msg.sender] = block.timestamp;

        // Update best bid/ask prices
        _updateBestPrices(asset, price, orderType);

        emit OrderCreated(orderId, msg.sender, asset, orderType, amount, price);
        emit Events.OrderCreated(
            orderId,
            msg.sender,
            asset,
            amount,
            price,
            orderType
        );

        // Try to match with existing orders
        _tryMatchOrder(orderId);
    }

    /**
     * @notice Cancel an active order
     * @param orderId Order ID to cancel
     */
    function cancelOrder(
        uint256 orderId
    )
        external
        validOrder(orderId)
        onlyOrderMaker(orderId)
        nonReentrant
        notInMatching(orderId)
    {
        Order storage order = orders[orderId];

        if (order.status != 0) {
            // ACTIVE
            revert HedVaultErrors.OrderDoesNotExist(orderId);
        }

        order.status = 2; // CANCELLED

        // Update user statistics
        userActiveOrders[msg.sender]--;
        userLastActivity[msg.sender] = block.timestamp;

        // Return collateral to maker
        uint256 remainingAmount = order.amount - order.filled;
        if (order.orderType == 1) {
            // SELL
            IERC20(order.asset).safeTransfer(order.maker, remainingAmount);
        } else {
            uint256 remainingCost = (remainingAmount * order.price) / 1e18;
            IERC20(order.paymentToken).safeTransfer(
                order.maker,
                remainingCost + order.fee
            );
        }

        // Clean up order book data
        _removeFromPriceLevel(order.asset, order.price, orderId);
        _updateBestPricesAfterCancel(order.asset, order.price, order.orderType);

        emit OrderCancelled(orderId, order.maker);
        emit Events.OrderCancelled(orderId, order.maker, block.timestamp);
    }

    /**
     * @notice Execute a market order (immediate fill at best available price)
     * @param asset Asset to trade
     * @param paymentToken Payment token address
     * @param amount Amount to trade
     * @param orderType Order type (BUY or SELL)
     * @param maxSlippage Maximum acceptable slippage in basis points
     */
    function marketOrder(
        address asset,
        address paymentToken,
        uint256 amount,
        uint8 orderType,
        uint256 maxSlippage
    )
        external
        validAsset(asset)
        validPaymentToken(paymentToken)
        whenNotPaused
        nonReentrant
        notInEmergency
    {
        if (amount < minOrderSize) {
            revert HedVaultErrors.InvalidAmount(
                amount,
                minOrderSize,
                maxOrderSize
            );
        }
        if (maxSlippage > maxSlippageAllowed) {
            revert HedVaultErrors.InvalidAmount(
                maxSlippage,
                0,
                maxSlippageAllowed
            );
        }

        // Update user activity
        userLastActivity[msg.sender] = block.timestamp;

        // Get oracle price for slippage calculation
        (uint256 oraclePrice, , ) = priceOracle.getPrice(asset);

        // Find and execute against best available orders
        _executeMarketOrder(
            asset,
            paymentToken,
            amount,
            orderType,
            oraclePrice,
            maxSlippage
        );

        // Update user trading statistics
        userTotalVolume[msg.sender] += amount;
        userTotalTrades[msg.sender]++;
    }

    /**
     * @notice Create an auction for selling assets
     * @param asset Asset to auction
     * @param amount Amount to auction
     * @param startPrice Starting price
     * @param reservePrice Reserve price (minimum acceptable)
     * @param duration Auction duration in seconds
     * @return auctionId New auction ID
     */
    function createAuction(
        address asset,
        uint256 amount,
        uint256 startPrice,
        uint256 reservePrice,
        uint256 duration
    )
        external
        validAsset(asset)
        whenNotPaused
        nonReentrant
        notInEmergency
        returns (uint256 auctionId)
    {
        if (amount == 0 || startPrice == 0) {
            revert HedVaultErrors.ZeroAmount();
        }
        if (reservePrice > startPrice) {
            revert HedVaultErrors.InvalidConfiguration(
                "Reserve price cannot exceed start price"
            );
        }
        if (duration < 1 hours || duration > 7 days) {
            revert HedVaultErrors.InvalidConfiguration(
                "Invalid auction duration"
            );
        }

        auctionId = nextAuctionId++;

        // Lock the asset
        IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);

        auctions[auctionId] = AuctionData({
            auctionId: auctionId,
            seller: msg.sender,
            asset: asset,
            amount: amount,
            startPrice: startPrice,
            reservePrice: reservePrice,
            currentBid: 0,
            highestBidder: address(0),
            startTime: block.timestamp,
            endTime: block.timestamp + duration,
            isActive: true,
            isSettled: false
        });

        emit AuctionCreated(
            auctionId,
            msg.sender,
            asset,
            amount,
            startPrice,
            block.timestamp + duration
        );
    }

    /**
     * @notice Place a bid on an auction
     * @param auctionId Auction ID
     * @param bidAmount Bid amount
     */
    function placeBid(
        uint256 auctionId,
        uint256 bidAmount
    ) external whenNotPaused nonReentrant notInEmergency {
        AuctionData storage auction = auctions[auctionId];

        if (!auction.isActive || auction.isSettled) {
            revert HedVaultErrors.InvalidConfiguration("Auction not active");
        }
        if (block.timestamp >= auction.endTime) {
            revert HedVaultErrors.InvalidTimestamp(auction.endTime);
        }
        if (bidAmount <= auction.currentBid) {
            revert HedVaultErrors.InvalidAmount(
                bidAmount,
                auction.currentBid,
                type(uint256).max
            );
        }
        if (bidAmount < auction.startPrice) {
            revert HedVaultErrors.InvalidAmount(
                bidAmount,
                auction.startPrice,
                type(uint256).max
            );
        }

        // Return previous bid to previous bidder
        if (auction.highestBidder != address(0)) {
            // In a real implementation, you'd use a payment token
            // For simplicity, assuming ETH bids
            payable(auction.highestBidder).transfer(auction.currentBid);
        }

        // Update auction state
        auction.currentBid = bidAmount;
        auction.highestBidder = msg.sender;

        emit BidPlaced(auctionId, msg.sender, bidAmount);
    }

    /**
     * @notice Settle an auction after it ends
     * @param auctionId Auction ID
     */
    function settleAuction(
        uint256 auctionId
    ) external nonReentrant whenNotPaused notInEmergency {
        AuctionData storage auction = auctions[auctionId];

        if (!auction.isActive || auction.isSettled) {
            revert HedVaultErrors.InvalidConfiguration("Auction not active");
        }
        if (block.timestamp < auction.endTime) {
            revert HedVaultErrors.InvalidTimestamp(auction.endTime);
        }

        auction.isActive = false;
        auction.isSettled = true;

        if (
            auction.highestBidder != address(0) &&
            auction.currentBid >= auction.reservePrice
        ) {
            // Successful auction
            uint256 fee = (auction.currentBid * auctionFee) / 10000;
            uint256 sellerProceeds = auction.currentBid - fee;

            // Transfer asset to winner
            IERC20(auction.asset).safeTransfer(
                auction.highestBidder,
                auction.amount
            );

            // Transfer proceeds to seller
            payable(auction.seller).transfer(sellerProceeds);

            // Transfer fee to protocol
            payable(feeRecipient).transfer(fee);
            totalFeesCollected += fee;

            emit AuctionSettled(
                auctionId,
                auction.highestBidder,
                auction.currentBid
            );
        } else {
            // Failed auction - return asset to seller
            IERC20(auction.asset).safeTransfer(auction.seller, auction.amount);

            // Return bid to bidder if any
            if (auction.highestBidder != address(0)) {
                payable(auction.highestBidder).transfer(auction.currentBid);
            }

            emit AuctionSettled(auctionId, address(0), 0);
        }
    }

    /**
     * @notice Update trading fees
     * @param _makerFee New maker fee in basis points
     * @param _takerFee New taker fee in basis points
     * @param _auctionFee New auction fee in basis points
     */
    function updateFees(
        uint256 _makerFee,
        uint256 _takerFee,
        uint256 _auctionFee
    ) external onlyRole(FEE_MANAGER_ROLE) {
        if (_makerFee > 1000) {
            revert HedVaultErrors.FeeTooHigh(_makerFee, 1000);
        }
        if (_takerFee > 1000) {
            revert HedVaultErrors.FeeTooHigh(_takerFee, 1000);
        }
        if (_auctionFee > 1000) {
            revert HedVaultErrors.FeeTooHigh(_auctionFee, 1000);
        }

        makerFee = _makerFee;
        takerFee = _takerFee;
        auctionFee = _auctionFee;

        emit FeesUpdated(_makerFee, _takerFee, _auctionFee);
    }

    /**
     * @notice Add supported asset
     * @param asset Asset address
     */
    function addSupportedAsset(
        address asset
    ) external onlyRole(MARKETPLACE_ADMIN_ROLE) {
        if (asset == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }
        supportedAssets[asset] = true;
    }

    /**
     * @notice Add supported payment token
     * @param token Payment token address
     */
    function addSupportedPaymentToken(
        address token
    ) external onlyRole(MARKETPLACE_ADMIN_ROLE) {
        if (token == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }
        supportedPaymentTokens[token] = true;
    }

    // View functions
    function getOrder(uint256 orderId) external view returns (Order memory) {
        return orders[orderId];
    }

    function getUserOrders(
        address user
    ) external view returns (uint256[] memory) {
        return userOrders[user];
    }

    function getAssetOrders(
        address asset,
        uint8 orderType
    ) external view returns (uint256[] memory) {
        return assetOrders[asset][orderType];
    }

    function getMarketData(
        address asset
    ) external view returns (MarketData memory) {
        return marketData[asset];
    }

    function getAuction(
        uint256 auctionId
    ) external view returns (AuctionData memory) {
        return auctions[auctionId];
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

    /**
     * @notice Activate emergency stop
     */
    function activateEmergencyStop() external onlyRole(EMERGENCY_ROLE) {
        emergencyStop = true;
        emit Events.EmergencyStopActivated(msg.sender, block.timestamp);
    }

    /**
     * @notice Deactivate emergency stop
     */
    function deactivateEmergencyStop() external onlyRole(EMERGENCY_ROLE) {
        emergencyStop = false;
        emit Events.EmergencyStopDeactivated(msg.sender, block.timestamp);
    }

    /**
     * @notice Enable/disable trading for a specific asset
     * @param asset Asset address
     * @param enabled Whether trading is enabled
     */
    function setAssetTradingEnabled(
        address asset,
        bool enabled
    ) external onlyRole(MARKETPLACE_ADMIN_ROLE) {
        if (!supportedAssets[asset]) {
            revert HedVaultErrors.TokenNotListed(asset);
        }

        assetTradingEnabled[asset] = enabled;
        emit Events.AssetTradingStatusChanged(asset, enabled, block.timestamp);
    }

    /**
     * @notice Update trading limits
     * @param _maxActiveOrdersPerUser Maximum active orders per user
     * @param _maxSlippageAllowed Maximum allowed slippage
     */
    function updateTradingLimits(
        uint256 _maxActiveOrdersPerUser,
        uint256 _maxSlippageAllowed
    ) external onlyRole(MARKETPLACE_ADMIN_ROLE) {
        if (_maxActiveOrdersPerUser == 0) {
            revert HedVaultErrors.InvalidAmount(
                _maxActiveOrdersPerUser,
                1,
                type(uint256).max
            );
        }
        if (_maxSlippageAllowed > 5000) {
            revert HedVaultErrors.InvalidAmount(_maxSlippageAllowed, 0, 5000);
        }

        maxActiveOrdersPerUser = _maxActiveOrdersPerUser;
        maxSlippageAllowed = _maxSlippageAllowed;

        emit Events.TradingLimitsUpdated(
            _maxActiveOrdersPerUser,
            _maxSlippageAllowed,
            block.timestamp
        );
    }

    // Internal functions
    function _tryMatchOrder(uint256 orderId) internal {
        Order storage order = orders[orderId];

        // Get opposite order type
        uint8 oppositeType = order.orderType == 0 // BUY
            ? 1 // SELL
            : 0; // BUY

        uint256[] memory oppositeOrders = assetOrders[order.asset][
            oppositeType
        ];

        for (
            uint256 i = 0;
            i < oppositeOrders.length && order.filled < order.amount;
            i++
        ) {
            uint256 oppositeOrderId = oppositeOrders[i];
            Order storage oppositeOrder = orders[oppositeOrderId];

            if (
                oppositeOrder.status != 0 || // ACTIVE
                oppositeOrder.expiry <= block.timestamp ||
                !_canMatch(order, oppositeOrder)
            ) {
                continue;
            }

            _executeMatch(orderId, oppositeOrderId);
        }
    }

    function _canMatch(
        Order memory order1,
        Order memory order2
    ) internal pure returns (bool) {
        if (order1.orderType == 0) {
            // BUY
            return order1.price >= order2.price;
        } else {
            return order1.price <= order2.price;
        }
    }

    function _executeMatch(uint256 orderId1, uint256 orderId2) internal {
        Order storage order1 = orders[orderId1];
        Order storage order2 = orders[orderId2];

        uint256 tradeAmount = _min(
            order1.amount - order1.filled,
            order2.amount - order2.filled
        );
        uint256 tradePrice = order2.price; // Price discovery: use maker's price

        // Update order fill amounts
        order1.filled += tradeAmount;
        order2.filled += tradeAmount;

        // Update order status if fully filled
        if (order1.filled == order1.amount) {
            order1.status = 1; // FILLED
        }
        if (order2.filled == order2.amount) {
            order2.status = 1; // FILLED
        }

        // Execute the trade
        _executeTrade(orderId1, orderId2, tradeAmount, tradePrice);
    }

    function _executeTrade(
        uint256 buyOrderId,
        uint256 sellOrderId,
        uint256 amount,
        uint256 price
    ) internal {
        Order storage buyOrder = orders[buyOrderId];
        Order storage sellOrder = orders[sellOrderId];

        // Ensure correct order types
        if (buyOrder.orderType == 1) {
            // SELL
            (buyOrderId, sellOrderId) = (sellOrderId, buyOrderId);
            (buyOrder, sellOrder) = (sellOrder, buyOrder);
        }

        uint256 tradeValue = (amount * price) / 1e18;
        uint256 buyerFee = (tradeValue * takerFee) / 10000;
        uint256 sellerFee = (tradeValue * makerFee) / 10000;

        // Transfer asset from seller to buyer
        IERC20(buyOrder.asset).safeTransfer(buyOrder.maker, amount);

        // Transfer payment from buyer to seller
        uint256 sellerProceeds = tradeValue - sellerFee;
        IERC20(buyOrder.paymentToken).safeTransfer(
            sellOrder.maker,
            sellerProceeds
        );

        // Transfer fees to protocol
        uint256 totalFees = buyerFee + sellerFee;
        IERC20(buyOrder.paymentToken).safeTransfer(feeRecipient, totalFees);
        totalFeesCollected += totalFees;

        // Record trade
        uint256 tradeId = nextTradeId++;
        trades[tradeId] = Trade({
            tradeId: tradeId,
            buyOrderId: buyOrderId,
            sellOrderId: sellOrderId,
            buyer: buyOrder.maker,
            seller: sellOrder.maker,
            asset: buyOrder.asset,
            amount: amount,
            price: price,
            timestamp: block.timestamp,
            buyerFee: buyerFee,
            sellerFee: sellerFee
        });

        // Update market data
        _updateMarketData(buyOrder.asset, price, amount);

        emit TradeExecuted(
            tradeId,
            buyOrderId,
            sellOrderId,
            buyOrder.maker,
            sellOrder.maker,
            buyOrder.asset,
            amount,
            price
        );
    }

    function _executeMarketOrder(
        address asset,
        address paymentToken,
        uint256 amount,
        uint8 orderType,
        uint256 oraclePrice,
        uint256 maxSlippage
    ) internal {
        // Simplified market order execution
        // In a real implementation, this would be more sophisticated
        uint8 oppositeType = orderType == 0 // BUY
            ? 1 // SELL
            : 0; // BUY

        uint256[] memory oppositeOrders = assetOrders[asset][oppositeType];
        uint256 remainingAmount = amount;

        for (
            uint256 i = 0;
            i < oppositeOrders.length && remainingAmount > 0;
            i++
        ) {
            Order storage oppositeOrder = orders[oppositeOrders[i]];

            if (
                oppositeOrder.status != 0 || // ACTIVE
                oppositeOrder.expiry <= block.timestamp
            ) {
                continue;
            }

            // Check slippage
            uint256 slippage = _calculateSlippage(
                oppositeOrder.price,
                oraclePrice
            );
            if (slippage > maxSlippage) {
                continue;
            }

            uint256 fillAmount = _min(
                remainingAmount,
                oppositeOrder.amount - oppositeOrder.filled
            );

            // Execute market order directly without creating temporary order
            uint256 tradeAmount = fillAmount;
            uint256 tradePrice = oppositeOrder.price;

            // Update opposite order fill amount
            oppositeOrder.filled += tradeAmount;

            // Update opposite order status if fully filled
            if (oppositeOrder.filled == oppositeOrder.amount) {
                oppositeOrder.status = 1; // FILLED
            }

            // Execute the trade directly
            uint256 tradeValue = (tradeAmount * tradePrice) / 1e18;
            uint256 buyerFee = (tradeValue * takerFee) / 10000;
            uint256 sellerFee = (tradeValue * makerFee) / 10000;

            if (orderType == 0) { // BUY market order
                // Transfer asset from seller to buyer
                IERC20(asset).safeTransfer(msg.sender, tradeAmount);
                
                // Transfer payment from buyer to seller
                uint256 sellerProceeds = tradeValue - sellerFee;
                IERC20(paymentToken).safeTransferFrom(msg.sender, oppositeOrder.maker, sellerProceeds);
                
                // Transfer fees from buyer to protocol
                IERC20(paymentToken).safeTransferFrom(msg.sender, feeRecipient, buyerFee + sellerFee);
            } else { // SELL market order
                // Transfer asset from seller to buyer
                IERC20(asset).safeTransferFrom(msg.sender, oppositeOrder.maker, tradeAmount);
                
                // Transfer payment from buyer to seller
                uint256 sellerProceeds = tradeValue - sellerFee;
                IERC20(paymentToken).safeTransfer(msg.sender, sellerProceeds);
                
                // Transfer fees to protocol (already collected from buyer's locked funds)
                IERC20(paymentToken).safeTransfer(feeRecipient, buyerFee + sellerFee);
            }
            
            totalFeesCollected += buyerFee + sellerFee;

            // Record trade
            uint256 tradeId = nextTradeId++;
            trades[tradeId] = Trade({
                tradeId: tradeId,
                buyOrderId: orderType == 0 ? 0 : oppositeOrders[i], // Use 0 for market orders
                sellOrderId: orderType == 1 ? 0 : oppositeOrders[i], // Use 0 for market orders
                buyer: orderType == 0 ? msg.sender : oppositeOrder.maker,
                seller: orderType == 1 ? msg.sender : oppositeOrder.maker,
                asset: asset,
                amount: tradeAmount,
                price: tradePrice,
                timestamp: block.timestamp,
                buyerFee: buyerFee,
                sellerFee: sellerFee
            });

            // Update market data
            _updateMarketData(asset, tradePrice, tradeAmount);

            emit TradeExecuted(
                tradeId,
                orderType == 0 ? 0 : oppositeOrders[i],
                orderType == 1 ? 0 : oppositeOrders[i],
                orderType == 0 ? msg.sender : oppositeOrder.maker,
                orderType == 1 ? msg.sender : oppositeOrder.maker,
                asset,
                tradeAmount,
                tradePrice
            );
            remainingAmount -= fillAmount;
        }

        if (remainingAmount > 0) {
            revert HedVaultErrors.InvalidAmount(remainingAmount, 0, amount);
        }
    }

    function _updateMarketData(
        address asset,
        uint256 price,
        uint256 volume
    ) internal {
        MarketData storage data = marketData[asset];

        // Update 24h data (simplified)
        if (block.timestamp - data.lastTradeTime > 24 hours) {
            data.volume24h = volume;
            data.high24h = price;
            data.low24h = price;
            data.priceChange24h = 0;
        } else {
            data.volume24h += volume;
            if (price > data.high24h) data.high24h = price;
            if (price < data.low24h || data.low24h == 0) data.low24h = price;
        }

        data.lastPrice = price;
        data.totalTrades++;
        data.lastTradeTime = block.timestamp;
    }

    function _calculateSlippage(
        uint256 executionPrice,
        uint256 oraclePrice
    ) internal pure returns (uint256) {
        if (oraclePrice == 0) return 0;

        uint256 priceDiff = executionPrice > oraclePrice
            ? executionPrice - oraclePrice
            : oraclePrice - executionPrice;

        return (priceDiff * 10000) / oraclePrice;
    }

    function _min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @notice Update price levels for order book management
     * @param asset Asset address
     * @param price Price level
     */
    function _updatePriceLevels(address asset, uint256 price, uint8) internal {
        uint256[] storage prices = activePrices[asset];

        // Check if price level already exists
        bool exists = false;
        for (uint256 i = 0; i < prices.length; i++) {
            if (prices[i] == price) {
                exists = true;
                break;
            }
        }

        // Add new price level if it doesn't exist
        if (!exists) {
            prices.push(price);
            // Sort prices (simple insertion sort for small arrays)
            for (uint256 i = prices.length - 1; i > 0; i--) {
                if (prices[i] < prices[i - 1]) {
                    (prices[i], prices[i - 1]) = (prices[i - 1], prices[i]);
                } else {
                    break;
                }
            }
        }
    }

    /**
     * @notice Update best bid and ask prices
     * @param asset Asset address
     * @param price New price
     * @param orderType Order type (0=BUY, 1=SELL)
     */
    function _updateBestPrices(
        address asset,
        uint256 price,
        uint8 orderType
    ) internal {
        if (orderType == 0) {
            // BUY order
            if (price > bestBidPrice[asset]) {
                bestBidPrice[asset] = price;
            }
        } else {
            // SELL order
            if (bestAskPrice[asset] == 0 || price < bestAskPrice[asset]) {
                bestAskPrice[asset] = price;
            }
        }
    }

    /**
     * @notice Remove order from price level
     * @param asset Asset address
     * @param price Price level
     * @param orderId Order ID to remove
     */
    function _removeFromPriceLevel(
        address asset,
        uint256 price,
        uint256 orderId
    ) internal {
        uint256[] storage orderIds = priceToOrders[asset][price];

        for (uint256 i = 0; i < orderIds.length; i++) {
            if (orderIds[i] == orderId) {
                // Move last element to current position and pop
                orderIds[i] = orderIds[orderIds.length - 1];
                orderIds.pop();
                break;
            }
        }

        // If no more orders at this price level, remove from active prices
        if (orderIds.length == 0) {
            _removePriceLevel(asset, price);
        }
    }

    /**
     * @notice Remove price level from active prices
     * @param asset Asset address
     * @param price Price to remove
     */
    function _removePriceLevel(address asset, uint256 price) internal {
        uint256[] storage prices = activePrices[asset];

        for (uint256 i = 0; i < prices.length; i++) {
            if (prices[i] == price) {
                prices[i] = prices[prices.length - 1];
                prices.pop();
                break;
            }
        }
    }

    /**
     * @notice Update best prices after order cancellation
     * @param asset Asset address
     * @param cancelledPrice Cancelled order price
     * @param orderType Order type
     */
    function _updateBestPricesAfterCancel(
        address asset,
        uint256 cancelledPrice,
        uint8 orderType
    ) internal {
        if (orderType == 0) {
            // BUY order
            if (cancelledPrice == bestBidPrice[asset]) {
                // Recalculate best bid
                bestBidPrice[asset] = _findBestBidPrice(asset);
            }
        } else {
            // SELL order
            if (cancelledPrice == bestAskPrice[asset]) {
                // Recalculate best ask
                bestAskPrice[asset] = _findBestAskPrice(asset);
            }
        }
    }

    /**
     * @notice Find best bid price for an asset
     * @param asset Asset address
     * @return bestBid Best bid price
     */
    function _findBestBidPrice(
        address asset
    ) internal view returns (uint256 bestBid) {
        uint256[] memory buyOrders = assetOrders[asset][0]; // BUY orders

        for (uint256 i = 0; i < buyOrders.length; i++) {
            Order memory order = orders[buyOrders[i]];
            if (order.status == 0 && order.expiry > block.timestamp) {
                // ACTIVE and not expired
                if (order.price > bestBid) {
                    bestBid = order.price;
                }
            }
        }

        return bestBid;
    }

    /**
     * @notice Find best ask price for an asset
     * @param asset Asset address
     * @return bestAsk Best ask price
     */
    function _findBestAskPrice(
        address asset
    ) internal view returns (uint256 bestAsk) {
        uint256[] memory sellOrders = assetOrders[asset][1]; // SELL orders

        for (uint256 i = 0; i < sellOrders.length; i++) {
            Order memory order = orders[sellOrders[i]];
            if (order.status == 0 && order.expiry > block.timestamp) {
                // ACTIVE and not expired
                if (bestAsk == 0 || order.price < bestAsk) {
                    bestAsk = order.price;
                }
            }
        }

        return bestAsk;
    }

    // Support for receiving ETH (for auctions)
    receive() external payable {}
}
