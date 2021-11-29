// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    uint256 private seed;

    //used to emit a changes. Frontend will update using getWave() when change happends 
    event NewWave(address indexed from, uint256 timestamp, string message);

    struct Wave {
        address waver;  //address who "waved"
        string message; // The message User sent
        uint256 timestamp; //Timestamp 
    }

    Wave[] waves; // Holds all "waves" (in my case messages) anyone sends

    mapping(address => uint256) public lastWavedAt; 

    constructor() payable {
        console.log("We have been constructed!");
 
        seed = (block.timestamp + block.difficulty) % 100;
    }


    //The message user sends to the frontend
    function wave(string memory _message) public {

        //prevents spamming by offering 
        require(
            lastWavedAt[msg.sender] + 15 seconds < block.timestamp,
            "Wait 15m"
        );

     
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s has waved!", msg.sender);

        //saves wave in array
        waves.push(Wave(msg.sender, _message, block.timestamp)); 

        //handles payouts
        seed = (block.difficulty + block.timestamp + seed) % 100;

        if (seed <= 50) {
            console.log("%s won!", msg.sender);

            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than they contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        return totalWaves;
    }
}