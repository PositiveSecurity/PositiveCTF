// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// The goal of this level is to win the lottery and hit the jackpot!

contract Azino777 {
    uint256 constant FACTOR = 1157920892373161954235709850086879078532699846656405640394575840079131296399;

    constructor() payable {
        require(msg.value == 0.01 ether);
    }

    function spin(uint256 bet) public payable {
        require(msg.value >= 0.01 ether);
        uint256 num = rand(100);
        if (num == bet) {
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    function rand(uint256 max) internal view returns (uint256 result) {
        uint256 factor = (FACTOR * 100) / max;
        uint256 lastBlockNumber = block.number - 1;
        uint256 hashVal = uint256(blockhash(lastBlockNumber));

        return uint256((uint256(hashVal) / factor)) % max;
    }
}
