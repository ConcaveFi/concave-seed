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



## set rounds
```
bbtCNV
merkleRoot: 0x7f80320bf13cdc364baae45469310b4f0201b8373bc85cd17f462baf681bbea2
rate: 10000000000000000000 (10e18)
```
```
aCNV
merkleRoot: 0x304c55b6afd8dd52f28b62a43710bdff2d7de4b0355610e65276325182973a75
rate: 50000000000000000000 (50e18)

merkleRoot: 0x397592c6cdcfbfc924ab491bf7039c8823e1ec6e061be4415a1502058b8c8cf6
rate: 50000000000000000000 (50e18)


merkleRoot: 0x3ff8a7b3426c536c0746fb1cb623b37135ec2d6693587be808a188e48d04315c
rate: 50000000000000000000 (50e18)
```

```
cast send --private-key <PRIVATE_KEY>  --rpc-url <RPC_URL>  0xc32baea7792bf39b8b89fa33a108d2064db43ee5 "setRound(bytes32,uint256)" 0x7f80320bf13cdc364baae45469310b4f0201b8373bc85cd17f462baf681bbea2 10000000000000000000

cast send --private-key <PRIVATE_KEY>  --rpc-url <RPC_URL>  <CONTRACT_ADDRESS> "setRound(bytes32,uint256)" <MERKLE_ROOT> <RATE>



```

## extra

Follow the `forge create` instructions ([CLI README](https://github.com/gakonst/foundry/blob/master/cli/README.md#build)) to deploy your contracts or use [Remix](https://remix.ethereum.org/).

You can specify the token `name`, `symbol`, `decimals`, and airdrop `merkleRoot` upon deploy.
