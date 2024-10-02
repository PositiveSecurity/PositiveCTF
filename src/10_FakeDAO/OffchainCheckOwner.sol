// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract OffchainCheckOwner {
    address public owner;

    event Signed(uint8 v, bytes32 r, bytes32 s, bytes32 hash);

    // Restrict reusing signatures
    mapping(bytes32 => bool) public used;

    constructor(address _owner) {
        owner = _owner;
    }

    function checkOwner(uint8 _v, bytes32 _r, bytes32 _s, bytes32 _hash) internal {
        require(!used[_hash]);
        address signer = ecrecover(_hash, _v, _r, _s);
        require(signer == owner);
        used[_hash] = true;
        emit Signed(_v, _r, _s, _hash);
    }
}
