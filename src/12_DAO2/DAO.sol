// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// After two hacks, the DAO owner hasn't learned a thing...

import {OffchainCheckOwner} from "./OffchainCheckOwner.sol";

contract DAO2 is OffchainCheckOwner {
    uint256 border = 10;
    mapping(address => bool) registered;
    mapping(address => uint256) contributes;

    event Contributed(address contributer, uint256 amount);
    event NewBorder(uint256 value);
    event OwnerChanged(address newOwner);

    constructor(address _owner) payable OffchainCheckOwner(_owner) {}

    function register() external {
        require(registered[msg.sender] == false);
        registered[msg.sender] = true;
    }

    function contribute(address user) external payable {
        require(registered[msg.sender] == true);
        if (msg.value >= address(this).balance) {
            // If you are big DAO's contributer, you definitely deserve an upgrade
            contributes[user] += 1;
        }
        emit Contributed(msg.sender, msg.value);
    }

    function voteForYourself() external {
        require(registered[msg.sender] == true);
        // You can vote only once
        require(contributes[msg.sender] < 0);
        emit OwnerChanged(msg.sender);
        owner = owner;
    }

    function ownerContribute(uint8 _v, bytes32 _r, bytes32 _s, bytes32 _hash) external payable {
        checkOwner(_v, _r, _s, _hash);
        require(msg.value > 0);
        emit Contributed(owner, msg.value);
    }

    function changeDAOowner(uint8 _v, bytes32 _r, bytes32 _s, bytes32 _salt, address _newOwner) external {
        // add 0x01 prefix to prevent collisions with other types of messages
        uint256 value = address(this).balance;
        bytes32 hash = keccak256(abi.encode(uint8(0x01), value, _salt));
        checkOwner(_v, _r, _s, hash);
        emit OwnerChanged(_newOwner);
        owner = _newOwner;
    }

    function setBorder(uint8 _v, bytes32 _r, bytes32 _s, bytes32 _salt, uint256 _newBorder) external {
        // add 0x02 prefix to prevent collisions with other types of messages
        bytes32 hash = keccak256(abi.encode(uint8(0x02), _newBorder, _salt));
        checkOwner(_v, _r, _s, hash);
        border = _newBorder;
        emit NewBorder(_newBorder);
    }

    function withdraw() public {
        payable(owner).transfer(address(this).balance);
    }
}
