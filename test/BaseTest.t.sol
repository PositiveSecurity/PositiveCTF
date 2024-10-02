// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";

contract BaseTest is Test {
    address user1;
    address user2;
    address owner;

    function setUp() public virtual {
        (user1,) = makeAddrAndKey("user1");
        (user2,) = makeAddrAndKey("user2");
        (owner,) = makeAddrAndKey("owner");
    }

    function checkSuccess() internal virtual {}

    receive() external payable virtual {}
}
