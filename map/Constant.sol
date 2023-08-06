// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Constant {
    
    struct Point {
        int x;
        int y;
    }
    
    int8 public mapOn = 0;
    int8 public mapOff = 1;
    
    int8 public down = 1;
    int8 public up = 3;
    int8 public left = 2;
    int8 public right = 4;
    
    int8[] public downDir = [int8(0), int8(-1)];
    int8[] public upDir = [int8(0), int8(1)];
    int8[] public leftDir = [int8(-1), int8(0)];
    int8[] public rightDir = [int8(1), int8(0)];
    
    int[2][8] public DIRS_8 = [
    [int(0), int(-1)],
    [int(1), int(-1)],
    [int(1), int(0)],
    [int(1), int(1)],
    [int(0), int(1)],
    [int(-1), int(1)],
    [int(-1), int(0)],
    [int(-1), int(-1)]
    ];
    
}
