// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/11_DAO/DAO.sol";

// forge test --match-contract DAO2Test -vvvv
contract DAO2Test is BaseTest {
    DAO instance;

    function setUp() public override {
        super.setUp();

        owner = 0xd7f54f3c4e77328812EcB4336B4462d8aFd7e891;

        instance = new DAO(owner);

        instance.ownerContribute{value: 0.005 ether}(
            27,
            0x02801b56e7d98f6e7f1055bf01d9c7368ff17038400a0b810659bf560018bb80,
            0x2a9d54e315fcdbf1fce3296464f628ca39da2cc8698d67f7d6aaedadf3cdfb4d,
            0x15425fb889550b53067fd3601ba57260d6f74299cbeff5c5952a1ed879289c21
        );
        instance.ownerContribute{value: 0.005 ether}(
            28,
            0x98eb7be6e8eaedd9ba72cfa498ab79acdc5f4870ce34b49a2633457ba02a70c8,
            0x75bb101930cc82015f06e00c0e7d8c5a147cc35d04bbf15baa148ccc6bea504e,
            0x559d658207ebc6ea21b93ebd59a7b70262b1d3087a327eb488b414ba0a56c636
        );
        instance.ownerContribute{value: 0.005 ether}(
            28,
            0x5422bb2c200cfb8041bb610dc2e34fce50da28d752e477c735ff1e830f049977,
            0x8b7f0d31c5e76796e33df7927d9f85c76694901ee82d45a050e9788772e603c7,
            0xf09ee717026e5d4b9582ba617169078cf474a4807e265192a950b536d5b7cf0f
        );
        instance.ownerContribute{value: 0.005 ether}(
            28,
            0x0d3e9ab57762c37c5707cb7ab9f01982912274ce40b93e86f3e0f4088ac71a7e,
            0xb0d77f07c517b72736b870be313caa8aec08e95b64ead741c10a1ed2f1821198,
            0x81eb55ebe8ce2fbd813670f187a616ae3139ef440b871eac1760c7f60262b914
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
