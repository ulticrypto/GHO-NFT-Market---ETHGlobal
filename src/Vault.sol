// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IAggregator.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "./interfaces/ICalculations.sol";
import "./interfaces/IBorrowControl.sol";
import "./interfaces/IFacilitator.sol";

contract Vault is AccessControl, ReentrancyGuard {

    event DepositCollateral(address indexed token, address indexed user, uint amount);
    event WithdrawCollateral(address indexed token, address indexed user, uint amount, uint rewards);
    event TakeBorrow(address indexed token, address indexed user, uint loan, uint date);
    event Repay(address indexed token, address indexed user, uint amount, uint date);

    using SafeERC20 for IERC20;

    bytes32 public constant DEV_ROLE = 0x51b355059847d158e68950419dbcd54fad00bdfd0634c2515a5c533288c7f0a2;

    IERC20 immutable public collateralToken;
    IBorrowControl immutable public control;
    ICalculations public calcs;
    IERC20 public borrowToken;
    IFacilitator public facilitator;
    address public treasury;
    bool public paused = false;

    constructor(address _collateralToken, address _control, address _calcs, address _borrowToken, address _facilitator) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEV_ROLE, msg.sender);
        collateralToken = IERC20(_collateralToken);
        control = IBorrowControl(_control);
        calcs = ICalculations(_calcs);
        borrowToken = IERC20(_borrowToken);
        facilitator = IFacilitator(_facilitator);
    }

    modifier onlyDev() {
     if(!hasRole(DEV_ROLE, msg.sender)){
        revert("not dev");
     }
        _;
    }

    function supply(uint amount) public nonReentrant {
        if(amount == 0){
            revert("zero amount");
        }   

        collateralToken.safeTransferFrom(msg.sender, address(this),amount);

        uint collateral = control.getUserInfo(msg.sender).collateralAmount;

        if(collateral == 0){

            control.createPosition(msg.sender, amount, address(collateralToken), getInterestPerSecond(amount, control.getAssetInfo(address(collateralToken)).collateralAPY));

        } else {

            control.updatePenRewads(msg.sender, getInterestPerSecond(collateral, control.getAssetInfo(address(collateralToken)).collateralAPY));

            uint total = collateral + amount;

            control.updateCollateral(msg.sender,total, getInterestPerSecond(total, control.getAssetInfo(address(collateralToken)).collateralAPY));
  
        }

        emitEventDeposit(address(collateralToken), msg.sender, amount);
    }

    function borrow(uint borrowAmount) public nonReentrant {

        int256 realValue = collateralUSDValue(control.getUserInfo(msg.sender).collateralAmount);
        uint256 maxBorrowAmount = percentage(SafeCast.toUint256(realValue));

        if(borrowAmount > maxBorrowAmount) {
            revert ("not enough collateral");
        }

        uint oldborrow = control.getUserInfo(msg.sender).borrowAmount;

        if(oldborrow == 0){

            control.setBorrowInfo(msg.sender,borrowAmount,getInterestPerSecond(borrowAmount, control.getborrowIntesrest())); 

        }else{
            
            control.updatePendingBorrowInterest(msg.sender, getInterestPerSecond(borrowAmount, control.getborrowIntesrest()));

            uint total = borrowAmount + oldborrow;

            control.updateBorrowInfo(msg.sender,total,getInterestPerSecond(total, control.getborrowIntesrest()));
 
        }

        facilitator.minting(msg.sender, borrowAmount);

        emitEventBorrow(address(borrowToken), msg.sender,borrowAmount, block.timestamp);
    }

    function repay() public nonReentrant {

        IBorrowControl.UserPosition memory info = control.getUserInfo(msg.sender);

        IERC20(borrowToken).safeTransferFrom(msg.sender, address(this),(info.borrowAmount + (info.borrowAmount + info.pendingBorrowInterestPerSecond + getInterestPerSecond(info.borrowAmount, control.getborrowIntesrest()))));

        control.updatePendingBorrowInterest(msg.sender, 0);

        control.updateBorrowInfo(msg.sender,0,0);

        control.updatePayStatus(msg.sender, true);

        facilitator.burning(info.borrowAmount);

        emitEventRepay(address(borrowToken),msg.sender,info.borrowAmount, block.timestamp);
    }

    function withdrawCollateral(uint amount) public nonReentrant {
        uint rewards;

        IBorrowControl.UserPosition memory info = control.getUserInfo(msg.sender);

        if(amount > info.collateralAmount){

            revert("more tha collateral");

        }else if(amount == info.collateralAmount){

            if(info.borrowAmount != 0){
                revert("have a loan");
            }

            rewards = control.getRewardsInfo(msg.sender).pendingRewards + getInterestPerSecond(info.collateralAmount, control.getAssetInfo(address(collateralToken)).collateralAPY);

            control.updatePenRewads(msg.sender, 0);
            control.updateCollateral(msg.sender,0, 0);   

            collateralToken.safeTransfer(msg.sender, amount);

            control.updateClaimRewads(msg.sender, rewards);

            IERC20(borrowToken).safeTransfer(msg.sender, rewards);

        }else {

            uint newCollateral = info.collateralAmount - amount;

            int256 realValue = collateralUSDValue(newCollateral);
            uint256 maxBorrowAmount = percentage(SafeCast.toUint256(realValue));

            if(info.borrowAmount > maxBorrowAmount) {
                revert("unhealthy loan");
            }

            rewards = control.getRewardsInfo(msg.sender).pendingRewards + getInterestPerSecond(info.collateralAmount, control.getAssetInfo(address(collateralToken)).collateralAPY);
            
            control.updatePenRewads(msg.sender, 0);

            control.updateCollateral(msg.sender,newCollateral, getInterestPerSecond(newCollateral, control.getAssetInfo(address(collateralToken)).collateralAPY)); 

            collateralToken.safeTransfer(msg.sender, amount);

            control.updateClaimRewads(msg.sender, rewards);

            IERC20(borrowToken).safeTransfer(msg.sender, rewards);
        }

        emitEventWithdraw(address(collateralToken), msg.sender, amount,rewards);
    }
    

    function collateralUSDValue(uint collateral) private view returns(int256 realValue){
        int256 roundPrice = getPrice();
        realValue = (SafeCast.toInt256(collateral) * roundPrice) / 1e18; 
    }

    function getInterestPerSecond(uint256 amount, uint256 precentage) private view returns(uint256 interestPerSecond) {
        interestPerSecond = calcs.interestForSecond(amount,precentage);
    }
    
    function getPrice() private view returns(int256 finalPrice){
        IBorrowControl.Assets memory info = control.getAssetInfo(address(collateralToken));
        IAggregator oracle = IAggregator(info.collateralOracle);
        uint8 decimals = oracle.decimals();
        uint256 rounding;
        if(decimals != 18) {
            int price = oracle.latestAnswer();
            uint256 diference = 18 - decimals;
            rounding = 10 ** diference;
            finalPrice = price * SafeCast.toInt256(rounding);
        }else {
            finalPrice = oracle.latestAnswer();
        }
        
    }
    
    function percentage(uint amount) public view returns(uint256 value){
        IBorrowControl.Assets memory info = control.getAssetInfo(address(collateralToken));
        value = (amount * info.ltv)/10000;
    }

    function emitEventDeposit(address token, address user, uint256 amount) private {
        assembly{
            //DepositCollateral(address,address,uint)
            let signatureHash := 0x156e3eee840364268dc5bc6a82162ffe390a22d7aa94443e0c64a7b252f3a9c4
            mstore(0, amount)
            log3(0, 0x20, signatureHash, token, user)
        }
    }

    function emitEventBorrow(address token, address user, uint loan, uint date) private {
        assembly{
            //TakeBorrow(address,address,uint256,uint256)
            let signatureHash := 0x82abfd72b35e29bfe8db6353d6e7bc118b8bdc90ebd3e7cf3f9f95fcd4f483c2
            mstore(0, loan)
            mstore(0x20, date)
            log3(0, 0x40, signatureHash, token, user)
        }
    }

    function emitEventRepay(address token, address user, uint amount, uint date) private {
        assembly{
            //Repay(address,address,uint256,uint256)
            let signatureHash := 0xe4a1ae657f49cb1fb1c7d3a94ae6093565c4c8c0e03de488f79c377c3c3a24e0
            mstore(0, amount)
            mstore(0x20, date)
            log3(0, 0x40, signatureHash, token, user)
        }
    }

    function emitEventWithdraw(address token, address user, uint amount, uint rewards) private {
        assembly{
            //WithdrawCollateral(address,address,uint256,uint256)
            let signatureHash := 0x7defc562b3eeddf62fd801e6b306167eef4078e7db2c676313406bffd53cbe3a
            mstore(0, amount)
            mstore(0x20, rewards)
            log3(0, 0x40, signatureHash, token, user)
        }
    }

    function emergencyPause(bool status) public onlyDev {
            paused = status;
    }

    function saveFunds() public onlyDev {
            collateralToken.safeTransfer(treasury, collateralToken.balanceOf(address(this)));
    }

    function setTreasury(address _treasury) public onlyDev {
            treasury = _treasury;
    }

    function updateCalcs(address _newCalcs) public onlyDev {
        calcs = ICalculations(_newCalcs);
    }

    function getRewards(address user) public view returns(uint256 _rewards){
        _rewards = control.getRewardsInfo(user).pendingRewards + getInterestPerSecond(control.getUserInfo(user).collateralAmount, control.getAssetInfo(address(collateralToken)).collateralAPY);
    }

}
