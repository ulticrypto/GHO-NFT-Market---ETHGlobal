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

        vm.startBroadcast(deployer);

        AggregatorProxy mockoracle = new AggregatorProxy();
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
        console2.logAddress(address(facilitator));

        Calculations calcs = new Calculations();
        console2.logString("calcs");
        console2.logAddress(address(calcs));

        Vault vault = new Vault(address(uBAYC), address(control), address(calcs), address(mockGho), address(facilitator));
        console2.logString("vault");
        console2.logAddress(address(vault));

        vm.stopBroadcast();
    }
}
