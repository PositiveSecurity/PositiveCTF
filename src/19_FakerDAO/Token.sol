// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor(string memory _name, string memory _symbol, address player) ERC20(_name, _symbol) {
        _mint(msg.sender, 1000000 * 1e18); // initial LP liquidity
        _mint(player, 5000 * 1e18); // a tip to user
    }
}
