// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

// Guess number before it's generated and you will receive all the funds from contract.

contract PredictTheFuture {
    address public player;
    uint8 public guess;
    uint256 nextBlockNumber;

    constructor() payable {
        require(msg.value == 0.01 ether);
    }

    function setGuess(uint8 n) public payable {
        require(player == address(0));
        require(msg.value == 0.01 ether);
        player = msg.sender;
        guess = n;
        nextBlockNumber = block.number + 1;
    }

    function solution() public {
        require(msg.sender == player, "Wrong user");
        require(block.number > nextBlockNumber, "Need to call at next block");

        uint256 answer = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))) % 10;

        player = address(0);
        if (guess == answer) {
            payable(msg.sender).transfer(address(this).balance);
        }
    }
}
