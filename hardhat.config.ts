import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-ethers";
import "@nomicfoundation/hardhat-toolbox";
import 'hardhat-deploy';
import { mintFundsToEOA } from "./scripts/tasks/mintFundsToEOA";

const dotenv = require("dotenv");
dotenv.config({ path: __dirname + '/.env' });

const PRIVATE_KEYS = (process.env.PRIVATE_KEYS ?? "you must set up your private keys in the .env file,separated by colons").split(",")

const config: HardhatUserConfig = {
  mocha: {
    timeout: 1000 * 60 * 10
  },
  networks: {
    hardhat: {
    },
    "ganache": {
      url: "http://localhost:8545",
      chainId: 1337,
      accounts: [...PRIVATE_KEYS],
      timeout: 100_000
    },
    "iota-aws-node-1": {
      url: "http://someURL",
      chainId: 1075,
      accounts: [...PRIVATE_KEYS],
      timeout: 100_000
    },
    "hl-besu": {
      url: "http://someURL",
      chainId: 1337,
      accounts: [...PRIVATE_KEYS],
      timeout: 100_000,
      verify: {
        etherscan: {
          apiUrl: "http://someURL"
        }
      }
    },
    "iota-testnet": {
      url: "https://api.sc.testnet.shimmer.network/chain/rms1pqxzfjwyhygwzp0w8scecncjf6ralqvxm2vkg5c7egk6cdf0cpf9sj4a2j7/evm/jsonrpc",
      chainId: 1076,
      accounts: [...PRIVATE_KEYS],
      timeout: 1000_000
    }
  },
  solidity: "0.8.17",
  namedAccounts: {
    deployer: 0,
    prosumer: 1,
    bridgeOperator: 2,
    user: 3
  },
};


task("mintFundsToEOA", "Mint new tokens to a specific address")
  .addParam("erc20Name", "the name of the deployed ERC20 Contract (as in /deployments)")
  .addParam("beneficiary", "the address of the beneficiary")
  .addParam("amount", "amount of tokens without decimals")
  .setAction(async ({ erc20Name, beneficiary, amount }, hre) => { await mintFundsToEOA(erc20Name, beneficiary, amount, hre) })

export default config;
