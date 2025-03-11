// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";

import "src/20_MainKhinkalChef/LPToken.sol";
import "src/20_MainKhinkalChef/MainChef.sol";
import "src/20_MainKhinkalChef/KhinkalToken.sol";

// forge test --match-contract MainKhinkalChefTest -vvvv
contract MainKhinkalChefTest is BaseTest {
    MainChef instance;
    LPToken lptoken;
    KhinkalToken khinkal;

    function setUp() public override {
        super.setUp();
        vm.startPrank(owner);
        khinkal = new KhinkalToken();
        lptoken = new LPToken();

        lptoken.mint(player, 1337);

        instance = new MainChef(khinkal, address(this), 31333333337, 0, 0, address(this));

        khinkal.mint(address(instance), 313337);
        khinkal.transferOwnership(address(instance));

        instance.addToken(IERC20(lptoken));
        vm.stopPrank();
    }

    function testExploitLevel() public {
        /* YOUR EXPLOIT GOES HERE */

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(khinkal.balanceOf(address(instance)) == 0, "Solution is not solving the level");
    }
}
