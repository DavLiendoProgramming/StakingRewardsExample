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
  let stakeContract;
  let account1, account2;
  before(async () => {
    // - Getting the factories for the contracts:
    const StakeERC20 = await ethers.getContractFactory('StakeERC20');
    const RewardERC20 = await ethers.getContractFactory('RewardERC20');
    const StakeContract = await ethers.getContractFactory('CustomStake');
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
    stakeContract = await StakeContract.deploy(
      stakeERC20.address,
      rewardERC20.address
    );
    await stakeERC20.deployed();
    await rewardERC20.deployed();
    await stakeContract.deployed();
    console.log('\nStake ERC20 Address: ', stakeERC20.address);
    console.log('Reward ERC20 Address: ', rewardERC20.address);
    console.log('Staking Contract Address: ', stakeContract.address);
  });

  it('Returns the starting balance of the owner, test user and contract', async () => {
    //Transferring token for staking to the user
    await stakeERC20.transfer(account2.address, 100);
    await rewardERC20.transfer(stakeContract.address, 250);

    //Getting the balances of every contract
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
    const stakerContractStakeBal = (
      await stakeERC20.balanceOf(stakeContract.address)
    ).toString();
    const stakerContractRewardsBal = (
      await rewardERC20.balanceOf(stakeContract.address)
    ).toString();

    console.log(
      "\nOwner's account starting balance",
      '\nStake Balance:',
      ownerStakeBal,
      '\nRewards Balance:',
      ownerRewardsBal
    );
    console.log(
      "\nUser's account starting balance",
      '\nStake Balance:',
      userStakeBal,
      '\nRewards Balance:',
      userRewardsBal
    );
    console.log(
      "\nStaker contract's account starting balance",
      '\nStake Balance:',
      stakerContractStakeBal,
      '\nRewards Balance:',
      stakerContractRewardsBal
    );
  });

  it('Make a deposit for staking from the user to the staker contract', async () => {
    //Allowing contract to spend our token for staking
    await stakeERC20.connect(account2).approve(stakeContract.address, 30);

    //Staking Token inside the contract
    await stakeContract.connect(account2).createStake(20);

    /**
     * Getting Balances after depositing
     */
    const userStakeBal = (
      await stakeERC20.balanceOf(account2.address)
    ).toString();
    const userRewardsBal = (
      await rewardERC20.balanceOf(account2.address)
    ).toString();
    const stakerContractStakeBal = (
      await stakeERC20.balanceOf(stakeContract.address)
    ).toString();
    const stakerContractRewardsBal = (
      await rewardERC20.balanceOf(stakeContract.address)
    ).toString();

    console.log(
      "\nUser's account balance just after staking",
      '\nStake Balance:',
      userStakeBal,
      '\nRewards Balance:',
      userRewardsBal
    );
    console.log(
      "\nStaker contract's account just after staking",
      '\nStake Balance:',
      stakerContractStakeBal,
      '\nRewards Balance:',
      stakerContractRewardsBal
    );

    //Asserting the balance of the stake
    assert(parseInt(stakerContractStakeBal) === 20);
  });
});
