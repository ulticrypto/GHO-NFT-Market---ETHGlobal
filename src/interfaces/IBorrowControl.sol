// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
interface IBorrowControl {

    struct UserPosition {
        uint256 collateralAmount;
        address collateralAddress;
        uint256 supplyDate;
        uint256 collateralInterestPerSecond;
        uint256 borrowAmount;
        uint256 borrowDate;
        uint256 borrowInterestPerSecond;
        uint256 pendingBorrowInterest;
        address delegateFor;
        bool isPay;
        bool isLiquidated;
        bool isDelegate;
    }

    struct Rewards {
        uint256 pendingRewards;
        uint256 rewardsClaimed;
        uint256 lastClaim;
    }

    struct Assets {
        address collateralOracle;
        uint256 collateralAPY;
        uint256 ltv;
        uint256 liquidationThreshold;
        bool freeze;
    }

    /// @notice write functions
    function createPosition(address user, uint256 collateralAmount, address collateralAddress, uint256 collateralInterestPerSecond) external;

    function updateCollateral(address user,uint256 newCollateralAmount, uint256 newCollateralInterestPerSecond) external;

    //function updatePendingCollateralInterest(address user, uint256 pendingCollateralInterest) external;

    function updatePayStatus(address user, bool status) external;

    function setBorrowInfo(address user,uint256 borrowAmount,uint256 borrowInterestPerSecond) external;

    function updateBorrowInfo(address user,uint256 newBorrowAmount,uint256 newBorrowInterestPerSecond) external;

    function updatePendingBorrowInterest(address user, uint256 pendingBorrowInterest) external;

    function updateLiquidateStatus(address user, bool status) external;

    function updateDelegateStatus(address user, address delegateTo, bool status) external;

    function updatePenRewads(address user, uint256 penRewards) external;

    function updateClaimRewads(address user, uint256 claimed) external;

    function AddVault(address collateralAddress, address vault) external;

    /// @notice read functions
    function getUserInfo(address user) external view returns(UserPosition memory info);

    function getRewardsInfo(address user) external view returns(Rewards memory prizes);

    //function getLastDateRewards(address user) external view returns(uint _lastcalc, uint _lastClaim);
    
    function getAssetInfo(address collateralAddress) external view returns(Assets memory info);

    function getborrowIntesrest() external view returns(uint256 _borrowInterest);
}