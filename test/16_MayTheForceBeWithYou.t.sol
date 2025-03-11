// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/16_MayTheForceBeWithYou/MayTheForceBeWithYou.sol";

// forge test --match-contract MayTheForceBeWithYouTest -vvvv
contract MayTheForceBeWithYouTest is BaseTest {
    MayTheForceBeWithYou instance;
    MiniMeToken yoda;

    function setUp() public override {
        super.setUp();
        vm.startPrank(owner);
        yoda = new MiniMeToken("YODA Token", 18, "YODA");
        instance = new MayTheForceBeWithYou(address(yoda));
        yoda.mint(address(instance), 69420);
        vm.stopPrank();
    }

    function testExploitLevel() public {
        /* YOUR EXPLOIT GOES HERE */

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(yoda.balanceOf(address(instance)) == 0, "Solution is not solving the level");
    }
}
