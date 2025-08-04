// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IHedVaultCore
 * @notice Interface for the HedVault Core contract
 */
interface IHedVaultCore {
    // View functions
    function feeRecipient() external view returns (address);
    function tradingFee() external view returns (uint256);
    function lendingFee() external view returns (uint256);
    function swapFee() external view returns (uint256);
    function bridgeFee() external view returns (uint256);
    function isInitialized() external view returns (bool);
    function emergencyMode() external view returns (bool);
    function admins(address admin) external view returns (bool);
    function circuitBreakers(
        string calldata module
    ) external view returns (bool);

    // Module addresses
    function rwaTokenFactory() external view returns (address);
    function marketplace() external view returns (address);
    function swapEngine() external view returns (address);
    function lendingPool() external view returns (address);
    function rewardsDistributor() external view returns (address);
    function priceOracle() external view returns (address);
    function complianceManager() external view returns (address);
    function portfolioManager() external view returns (address);
    function crossChainBridge() external view returns (address);
    function analyticsEngine() external view returns (address);

    // Functions
    function getProtocolFee(
        string calldata operation
    ) external view returns (uint256);
    function isValidModule(address module) external view returns (bool);
    function updateStatistics(
        address user,
        uint256 transactionValue,
        uint256 feeAmount
    ) external;

    // Events
    event ProtocolInitialized(address indexed core, uint256 timestamp);
    event ProtocolPaused(address indexed admin, uint256 timestamp);
    event ProtocolUnpaused(address indexed admin, uint256 timestamp);
    event FeeUpdated(string feeType, uint256 oldFee, uint256 newFee);
    event AdminAdded(address indexed admin, address indexed addedBy);
    event AdminRemoved(address indexed admin, address indexed removedBy);
}
