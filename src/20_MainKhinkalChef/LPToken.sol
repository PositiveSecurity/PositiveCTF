// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LPToken is ERC20("LP Token", "LPT"), Ownable {
    constructor() Ownable(msg.sender) {
        _mint(msg.sender, 10e18);
    }

    function mint(address account, uint256 value) public onlyOwner {
        _mint(account, value);
    }
}
