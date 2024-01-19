// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ICalculations {

    function interestForSecond(uint256 _amount, uint256 _interest) external pure returns(uint256 payPerSecond);

}