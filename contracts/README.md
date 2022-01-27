# pCNV

ERC20 token claimable by members of a [Merkle tree](https://en.wikipedia.org/wiki/Merkle_tree). Useful for conducting Airdrops. Utilizes [Solmate ERC20](https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC20.sol) for modern ERC20 token implementation.

## Test

Tests use [Foundry: Forge](https://github.com/gakonst/foundry).

### Install Forge

```bash
cargo install --git https://github.com/gakonst/foundry --bin forge --locked
```

### Run tests

```bash
# Go to contracts directory, if not already there
cd contracts/

# Get dependencies
forge update

# Run tests
forge test --root . --verbosity 4
```

## Testnet (ropsten)

```
FRAX:   0xE7E9F348202f6EDfFF2607025820beE92F51cdAA
DAI:    0x7B731FFcf1b9C6E0868dA3F1312673A12Da28dc5
bbtCNV: 0xc32baea7792bf39b8b89fa33a108d2064db43ee5
aCNV:   0x6c64efbbaea3ebec73588a8e20cf058344f5f1cf

```

## abis

```
../artifacts/bbtCNV.json
../artifacts/aCNV.json
```

## Deploy

```
forge create bbtCNV  --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --optimize  --force --root .

forge create aCNV  --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --optimize  --force --root .
```

## extra

Follow the `forge create` instructions ([CLI README](https://github.com/gakonst/foundry/blob/master/cli/README.md#build)) to deploy your contracts or use [Remix](https://remix.ethereum.org/).

You can specify the token `name`, `symbol`, `decimals`, and airdrop `merkleRoot` upon deploy.
