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

contract DeployScript is Script {   

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        address uBAYC=0x5576f5faE5620DA23956437b6F550A091430e21C;
        address mockGho=0x77f81ce344a994471Da41C3905d75006bB991672;
        address control=0x9a6724c2cb8bAAF151e7Df43fD3c52874aA9434C;
        address facilitator=0x50CA939E4D27261FA0703AD09D6b0FcF933DCB0a;
        address calcs= 0x2a308a8381448dE36c35EDd41495cc96D4EB8a99;

        vm.startBroadcast(deployer);

       /*  AggregatorProxy mockoracle = new AggregatorProxy();
        console2.logString("mockoracle");
        console2.logAddress(address(mockoracle));

        mockuBAYC uBAYC = new mockuBAYC();
        console2.logString("uBAYC");
        console2.logAddress(address(uBAYC));

        GhoToken mockGho = new GhoToken(deployer); 
        console2.logString("mockGho");
        console2.logAddress(address(mockGho));

        BorrowControl control = new BorrowControl();
        console2.logString("control");
        console2.logAddress(address(control)); 

        Facilitator facilitator = new Facilitator(address(mockGho));
        console2.logString("facilitator");
        console2.logAddress(address(facilitator));*/

        /* Calculations calcs = new Calculations();
        console2.logString("calcs");
        console2.logAddress(address(calcs)); */

        /* Vault vault = new Vault(address(uBAYC), address(control), address(calcs), address(mockGho), address(facilitator));
        console2.logString("vault");
        console2.logAddress(address(vault)); */

        Vault vault = new Vault(uBAYC, control, calcs, mockGho, facilitator);
        console2.logString("vault");
        console2.logAddress(address(vault));

        vm.stopBroadcast();
    }
}
