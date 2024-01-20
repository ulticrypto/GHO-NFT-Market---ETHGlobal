// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import "src/BorrowControl.sol";
import "src/Vault.sol";
import "src/Calculations.sol";
import "src/Facilitator.sol";
import "src/Mock/GhoToken.sol";
import "src/Mock/Oracle.sol";
import "src/Mock/ERC20.sol";
import "src/Mock/mockuBACK.sol";

import "src/RewardsVault.sol";

contract DeployScript is Script {   

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        address uBAYC=0x5576f5faE5620DA23956437b6F550A091430e21C;
        address mockGho=0x77f81ce344a994471Da41C3905d75006bB991672;
        address control=0x8f4B0e5EeD0951296Ba0684d126E36Fc2AA20E32;
        address facilitator=0x50CA939E4D27261FA0703AD09D6b0FcF933DCB0a;
        address calcs= 0x867F5acc4866589F55619E08c41cF570d039A7FB;
        address rewards = 0xfCFD8113891d8829cc457412A687797e239b9d1B;

        vm.startBroadcast(deployer);

       /*  AggregatorProxy mockoracle = new AggregatorProxy();
        console2.logString("mockoracle");
        console2.logAddress(address(mockoracle));

        mockuBAYC uBAYC = new mockuBAYC();
        console2.logString("uBAYC");
        console2.logAddress(address(uBAYC));

        GhoToken mockGho = new GhoToken(deployer); 
        console2.logString("mockGho");
        console2.logAddress(address(mockGho));*/

        /* BorrowControl control = new BorrowControl();
        console2.logString("control");
        console2.logAddress(address(control));  */

        /*Facilitator facilitator = new Facilitator(address(mockGho));
        console2.logString("facilitator");
        console2.logAddress(address(facilitator));*/

        /* Calculations calcs = new Calculations();
        console2.logString("calcs");
        console2.logAddress(address(calcs)); */

        /* Vault vault = new Vault(address(uBAYC), address(control), address(calcs), address(mockGho), address(facilitator));
        console2.logString("vault");
        console2.logAddress(address(vault)); */

        /* RewardsVault rewards = new  RewardsVault(address(mockGho));
        console2.logString("rewards");
        console2.logAddress(address(rewards)); */

        Vault vault = new Vault(uBAYC, control, calcs, mockGho, facilitator,rewards);
        console2.logString("vault");
        console2.logAddress(address(vault));

       

        vm.stopBroadcast();
    }
}
