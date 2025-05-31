# ERC20Forkable

A forkable ERC20 token implementation that allows for lazy migration of token balances during chain forks.

## Features

- Lazy migration of token balances
- Historical balance resolution using ERC20Votes
- Gas-efficient implementation
- Reentrancy-safe migration logic
- No claim transactions required
- Immediate wallet visibility post-fork

## Development

This project uses [Foundry](https://getfoundry.sh/) for development and testing.

### Prerequisites

- [Foundry](https://getfoundry.sh/)
- Git

### Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/ERC20Forkable.git
cd ERC20Forkable
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

## License

MIT

## Security

This project is in development. Use at your own risk.
