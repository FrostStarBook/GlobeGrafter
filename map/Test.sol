// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Rogue.sol";

contract Test is Rogue {

    function testConnectRoom() public returns (int16[][] memory) {
        return create(int16(168), int16(56), int16(3), int16(3), [int16(0), int16(0)], [int16(0), int16(0)]);
    }

    // function test() public pure returns (bytes memory){
    //     return bytes32(create(int16(168), int16(56), int16(3), int16(3), [int16(0), int16(0)], [int16(0), int16(0)]));
    // }

}
