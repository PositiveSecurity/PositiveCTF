// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./Babylonian.sol";
import "./Interfaces.sol";

contract DiscoLP is ERC20, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public immutable reserveToken;
    uint8 private _customDecimals;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, address _reserveToken)
        ERC20(_name, _symbol)
        Ownable(msg.sender)
    {
        _customDecimals = _decimals;
        assert(_reserveToken != address(0));
        reserveToken = _reserveToken;
        _mint(address(this), 100000 * 1e18); // some inital supply
    }

    function decimals() public view override returns (uint8) {
        return _customDecimals;
    }

    function calcCostFromShares(uint256 _shares) public view returns (uint256 _cost) {
        return (_shares * totalReserve()) / totalSupply();
    }

    function totalReserve() public view returns (uint256 _totalReserve) {
        return IERC20(reserveToken).balanceOf(address(this));
    }

    // accepts only JIMBO or JAMBO tokens
    function depositToken(address _token, uint256 _amount, uint256 _minShares) external nonReentrant {
        address _from = msg.sender;
        uint256 _minCost = calcCostFromShares(_minShares);
        if (_amount != 0) {
            IERC20(_token).safeTransferFrom(_from, address(this), _amount);
        }
        uint256 _cost = UniswapV2LiquidityPoolAbstraction._joinPool(reserveToken, _token, _amount, _minCost);
        uint256 _shares = (_cost * totalSupply()) / (totalReserve() - _cost);

        _mint(_from, _shares);
    }
}

library UniswapV2LiquidityPoolAbstraction {
    using SafeERC20 for IERC20;

    function _joinPool(address _pair, address _token, uint256 _amount, uint256 _minShares)
        internal
        returns (uint256 _shares)
    {
        if (_amount == 0) return 0;
        address _router = $.UniswapV2_ROUTER;
        address _token0 = Pair(_pair).token0();
        address _token1 = Pair(_pair).token1();
        address _otherToken = _token == _token0 ? _token1 : _token0;
        (uint256 _reserve0, uint256 _reserve1,) = Pair(_pair).getReserves();
        uint256 _swapAmount = _calcSwapOutputFromInput(_token == _token0 ? _reserve0 : _reserve1, _amount);
        if (_swapAmount == 0) _swapAmount = _amount / 2;
        uint256 _leftAmount = _amount - _swapAmount;
        _approveFunds(_token, _router, _amount);
        address[] memory _path = new address[](2);
        _path[0] = _token;
        _path[1] = _otherToken;
        uint256 _otherAmount = IUniswapV2Router(_router).swapExactTokensForTokens(
            _swapAmount, 1, _path, address(this), type(uint256).max
        )[1];
        _approveFunds(_otherToken, _router, _otherAmount);
        (,, _shares) = IUniswapV2Router(_router).addLiquidity(
            _token, _otherToken, _leftAmount, _otherAmount, 1, 1, address(this), type(uint256).max
        );
        require(_shares >= _minShares, "high slippage");
        return _shares;
    }

    function _calcSwapOutputFromInput(uint256 _reserveAmount, uint256 _inputAmount) private pure returns (uint256) {
        return (
            Babylonian.sqrt(_reserveAmount * ((_inputAmount * 3988000) + (_reserveAmount * 3988009)))
                - (_reserveAmount * 1997)
        ) / 1994;
    }

    function _approveFunds(address _token, address _to, uint256 _amount) internal {
        uint256 _allowance = IERC20(_token).allowance(address(this), _to);
        if (_allowance > _amount) {
            IERC20(_token).safeDecreaseAllowance(_to, _allowance - _amount);
        } else if (_allowance < _amount) {
            IERC20(_token).safeIncreaseAllowance(_to, _amount - _allowance);
        }
    }
}
