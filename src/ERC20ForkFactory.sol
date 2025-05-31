// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC20Fork.sol";
import "./interfaces/IERC20Votes.sol";

/// @title ERC20ForkFactory
/// @notice Factory contract for deploying ERC20Fork tokens
/// @dev Creates new ERC20Fork tokens that can be forks of any ERC20Votes token
contract ERC20ForkFactory {
    /// @notice Event emitted when a new fork is created
    event ForkCreated(
        address indexed parentToken,
        address indexed fork,
        uint256 forkBlock,
        string name,
        string symbol
    );

    /// @notice Creates a new ERC20Fork token
    /// @param name The name of the token
    /// @param symbol The symbol of the token
    /// @param initialSupply The initial supply of tokens (0 for fork deployment)
    /// @param initialHolder The address that will receive the initial supply (address(0) for fork deployment)
    /// @return The address of the newly created token
    function createToken(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address initialHolder
    ) external returns (address) {
        ERC20Fork newToken = new ERC20Fork(
            name,
            symbol,
            initialSupply,
            initialHolder
        );
        return address(newToken);
    }

    /// @notice Creates a new fork of an existing ERC20Votes token
    /// @param parentToken The address of the token to fork from
    /// @param name The name of the forked token
    /// @param symbol The symbol of the forked token
    /// @param owner The address that will own the forked token
    /// @param freezeTransfers Whether to freeze transfers initially
    /// @return The address of the newly created fork
    function createFork(
        address parentToken,
        string memory name,
        string memory symbol,
        address owner,
        bool freezeTransfers
    ) external returns (address) {
        // Validate parent token
        require(parentToken != address(0), "Invalid parent token");
        require(IERC20Votes(parentToken).getPastTotalSupply(block.number) > 0, "Token does not appear to implement ERC20Votes");

        // Deploy new fork
        ERC20Fork newFork = new ERC20Fork(
            name,
            symbol,
            0,  // No initial supply
            address(0)  // No initial holder
        );

        // Initialize the fork
        newFork.initializeFork(
            parentToken,
            block.number,
            owner,
            freezeTransfers
        );

        emit ForkCreated(
            parentToken,
            address(newFork),
            block.number,
            name,
            symbol
        );

        return address(newFork);
    }
} 