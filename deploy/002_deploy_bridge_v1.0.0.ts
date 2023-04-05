import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments, getNamedAccounts } = hre;
    const { deploy } = deployments;

    const { deployer } = await getNamedAccounts();

    const bridgeTimelockControllerDeployment = await deploy('BridgeTimelockController', {
        from: deployer,
        args: [1, [], [], deployer],
        log: true,
    });


};
export default func;
func.tags = ["BridgeTimelockController"];