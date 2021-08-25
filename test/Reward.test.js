const { upgrades, ethers, network } = require('hardhat');
const assert = require('assert');
const { expect } = require('chai');

/**
 * Openzeppelin test utilities
 */

const {
  BN, // Big Number support
  constants, // Common constants, like the zero address and largest integers
  expectEvent, // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
} = require('@openzeppelin/test-helpers');

/**
 * Useful addresses
 */
const LINK = '0x514910771AF9Ca656af840dff83E8264EcF986CA';

describe('Deploying ERC20 contracts and testing functionalities', () => {
  let stakeERC20;
  let rewardERC20;
  let stakeContract;
  let account1, account2, account3, account4, account5;
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
    [account1, account2, account3, account4, account5] =
      await ethers.getSigners();

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
    console.log('\nStake ERC20 Contract Address: ', stakeERC20.address);
    console.log('\nReward ERC20 Contract Address: ', rewardERC20.address);
    console.log('\nStaking Contract Address: ', stakeContract.address);
    console.log('\nOwner Account Address: ', account1.address);
    console.log('\nUser2 Account Address: ', account2.address);
    console.log('\nUser3 Account Address: ', account3.address);
    console.log('\nUser4 Account Address: ', account4.address);
    console.log('\nUser5 Account Address: ', account5.address);
  });

  it('Returns the starting balance of the owner, test users and contract for staking', async () => {
    //Transferring token for staking to the user and giving rewards tokens for use inside the staking contract
    await stakeERC20.transfer(account2.address, 10000);
    await stakeERC20.transfer(account3.address, 10000);
    await stakeERC20.transfer(account4.address, 10000);
    await stakeERC20.transfer(account5.address, 10000);
    await rewardERC20.transfer(stakeContract.address, 250000);

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
    const userStakeBal3 = (
      await stakeERC20.balanceOf(account3.address)
    ).toString();
    const userRewardsBal3 = (
      await rewardERC20.balanceOf(account3.address)
    ).toString();
    const userStakeBal4 = (
      await stakeERC20.balanceOf(account4.address)
    ).toString();
    const userRewardsBal4 = (
      await rewardERC20.balanceOf(account4.address)
    ).toString();
    const userStakeBal5 = (
      await stakeERC20.balanceOf(account5.address)
    ).toString();
    const userRewardsBal5 = (
      await rewardERC20.balanceOf(account5.address)
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
      '\nUsers accounts  starting balance',
      '\nUser 2 Stake Token Balance:',
      userStakeBal,
      '\nUser 2 Rewards Token Balance:',
      userRewardsBal,
      '\nUser 3 Stake Token Balance:',
      userStakeBal3,
      '\nUser 3 Rewards Token Balance:',
      userRewardsBal3,
      '\nUser 4 Stake Token Balance:',
      userStakeBal4,
      '\nUser 4 Rewards Token Balance:',
      userRewardsBal4,
      '\nUser 5 Stake Token Balance:',
      userStakeBal5,
      '\nUser 5 Rewards Token Balance:',
      userRewardsBal5
    );
    console.log(
      "\nStaker contract's balance starting balance",
      '\nStake Balance:',
      stakerContractStakeBal,
      '\nRewards Balance:',
      stakerContractRewardsBal
    );
  });

  it('Make a deposit for staking from the users to the staker contract', async () => {
    //Allowing contract to spend our token for staking
    // safeApprove should only be called when setting an initial allowance,
    // or when resetting it to zero. To increase and decrease it, use
    // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'

    await stakeERC20.connect(account2).approve(stakeContract.address, 1000);
    await stakeERC20.connect(account3).approve(stakeContract.address, 1000);
    await stakeERC20.connect(account4).approve(stakeContract.address, 1000);
    await stakeERC20.connect(account5).approve(stakeContract.address, 1000);

    //Staking Token inside the contract
    //Platinum Tier
    await stakeContract.connect(account2).createStake(1000);
    //Gold Tier
    await stakeContract.connect(account3).createStake(500);
    //Silver Tier
    await stakeContract.connect(account4).createStake(100);
    //Bronze Tier
    await stakeContract.connect(account5).createStake(99);

    /**
     * Getting Balances and tier  just after  depositing
     */
    const userStakeBal = (
      await stakeERC20.balanceOf(account2.address)
    ).toString();
    const userRewardsBal = (
      await rewardERC20.balanceOf(account2.address)
    ).toString();
    const userTier = await stakeContract.getTierOf(account2.address);
    const userStakeBal3 = (
      await stakeERC20.balanceOf(account3.address)
    ).toString();
    const userRewardsBal3 = (
      await rewardERC20.balanceOf(account3.address)
    ).toString();
    const userTier3 = await stakeContract.getTierOf(account3.address);
    const userStakeBal4 = (
      await stakeERC20.balanceOf(account4.address)
    ).toString();
    const userRewardsBal4 = (
      await rewardERC20.balanceOf(account4.address)
    ).toString();
    const userTier4 = await stakeContract.getTierOf(account4.address);
    const userStakeBal5 = (
      await stakeERC20.balanceOf(account5.address)
    ).toString();
    const userRewardsBal5 = (
      await rewardERC20.balanceOf(account5.address)
    ).toString();
    const userTier5 = await stakeContract.getTierOf(account5.address);
    const stakerContractStakeBal = (
      await stakeERC20.balanceOf(stakeContract.address)
    ).toString();
    const stakerContractRewardsBal = (
      await rewardERC20.balanceOf(stakeContract.address)
    ).toString();

    console.log(
      '\nUsers account balance just after staking: ',
      '\nUser 2 Stake Balance: ',
      userStakeBal,
      '\nUser 2 Rewards Balance: ',
      userRewardsBal,
      '\nUser 2 Rewards Tier: ',
      userTier,
      '\nUser 3 Stake Balance: ',
      userStakeBal3,
      '\nUser 3 Rewards Balance: ',
      userRewardsBal3,
      '\nUser 3 Rewards Tier: ',
      userTier3,
      '\nUser 4 Stake Balance: ',
      userStakeBal4,
      '\nUser 4 Rewards Balance: ',
      userRewardsBal4,
      '\nUser 4 Rewards Tier: ',
      userTier4,
      '\nUser 5 Stake Balance: ',
      userStakeBal5,
      '\nUser 5 Rewards Balance: ',
      userRewardsBal5,
      '\nUser 5 Rewards Tier: ',
      userTier5
    );
    console.log(
      "\nStaker contract's account just after staking",
      '\nStake Balance:',
      stakerContractStakeBal,
      '\nRewards Balance:',
      stakerContractRewardsBal
    );

    //Asserting the balance of the staking contract
    assert(parseInt(stakerContractStakeBal) === 1699);
  });

  it('Collects the rewards of a particular user after certain amount of time', async () => {
    //Increasing current time for 1 hour into the future
    await network.provider.send('evm_increaseTime', [3600]);

    //Withdrawoin rewards
    await stakeContract.connect(account2).withdrawReward();
    await stakeContract.connect(account3).withdrawReward();
    await stakeContract.connect(account4).withdrawReward();
    await stakeContract.connect(account5).withdrawReward();

    console.log(
      '\nBalance of reward token for account2 of tier platinum: ',
      (await rewardERC20.balanceOf(account2.address)).toString()
    );
    console.log(
      '\nBalance of reward token for account3 of tier gold: ',
      (await rewardERC20.balanceOf(account3.address)).toString()
    );
    console.log(
      '\nBalance of reward token for account4 of tier silver: ',
      (await rewardERC20.balanceOf(account4.address)).toString()
    );
    console.log(
      '\nBalance of reward token for account5 of tier bronze: ',
      (await rewardERC20.balanceOf(account5.address)).toString()
    );
  });
});
