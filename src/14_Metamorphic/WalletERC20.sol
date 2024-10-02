//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WalletERC20 {
    IERC20 public token;
    bool public isInitialized;

    function initializer(IERC20 _token) external {
        require(!isInitialized);
        token = _token;
        isInitialized = true;
    }

    function balanceOf() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function kill() external {
        selfdestruct(payable(msg.sender));
    }
}
