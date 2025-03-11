// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";

import "src/19_FakerDAO/Token.sol";
import "src/19_FakerDAO/FakerDAO.sol";

// forge test --fork-url wss://eth.drpc.org --match-contract FakerDAOTest -vvv
contract FakerDAOTest is BaseTest {
    FakerDAO instance;

    function setUp() public override {
        super.setUp();
        vm.startPrank(owner);
        address _factory = $.UniswapV2_FACTORY;
        address _router = $.UniswapV2_ROUTER;
        Token yin = new Token("Yin", "YIN", player);
        Token yang = new Token("Yang", "YANG", player);
        address pair = IUniswapV2Factory(_factory).createPair(address(yin), address(yang));
        instance = new FakerDAO(pair);
        yin.approve(_router, type(uint256).max);
        yang.approve(_router, type(uint256).max);
        IUniswapV2Router(_router).addLiquidity(
            address(yin), address(yang), 1000000 * 1e18, 1000000 * 1e18, 1, 1, address(instance), type(uint256).max
        );
        vm.stopPrank();
    }

    function testExploitLevel() public {
        /* YOUR EXPLOIT GOES HERE */

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(instance.balanceOf(address(this)) > 0, "Solution is not solving the level");
    }
}
