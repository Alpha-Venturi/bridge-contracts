import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ERC20PresetMinterPauser__factory } from "../../typechain-types"

export const mintFundsToEOA = async (erc20Name: string, beneficiary: string, amount: number, hre: HardhatRuntimeEnvironment) => {

    const { deployer } = await hre.getNamedAccounts()

    const tokenContractDeployment = await hre.deployments.get(erc20Name)
    const tokenContract = await ERC20PresetMinterPauser__factory.connect(tokenContractDeployment.address, await hre.ethers.getSigner(deployer))

    const mintTransaction = await tokenContract.mint(beneficiary, amount)
    console.log(`minted ${amount} tokens (without decimals) for ${beneficiary} at the ${erc20Name} contract; txHash: ${mintTransaction.hash}`)
}