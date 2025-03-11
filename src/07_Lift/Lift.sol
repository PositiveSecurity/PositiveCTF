// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface House {
    function isTopFloor(uint256) external returns (bool);
}

contract Lift {
    bool public top;
    uint256 public floor;

    function goToFloor(uint256 _floor) public {
        House house = House(msg.sender);
        if (!house.isTopFloor(_floor)) {
            floor = _floor;
            top = house.isTopFloor(floor);
        }
    }
}
