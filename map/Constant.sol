// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Constant {
    struct Point {
        int16 x;
        int16 y;
    }

    struct Setup {
        int16 width;
        int16 height;
        int16 roomCountHorizontally;
        int16 roomCountVertically;
        int16[2] roomWidthRange;
        int16[2] roomHeightRange;
    }

    struct Room {
        int16 xOfMap;
        int16 yOfMap;
        int16 width;
        int16 height;
        int16 xOfRooms;
        int16 yOfRooms;
        uint16 connectedPointsCount;
        Point[] connectedPoints;
    }

    int16 public mapOn = 0;
    int16 public mapOff = 1;

    int8 public down = 1;
    int8 public up = 3;
    int8 public left = 2;
    int8 public right = 4;


    Point[] public allConnectedPoints;

    int8[] public downDir = [int8(0), int8(- 1)];
    int8[] public upDir = [int8(0), int8(1)];
    int8[] public leftDir = [int8(- 1), int8(0)];
    int8[] public rightDir = [int8(1), int8(0)];


    int16[2][8] public DIRS_8 = [
    [int16(0), int16(- 1)],
    [int16(1), int16(- 1)],
    [int16(1), int16(0)],
    [int16(1), int16(1)],
    [int16(0), int16(1)],
    [int16(- 1), int16(1)],
    [int16(- 1), int16(0)],
    [int16(- 1), int16(- 1)]
    ];


}
