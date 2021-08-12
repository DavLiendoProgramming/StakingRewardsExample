// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

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
    address[] internal stakeHolders;
    mapping(address => uint256) internal stakes;
    mapping(address => uint256) internal rewards;


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
       returns(bool, uint256)
   {
       for (uint256 s = 0; s < stakeHolders.length; s += 1){
           if (_address == stakeHolders[s]) return (true, s);
       }
       return (false, 0);
   }

   /**
    * @notice A method to add a stakeholder.
    * @param _stakeholder The stakeholder to add.
    */
   function addStakeholder(address _stakeholder)
       public
   {
       (bool _isStakeholder, ) = isStakeholder(_stakeholder);
       if(!_isStakeholder) stakeHolders.push(_stakeholder);
   }

   /**
    * @notice A method to remove a stakeholder.
    * @param _stakeholder The stakeholder to remove.
    */
   function removeStakeholder(address _stakeholder)
       public
   {
       (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
       if(_isStakeholder){
           stakeHolders[s] = stakeHolders[stakeHolders.length - 1];
           stakeHolders.pop();
       }
   }

      /**
    * @notice A method to retrieve the stake for a stakeholder.
    * @param _stakeholder The stakeholder to retrieve the stake for.
    * @return uint256 The amount of wei staked.
    */
   function stakeOf(address _stakeholder)
       public
       view
       returns(uint256)
   {
       return stakes[_stakeholder];
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
       uint256 _totalStakes = 0;
       for (uint256 s = 0; s < stakeHolders.length; s += 1){
           _totalStakes = _totalStakes.add(stakes[stakeHolders[s]]);
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
       /**
        * Register Stake holder
        */
       if(stakes[msg.sender] == 0) addStakeholder(msg.sender);
       stakes[msg.sender] = stakes[msg.sender].add(_stake);

       /**
        * Transferring token
        */
        stakingToken.transferFrom(msg.sender, address(this), _stake);
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
       stakes[msg.sender] = stakes[msg.sender].sub(_stake);
       if(stakes[msg.sender] == 0) removeStakeholder(msg.sender);
       
       /**
        * Transferring token
        */
        stakingToken.transfer(msg.sender, _stake);
   }

   /**
    * ================ Rewards Mechanism ================
    */

      
   /**
    * @notice A method to allow a stakeholder to check his rewards.
    * @param _stakeholder The stakeholder to check rewards for.
    */
   function rewardOf(address _stakeholder)
       public
       view
       returns(uint256)
   {
       return rewards[_stakeholder];
   }

   /**
    * @notice A method to the aggregated rewards from all stakeholders.
    * @return uint256 The aggregated rewards from all stakeholders.
    */
   function totalRewards()
       public
       view
       returns(uint256)
   {
       uint256 _totalRewards = 0;
       for (uint256 s = 0; s < stakeHolders.length; s += 1){
           _totalRewards = _totalRewards.add(rewards[stakeHolders[s]]);
       }
       return _totalRewards;
   }
   
   /**
    * @notice A simple method that calculates the rewards for each stakeholder.
    * @param _stakeholder The stakeholder to calculate rewards for.
    */
   function calculateReward(address _stakeholder)
       public
       view
       returns(uint256)
   {
       return stakes[_stakeholder] / 100;
   }

   /**
    * @notice A method to distribute rewards to all stakeholders.
    */
   function distributeRewards()
       public
       onlyOwner
   {
       for (uint256 s = 0; s < stakeHolders.length; s += 1){
           address stakeholder = stakeHolders[s];
           uint256 reward = calculateReward(stakeholder);
           emit RewardDistributed(stakeholder, reward);
           rewards[stakeholder] = rewards[stakeholder].add(reward);
       }
   }

   /**
    * @notice A method to allow a stakeholder to withdraw his rewards.
    */
   function withdrawReward()
       public
   {   
       require(rewards[msg.sender] > 0, "No reward created yet");
       uint256 reward = rewards[msg.sender];
       rewards[msg.sender] = 0;
       rewardsToken.transfer(msg.sender, reward); 

       //remove stakeholder from the array
       removeStakeholder(msg.sender);
       emit Withdrawn(msg.sender, reward);
   } 

    /* ========== EVENTS ========== */
    event Staked(address indexed user, uint256 amount);
    event RewardDistributed(address indexed user, uint256 amount);  
    event Withdrawn(address indexed user, uint256 amount);
}