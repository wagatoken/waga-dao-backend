// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * @title OracleLib
 * @notice Library for interacting with Chainlink price feeds with stale price protection
 * @dev Used by WAGA DAO contracts to get reliable price data
 */
library OracleLib {
    error OracleLib__StalePriceData();
    
    uint256 private constant TIMEOUT = 3 hours; // 3 hour timeout for stale price data

    /**
     * @dev Gets the latest round data from a Chainlink price feed with stale price check
     * @param priceFeed The Chainlink price feed interface
     * @return roundId The round ID
     * @return answer The price answer
     * @return startedAt When the round started
     * @return updatedAt When the round was last updated
     * @return answeredInRound The round ID of the round in which the answer was computed
     */
    function stalePriceCheckLatestRoundData(
        AggregatorV3Interface priceFeed
    ) public view returns (uint80, int256, uint256, uint256, uint80) {
        (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();

        if (block.timestamp - updatedAt > TIMEOUT) {
            revert OracleLib__StalePriceData();
        }
        return (roundId, answer, startedAt, updatedAt, answeredInRound);
    }
    
    /**
     * @dev Gets the latest price from a Chainlink price feed with stale price check
     * @param priceFeed The Chainlink price feed interface
     * @return price The latest price (8 decimals from Chainlink)
     */
    function getPrice(AggregatorV3Interface priceFeed) public view returns (uint256) {
        (, int256 answer, , , ) = stalePriceCheckLatestRoundData(priceFeed);
        require(answer > 0, "Invalid price data");
        return uint256(answer);
    }
    
    /**
     * @dev Converts Chainlink price (8 decimals) to 18 decimals
     * @param priceFeed The Chainlink price feed interface
     * @return price The price converted to 18 decimals
     */
    function getPriceWith18Decimals(AggregatorV3Interface priceFeed) public view returns (uint256) {
        uint256 price = getPrice(priceFeed);
        return price * 1e10; // Convert from 8 decimals to 18 decimals
    }
}
