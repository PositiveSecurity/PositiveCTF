// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/18_P2PSwapper/P2PSwapper.sol";

// forge test --match-contract P2PSwapperTest -vvvv
contract P2PSwapperTest is BaseTest {
    P2PSwapper instance;
    P2P_WETH p2pweth;

    function setUp() public override {
        super.setUp();

        vm.deal(owner, 10 ether);
        vm.startPrank(owner);

        p2pweth = new P2P_WETH();
        instance = new P2PSwapper(address(p2pweth));

        p2pweth.deposit{value: 0.1 ether}();
        p2pweth.approve(address(instance), 123);
        instance.createDeal{value: 313337}(address(p2pweth), 1, address(p2pweth), 0.000001 ether);
        vm.stopPrank();
    }

    function testExploitLevel() public {
        /* YOUR EXPLOIT GOES HERE */

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(p2pweth.balanceOf(address(instance)) == 0, "Solution is not solving the level");
    }
}
