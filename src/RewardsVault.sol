// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract RewardsVault is AccessControl, ReentrancyGuard {

        using SafeERC20 for IERC20;

        bytes32 public constant DEV_ROLE = 0x51b355059847d158e68950419dbcd54fad00bdfd0634c2515a5c533288c7f0a2;
        bytes32 public constant DEPOSIT_ROLE = 0x2561bf26f818282a3be40719542054d2173eb0d38539e8a8d3cff22f29fd2384;
        uint256 public totalSupply;
        IERC20 public token;
        address public treasury;

        bool public paused = false;

        mapping(address => bool) private authorized;

        constructor(address _token) {
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
            _grantRole(DEV_ROLE, msg.sender);
            _grantRole(DEPOSIT_ROLE, msg.sender);
            token = IERC20(_token);
        }

        modifier onlyAuth() {
            if(!authorized[msg.sender]){
                revert ("not authorized");
            }
            _;
        }

        modifier onlyDev() {
             if (!hasRole(DEV_ROLE, msg.sender)) {
            revert("have no dev role");
        }
            _;
        }

         modifier onlyDeposit() {
             if (!hasRole(DEPOSIT_ROLE, msg.sender)) {
            revert("have no dev role");
        }
            _;
        }

        modifier isPaused() {
            if(paused) {
                revert("emergency pause on");
            }
            _;
        }

        function deposit(uint256 _amount) public onlyDeposit nonReentrant isPaused {
            totalSupply += _amount;
            token.safeTransferFrom(msg.sender,address(this),_amount);
        }

        function withdraw(uint256 _amount) public onlyAuth nonReentrant isPaused {
            totalSupply -= _amount;
            token.safeTransfer(msg.sender, _amount);
        }


        function emergencyPause(bool status) public onlyDev {
            paused = status;
        }

        function saveFunds() public onlyDev {
            token.safeTransfer(treasury, token.balanceOf(address(this)));
        }

        function getAuthorized(address _user) public view returns(bool _status){
            return authorized[_user];
        }

        function setAuthorized(address _user, bool _status) public onlyDev {
            authorized[_user] = _status;
        }

        function setTreasury(address _treasury) public onlyDev {
            treasury = _treasury;
        }
}