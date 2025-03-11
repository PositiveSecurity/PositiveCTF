// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/17_DiscoLP/DiscoLP.sol";
import "src/17_DiscoLP/Token.sol";

// forge test --fork-url wss://eth.drpc.org --match-contract DiscoLPTest -vvv
contract DiscoLPTest is BaseTest {
    DiscoLP instance;

    function setUp() public override {
        super.setUp();
        vm.startPrank(owner);
        address _factory = $.UniswapV2_FACTORY;
        address _router = $.UniswapV2_ROUTER;
        ERC20 tokenA = new Token("Jimbo", "JIMBO", player);
        ERC20 tokenB = new Token("Jambo", "JAMBO", player);
        address reserveToken = IUniswapV2Factory(_factory).createPair(address(tokenA), address(tokenB));
        instance = new DiscoLP("DiscoLP", "DISCO", 18, reserveToken);
        tokenA.approve(_router, type(uint256).max);
        tokenB.approve(_router, type(uint256).max);
        IUniswapV2Router(_router).addLiquidity(
            address(tokenA), address(tokenB), 100000 * 1e18, 100000 * 1e18, 1, 1, address(instance), type(uint256).max
        );
        vm.stopPrank();
    }

    function testExploitLevel() public {
        /* YOUR EXPLOIT GOES HERE */

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(instance.balanceOf(address(this)) > 100 * 1e18, "Solution is not solving the level");
    }
}
