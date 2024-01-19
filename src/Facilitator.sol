// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IGhoToken.sol";

contract Facilitator is AccessControl, ReentrancyGuard {

    bytes32 public constant DEV_ROLE = 0x51b355059847d158e68950419dbcd54fad00bdfd0634c2515a5c533288c7f0a2;
    bytes32 public VAULT_ROLE = 0x31e0210044b4f6757ce6aa31f9c6e8d4896d24a755014887391a926c5224d959;

    IGhoToken immutable public token;
    constructor(address _token) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEV_ROLE, msg.sender);
        _grantRole(VAULT_ROLE, msg.sender);
        token = IGhoToken(_token);
    }

    modifier onlyVault() {
        if(!hasRole(VAULT_ROLE, msg.sender)){
            revert("not vault"); 
        }
        _;
    }

    function minting() public onlyVault {}

    function burning() public onlyVault {}
}