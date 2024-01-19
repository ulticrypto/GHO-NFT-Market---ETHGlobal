// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Script.sol";

contract DeployScript is Script {   

    address public mControl = 0xcd3C135eB2EA71335364E062246d65D9fa1AB8fD;
    address public credit = 0x7cbF2D238830CF0c230C4591F0db77fa5ba76eCc;
    address public control = 0xDBa7F003a8aC3F9eCCdC7abFde27f92f78746e41;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployer);

        vm.stopBroadcast();
    }
}
