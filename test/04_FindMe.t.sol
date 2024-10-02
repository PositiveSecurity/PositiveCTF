// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/04_FindMe/FindMe.sol";

// forge test --match-contract FindMeTest -vvvv
contract FindMeTest is BaseTest {
    FindMe instance;

    function setUp() public override {
        super.setUp();

        uint16 setImmutable = uint16(uint160(tx.origin));
        bytes32[3] memory data;
        data[0] = keccak256(abi.encodePacked(tx.origin, "0"));
        data[1] = keccak256(abi.encodePacked(tx.origin, "1"));
        data[2] = keccak256(abi.encodePacked(tx.origin, "2"));
        instance = new FindMe(setImmutable, data);
    }

    function testExploitLevel() public {
        /* YOUR EXPLOIT GOES HERE */

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(instance.isUnlock(), "Solution is not solving the level");
    }
}
