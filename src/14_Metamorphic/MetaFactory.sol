//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// The owner of a decent amount of tokens did not take care of security and used a public contract factory.
// There are so many tokens on his wallet, can you steal these tokens?

contract MetaFactory {
    mapping(address => address) public implementations;
    mapping(uint256 => address) public salt;

    event Deployed(address metaAddr);

    function deploy(uint256 _salt, bytes calldata _bytecode) public returns (address) {
        bytes memory implInitCode = _bytecode;
        // set init code for metamorhpic contract
        bytes memory metamorphicCode = (hex"5860208158601c335a63aaf10f428752fa158151803b80938091923cf3");
        // get metamorhpic contract address
        address metamorphicContractAddress = _getMetamorphicContractAddress(_salt, metamorphicCode);

        address impContract;
        // load implementation initialization code and its length, then deploy with CREATE
        assembly {
            let encoded_data := add(0x20, implInitCode)
            let encoded_size := mload(implInitCode)
            impContract := create(0, encoded_data, encoded_size)
        }
        // first we deploy the code we want to deploy to a separate address
        // store the realization to be extracted by the metamorphic contract
        implementations[metamorphicContractAddress] = impContract;

        address metaAddr;
        assembly {
            let encoded_data := add(0x20, metamorphicCode)
            let encoded_size := mload(metamorphicCode)
            metaAddr := create2(0, encoded_data, encoded_size, _salt)
        }
        require(metaAddr == metamorphicContractAddress, "Failed to deploy the new metamorphic contract");

        emit Deployed(metaAddr);

        return metaAddr;
    }

    function _getMetamorphicContractAddress(uint256 _salt, bytes memory _metamorphicCode)
        internal
        view
        returns (address)
    {
        // determine the address of the metamorphic contract.
        return address(
            uint160( // downcast to match the address type.
                uint256( // convert to uint to truncate upper digits.
                    keccak256( // compute the CREATE2 hash using 4 inputs.
                        abi.encodePacked( // pack all inputs to the hash together.
                            hex"ff", // start with 0xff to distinguish from RLP.
                            address(this), // this contract will be the caller.
                            _salt, // pass in the supplied salt value.
                            keccak256(abi.encodePacked(_metamorphicCode))
                        )
                    )
                )
            )
        );
    }
    //those two functions are getting called by the metamorphic Contract

    function getImplementation() external view returns (address implementation) {
        return implementations[msg.sender];
    }
}
