# brdige-contracts #

This repository contains the smart contracts of the holoni token bridge based on Hash Time Locked Contracts.

## What is this repository for? ##


The current version of this repository is: **v2.0.0**

## How do I get set up? ##

Detailed documentation for respective interests can be found in dedicated files:

* [deployment](./documentation/deployment.md)
* [verifying smart contracts on a block explorer](./documentation/verify_in_blockexplorer.md)

But the prerequisites below must be met in any case.

### Prerequisites
* node v18.12.1 must be installed on the machine
* `npm install --force` must be executed to install dependencies



## Contribution guidelines ##

Tasks can be set up in the hardhat.config.ts file. Reoccurring tasks should be scripted, so they can be replicated easily. Though, smart contracts should be configured upon deployment. Only reoccurring tasks should be executed with hardhat tasks

For an overview of tasks use

```
npx hardhat
```

To get help on params for a task use

```
npx hardhat help <taskName>
```
## Contributors ##
* Jonathan Rau (JadenX)
