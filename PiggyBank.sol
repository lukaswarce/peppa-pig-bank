// Piggy bank smart contract for Ethereum

// SPDX License Identifier
// SPDX-License-Identifier: MIT

// Solidity version
pragma solidity ^0.8.16;

// Imports
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Declare the smart contract
contract PiggyBank {

    // For what do we use the libraries?
    using SafeMath for uint256;

    // Add variables for analytics
    uint256 public ethersIn;
    uint256 public ethersOut;

    // Variables for locking the deposit
    uint256 public lockTime;

    // Access
    address public owner;

    // Struct in order to make a deposit
    struct Deposit {
        uint256 _depositId;
        uint256 _amount; // Amount of tokens to be deposited
        address _from; // Who made the deposit
        uint256 _depositTime; // When the deposit was made?
        uint256 _unlockTime; // When the deposit will be unlocked?
    }

    // Create an array of deposits
    Deposit[] public deposits;

    // Giving initial values of our variables on deployment 
    constructor () {
        ethersIn = 0;
        ethersOut = 0;
        lockTime = 2 minutes;
        // The owner of this smart contract will be the deployer
        owner = msg.sender;
    }

    // Create a modifier
    // Functions marked with this modifier can be executed only if the "require" statement is checked
    modifier onlyOwner {
        // If the address that is calling a function is not the owner, an error will be thrown
        require(msg.sender == owner, "You are not the owner of the smart contract!");
        _;
    }

     // Allow the smart contract to receive ether
    receive() external payable {
    }

    // Deposit eth to the smart contract
    function depositEth(uint256 _amount) public payable onlyOwner{
        require(msg.value == _amount);
        
        ethersIn = ethersIn.add(_amount);

        // Get the total of deposits that were made
        uint256 depositId = deposits.length;

        // Create a new struct for the deposit
        Deposit memory newDeposit = Deposit(depositId, msg.value, msg.sender, block.timestamp, block.timestamp.add(lockTime));
        
        // Push the new deposit to the array
        deposits.push(newDeposit);
    }

    function withdrawEthFromDeposit(uint256 _depositId) public {
        require(block.timestamp >= deposits[_depositId]._unlockTime, "Unlock time not reached!");
        ethersOut = ethersOut.add(deposits[_depositId]._amount);
        payable(msg.sender).transfer(deposits[_depositId]._amount);
    }

    // Getter - functions that get a value
    // Get the amount of eth deposited in eth, not in Wei
    // 1 Eth = 1 * 10**18 Wei

    function getEthDeposited() public view returns (uint256) {
        return ethersIn.div(10**18);
    }

    function getEthWithdrawn() public view returns (uint256) {
        return ethersOut.div(10**18);
    }

    function getBalanceInWei() public view returns (uint256) {
        return address(this).balance;
    }

    function getBalanceInEth() public view returns (uint256) {
        uint256 weiBalance = address(this).balance;
        uint256 ethBalance = weiBalance.div(10**18);
        return ethBalance;
    }

    // Setters - a function that, obviously, set a value

    // Set the unlock time of deposits to 10 minutes
    function setUnlockTimeToTenMinutes() public onlyOwner {
        lockTime = 10 minutes;
    }

    // Set the unlock time of deposits to 10 days
    function setUnlockTimeToTenDays() public onlyOwner {
        lockTime = 10 days;
    }

    // Set the unlock time of deposits to 5months
    function setUnlockTimeToTenMonths() public onlyOwner {
        lockTime = 5 * 30 days; // As we don't have "months" in solidity we will use 5 * 30 days
    }

    // Set the unlock time of deposits to 1 year
    function setUnlockTimeToOneYear() public onlyOwner {
        lockTime = 12 * 30 days; // As we don't have "years" in solidity we will use 12 * 30 days
    }

    // Set custom unlock time in minutes
    function setCustomUnlockTimeInMinutes(uint256 _minutes) public onlyOwner {
        uint256 _newLockTime = _minutes * 1 minutes;
        lockTime = _newLockTime;
    }

    // Set new owner
    function setNewOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}
