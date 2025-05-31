// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ERC20ForkFactory.sol";

contract DeployForkScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the factory
        ERC20ForkFactory factory = new ERC20ForkFactory();
        console.log("ERC20ForkFactory deployed to:", address(factory));

        // Create a fork of the specified token
        address parentToken = 0xa5D37933563614A0d668eA50896D05e267207333;
        address newFork = factory.createFork(
            parentToken,
            "Forked Test Token",
            "FTEST",
            msg.sender,  // Owner of the fork
            true        // Freeze transfers initially
        );
        console.log("Fork deployed to:", newFork);

        vm.stopBroadcast();
    }
} 