const { upgrades, ethers, network } = require('hardhat');
const assert = require('assert');
const { expect } = require('chai');

/**
 * Useful addresses
 */
const LINK = '0x514910771AF9Ca656af840dff83E8264EcF986CA';

describe('Deploying ERC20 contracts and testing functionalities', () => {
  let stakeERC20;
  let rewardERC20;
  before(async () => {
    // - Getting the factories for the contracts:
    const StakeERC20 = await ethers.getContractFactory('StakeERC20');
    const RewardERC20 = await ethers.getContractFactory('RewardERC20');

    /**
     * Accounts for transferring tokens
     * Owner or deployer of the contracts: account1
     * TestUser: account2
     */
    [account1, account2] = await ethers.getSigners();

    /**
     * Deploying
     */
    stakeERC20 = await StakeERC20.deploy();
    rewardERC20 = await RewardERC20.deploy();
    await stakeERC20.deployed();
    await rewardERC20.deployed();
    console.log('Stake ERC20 Address: ', stakeERC20.address);
    console.log('Reward ERC20 Address: ', rewardERC20.address);
  });

  it('Returns the starting balance of the owner and test user', async () => {
    //Transferring token for staking to the user
    await stakeERC20.transfer(account2.address, 100);
    const ownerStakeBal = (
      await stakeERC20.balanceOf(account1.address)
    ).toString();
    const ownerRewardsBal = (
      await rewardERC20.balanceOf(account1.address)
    ).toString();
    const userStakeBal = (
      await stakeERC20.balanceOf(account2.address)
    ).toString();
    const userRewardsBal = (
      await rewardERC20.balanceOf(account2.address)
    ).toString();

    console.log(
      "Owner's account starting balance",
      '\nStake Balance:',
      ownerStakeBal,
      '\nRewards Balance:',
      ownerRewardsBal
    );
    console.log(
      "User's account starting balance",
      '\nStake Balance:',
      userStakeBal,
      '\nRewards Balance:',
      userRewardsBal
    );
  });
});
