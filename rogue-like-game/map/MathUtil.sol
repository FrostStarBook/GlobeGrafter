// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library MathUtil {
    
    function toUint(int origin) public pure returns(uint result){
        require(origin >= 0, "origin must be non-negative");
        result = (uint)(origin);
    }
    
}