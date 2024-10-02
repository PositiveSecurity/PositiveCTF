// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// We added a private seed, nobody will ever learn it!

contract PrivateRyan {
    uint256 constant FACTOR = 1157920892373161954135709850086879078532699843656405640394575840079131296399;

    uint256 seed = 1;

    constructor() payable {
        require(msg.value == 0.01 ether);
        seed = rand(256);
    }

    function spin(uint256 bet) public payable {
        require(msg.value >= 0.01 ether);
        uint256 num = rand(100);
        seed = rand(256);
        if (num == bet) {
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    function rand(uint256 max) internal view returns (uint256 result) {
        uint256 factor = (FACTOR * 100) / max;
        uint256 blockNumber = block.number - seed;
        uint256 hashVal = uint256(blockhash(blockNumber));

        return uint256((uint256(hashVal) / factor)) % max;
    }
}
