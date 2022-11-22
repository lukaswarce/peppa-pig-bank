// Piggy bank smart contract for Ethereum

// SPDX License Identifier
// SPDX-License-Identifier: MIT

// Solidity version
pragma solidity ^0.8.16;

// My contract address:  <<Update me>>

// Imports
// This library is used to avoid integers overflows and underflows

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Declare the smart contract
contract PiggyBank {

    // To avoid integers overflows and underflows
    using SafeMath for uint256;

    // Add variables for analytics
    uint256 public ethersIn;
    uint256 public ethersOut;

    // Set up so that the owner is the person who deployed the contract.
    address public owner;

    // Saving goal
    uint256 public goal;

    // Struct in order to make a deposit
    struct Deposit {
        uint256 _depositId;
        uint256 _amount; // Amount of tokens to be deposited
        address _from; // Who made the deposit
    }

    // Create an array of deposits
    Deposit[] public deposits;

    // Giving initial values of our variables on deployment 
    constructor () {
        // The owner of this smart contract will be the deployer
        owner = msg.sender;
        ethersIn = 0;
        ethersOut = 0;
    }
    
    // Create a modifier
    // Functions marked with this modifier can be executed only if the "require" statement is checked
    modifier onlyOwner {
        // If the address that is calling a function is not the owner, an error will be thrown
        require(msg.sender == owner, "You are not the owner of the smart contract!");
        _;
    }

     // Allow the smart contract to receive ether from an account
    receive() external payable {
    }


    // 1.- Set a Saving Goal
    function savingGoal(uint _goal) public {
        goal = _goal;
    }

    function getSavingGoalEth() public view returns (uint256) {
        return goal.div(10**18);
    }

    // 3.- Function to receive ETH, called depositToTheBank
    function depositToTheBank(uint256 _amount) public payable onlyOwner{
        
        // validate the amount value
        require(msg.value == _amount);

        // Create an event to emit once you reach the saving goal
        uint256 weiBalance = address(this).balance;
        require(weiBalance <= goal , "You reach the Saving Goal");
        
        ethersIn = ethersIn.add(_amount);

        // Get the total of deposits that were made
        uint256 depositId = deposits.length;

        // Create a new struct for the deposit
        Deposit memory newDeposit = Deposit(depositId, msg.value, msg.sender);
        
        // Push the new deposit to the array
        deposits.push(newDeposit);
    }

    // 4.- Function to return the balance of the contract, called getBalance
    //      - Note: you will need to use address(this).balance which returns the balance in Wei.
    //      - 1 Eth = 1 * 10**18 Wei
    function getBalanceInWei() public view returns (uint256) {
        return address(this).balance;
    }

    function getBalanceInEth() public view returns (uint256) {
        uint256 weiBalance = address(this).balance;
        uint256 ethBalance = weiBalance.div(10**18);
        return ethBalance;
    }

    // 5.- Function to look up how much any depositor has deposited, called getDepositsValue
    //      - Get the amount of eth deposited in eth and wei
    //      - 1 Eth = 1 * 10**18 Wei

    function getDepositsValueinEth() public view returns (uint256) {
        return ethersIn.div(10**18);
    }

    function getDepositsValueinWei() public view returns (uint256) {
        return ethersIn;
    }

    // 6.- Function to withdraw (send) ETH, called emptyTheBank
    //      - Function should only send to you if you're the owner of the contract

    function emptyTheBank(uint256 _depositId) public {
        ethersOut = ethersOut.add(deposits[_depositId]._amount);
        payable(msg.sender).transfer(deposits[_depositId]._amount);
    }

    function getEthWithdrawn() public view returns (uint256) {
        return ethersOut.div(10**18);
    }
}
