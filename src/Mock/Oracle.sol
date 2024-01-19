// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract AggregatorProxy is Ownable {

  int256 private answer;
  uint256 private updatedAt;
  constructor() {}

  function latestAnswer()
    public
    view
    returns (int256 _answer)
  {
    _answer= answer;
  }

  function latestTimestamp()
    public
    view
    returns (uint256 _updatedAt)
  {
    _updatedAt = updatedAt;
  }

  function SetlatestAnswer(int lastAnswer, uint time) public onlyOwner {
    answer = lastAnswer;
    updatedAt = time;
  }
  
  function description() public pure returns(string memory name){
    name = "Bored Ape Yacht Club Floor Price / ETH ";
  }

  function decimals() public pure returns(uint){
    return 18;
  }

 

}