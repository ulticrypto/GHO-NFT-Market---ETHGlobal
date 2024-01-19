// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

contract BorrowControl is AccessControl {

    bytes32 public constant DEV_ROLE = 0x51b355059847d158e68950419dbcd54fad00bdfd0634c2515a5c533288c7f0a2;

    uint256 private borrowIntesrest;
    
    mapping(address vault => bool stauts) private authorized;

    struct UserPosition {
        uint256 collateralAmount;
        address collateralAddress;
        uint256 supplyDate;
        uint256 collateralInterestPerSecond;
        uint256 borrowAmount;
        uint256 borrowDate;
        uint256 borrowInterestPerSecond;
        uint256 pendingBorrowInterestPerSecond;
        address delegateFor;
        bool isPay;
        bool isLiquidated;
        bool isDelegate;
    }

    mapping(address user => UserPosition) private position;

    struct Assets {
        address collateralOracle;
        uint256 collateralAPY;
        uint256 ltv;
        uint256 liquidationThreshold;
        bool freeze;
    }

    mapping(address collateralAddress => Assets) private assetInfo;

    mapping(address collateralAddress => address vault) private vaultsInfo;

    struct Rewards {
        uint256 pendingRewards;
        uint256 rewardsClaimed;
        uint256 lastClaim;
    }

    mapping(address user => Rewards) private rewards;
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEV_ROLE, msg.sender);
    }

    modifier onlyDev() {
        if(!hasRole(DEV_ROLE, msg.sender)){
            revert ("not dev role");
        }
        _;
    }

    modifier onlyAuth() {
        if(!authorized[msg.sender]){
            revert("not auth");
        }
        _;
    }
    
    ///@dev function to create a new user position
    function createPosition(address user, uint256 collateralAmount, address collateralAddress, uint256 collateralInterestPerSecond) public onlyAuth {
        position[user].collateralAddress = collateralAddress;
        position[user].collateralAmount = collateralAmount;
        position[user].supplyDate = block.timestamp;
        position[user].collateralInterestPerSecond = collateralInterestPerSecond;
    }

    ///@dev function to udpate a user's position
    function updateCollateral(address user,uint256 newCollateralAmount, uint256 newCollateralInterestPerSecond) public onlyAuth {
        position[user].collateralAmount = newCollateralAmount;
        position[user].collateralInterestPerSecond = newCollateralInterestPerSecond;
        position[user].supplyDate = block.timestamp;
    }

    function updatePayStatus(address user, bool status) public onlyAuth {
        position[user].isPay = status;
    }

    function setBorrowInfo(address user,uint256 borrowAmount,uint256 borrowInterestPerSecond) public onlyAuth {
        position[user].borrowAmount = borrowAmount;
        position[user].borrowDate= block.timestamp;
        position[user].borrowInterestPerSecond = borrowInterestPerSecond;
    }

    function updateBorrowInfo(address user,uint256 newBorrowAmount,uint256 newBorrowInterestPerSecond) public onlyAuth {
        position[user].borrowAmount = newBorrowAmount;
        position[user].borrowInterestPerSecond = newBorrowInterestPerSecond;
    }

    function updatePendingBorrowInterest(address user, uint256 pendingBorrowInterestPerSecond)  public onlyAuth {
        position[user].pendingBorrowInterestPerSecond = pendingBorrowInterestPerSecond;
        position[user].borrowDate= block.timestamp;
    }

    function updateLiquidateStatus(address user, bool status) public onlyAuth {
        position[user].isLiquidated = status;
    }

    function updateDelegateStatus(address user, address delegateTo, bool status) public onlyAuth {
        position[user].delegateFor = delegateTo;
        position[user].isDelegate = status;
    }

    function getUserInfo(address user) public view returns(UserPosition memory info){
        info = position[user];
    }


    function getRewardsInfo(address user) public view returns(Rewards memory prizes) {
        prizes = rewards[user];
    }

    ///@dev function to update the pending rewards of a user's position
    function updatePenRewads(address user, uint256 penRewards) public onlyAuth {
        rewards[user].pendingRewards = penRewards;
    }

    ///@dev function to update the rewards claimed of a user's position
    function updateClaimRewads(address user, uint256 claimed) public onlyAuth {
        rewards[user].rewardsClaimed = claimed;
        rewards[user].lastClaim = block.timestamp;
    }

    function setAssetInfo(Assets memory info, address collateralAddress) public onlyDev {
        assetInfo[collateralAddress] = info;
    }

    function setFreezeAsset(address collateralAddress, bool _freeze) public onlyDev {
        assetInfo[collateralAddress].freeze = _freeze;
    }

    function getAssetInfo(address collateralAddress) public view returns(Assets memory info) {
        info = assetInfo[collateralAddress];
    }

    function AddVault(address collateralAddress, address vault) public onlyDev {
        if(vaultsInfo[collateralAddress] != address(0)){
            revert ("vault already create");
        }
        vaultsInfo[collateralAddress] = vault;
    }
    
    function getborrowIntesrest() public view returns(uint256 _borrowInterest){
        _borrowInterest = borrowIntesrest;
    }

    function setborrowIntesrest(uint256 newBorrowInterest) public onlyDev {
        if(newBorrowInterest > 5000){ //50% 
            revert("Interest to high");
        }

        borrowIntesrest = newBorrowInterest;
    }

    function getVault(address collateralAddress) public view returns(address vault) {
        vault = vaultsInfo[collateralAddress];
    }

    function deleteVault(address collateralAddress) public onlyDev {
        delete vaultsInfo[collateralAddress];
    }


    function setAuthorized(address vault, bool stauts) public onlyDev {
        authorized[vault] = stauts;
    }

    function getAuthorized(address vault) public view returns(bool stauts) {
        stauts = authorized[vault];
     }

}
