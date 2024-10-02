// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/15_PirateShip/PirateShip.sol";

// forge test --match-contract PirateShipTest -vvvv
contract PirateShipTest is BaseTest {
    PirateShip instance;

    function setUp() public override {
        super.setUp();
        instance = new PirateShip();
        instance.dropAnchor(block.number + 100001);
        vm.roll(824);
    }

    function testExploitLevel() public {
        /* YOUR EXPLOIT GOES HERE */

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(instance.blackJackIsHauled() == true, "Solution is not solving the level");
    }
}
