// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

//Erase after use
import "hardhat/console.sol";
/**
* @title Staking Contract
* @author David Liendo
* @notice Implements a basic mechanism for staking and receiving rewards out of 2 ERC20
*/

contract CustomStake is Ownable {

    using SafeMath for uint256; 
    using SafeERC20 for IERC20;
    
    
    /* ========== STATE VARIABLES ========== */

    IERC20 public stakingToken;
    IERC20 public rewardsToken;
    // Registering stakeholders for security reasons
    address[] internal stakeHolders;
    // mapping(address => uint256) internal rewards;

    // 0: Bronze,1: Silver,2: Gold,3: Platinum,
    enum StakeTier {
        Bronze,Silver,Gold,Platinum
    }

    struct UserRewards {
        uint256 accumulated;                            
        uint256 checkpoint;
    }
    
    struct StakeStruct { 
        uint256 stake;
        address stakerAddress;
        uint256 startDate;
        UserRewards reward;
        StakeTier tier;
    }


    mapping(address => StakeStruct) internal stakesMap;
   /**
    * @notice The constructor for the Staking Contract.
    */
   constructor(
    // address _owner,
    address _stakingToken,
    address _rewardsToken
   )
   {
       stakingToken = IERC20(_stakingToken);
       rewardsToken = IERC20(_rewardsToken);
   }
    /**
    * ================ Utility Functions ================
    */

    /**
    * @notice A method for setting the tier
    * @param _stake the amount to stake
    */
    function setTier(uint256 _stake) internal pure returns(StakeTier tier) {
        if(_stake >= 1000){
            return StakeTier.Platinum;
        } else if (_stake >= 500 && _stake  < 1000) {
            return StakeTier.Gold;
        } else if (_stake >= 100 && _stake  < 500) {
            return StakeTier.Silver;
        }  else if (_stake > 0  && _stake  < 100) {
            return StakeTier.Bronze;
        }

    }
        
    /**
    * @notice A method for getting the tier
    * @param _staker address of the required user
    */

    function getTierOf(address _staker) public view returns(StakeTier){
        return stakesMap[_staker].tier;
    }
        
    /**
    * @notice A method for getting the stake of a user
    * @param _staker address of the required user
    */

    function getStakesOf(address _staker) public view returns(uint256){
        return stakesMap[_staker].stake;
    }

    /**
    * @dev Update the rewards per token accumulator.
    * @notice Needs to be called on each liquidity event
    * Tiers:
    * Platinum reward of 100 RewardToken 
    * Gold reward of 50 RewardToken 
    * Silver reward of 10 RewardToken
    * Bronze reward of 5 RewardToken
    */
    function _updateRewardsPerToken(StakeStruct storage _staker, uint256 _stake) internal {

        // Getting amount of periods that has passed since last update
        uint256 rewardPeriods = (block.timestamp.sub( _staker.startDate)).div(10 minutes);

        console.log('Amount of Reward Periods since last Update: %s', rewardPeriods);

        // Restarting period
        _staker.startDate = block.timestamp;

        console.log('initial stake: %s', _staker.stake);

        // Incrementing staked amount
        uint256 accumulatedStake = _staker.stake;
        _staker.stake = accumulatedStake.add(_stake);
        
        console.log('final stake: %s', _staker.stake);
        //Setting the new tier according to the new stake
        _staker.tier = setTier(_staker.stake);

        //Assigning new amount of reward
        //using library for safe math operations
        if(_staker.tier == StakeTier.Platinum){
            _staker.reward.accumulated = _staker.reward.accumulated.add( rewardPeriods.mul(100));
        } else if (_staker.tier == StakeTier.Gold){
            _staker.reward.accumulated = _staker.reward.accumulated.add( rewardPeriods.mul(50));

        } else if (_staker.tier == StakeTier.Silver){
            _staker.reward.accumulated = _staker.reward.accumulated.add( rewardPeriods.mul(10));

        } else if (_staker.tier == StakeTier.Bronze){
            _staker.reward.accumulated = _staker.reward.accumulated.add( rewardPeriods.mul(5));
        }

        console.log('Actual amount of rewards: %s', _staker.reward.accumulated);
    }
   /**
    * ================ Staking Mechanism ================
    */

    /**
    * @notice A method to check if an address is a stakeholder.
    * @param _address The address to verify.
    * @return bool, uint256 Whether the address is a stakeholder,
    * and if so its position in the stakeHolders array.
    */
   function isStakeholder(address _address)
       public
       view
       returns(bool)
   {
       return stakesMap[_address].stake > 0 ? true : false;

   }

   /**
    * @notice A method to add a stakeholder.
    * @param _stakeholder The stakeholder to add.
    */
   function addStakeholder(address _stakeholder)
       public
   {
       (bool _isStakeholder) = isStakeholder(_stakeholder);
       if(!_isStakeholder) stakeHolders.push(_stakeholder);
   }

   /**
    * @notice A method to remove a stakeholder.
    * @param _stakeholder The stakeholder to remove.
    */
//    function removeStakeholder(address _stakeholder)
//        public
//    {
//        (bool _isStakeholder) = isStakeholder(_stakeholder);
//        if(_isStakeholder){
//            stakeHolders[s] = stakeHolders[stakeHolders.length - 1];
//            stakeHolders.pop();
//        }
//    }

    /**
    * @notice A method to retrieve the stake for a stakeholder.
    * @param _stakeHolder The stakeholder to retrieve the stake for.
    * @return uint256 The amount of wei staked.
    */
   function stakeOf(address _stakeHolder)
       public
       view
       returns(uint256)
   {
       uint256 totalStake = stakesMap[_stakeHolder].stake;
       return totalStake;
   }

   /**   
    * @notice A method to the aggregated stakes from all stakeholders.
    * @return uint256 The aggregated stakes from all stakeholders.
    */
   function totalStakes()
       public
       view
       returns(uint256)
   {
       uint256 _totalStakes;
       for (uint256 s = 0; s < stakeHolders.length; s += 1){
           _totalStakes = _totalStakes.add(stakesMap[stakeHolders[s]].reward.accumulated);
       }
       return _totalStakes;
   }

    /**
    * @notice A method for a stakeholder to create a stake.
    * @param _stake The size of the stake to be created.
    */
   function createStake(uint256 _stake)
       public
   {   
        require(_stake > 0, "You need to stake more than 0");

        console.log('Initial stake inserted in function: %s', _stake);
        console.log('Initial stake: %s', stakesMap[msg.sender].stake);
       /**
        * Register Stake holder
        */
        if(stakesMap[msg.sender].stake == 0){

            addStakeholder(msg.sender);
            stakesMap[msg.sender].startDate = block.timestamp;
            stakesMap[msg.sender].stake = _stake;
            stakesMap[msg.sender].stakerAddress = msg.sender;
            stakesMap[msg.sender].tier = setTier(_stake);

        } 

        /*
        * Updating reward
        */
        else {
            _updateRewardsPerToken(stakesMap[msg.sender], _stake);
        }
        console.log('final stake: %s', stakesMap[msg.sender].stake);
       /**
        * Transferring token
        */
        stakingToken.safeTransferFrom(msg.sender, address(this), _stake);
        emit Staked(msg.sender, _stake);
   }

   /**
    * @notice A method for a stakeholder to remove a stake.
    * @param _stake The size of the stake to be removed.
    */
   function removeStake(uint256 _stake)
       public
   {   
       require(_stake > 0, "You need to remove more than 0");
       require(_stake <= stakesMap[msg.sender].stake, "You need to remove less than what you have");

        //Removing amount of stake token
        stakesMap[msg.sender].stake = stakesMap[msg.sender].stake.sub(_stake);
        _updateRewardsPerToken(stakesMap[msg.sender] , 0);
        // Transferring stake token back
        stakingToken.transfer(msg.sender, _stake);
   }

   /**
    * ================ Rewards Mechanism ================
    */

   /**
    * @notice A method to allow a stakeholder to check his rewards.
    * @param _stakeHolder The stakeholder to check rewards for.
    */
    //Should it be view?
   function rewardOf(address _stakeHolder)
       public
       returns(uint256)
   {   
       //Updates the accumulated reward
       _updateRewardsPerToken(stakesMap[_stakeHolder], 0);
       return stakesMap[_stakeHolder].reward.accumulated;
   }

   /**
    * @notice A method to the aggregated rewards from all stakeholders.
    * @return uint256 The aggregated rewards from all stakeholders.
    */
//    function totalRewards()
//        public
//        view
//        returns(uint256)
//    {
//        uint256 _totalRewards = 0;
//        for (uint256 s = 0; s < stakeHolders.length; s += 1){
//            _totalRewards = _totalRewards.add(rewards[stakeHolders[s]]);
//        }
//        return _totalRewards;
//    }
   


   /**
    * @notice A method to allow a stakeholder to withdraw his rewards.
    */
   function withdrawReward()
       public
   {   
       require(stakesMap[msg.sender].stake > 0, "No stake created yet");

       _updateRewardsPerToken(stakesMap[msg.sender], 0); 
       rewardsToken.transfer(msg.sender, stakesMap[msg.sender].reward.accumulated); 
       emit Withdrawn(msg.sender, stakesMap[msg.sender].reward.accumulated);
       stakesMap[msg.sender].reward.accumulated = 0;
   } 

    /* ========== EVENTS ========== */
    event Staked(address indexed user, uint256 amount);
    event RewardDistributed(address indexed user, uint256 amount);  
    event Withdrawn(address indexed user, uint256 amount);
}