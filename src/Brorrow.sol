// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IPool.sol";
import "./interfaces/ICreditDelegationToken.sol";
import "./interfaces/IAggregator.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "./interfaces/ICalculations.sol";

contract Borrows is AccessControl {

    event BorrowDelivered(address indexed vault, address indexed borrower, uint amount);

     using SafeERC20 for IERC20;

    bytes32 public constant BORROW_ROLE = 0x530c3f8e4fc58decc3c11520b4830edeb873a50632d9a28591dc6bd94f8f9349;
    bytes32 public constant DELEGATOR_ROLE = 0x1948e62cb88693562db3600e12aba035ba28da4a0626473ef28234bb89054073;

    address immutable public pool;
    address immutable public debtContract;
    address public delegator;
    IERC20 private gho = IERC20(0xc4bF5CbDaBE595361438F8c6a187bDc330539c60);
    IERC20 private aWeth = IERC20(0x5b071b590a59395fE4025A0Ccc1FcC931AAc1830);
    IAggregator private oracle = IAggregator(0xDde0E8E6d3653614878Bf5009EDC317BC129fE2F);

    //SEPOLIA
    //Proxy Pool 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951
    //ETH Pool to supply collateral 0x387d311e47e80b498169e6fb51d3193167d89F7D
    //GHO token 0xc4bF5CbDaBE595361438F8c6a187bDc330539c60
    //GHO proxy Variable Debt 0x67ae46EF043F7A4508BD1d6B94DB6c33F0915844
    //Oracle Price Aggregator WETH 0xDde0E8E6d3653614878Bf5009EDC317BC129fE2F
    constructor(address _pool, address _debtContract, address _delegator, address user) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(BORROW_ROLE, user);
        _grantRole(DELEGATOR_ROLE, msg.sender);
        pool = _pool;
        debtContract = _debtContract;
        delegator = _delegator;
    }

    modifier onlyBorrower() {
     if(!hasRole(BORROW_ROLE, msg.sender)){
        revert("not the borrower");
     }
        _;
    }

    modifier onlyDelegator() {
     if(!hasRole(DELEGATOR_ROLE, msg.sender)){
        revert("not the Delegator");
     }
        _;
    }

    function delegateCredit(uint256 delegateAmount,uint256 deadline, uint8 v,bytes32 r,bytes32 s) public onlyDelegator {
        uint allow = ICreditDelegationToken(debtContract).borrowAllowance(delegator, address(this));

        if(allow < delegateAmount){
            ICreditDelegationToken(debtContract).delegationWithSig(delegator,address(this),delegateAmount,deadline,v,r,s);
        }
        
    }

    function getBorrow(uint256 borrowAmount) public onlyBorrower{
        uint allow = ICreditDelegationToken(debtContract).borrowAllowance(delegator, address(this));

        if(allow < borrowAmount){   
            revert("not enough delegation");
        }
        //Borrow power in aave for eth is 80%
        int256 roundPrice = getPrice();
        uint256 balance = aWeth.balanceOf(delegator);
        int256 realValue = (SafeCast.toInt256(balance) * roundPrice) / 1e18;
        uint256 maxBorrowAmount = percentage(SafeCast.toUint256(realValue));

        if(borrowAmount <= maxBorrowAmount) {
            IPool(pool).borrow(address(gho),borrowAmount,2,0,delegator);
        }else {
            revert("More from the available");
        }
        
        gho.safeTransfer(msg.sender,borrowAmount);

        emitEvent(address(this),msg.sender,borrowAmount);
    }

    function getPrice() private view returns(int256 finalPrice){
        int price = oracle.latestAnswer();
        uint8 decimals = oracle.decimals();
        uint256 diference = 18 - decimals;
        uint rounding = 10 ** diference;
        finalPrice = price * SafeCast.toInt256(rounding);
    }
    
    function percentage(uint amount) public pure returns(uint256 value){
        value = (amount * 800)/1000;
    }

    function emitEvent(address vault, address borrower, uint amount) private {
        assembly{
            //BorrowDelivered(address,address,uint256);
            let signatureHash := 0xcd1c1f88f94d51082987017eacb49408fb5ad4f79ec26845129fbfff2bc93afb
            mstore(0, amount)
            log3(0, 0x20, signatureHash, vault, borrower)
        }
    }
}
