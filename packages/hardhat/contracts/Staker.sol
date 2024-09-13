// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker { 

  mapping (address => uint256) public balances;
  uint256 public constant treshold = 1e18;
  bool openForWithdraw;
  ExampleExternalContract public exampleExternalContract;
  event Stake(address stakerAddress, uint256 value);
  uint256 public deadline = block.timestamp + 30 seconds;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  modifier notCompleted(){
    require(exampleExternalContract.completed() == true, "Not completed");
    _;
  }
  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)
  function _stake(address _stakerAddress, uint256 amount) public payable returns(bool){
    require(amount != 0, "Amount should be less than 0");
    balances[_stakerAddress] += amount;
    emit Stake(_stakerAddress, amount);
    return true;
  }

  function stake() public payable returns(bool){
    bool value =  _stake(msg.sender, msg.value);
    return value;
  }

  function balance(address walletAddress) public view returns (uint256){
    return balances[walletAddress];
  }
  function execute() notCompleted public returns(bool){
    if (address(this).balance > treshold){
      exampleExternalContract.complete{value: address(this).balance}();
    }
    if (address(this).balance < treshold){
      openForWithdraw = true;
    }
    return true;
  }

  function timeLeft() public view returns (uint256){
    if (block.timestamp >= deadline){
      return 0;
    } else{
      return deadline;
    }
  }

  receive() external payable{
    _stake(msg.sender, msg.value);
  }

  function withdraw() notCompleted public payable returns(bool){
    require(openForWithdraw, "Not open for withdrawal");
    address reciever = msg.sender;
    uint _balance = balance(msg.sender);
    (bool value, ) = payable(reciever).call{value: _balance}("");
    balances[reciever] = 0;
    return value;
  }
  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`


  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend


  // Add the `receive()` special function that receives eth and calls stake()

}
