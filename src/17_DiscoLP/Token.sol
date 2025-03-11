// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor(string memory _name, string memory _symbol, address player) ERC20(_name, _symbol) {
        _mint(msg.sender, 100000 * 10 ** 18); // initial LP liquidity
        _mint(player, 1 * 10 ** 18); // a tip to user
    }
}
