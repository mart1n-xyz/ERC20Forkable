// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/utils/Nonces.sol";

/// @title ERC20Forkable
/// @notice An ERC20 token that supports lazy migration during chain forks
/// @dev Inherits from ERC20Votes to support historical balance resolution
contract ERC20Forkable is ERC20, ERC20Votes, ERC20Permit {
    /// @notice Address of the parent token contract
    address public parentToken;
    
    /// @notice Block number at which the fork occurred
    uint256 public forkBlock;

    /// @notice Mapping to track migrated accounts
    mapping(address => bool) public hasMigrated;

    /// @notice Event emitted when tokens are migrated
    event TokensMigrated(address indexed account, uint256 amount);

    constructor(
        string memory name,
        string memory symbol,
        address _parentToken,
        uint256 _forkBlock
    ) ERC20(name, symbol) ERC20Votes() ERC20Permit(name) {
        parentToken = _parentToken;
        forkBlock = _forkBlock;
    }

    // The following functions are overrides required by Solidity
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Votes)
    {
        super._update(from, to, value);
    }

    function nonces(address owner)
        public
        view
        override(ERC20Permit, Nonces)
        returns (uint256)
    {
        return super.nonces(owner);
    }
} 