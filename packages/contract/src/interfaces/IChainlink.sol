// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Chainlink Interfaces
 * @notice Common Chainlink interfaces used across the protocol
 */

// Chainlink Price Feed Interface
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
    function version() external view returns (uint256);
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

// Interface for Chainlink Functions (for custom offchain data)
interface IChainlinkFunctions {
    function sendRequest(
        bytes calldata source,
        bytes calldata secrets,
        string[] calldata args,
        uint64 subscriptionId,
        uint32 gasLimit
    ) external returns (bytes32 requestId);
}
