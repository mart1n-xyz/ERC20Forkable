// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ERC20Fork.sol";
import "../src/ERC20ForkFactory.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the factory
        ERC20ForkFactory factory = new ERC20ForkFactory();
        console.log("ERC20ForkFactory deployed to:", address(factory));

        // Deploy a test token
        address testToken = factory.createToken(
            "Test Token",
            "TEST",
            1000000 * 10**18,  // 1 million tokens
            msg.sender,
            msg.sender
        );
        console.log("Test token deployed to:", testToken);

        vm.stopBroadcast();
    }
} 