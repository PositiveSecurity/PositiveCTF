// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "./Interfaces.sol";

contract FakerDAO is ERC20, ReentrancyGuard {
    address public immutable pair;
    uint8 private immutable _customDecimals;

    constructor(address _pair) ERC20("Lambo", "LAMBO") {
        _customDecimals = 0;
        pair = _pair; // Uniswap YIN-YANG pair
    }

    function borrow(uint256 _amount) public nonReentrant {
        uint256 _balance = Pair(pair).balanceOf(msg.sender);
        uint256 _tokenPrice = price();
        uint256 _depositRequired = _amount * _tokenPrice;

        require(_balance >= _depositRequired, "Not enough collateral");

        // we get LP tokens
        Pair(pair).transferFrom(msg.sender, address(this), _depositRequired);
        // you get a LAMBO
        _mint(msg.sender, _amount);
    }

    function price() public view returns (uint256) {
        address token0 = Pair(pair).token0();
        address token1 = Pair(pair).token1();
        uint256 _reserve0 = IERC20(token0).balanceOf(pair);
        uint256 _reserve1 = IERC20(token1).balanceOf(pair);
        return (_reserve0 * _reserve1) / Pair(pair).totalSupply();
    }

    function decimals() public view override returns (uint8) {
        return _customDecimals;
    }
}
