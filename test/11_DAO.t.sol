// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/11_DAO/DAO.sol";

// forge test --match-contract DAOTest -vvvv
contract DAOTest is BaseTest {
    DAO instance;

    function setUp() public override {
        super.setUp();

        owner = 0xAe400C03795C420ECf8948b14A53C97F1d6FC824;

        instance = new DAO(owner);

        instance.ownerContribute{value: 0.01 ether}(
            28,
            0x740fea3982e3e205a04f0021c6f0ee976835157bb7e1ca4be98b7df29330a099,
            0x312329cc813422c4245a59ac9ce26233f3481225c201f268c9e7c4ecc3296491,
            0x54eea92ca59602878b3bba9eb2f362048431c42e944a06788e4fa8c3977dcb21
        );
        instance.ownerContribute{value: 0.01 ether}(
            28,
            0x740fea3982e3e205a04f0021c6f0ee976835157bb7e1ca4be98b7df29330a099,
            0x5ad63cdf1a1b3312a989d7e28496947583093bca50a41bf82918450968509281,
            0x81416315ea56402951ed2bdf02d4956c4eba56558745b49f3d310935a3ece1ae
        );
    }

    function testExploitLevel() public {
        /* YOUR EXPLOIT GOES HERE */

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(address(instance).balance == 0, "Solution is not solving the level");
    }
}
