// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
// Counters.sol removed in OpenZeppelin v5 - using simple uint256 counter
import "./libraries/DataTypes.sol";
import "./libraries/Events.sol";
import "./libraries/HedVaultErrors.sol";
import "./interfaces/IHedVaultCore.sol";
import "./RWAToken.sol";

/**
 * @title RWATokenFactory
 * @notice Factory contract for creating and managing RWA tokens
 * @dev Integrates with Hedera Token Service for token creation
 */
contract RWATokenFactory is AccessControl, ReentrancyGuard, Pausable {
    // Roles
    bytes32 public constant CREATOR_ROLE = keccak256("CREATOR_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // Core protocol reference
    IHedVaultCore public immutable hedVaultCore;

    // Token counter
    uint256 private _tokenIdCounter;

    // Token registry
    mapping(uint256 => address) public tokenById;
    mapping(address => uint256) public tokenToId;
    mapping(address => DataTypes.AssetInfo) public assetInfo;
    mapping(address => bool) public isRWAToken;

    // Creator registry
    mapping(address => uint256[]) public creatorTokens;
    mapping(address => bool) public approvedCreators;

    // Asset type registry
    mapping(string => bool) public supportedAssetTypes;
    mapping(string => uint256) public assetTypeCount;

    // Token listing fees
    uint256 public listingFee = 50 * 1e18; // 50 HBAR equivalent

    // Minimum requirements
    uint256 public constant MIN_TOTAL_SUPPLY = 1000 * 1e18;
    uint256 public constant MAX_TOTAL_SUPPLY = 1000000000 * 1e18;
    uint256 public constant MIN_VALUATION = 1000 * 1e18; // $1000 minimum

    // Events
    event TokenCreated(
        uint256 indexed tokenId,
        address indexed tokenAddress,
        address indexed creator,
        string assetType,
        uint256 totalSupply
    );

    event TokenListed(
        address indexed tokenAddress,
        address indexed creator,
        uint256 timestamp
    );

    event TokenDelisted(
        address indexed tokenAddress,
        address indexed admin,
        string reason
    );

    event CreatorApproved(address indexed creator, address indexed admin);
    event CreatorRevoked(address indexed creator, address indexed admin);
    event AssetTypeAdded(string assetType, address indexed admin);
    event AssetTypeRemoved(string assetType, address indexed admin);

    // Removed onlyApprovedCreator modifier - anyone can now create RWA tokens

    modifier validTokenAddress(address token) {
        if (!isRWAToken[token]) {
            revert HedVaultErrors.TokenDoesNotExist(token);
        }
        _;
    }

    constructor(address _hedVaultCore) {
        if (_hedVaultCore == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }

        hedVaultCore = IHedVaultCore(_hedVaultCore);

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(CREATOR_ROLE, msg.sender);

        // Initialize supported asset types
        _addAssetType("RealEstate");
        _addAssetType("PreciousMetals");
        _addAssetType("Art");
        _addAssetType("Commodities");
        _addAssetType("Bonds");
    }

    /**
     * @notice Create a new RWA token
     * @param metadata RWA metadata for the token
     * @param name Token name
     * @param symbol Token symbol
     * @param totalSupply Total supply of tokens
     * @return tokenAddress Address of created token
     */
    function createRWAToken(
        DataTypes.RWAMetadata calldata metadata,
        string calldata name,
        string calldata symbol,
        uint256 totalSupply
    ) external whenNotPaused nonReentrant returns (address tokenAddress) {
        // Validate inputs
        _validateTokenCreation(metadata, totalSupply);

        // No creation fee required

        // Increment token ID
        _tokenIdCounter++;
        uint256 tokenId = _tokenIdCounter;

        // Deploy new RWA token
        RWAToken newToken = new RWAToken(
            name,
            symbol,
            totalSupply,
            msg.sender,
            address(this)
        );

        tokenAddress = address(newToken);

        // Register token
        tokenById[tokenId] = tokenAddress;
        tokenToId[tokenAddress] = tokenId;
        isRWAToken[tokenAddress] = true;

        // Store asset information
        assetInfo[tokenAddress] = DataTypes.AssetInfo({
            tokenAddress: tokenAddress,
            creator: msg.sender,
            creationTime: block.timestamp,
            metadata: metadata,
            complianceLevel: 1, // Basic compliance required
            isListed: false,
            tradingVolume: 0,
            holders: 1
        });

        // Update creator registry
        creatorTokens[msg.sender].push(tokenId);
        assetTypeCount[metadata.assetType]++;

        // No creation fee to transfer

        emit TokenCreated(
            tokenId,
            tokenAddress,
            msg.sender,
            metadata.assetType,
            totalSupply
        );
        emit Events.RWATokenCreated(
            tokenAddress,
            msg.sender,
            metadata.assetType,
            totalSupply,
            metadata.valuation
        );

        return tokenAddress;
    }

    /**
     * @notice List a token for trading
     * @param tokenAddress Address of token to list
     */
    function listToken(
        address tokenAddress
    ) external payable validTokenAddress(tokenAddress) whenNotPaused {
        DataTypes.AssetInfo storage info = assetInfo[tokenAddress];

        // Only creator or admin can list
        if (msg.sender != info.creator && !hasRole(ADMIN_ROLE, msg.sender)) {
            revert HedVaultErrors.UnauthorizedAccess(
                msg.sender,
                "creator or admin"
            );
        }

        if (info.isListed) {
            revert HedVaultErrors.TokenAlreadyListed(tokenAddress);
        }

        // Check listing fee
        if (msg.value < listingFee) {
            revert HedVaultErrors.InsufficientFeePayment(msg.value, listingFee);
        }

        info.isListed = true;
        _transferFee(listingFee);

        emit TokenListed(tokenAddress, msg.sender, block.timestamp);
        emit Events.RWATokenListed(tokenAddress, msg.sender, block.timestamp);
    }

    /**
     * @notice Delist a token from trading
     * @param tokenAddress Address of token to delist
     * @param reason Reason for delisting
     */
    function delistToken(
        address tokenAddress,
        string calldata reason
    ) external onlyRole(ADMIN_ROLE) validTokenAddress(tokenAddress) {
        DataTypes.AssetInfo storage info = assetInfo[tokenAddress];

        if (!info.isListed) {
            revert HedVaultErrors.TokenNotListed(tokenAddress);
        }

        info.isListed = false;

        emit TokenDelisted(tokenAddress, msg.sender, reason);
        emit Events.RWATokenDelisted(tokenAddress, msg.sender, block.timestamp);
    }

    /**
     * @notice Update token metadata
     * @param tokenAddress Address of token to update
     * @param newMetadata New metadata
     */
    function updateTokenMetadata(
        address tokenAddress,
        DataTypes.RWAMetadata calldata newMetadata
    ) external validTokenAddress(tokenAddress) {
        DataTypes.AssetInfo storage info = assetInfo[tokenAddress];

        // Only creator, admin, or oracle can update
        if (
            msg.sender != info.creator &&
            !hasRole(ADMIN_ROLE, msg.sender) &&
            msg.sender != info.metadata.oracle
        ) {
            revert HedVaultErrors.UnauthorizedAccess(
                msg.sender,
                "creator, admin, or oracle"
            );
        }

        // Validate new metadata
        _validateMetadata(newMetadata);

        info.metadata = newMetadata;

        emit Events.RWATokenUpdated(
            tokenAddress,
            newMetadata.valuation,
            block.timestamp
        );
    }

    /**
     * @notice Approve a creator
     * @param creator Address to approve as creator
     */
    function approveCreator(address creator) external onlyRole(ADMIN_ROLE) {
        if (creator == address(0)) {
            revert HedVaultErrors.ZeroAddress();
        }
        if (approvedCreators[creator]) {
            revert HedVaultErrors.AdminAlreadyExists(creator);
        }

        approvedCreators[creator] = true;
        _grantRole(CREATOR_ROLE, creator);

        emit CreatorApproved(creator, msg.sender);
    }

    /**
     * @notice Revoke creator approval
     * @param creator Address to revoke
     */
    function revokeCreator(address creator) external onlyRole(ADMIN_ROLE) {
        if (!approvedCreators[creator]) {
            revert HedVaultErrors.AdminDoesNotExist(creator);
        }

        approvedCreators[creator] = false;
        _revokeRole(CREATOR_ROLE, creator);

        emit CreatorRevoked(creator, msg.sender);
    }

    /**
     * @notice Add supported asset type
     * @param assetType Asset type to add
     */
    function addAssetType(
        string calldata assetType
    ) external onlyRole(ADMIN_ROLE) {
        _addAssetType(assetType);
        emit AssetTypeAdded(assetType, msg.sender);
    }

    /**
     * @notice Remove supported asset type
     * @param assetType Asset type to remove
     */
    function removeAssetType(
        string calldata assetType
    ) external onlyRole(ADMIN_ROLE) {
        if (!supportedAssetTypes[assetType]) {
            revert HedVaultErrors.InvalidConfiguration(assetType);
        }

        supportedAssetTypes[assetType] = false;
        emit AssetTypeRemoved(assetType, msg.sender);
    }

    // Token creation fee functionality removed

    /**
     * @notice Update listing fee
     * @param newFee New listing fee
     */
    function updateListingFee(uint256 newFee) external onlyRole(ADMIN_ROLE) {
        listingFee = newFee;
    }

    /**
     * @notice Pause the contract
     */
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    /**
     * @notice Unpause the contract
     */
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    // View functions
    function getTotalTokens() external view returns (uint256) {
        return _tokenIdCounter;
    }

    function getCreatorTokens(
        address creator
    ) external view returns (uint256[] memory) {
        return creatorTokens[creator];
    }

    function getAssetInfo(
        address tokenAddress
    ) external view returns (DataTypes.AssetInfo memory) {
        return assetInfo[tokenAddress];
    }

    function isAssetTypeSupported(
        string calldata assetType
    ) external view returns (bool) {
        return supportedAssetTypes[assetType];
    }

    function getAssetTypeCount(
        string calldata assetType
    ) external view returns (uint256) {
        return assetTypeCount[assetType];
    }

    /**
     * @notice Get all RWA token addresses
     * @return tokens Array of all RWA token addresses
     */
    function getAllRWATokens() external view returns (address[] memory tokens) {
        tokens = new address[](_tokenIdCounter);
        for (uint256 i = 1; i <= _tokenIdCounter; i++) {
            tokens[i - 1] = tokenById[i];
        }
        return tokens;
    }

    /**
     * @notice Get all RWA tokens with their asset info
     * @return tokenAddresses Array of token addresses
     * @return assetInfos Array of corresponding asset info
     */
    function getAllRWATokensWithInfo()
        external
        view
        returns (
            address[] memory tokenAddresses,
            DataTypes.AssetInfo[] memory assetInfos
        )
    {
        tokenAddresses = new address[](_tokenIdCounter);
        assetInfos = new DataTypes.AssetInfo[](_tokenIdCounter);

        for (uint256 i = 1; i <= _tokenIdCounter; i++) {
            address tokenAddr = tokenById[i];
            tokenAddresses[i - 1] = tokenAddr;
            assetInfos[i - 1] = assetInfo[tokenAddr];
        }

        return (tokenAddresses, assetInfos);
    }

    // Internal functions
    function _validateTokenCreation(
        DataTypes.RWAMetadata calldata metadata,
        uint256 totalSupply
    ) internal view {
        if (totalSupply < MIN_TOTAL_SUPPLY || totalSupply > MAX_TOTAL_SUPPLY) {
            revert HedVaultErrors.InvalidAmount(
                totalSupply,
                MIN_TOTAL_SUPPLY,
                MAX_TOTAL_SUPPLY
            );
        }

        _validateMetadata(metadata);
    }

    function _validateMetadata(
        DataTypes.RWAMetadata calldata metadata
    ) internal view {
        if (!supportedAssetTypes[metadata.assetType]) {
            revert HedVaultErrors.InvalidTokenMetadata("assetType");
        }

        if (metadata.valuation < MIN_VALUATION) {
            revert HedVaultErrors.InvalidAmount(
                metadata.valuation,
                MIN_VALUATION,
                type(uint256).max
            );
        }

        if (bytes(metadata.location).length == 0) {
            revert HedVaultErrors.InvalidTokenMetadata("location");
        }

        if (bytes(metadata.certificationHash).length == 0) {
            revert HedVaultErrors.InvalidTokenMetadata("certificationHash");
        }

        if (metadata.oracle == address(0)) {
            revert HedVaultErrors.InvalidTokenMetadata("oracle");
        }
    }

    function _addAssetType(string memory assetType) internal {
        supportedAssetTypes[assetType] = true;
    }

    function _transferFee(uint256 amount) internal {
        if (amount > 0) {
            (bool success, ) = payable(hedVaultCore.feeRecipient()).call{
                value: amount
            }("");
            if (!success) {
                revert HedVaultErrors.FeeCollectionFailed("Transfer failed");
            }
        }
    }
}
