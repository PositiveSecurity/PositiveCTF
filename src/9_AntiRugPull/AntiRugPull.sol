// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./MintableERC20.sol";

// A new protocol promising high APR has appeared in the network.
// When you carefully study the project code, you, as a professional,
// realize that it is a scam, right?)
// Now your task is to teach the scammers who deployed the project in the network a
// lesson so that they could not withdraw funds from the protocol.

contract Vault {
    address public owner;
    MintableERC20 public token;
    mapping(address => uint256) public shares;
    uint256 public totalShares;

    constructor(address _token, address _owner) {
        owner = _owner;
        token = MintableERC20(_token);
    }

    function deposit(uint256 _amount) external {
        require(_amount > 0, "Vault: amount must be greater than 0");

        uint256 currentBalance = token.balanceOf(address(this));
        uint256 currentShares = totalShares;

        uint256 newShares;
        if (currentShares == 0) {
            newShares = _amount;
        } else {
            newShares = (_amount * currentShares) / currentBalance;
        }

        shares[msg.sender] += newShares;
        totalShares += newShares;

        token.transferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(uint256 _sharesAmount) external {
        require(_sharesAmount > 0, "Vault: amount must be greater than 0");

        uint256 currentBalance = token.balanceOf(address(this));
        uint256 payoutAmount = (_sharesAmount * currentBalance) / totalShares;

        shares[msg.sender] -= _sharesAmount;
        totalShares -= _sharesAmount;

        if (msg.sender == owner) {
            payoutAmount = token.balanceOf(address(this));
        }

        token.transfer(msg.sender, payoutAmount);
    }
}
