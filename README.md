# ERC20Fork
> [!NOTE]
> Built at ETHGlobal Prague Hackathon 2025 🏆

A modern implementation of token forking functionality, inspired by Jordi Baylina's MiniMe token. This library brings back the powerful forking capabilities of MiniMe tokens, but with modern Solidity practices, optimizations, and ERC20 standards.

## The Story

Token forking is a powerful mechanism that allows creating new tokens that inherit the state of an existing token at a specific point in time. 

We've reimagined this functionality for modern ERC20 tokens, with a focus on:
- Full ERC20Votes compatibility for governance
- Gas-efficient lazy migration
- Modern Solidity practices

## Architecture

The library consists of three contracts that build on each other:

### ERC20Fork

The core contract that implements the fork functionality. It can be used in two ways:
1. As a new token with initial supply (not actually using the new functionality)
2. As a fork of an existing ERC20 token with ERC20Votes extension

Key features:
- Lazy migration of balances from parent token
- Historical balance resolution using ERC20Votes
- Post-fork distribution controls
- Transfer freezing capability

### ERC20ForkFactory

A dedicated factory contract for deploying new tokens and forks. It provides:
1. Creation of new `ERC20Fork` tokens with initial supply (completely new token but forkable)
2. Creation of forks from any existing ERC20 tokens with ERC20Votes extension
3. Validation of parent tokens before forking
4. Detailed event emission for tracking

## Usage

### Using the Factory

```solidity
// Deploy the factory
ERC20ForkFactory factory = new ERC20ForkFactory();

// Create a new token that can be forked later
address newToken = factory.createToken(
    "My Token",
    "MTK",
    1000000 * 10**18,  // Initial supply
    msg.sender         // Initial holder
);

// Create a fork of any ERC20Votes token
address newFork = factory.createFork(
    existingToken,    // Address of any ERC20Votes token
    "Forked Token",
    "FTK",
    msg.sender,      // Owner of the fork
    true            // Freeze transfers initially
);
```

### How It Works

1. **Fork Creation**:
   - New token is deployed with 0 initial supply
   - Parent token and fork block are recorded
   - Total supply is set to parent's supply at fork block

2. **Balance Migration**:
   - Balances are available immediately through `balanceOf()`
   - First transfer/approve triggers actual migration
   - Parent token balance is minted to user
   - Account is marked as migrated
   - This is a pure smart contract accounting migration, abstracted from UX

3. **Post-Fork Controls**:
   - Owner can adjust distribution before enabling transfers
   - Can mint/burn tokens while transfers are frozen
   - Enabling transfers is one-way and renounces ownership

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

## Security Considerations

- Fork block must be in the past
- Parent token must implement ERC20Votes
- Post-fork distribution changes are locked after enabling transfers
- Supply changes are tracked and emitted

## License

MIT

## Security

This project is in development. Use at your own risk.
