// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// Ahoy, landlubber! The pirate ship "Black Pearl" is at anchor.
// Make it pull the anchor and haul the black jack flag to set off for the search of treasures.

contract PirateShip {
    address public anchor = address(0x0);
    bool public blackJackIsHauled = false;

    function sailAway() public {
        require(anchor != address(0x00));

        address a = anchor;
        uint256 size = 0;
        assembly {
            size := extcodesize(a)
        }
        if (size > 0) {
            revert(); // it is too early to sail away
        }

        blackJackIsHauled = true; // Yo Ho Ho!
    }

    function pullAnchor() public {
        require(anchor != address(0x0));
        (bool success,) = anchor.call("");
        require(success); // raise the anchor if the ship is ready to sail away
    }

    function dropAnchor(uint256 blockNumber) public returns (address addr) {
        // the ship will be able to sail away in 100k blocks time
        require(blockNumber > block.number + 100000, "The anchor is still at the bottom!");

        // if(block.number < blockNumber) { throw; }
        // suicide(msg.sender);

        uint256[8] memory a;
        a[0] = 0x6300; // PUSH4 0x00...
        a[1] = blockNumber; // ...block number (3 bytes)
        a[2] = 0x43; // NUMBER
        a[3] = 0x10; // LT
        a[4] = 0x58; // PC
        a[5] = 0x57; // JUMPI
        a[6] = 0x33; // CALLER
        a[7] = 0xff; // SELFDESTRUCT

        uint256 code = assemble(a);

        // init code to deploy contract: stores it in memory and returns appropriate offsets
        uint256[8] memory b;
        b[0] = 0; // allign
        b[1] = 0x6a; // PUSH11
        b[2] = code; // contract
        b[3] = 0x6000; // PUSH1 0
        b[4] = 0x52; // MSTORE
        b[5] = 0x600b; // PUSH1 11 ;; length
        b[6] = 0x6015; // PUSH1 21 ;; offset
        b[7] = 0xf3; // RETURN

        uint256 initcode = assemble(b);
        uint256 sz = getSize(initcode);
        uint256 offset = 32 - sz;

        assembly {
            let solidity_free_mem_ptr := mload(0x40)
            mstore(solidity_free_mem_ptr, initcode)
            addr := create(0, add(solidity_free_mem_ptr, offset), sz)
        }

        require(addr != address(0x00));
        anchor = addr;
    }

    ///////////////// HELPERS /////////////////

    function assemble(uint256[8] memory chunks) internal pure returns (uint256 code) {
        for (uint256 i = chunks.length; i > 0; i--) {
            code ^= chunks[i - 1] << 8 * getSize(code);
        }
    }

    function getSize(uint256 chunk) internal pure returns (uint256) {
        bytes memory b = new bytes(32);
        assembly {
            mstore(add(b, 32), chunk)
        }
        for (uint32 i = 0; i < b.length; i++) {
            if (b[i] != 0) {
                return 32 - i;
            }
        }
        return 0;
    }
}
