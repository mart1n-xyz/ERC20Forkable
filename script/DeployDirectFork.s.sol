// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ERC20Fork.sol";

contract DeployDirectForkScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy ERC20Fork directly
        ERC20Fork fork = new ERC20Fork(
            "Forked Test Token",
            "FTEST",
            0,              // No initial supply
            address(0),     // No initial holder
            msg.sender      // Owner
        );
        console.log("ERC20Fork deployed to:", address(fork));

        // Initialize the fork with parent token
        uint256 forkBlock = block.number - 1;
        fork.initializeFork(
            0xa5D37933563614A0d668eA50896D05e267207333,  // Parent token
            forkBlock,                                    // Fork block (1 block ago)
            msg.sender,                                  // Owner
            false                                        // Don't freeze transfers
        );
        console.log("Fork initialized with parent token at block:", forkBlock);

        vm.stopBroadcast();
    }
} 