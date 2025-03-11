// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library $ {
    address constant UniswapV2_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f; // Mainnet
    address constant UniswapV2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // Mainnet
}

interface IUniswapV2Router {
    function WETH() external pure returns (address _token);
    function addLiquidity(
        address _tokenA,
        address _tokenB,
        uint256 _amountADesired,
        uint256 _amountBDesired,
        uint256 _amountAMin,
        uint256 _amountBMin,
        address _to,
        uint256 _deadline
    ) external returns (uint256 _amountA, uint256 _amountB, uint256 _liquidity);
    function removeLiquidity(
        address _tokenA,
        address _tokenB,
        uint256 _liquidity,
        uint256 _amountAMin,
        uint256 _amountBMin,
        address _to,
        uint256 _deadline
    ) external returns (uint256 _amountA, uint256 _amountB);
    function swapExactTokensForTokens(
        uint256 _amountIn,
        uint256 _amountOutMin,
        address[] calldata _path,
        address _to,
        uint256 _deadline
    ) external returns (uint256[] memory _amounts);
    function swapETHForExactTokens(uint256 _amountOut, address[] calldata _path, address _to, uint256 _deadline)
        external
        payable
        returns (uint256[] memory _amounts);
    function getAmountOut(uint256 _amountIn, uint256 _reserveIn, uint256 _reserveOut)
        external
        pure
        returns (uint256 _amountOut);
}

interface Pair is IERC20 {
    function token0() external view returns (address _token0);
    function token1() external view returns (address _token1);
    function price0CumulativeLast() external view returns (uint256 _price0CumulativeLast);
    function price1CumulativeLast() external view returns (uint256 _price1CumulativeLast);
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
    function mint(address _to) external returns (uint256 _liquidity);
    function sync() external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}
