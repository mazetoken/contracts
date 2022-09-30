// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TheBookOfDogStake is Ownable {

    address public token;
    address public reward;
    uint256 public emission_rate;

    address[] public stakers;
    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;
    mapping(address => uint256) public tokenStakedAt;

    constructor(address _token, address _reward, uint256 _emission_rate) {
        token = _token;
        reward = _reward;
        emission_rate = _emission_rate;
    }

    function newEmissionRate(uint256 _emission_rate) external onlyOwner() {
        emission_rate = _emission_rate;
    }

    function newReward(address _reward) external onlyOwner() {
        reward = _reward;
    }

    // stake
    
    function stakeTokens(uint256 _amount) external {
        require(_amount > 0, "staking amount can not be 0");
        require(_amount <= 1000000000000, "staking amount can not be more than 10000");

        // Transfer tokens to contract for staking
        IERC20(token).transferFrom(msg.sender, address(this), _amount);

        // Update the staking balance in map
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;
        tokenStakedAt[msg.sender] = block.timestamp;

        // Add user to stakers array if they haven't staked already
        if(!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        // Update staking status to track
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

    // calculate reward

    function calculateReward() public view returns (uint256) {
        uint256 balance = stakingBalance[msg.sender];
        require(balance > 0, "staking balance can not be 0");
        uint256 timeElapsed = block.timestamp - tokenStakedAt[msg.sender];
        return balance * (timeElapsed * emission_rate) / 100000000;
    } 

    // unstake
    
    function unstakeTokens() external {

    	// get the users staking balance in stake tokens
    	uint256 balance = stakingBalance[msg.sender];
    
        // reqire the amount staked needs to be greater then 0
        require(balance > 0, "staking balance can not be 0");

        require(IERC20(reward).balanceOf(address(this)) >= calculateReward());
    
        // transfer tokens out of this contract
        IERC20(token).transfer(msg.sender, balance);
        IERC20(reward).transfer(msg.sender, calculateReward());
    
        // reset staking balance map to 0
        stakingBalance[msg.sender] = 0;
        delete tokenStakedAt[msg.sender];
    
        // update the staking status
        isStaking[msg.sender] = false;
    }

    // withdraw reward tokens from contract

    function withdrawTokens() external onlyOwner {
        uint256 balance = IERC20(reward).balanceOf(address(this));
        IERC20(reward).transfer(msg.sender, balance);
    }
}