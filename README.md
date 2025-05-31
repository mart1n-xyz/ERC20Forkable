# ERC20Fork

An ERC20 token implementation that supports lazy migration during token forks, with optional post-fork distribution controls.

## Features

- **Dual Deployment Modes**:
  - Direct deployment with initial supply (as a new ERC20 token)
  - Fork deployment from an existing ERC20 token with ERC20Votes extension

- **Lazy Migration**:
  - Balances are read from parent token's historical snapshot at fork block using `getPastVotes`
  - Balance migration happens lazily on first interaction (transfer, approve, etc.) via internal `migrate()` function
  - Balances are immediately wallet-visible post-fork without requiring claim transactions
  - Migration only affects internal accounting - UX remains seamless for users

- **Voting Power Support**:
  - Inherits from ERC20Votes for full governance functionality
  - Maintains voting power from parent token through lazy migration
  - Voting power is migrated along with balances during first interaction
  - Supports complete ERC20Votes functionality including:
    - Delegation of voting power
    - Historical voting power queries
    - Vote tracking across checkpoints
    - Governance integration readiness
  - Fork maintains full compatibility with governance protocols
  - Seamless transition of voting rights from parent to forked token

- **Post-Fork Controls** (Optional):
  - Owner can mint/burn tokens before enabling transfers
  - Transfers must be frozen during distribution adjustment
  - One-way unfreezing that renounces ownership

## Usage

### Direct Deployment

```solidity
// Deploy with initial supply
ERC20Fork token = new ERC20Fork(
    "My Token",
    "MTK",
    1000000 * 10**18,  // 1M tokens
    initialHolder
);
```

### Fork Deployment

```solidity
// Deploy with 0 supply
ERC20Fork token = new ERC20Fork(
    "Forked Token",
    "FTK",
    0,
    address(0)
);

// Initialize fork
token.initializeFork(
    parentToken,    // Address of parent ERC20Votes token
    forkBlock,      // Block number to fork from
    owner,          // Address that will control post-fork distribution
    true           // Whether to freeze transfers initially
);

// Optional: Adjust distribution
token.mintPostFork(newHolder, amount);
token.burnPostFork(oldHolder, amount);

// Enable transfers and renounce ownership
token.enableTransfers();
```

## Migration Flow

1. User's balance is automatically available through `balanceOf()`
2. First transfer/approve triggers migration
3. Parent token balance is migrated to forked contract
4. User can now transfer tokens normally

## Post-Fork Controls

When deployed as a fork with an owner:

1. If owner decides to freeze transfers and make adjustments:
2. Owner can:
   - Mint new tokens (`mintPostFork`)
   - Burn existing tokens (`burnPostFork`)
   - Enable transfers (`enableTransfers`)
3. Enabling transfers:
   - Makes tokens transferable
   - Renounces ownership
   - Cannot be reversed

## Security Considerations

- Fork block must be in the past
- Parent token must implement ERC20Votes
- Migration is one-way and cannot be reversed
- Post-fork distribution changes are locked after enabling transfers

## License

MIT

## Development

This project uses [Foundry](https://getfoundry.sh/) for development and testing.

### Prerequisites

- [Foundry](https://getfoundry.sh/)
- Git

### Setup

1. Clone the repository:
```bash
git clone "this repo"
cd ERC20Fork
```

2. Install dependencies:
```bash
forge install
```

3. Build the project:
```bash
forge build
```

4. Run tests:
```bash
forge test
```

## Security

This project is in development. Use at your own risk.
