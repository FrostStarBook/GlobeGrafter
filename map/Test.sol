// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Rogue.sol";

contract Test is Rogue {

    function testConnectRoom() public returns (int16[][] memory) {
        
        return create(int16(10),
            int16(10),
            int16(4),
            int16(4),
            [int16(1), int16(2)],
            [int16(1), int16(2)]);

    }
    
}
