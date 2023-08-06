// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Map.sol";
import "./Rng.sol";

contract Rogue is MapConstructor, Rng {
    
    using MathUtil for int16;
    
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
    
    Point[] allConnectedPoints;
    
    function create(
        int16 width,
        int16 height,
        int16 roomCountHorizontally,
        int16 roomCountVertically,
        int16[2] memory roomWidthRange,
        int16[2] memory roomHeightRange
    ) public returns (int16[][] memory map) {
        Setup memory setup;
        Room[][] memory rooms;
        
        setup = _initSetup(
            width,
            height,
            roomCountHorizontally,
            roomCountVertically,
            roomWidthRange,
            roomHeightRange
        );
        map = _fillMap(1, width, height);
        

    }
    
    function _initSetup(
        int16 width,
        int16 height,
        int16 roomCountHorizontally,
        int16 roomCountVertically,
        int16[2] memory roomWidthRange,
        int16[2] memory roomHeightRange
    ) public pure returns (Setup memory setup) {
        setup.width = width;
        setup.height = height;
        
        setup.roomCountHorizontally = roomCountHorizontally == int16(0)
            ? int16(3)
            : roomCountHorizontally;
        setup.roomCountVertically = roomCountVertically == int16(0) ? int16(3) : roomCountVertically;
        
        if (roomWidthRange[1] == 0 || roomWidthRange[0] > roomWidthRange[1]) {
            setup.roomWidthRange = roomWidthRange;
        } else {
            setup.roomWidthRange = _calculateRoomSize(width, roomCountHorizontally);
        }
        
        if (roomHeightRange[1] == 0 || roomHeightRange[0] > roomHeightRange[1]) {
            setup.roomHeightRange = roomHeightRange;
        } else {
            setup.roomHeightRange = _calculateRoomSize(height, roomCountVertically);
        }
    }
    
    function _calculateRoomSize(int16 size, int16 count) private pure returns (int16[2] memory roomSize) {
        roomSize[0] = (size * 80) / count / 100;
        roomSize[1] = (size * 25) / count / 100;
        if (roomSize[0] < 2) {
            roomSize[0] = 2;
        }
        if (roomSize[1] < 2) {
            roomSize[1] = 2;
        }
    }
    
    function _initRooms(Setup memory setup) public pure returns (Room[][] memory rooms) {
        rooms = new Room[][](setup.roomCountHorizontally.toUint());
        for (uint16 i = 0; i < setup.roomCountHorizontally.toUint(); i++) {
            rooms[i] = new Room[](setup.roomCountVertically.toUint());
            for (uint16 j = 0; j < setup.roomCountVertically.toUint(); j++) {
                // Point[] memory point16 = new Point[](i + j);
                rooms[i][j].connectedPoints = new Point[](i + j);
                rooms[i][j].connectedPointsCount = 0;
                rooms[i][j].xOfRooms = int16(i);
                rooms[i][j].yOfRooms = int16(j);
            }
        }
    }
    
    
}
