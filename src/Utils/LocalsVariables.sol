
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
interface LocalsVariables {

    struct localsVars {
        uint256 price;
        uint256 loan;
        uint256 wrapBalance;
        address owner;
        uint nftBalance;
        uint totalmortgage;
        address collection;
        uint256 nftId;
        address wrapContract;
        uint256 _loan;
        uint256 downPay; 
        uint256 _price;
        uint256 startDate;
        uint256 period;
        uint64  interestrate;
        uint256 payCounter;
        bool isPay;
        bool mortgageAgain;
        uint256 linkId;
    }      

    struct LocaDebt {
        uint256 totalDebt;
        uint256 totalMonthlyPay;
        uint256 totalDelayedMonthlyPay;
        uint256 totalToPayOnLiquidation;
        uint256 lastTimePayment;
        bool isMonthlyPaymentPayed;
        bool isMonthlyPaymentDelayed;
        bool liquidate;
    } 

    struct Rewards {
            uint256 rewardPerBuilder;
            uint256 lastTimePayBuilder;
            uint256 lastTimeCalcBuilder;
            uint256 rewardPerHolder;
            uint256 lastTimePayHolder;
            uint256 lastTimeCalcHolder;
            uint256 rewardPerRent;
            uint256 lastTimePayRent;
            uint256 lastTimeCalcRent;
            uint256 rewardPerRentNFT;
    } 
} 