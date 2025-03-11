// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";

contract BaseTest is Test {
    address player;
    address owner;

    function setUp() public virtual {
        (player,) = makeAddrAndKey("player");
        (owner,) = makeAddrAndKey("owner");
    }

    function checkSuccess() internal virtual {}

    receive() external payable virtual {}
}
