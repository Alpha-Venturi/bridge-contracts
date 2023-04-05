# Verifying the smart contracts on a block explorer

All Smart Contracts can be verified on a block explorer, so the called contract methods, inputs and logs can be decoded. This helps users to understand what is going on when interacting with the blockchain.

## Configuration

You have to add the `verify` field to your network in the hardhat.config.ts. E.g.:

```
"hl-besu": {
      url: <BESU_URL>,
      chainId: 1337,
      accounts: [...<ACCOUNTS>],
      timeout: 100_000,
      verify: {
        etherscan: {
          apiUrl: <BLOCK_EXPLORER_URL>,
          apiKey: <BLOCK_EXPLORER_API_KEY>
        }
      }
    },
```

## Execution

`npx hardhat etherscan-verify --network <networkName>`

Note: Custom deployments of a block explorer such as blockscout are usually supported as well, even though the command is called etherscan-verify.