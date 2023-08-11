// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MathUtil {
    function toUint(int16 origin) public pure returns (uint16) {
        require(origin >= 0, "origin must be non-negative");
        uint16 result = uint16(origin);
        return result;
    }
}
