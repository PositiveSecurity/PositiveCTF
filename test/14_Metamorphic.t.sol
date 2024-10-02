// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/14_Metamorphic/MyToken.sol";
import "src/14_Metamorphic/WalletERC20.sol";
import "src/14_Metamorphic/MetaFactory.sol";

// forge test --match-contract MetamorphicTest
contract MetamorphicTest is BaseTest {
    MyToken token;
    MetaFactory instance;
    WalletERC20 implementation;
    address metaAddr;

    function setUp() public override {
        super.setUp();

        token = new MyToken(address(this));
        instance = new MetaFactory();
        implementation = new WalletERC20();

        bytes memory bytecode = _concatenateAddr(address(implementation));
        metaAddr = instance.deploy(uint256(keccak256(bytecode)), bytecode);
        WalletERC20(metaAddr).initializer(token);
        token.mint(metaAddr, 1000);
    }

    function testExploitLevel() public {
        /* YOUR EXPLOIT GOES HERE */

        checkSuccess();
    }

    function checkSuccess() internal view override {
        uint256 balance = token.balanceOf(metaAddr);
        assertTrue(balance == 0, "Solution is not solving the level");
    }

    function _concatenateAddr(address _implementation) internal pure returns (bytes memory) {
        bytes20 implAddrBytes = bytes20(_implementation);

        bytes memory part1 = hex"5f602d80600a5f3981f3365f5f375f5f5f365f73";
        bytes memory part3 = hex"5af43d82803e903d91602b57fd5bf3";

        uint256 totalLength = part1.length + implAddrBytes.length + part3.length;

        bytes memory result = new bytes(totalLength);

        uint256 k = 0;

        for (uint256 i = 0; i < part1.length; ++i) {
            result[k++] = part1[i];
        }
        for (uint256 i = 0; i < implAddrBytes.length; ++i) {
            result[k++] = implAddrBytes[i];
        }
        for (uint256 i = 0; i < part3.length; ++i) {
            result[k++] = part3[i];
        }

        return result;
    }
}
