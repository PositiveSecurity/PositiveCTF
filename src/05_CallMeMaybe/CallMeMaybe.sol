// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// This contract does not like when other contracts are calling it.

contract CallMeMaybe {
    constructor() payable {}

    modifier callMeMaybe() {
        uint32 size;
        address addr = msg.sender;
        assembly {
            size := extcodesize(addr)
        }
        if (size > 0) {
            revert();
        }
        _;
    }

    function hereIsMyNumber() public callMeMaybe {
        if (tx.origin == msg.sender) {
            revert();
        } else {
            payable(msg.sender).transfer(address(this).balance);
        }
    }
}
