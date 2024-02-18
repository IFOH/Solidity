// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Randint.sol";

contract lotto  {

    randomNumber randintContract = new randomNumber();
    uint256 public balance;
    uint256 private playerCount;
    mapping(uint256 => person) public players;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner allowed");
        _;
    }

    struct person {
        address payable personAddress;
        uint256 funds;
        uint256 chance;
    }

    function enterDraw() public payable {
        require(msg.value > 0,"No ether sent");
        playerCount += 1;
        bool found = false;
        // Checks if address has already got funds 
        for(uint n = 1; n < uint(playerCount + 1); n++){
            if (keccak256(abi.encode(msg.sender)) == keccak256(abi.encode(players[n].personAddress))) {
                found = true;
                players[n].funds += msg.value;
                break;
            }
        }
        if (found == false) {
            players[playerCount] = person(payable(msg.sender),msg.value,0);
        }
        balance = balance + uint(msg.value);
    }

    // Assigns every person numbers in a list. The more funds, the more numbers assigned
    function calculateChance() internal returns(uint){
        uint listNum;
        for(uint n = 1; n < uint(playerCount + 1); n++) {
            players[n].chance = listNum + players[n].funds;
            listNum += players[n].funds;
        }
        return(listNum);
    }

    function chooseWinner() onlyOwner() public payable {
        uint max = calculateChance();
        uint winningNum = randintContract.random(max);
        for(uint n = 1; n < uint(playerCount + 1); n++) {
            if (players[n].chance >= winningNum) {
                person storage winner = players[n];
                winner.personAddress.transfer(balance);
                break;
            }
        }
    }
}