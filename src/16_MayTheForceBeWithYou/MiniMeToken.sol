// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MiniMeToken is Ownable {
    string public name;
    uint8 public decimals;
    string public symbol;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    uint256 totalSupply;

    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(address indexed _owner, address indexed _spender, uint256 _amount);

    constructor(string memory _tokenName, uint8 _decimalUnits, string memory _tokenSymbol) Ownable(msg.sender) {
        name = _tokenName; // Set the name
        decimals = _decimalUnits; // Set the decimals
        symbol = _tokenSymbol; // Set the symbol
    }

    function transfer(address _to, uint256 _amount) public returns (bool success) {
        return doTransfer(msg.sender, _to, _amount);
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        if (allowed[_from][msg.sender] < _amount) {
            return false;
        }
        allowed[_from][msg.sender] -= _amount;
        return doTransfer(_from, _to, _amount);
    }

    function doTransfer(address _from, address _to, uint256 _amount) internal returns (bool) {
        if (_amount == 0) {
            return true;
        }
        // Do not allow transfer to 0x0 or the token contract itself
        require((_to != address(0)) && (_to != address(this)));
        // If the amount being transfered is more than the balance of the
        //  account the transfer returns false
        if (balances[_from] < _amount) {
            return false;
        }

        // First update the balance array with the new value for the address
        //  sending the tokens
        balances[_from] = balances[_from] - _amount;
        // Then update the balance array with the new value for the address
        //  receiving the tokens

        require(balances[_to] + _amount >= balances[_to]); // Check for overflow
        balances[_to] = balances[_to] + _amount;
        // An event to make the transfer easy to find on the blockchain
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount) public returns (bool success) {
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function mint(address _owner, uint256 _amount) public onlyOwner {
        balances[_owner] = _amount;
        totalSupply += _amount;
    }
}
