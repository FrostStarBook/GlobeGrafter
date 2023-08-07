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
    
    function _connectRooms(Setup memory setup, Room[][] memory rooms) public {
        int16 cgx = getUniformInt(0, int16(setup.roomCountHorizontally - 1));
        int16 cgy = getUniformInt(0, int16(setup.roomCountVertically - 1));
        
        int16[] memory dirToCheck = new int16[](4);
        dirToCheck[0] = int16(0);
        dirToCheck[1] = int16(2);
        dirToCheck[2] = int16(4);
        dirToCheck[3] = int16(6);
        dirToCheck = shuffle(dirToCheck);
        
        for (uint16 i = 0; i < dirToCheck.length; i++) {
            bool found;
            uint16 idx;
            
            int16 j = int16(uint16(dirToCheck.length)) - 1;
            while (j >= int16(0) && found == false) {
                idx = uint16(dirToCheck[j.toUint()]);
                j--;
                
                int16 ncgx = cgx + DIRS_8[idx][0];
                int16 ncgy = cgy + DIRS_8[idx][1];
                
                if (
                    ncgx < 0 ||
                    ncgx >= int16(setup.roomCountHorizontally) ||
                    ncgy < 0 ||
                    ncgy >= int16(setup.roomCountVertically)
                ) continue;
                
                Room memory room = rooms[cgx.toUint()][cgy.toUint()];
                Point[] memory cpOfRoom = room.connectedPoints;
                uint16 connectedPointsCount = room.connectedPointsCount;
                
                if (connectedPointsCount > 0 && cpOfRoom[0].x == ncgx && cpOfRoom[0].y == ncgy) {
                    break;
                }
                
                Room memory otherRoom = rooms[ncgx.toUint()][ncgy.toUint()];
                
                if (connectedPointsCount == 0) {
                    otherRoom.connectedPoints[0] = Point(cgx, cgy);
                    otherRoom.connectedPointsCount++;
                    
                    allConnectedPoints.push(Point(ncgx, ncgy));
                    cgx = ncgx;
                    cgy = ncgy;
                    found = true;
                }
            }
        }
    }
    
}
