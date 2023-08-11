// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Constant.sol";
import "./MathUtil.sol";
import "./Rng.sol";

contract RoomManager is Constant{

    Constant private _constant;
    Rng private rng;
    MathUtil private mathUtil;

    constructor() {
        _constant = Constant(0x26E93649076Db1AcA99939318b6095eCE3905D14);
        rng = Rng(0xB19108002A01aECC326F56d9DaF66C7d1b1d7BBc);
        mathUtil = MathUtil(0x935602fd8D2cB4A547D9214d0FD4cb2B53709F4F);
    }

    function _initRooms(Setup memory setup) public view returns (Room[][] memory rooms) {
        uint16 sum = uint16(setup.roomCountHorizontally +setup.roomCountVertically);
        rooms = new Room[][](mathUtil.toUint(setup.roomCountHorizontally));
        for (uint16 i = 0; i < mathUtil.toUint(setup.roomCountHorizontally); i++) {
            rooms[i] = new Room[](mathUtil.toUint(setup.roomCountVertically));
            for (uint16 j = 0; j < mathUtil.toUint(setup.roomCountVertically); j++) {
                Point[] memory points = new Point[](sum);
                for (uint16 k = 0; k < sum; k++) {
                    points[k] = Point(0, 0);
                }
                rooms[i][j].connectedPoints = points;
                rooms[i][j].connectedPointsCount = 0;
                rooms[i][j].xOfRooms = int16(i);
                rooms[i][j].yOfRooms = int16(j);
            }
        }
    }

    function _connectRooms(Setup memory setup, Room[][] memory rooms) public {
        int16 cgx = rng.getUniformInt(0, int16(setup.roomCountHorizontally - 1));
        int16 cgy = rng.getUniformInt(0, int16(setup.roomCountVertically - 1));

        int16[] memory dirToCheck = new int16[](4);
        dirToCheck[0] = int16(0);
        dirToCheck[1] = int16(2);
        dirToCheck[2] = int16(4);
        dirToCheck[3] = int16(6);
        dirToCheck = rng.shuffle(dirToCheck);

        for (uint16 i = 0; i < dirToCheck.length; i++) {
            bool found;
            uint16 idx;

            int16 j = int16(uint16(dirToCheck.length)) - 1;
            while (j >= int16(0) && found == false) {
                idx = uint16(dirToCheck[mathUtil.toUint(j)]);
                j--;

                int16 ncgx = cgx + DIRS_8[idx][0];
                int16 ncgy = cgy + DIRS_8[idx][1];

                if (
                    ncgx < 0 || ncgx >= int16(setup.roomCountHorizontally) || ncgy < 0
                    || ncgy >= int16(setup.roomCountVertically)
                ) continue;

                Room memory room = rooms[mathUtil.toUint(cgx)][mathUtil.toUint(cgy)];
                Point[] memory cpOfRoom = room.connectedPoints;
                uint16 connectedPointsCount = room.connectedPointsCount;

                if (connectedPointsCount > 0 && cpOfRoom[0].x == ncgx && cpOfRoom[0].y == ncgy) {
                    break;
                }

                Room memory otherRoom = rooms[mathUtil.toUint(ncgx)][mathUtil.toUint(ncgy)];

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

    function _connectUnconnectedRooms(Setup memory setup, Room[][] memory rooms) public  {
        uint16 roomCountHorizontally = mathUtil.toUint(setup.roomCountHorizontally);
        uint16 roomCountVertically = mathUtil.toUint(setup.roomCountVertically);

        for (uint16 i = 0; i < roomCountVertically; i++) {
            for (uint16 j = 0; j < roomCountVertically; j++) {
                Room memory room = rooms[i][j];

                if (room.connectedPointsCount == 0) {
                    int16[] memory direction = new int16[](4);
                    direction[0] = 0;
                    direction[1] = 2;
                    direction[2] = 4;
                    direction[3] = 6;
                    direction = rng.shuffle(direction);
                    bool validRoom = false;

                    int16 xOfRoom;
                    int16 yOfRoom;

                    uint16 length = uint16(direction.length);

                    while (length > 0) {
                        uint16 dirIdx = mathUtil.toUint(direction[length - 1]);
                        length--;
                        int16 newI = int16(i) + DIRS_8[dirIdx][0];
                        int16 newJ = int16(j) + DIRS_8[dirIdx][1];

                        if (
                            newI < 0 || newI >= int16(roomCountHorizontally) || newJ < 0
                            || newJ >= int16(roomCountVertically)
                        ) {
                            continue;
                        }
                        Room memory otherRoom = rooms[mathUtil.toUint(newI)][mathUtil.toUint(newJ)];
                        validRoom = true;
                        xOfRoom = otherRoom.xOfRooms;
                        yOfRoom = otherRoom.yOfRooms;

                        if (otherRoom.connectedPointsCount == 0) {
                            break;
                        }

                        Point[] memory point16 = otherRoom.connectedPoints;
                        for (uint16 k = 0; k < otherRoom.connectedPointsCount; k++) {
                            if (point16[k].x == int16(i) && point16[k].y == int16(j)) {
                                validRoom = false;
                                break;
                            }
                        }

                        if (validRoom) {
                            break;
                        }
                    }

                    if (validRoom) {
                        Point[] memory connectedPoints = room.connectedPoints;

                        connectedPoints[room.connectedPointsCount] = Point(xOfRoom, yOfRoom);
                        room.connectedPointsCount++;
                    }
                }
            }
        }
    }
}