// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import '../Mock/ERC20.sol';

contract mockuBAYC is ERC20 {

    constructor() ERC20("mockuBAYC","mockuBAYC",18){}

    function mint(address to, uint256 amount) public {
        _mint(to,amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender,amount);
    }
}