// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// This lottery uses blockhash of a future block, try to beat it!

contract WheelOfFortune {
    Game[] public games;

    struct Game {
        address player;
        uint256 id;
        uint256 bet;
        uint256 blockNumber;
    }

    constructor() payable {
        require(msg.value == 0.01 ether);
    }

    function spin(uint256 _bet) public payable {
        require(msg.value >= 0.01 ether);
        uint256 gameId = games.length;
        games.push(Game({player: msg.sender, id: gameId, bet: _bet, blockNumber: block.number}));
        if (gameId > 0) {
            uint256 lastGameId = gameId - 1;
            uint256 num = rand(blockhash(games[lastGameId].blockNumber), 100);
            if (num == games[lastGameId].bet) {
                payable(games[lastGameId].player).transfer(address(this).balance);
            }
        }
    }

    function rand(bytes32 _hash, uint256 _max) internal pure returns (uint256 result) {
        result = uint256(keccak256(abi.encode(_hash))) % _max;
    }
}
