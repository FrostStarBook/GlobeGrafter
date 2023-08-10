// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Constant {
    struct Point {
        int16 x;
        int16 y;
    }
    
    int16 public mapOn = 0;
    int16 public mapOff = 1;
    
    int8 public down = 1;
    int8 public up = 3;
    int8 public left = 2;
    int8 public right = 4;
    
    int8[] public downDir = [int8(0), int8(-1)];
    int8[] public upDir = [int8(0), int8(1)];
    int8[] public leftDir = [int8(-1), int8(0)];
    int8[] public rightDir = [int8(1), int8(0)];
    
    
    
    int16[2][8] public DIRS_8 = [
    [int16(0), int16(-1)],
    [int16(1), int16(-1)],
    [int16(1), int16(0)],
    [int16(1), int16(1)],
    [int16(0), int16(1)],
    [int16(-1), int16(1)],
    [int16(-1), int16(0)],
    [int16(-1), int16(-1)]
    ];
    
    
}
