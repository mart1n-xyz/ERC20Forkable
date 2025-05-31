// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/utils/Nonces.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IERC20Votes.sol";

/// @title ERC20Forkable
/// @notice An ERC20 token that supports lazy migration during chain forks
/// @dev Inherits from ERC20Votes to support historical balance resolution
contract ERC20Forkable is ERC20, ERC20Votes, ERC20Permit {
    /// @notice Address of the parent token contract
    /// @dev address(0) indicates this is a direct deployment, not a fork
    address public parentToken;
    
    /// @notice Block number at which the fork occurred
    /// @dev 0 indicates this is a direct deployment, not a fork
    uint256 public forkBlock;

    /// @notice Mapping to track migrated accounts
    mapping(address => bool) public hasMigrated;

    /// @notice Total supply of the parent token at fork block
    uint256 private _forkTotalSupply;

    /// @notice Changes to total supply after fork (can be negative)
    int256 private _supplyDelta;

    /// @notice Event emitted when tokens are migrated
    event TokensMigrated(address indexed account, uint256 amount);

    /// @notice Event emitted when a token is forked
    event TokenForked(address indexed parentToken, uint256 forkBlock);

    /// @notice Deploys a new ERC20Forkable token
    /// @param name The name of the token
    /// @param symbol The symbol of the token
    /// @param initialSupply The initial supply of tokens (0 for fork deployment)
    /// @param initialHolder The address that will receive the initial supply (address(0) for fork deployment)
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address initialHolder
    ) ERC20(name, symbol) ERC20Votes() ERC20Permit(name) {
        if (initialSupply > 0) {
            require(initialHolder != address(0), "Invalid initial holder");
            _mint(initialHolder, initialSupply);
        }
    }

    /// @notice Initializes a fork of an existing token
    /// @param _parentToken The address of the parent token
    /// @param _forkBlock The block number at which the fork occurred
    /// @dev Can only be called once and only if this is a direct deployment
    function initializeFork(
        address _parentToken,
        uint256 _forkBlock
    ) external {
        require(_parentToken != address(0), "Invalid parent token");
        require(_forkBlock > 0, "Invalid fork block");
        require(parentToken == address(0), "Already initialized");
        require(forkBlock == 0, "Already forked");

        parentToken = _parentToken;
        forkBlock = _forkBlock;
        
        // Set total supply to parent token's supply at fork block
        _forkTotalSupply = IERC20Votes(_parentToken).getPastTotalSupply(_forkBlock);
        
        emit TokenForked(_parentToken, _forkBlock);
    }

    /// @notice Returns the total supply of tokens
    /// @return The total supply of tokens
    function totalSupply() public view override returns (uint256) {
        if (parentToken != address(0)) {
            // For forks: fork supply + any changes after fork
            return uint256(int256(_forkTotalSupply) + _supplyDelta);
        }
        return super.totalSupply();
    }

    /// @notice Returns the balance of an account, including unmigrated balance from parent token at fork block
    /// @param account The address to check the balance of
    /// @return The total balance of the account
    function balanceOf(address account) public view override returns (uint256) {
        uint256 balance = super.balanceOf(account);
        
        // If this is a fork and the account hasn't migrated yet, add parent token balance at fork block
        if (parentToken != address(0) && !hasMigrated[account]) {
            balance += IERC20Votes(parentToken).getPastVotes(account, forkBlock);
        }
        
        return balance;
    }

    /// @notice Returns the voting power of an account, including unmigrated power from parent token
    /// @param account The address to check the voting power of
    /// @return The total voting power of the account
    function getVotes(address account) public view override returns (uint256) {
        uint256 votes = super.getVotes(account);
        
        // If this is a fork and the account hasn't migrated yet, add parent token voting power
        if (parentToken != address(0) && !hasMigrated[account]) {
            votes += IERC20Votes(parentToken).getVotes(account);
        }
        
        return votes;
    }

    /// @notice Returns the voting power of an account at a specific block number
    /// @param account The address to check the voting power of
    /// @param blockNumber The block number to check the voting power at
    /// @return The voting power of the account at the specified block
    function getPastVotes(address account, uint256 blockNumber) public view override returns (uint256) {
        uint256 votes = super.getPastVotes(account, blockNumber);
        
        // If this is a fork and the account hasn't migrated yet, add parent token voting power
        // Only add parent voting power if the block is after the fork block
        if (parentToken != address(0) && !hasMigrated[account] && blockNumber >= forkBlock) {
            votes += IERC20Votes(parentToken).getPastVotes(account, blockNumber);
        }
        
        return votes;
    }

    /// @notice Migrates balance from parent token to this token at fork block
    /// @param account The address to migrate balance for
    /// @dev Can only be called if this is a fork and the account hasn't migrated yet
    function migrate(address account) external {
        _migrate(account);
    }

    /// @notice Internal function to migrate balance from parent token to this token at fork block
    /// @param account The address to migrate balance for
    function _migrate(address account) internal {
        require(parentToken != address(0), "Not a fork");
        require(!hasMigrated[account], "Already migrated");
        
        uint256 parentBalance = IERC20Votes(parentToken).getPastVotes(account, forkBlock);
        hasMigrated[account] = true;
        
        if (parentBalance > 0) {
            _mint(account, parentBalance);
            // Compensate for the mint by decreasing supply delta
            // This ensures the total supply stays at _forkTotalSupply
            _supplyDelta -= int256(parentBalance);
            emit TokensMigrated(account, parentBalance);
        }
    }

    // The following functions are overrides required by Solidity
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Votes)
    {
        // If this is a fork, ensure accounts are migrated before transfer
        if (parentToken != address(0)) {
            if (!hasMigrated[from]) {
                _migrate(from);
            }
            if (to != address(0) && !hasMigrated[to]) {
                _migrate(to);
            }
        }
        
        // Track supply changes for forks
        if (parentToken != address(0)) {
            if (from == address(0)) {
                // Minting
                _supplyDelta += int256(value);
            } else if (to == address(0)) {
                // Burning
                _supplyDelta -= int256(value);
            }
        }
        
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