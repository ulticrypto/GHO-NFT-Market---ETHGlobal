// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "./PRBMathUD60x18Typed.sol";

contract Calculations {

    using PRBMathUD60x18Typed for PRBMath.UD60x18;

    uint256 private constant SECONDS_PER_YEAR = 365 days;

    /// @dev Function to calculate the interest paid for the user every second.
    /// @param _amount amount deposited by the user.
    /// @param _interest interest payable on ten thousand basis.
    function interestForSecond(uint256 _amount, uint256 _interest) public pure returns(uint256 payPerSecond){
        if(_amount == 0){
           return payPerSecond = 0;
        }
        PRBMath.UD60x18 memory amount = PRBMath.UD60x18({value: _amount});
        PRBMath.UD60x18 memory AmountxPercentage = amount.mul(PRBMath.UD60x18({value: _interest}));
        PRBMath.UD60x18 memory annualPay = AmountxPercentage.div(PRBMath.UD60x18({value: 10000}));
        PRBMath.UD60x18 memory AmountPerSecond = annualPay.div(PRBMath.UD60x18({value: SECONDS_PER_YEAR * 1e18}));

        payPerSecond = AmountPerSecond.value; // return number in factor 18
    }

     /// @dev Function to calculate the total interest paid.
     function calculateInterest(uint256 _startTime, uint256 payPerSecond) public view returns(uint256 totalInterest){
         if(payPerSecond == 0){
           return totalInterest = 0;
        }
        PRBMath.UD60x18 memory _payPerSecond = PRBMath.UD60x18({value: payPerSecond * 1e18});
        PRBMath.UD60x18 memory today = PRBMath.UD60x18({value: block.timestamp});
        PRBMath.UD60x18 memory numberOfDays = today.sub(PRBMath.UD60x18({value: _startTime}));
        PRBMath.UD60x18 memory totalInterestAmount= numberOfDays.mul(_payPerSecond);

        totalInterest = totalInterestAmount.value; // return number in factor 18
    }

}