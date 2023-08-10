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

    Point[] private allConnectedPoints;

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

        setup = _initSetup(width, height, roomCountHorizontally, roomCountVertically, roomWidthRange, roomHeightRange);
        map = _fillMap(1, width, height);
        rooms = _initRooms(setup);

        _connectRooms(setup, rooms);
        _connectUnconnectedRooms(setup, rooms);

        _createRooms(map, setup, rooms);
        _createCorridors(setup, rooms, map);
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

        setup.roomCountHorizontally = roomCountHorizontally == int16(0) ? int16(3) : roomCountHorizontally;
        setup.roomCountVertically = roomCountVertically == int16(0) ? int16(3) : roomCountVertically;

        if (roomWidthRange[1] == 0 || roomWidthRange[0] > roomWidthRange[1]) {
            setup.roomWidthRange = _calculateRoomSize(width, roomCountHorizontally);
        } else {
            setup.roomWidthRange = roomWidthRange;
        }

        if (roomHeightRange[1] == 0 || roomHeightRange[0] > roomHeightRange[1]) {
            setup.roomHeightRange = _calculateRoomSize(height, roomCountVertically);
        } else {
            setup.roomHeightRange = roomHeightRange;
        }
    }

    function _calculateRoomSize(int16 size, int16 count) private pure returns (int16[2] memory roomSize) {
        roomSize[0] = (size * 25) / count / 100;
        roomSize[1] = (size * 80) / count / 100;
        if (roomSize[0] < 2) {
            roomSize[0] = 2;
        }
        if (roomSize[1] < 2) {
            roomSize[1] = 2;
        }
    }

    function _initRooms(Setup memory setup) public pure returns (Room[][] memory rooms) {
        uint16 sum = uint16(setup.roomCountHorizontally +setup.roomCountVertically);
        rooms = new Room[][](setup.roomCountHorizontally.toUint());
        for (uint16 i = 0; i < setup.roomCountHorizontally.toUint(); i++) {
            rooms[i] = new Room[](setup.roomCountVertically.toUint());
            for (uint16 j = 0; j < setup.roomCountVertically.toUint(); j++) {
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
                    ncgx < 0 || ncgx >= int16(setup.roomCountHorizontally) || ncgy < 0
                        || ncgy >= int16(setup.roomCountVertically)
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

    function _connectUnconnectedRooms(Setup memory setup, Room[][] memory rooms) public view {
        uint16 roomCountHorizontally = setup.roomCountHorizontally.toUint();
        uint16 roomCountVertically = setup.roomCountVertically.toUint();

        for (uint16 i = 0; i < roomCountVertically; i++) {
            for (uint16 j = 0; j < roomCountVertically; j++) {
                Room memory room = rooms[i][j];

                if (room.connectedPointsCount == 0) {
                    int16[] memory direction = new int16[](4);
                    direction[0] = 0;
                    direction[1] = 2;
                    direction[2] = 4;
                    direction[3] = 6;
                    direction = shuffle(direction);
                    bool validRoom = false;

                    int16 xOfRoom;
                    int16 yOfRoom;

                    uint16 length = uint16(direction.length);

                    while (length > 0) {
                        uint16 dirIdx = direction[length - 1].toUint();
                        length--;
                        int16 newI = int16(i) + DIRS_8[dirIdx][0];
                        int16 newJ = int16(j) + DIRS_8[dirIdx][1];

                        if (
                            newI < 0 || newI >= int16(roomCountHorizontally) || newJ < 0
                                || newJ >= int16(roomCountVertically)
                        ) {
                            continue;
                        }
                        Room memory otherRoom = rooms[newI.toUint()][newJ.toUint()];
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

    function _createRooms(int16[][] memory map, Setup memory setup, Room[][] memory rooms) public view {
        int16 averageRoomWidth = setup.width / setup.roomCountHorizontally;
        int16 averageRoomHeight = setup.height / setup.roomCountVertically;

        for (int16 i = 0; i < setup.roomCountHorizontally; i++) {
            for (int16 j = 0; j < setup.roomCountVertically; j++) {
                int16 assumeX = i * averageRoomWidth;
                if (assumeX == 0) {
                    assumeX = 1;
                }
                int16 assumeY = j * averageRoomHeight;
                if (assumeY == 0) {
                    assumeY = 1;
                }

                int16 roomWidth = getUniformInt(setup.roomWidthRange[0], setup.roomWidthRange[1]);
                int16 roomHeight = getUniformInt(setup.roomHeightRange[0], setup.roomHeightRange[1]);

                if (j > 0) {
                    Room memory otherRoom = rooms[i.toUint()][j.toUint() - 1];
                    while (assumeY - otherRoom.yOfMap - otherRoom.height < 3) {
                        assumeY++;
                    }
                }

                if (i > 0) {
                    Room memory otherRoom = rooms[i.toUint() - 1][j.toUint()];
                    while (assumeX - otherRoom.xOfMap - otherRoom.width < 3) {
                        assumeX++;
                    }
                }

                int16 offsetHoricontal = getUniformInt(0, averageRoomWidth - roomWidth) / 2;
                int16 offsetVertical = getUniformInt(0, averageRoomHeight - roomHeight) / 2;

                while (assumeX + offsetHoricontal + roomWidth >= setup.width) {
                    offsetHoricontal > 0 ? offsetHoricontal-- : roomWidth--;
                }

                while (assumeY + offsetVertical + roomHeight >= setup.height) {
                    offsetVertical > 0 ? offsetVertical-- : roomHeight--;
                }

                assumeX += offsetHoricontal;
                assumeY += offsetVertical;

                rooms[i.toUint()][j.toUint()].xOfMap = assumeX;
                rooms[i.toUint()][j.toUint()].yOfMap = assumeY;
                rooms[i.toUint()][j.toUint()].width = roomWidth;
                rooms[i.toUint()][j.toUint()].height = roomHeight;

                for (uint16 k = assumeX.toUint(); k < (assumeX + roomWidth).toUint(); k++) {
                    for (uint16 l = assumeY.toUint(); l < (assumeY + roomHeight).toUint(); l++) {
                        map[k][l] = mapOn;
                    }
                }
            }
        }
    }

    function _createCorridors(Setup memory setup, Room[][] memory rooms, int16[][] memory map) public view {
        for (int16 i = 0; i < setup.roomCountHorizontally; i++) {
            for (int16 j = 0; j < setup.roomCountVertically; j++) {
                Room memory room = rooms[i.toUint()][j.toUint()];

                for (uint16 k = 0; k < room.connectedPointsCount; k++) {
                    Point memory point16 = room.connectedPoints[k];

                    Room memory otherRoom = rooms[point16.x.toUint()][point16.y.toUint()];

                    int8 wall;
                    int8 otherWall;
                    if (room.xOfRooms < otherRoom.xOfRooms) {
                        wall = left;
                        otherWall = right;
                    } else if (room.xOfRooms > otherRoom.xOfRooms) {
                        wall = right;
                        otherWall = left;
                    } else if (room.yOfRooms < otherRoom.yOfRooms) {
                        wall = down;
                        otherWall = up;
                    } else if (room.yOfRooms > otherRoom.yOfRooms) {
                        wall = up;
                        otherWall = down;
                    }

                    _drawCorridor(_getWallPosition(room, wall, map), _getWallPosition(otherRoom, otherWall, map), map);
                }
            }
        }
    }

    function _getWallPosition(Room memory room, int8 wall, int16[][] memory map)
        internal
        view
        returns (Point memory point)
    {
        int16 x;
        int16 y;
        int16 door;
        if (wall == left) {
            y = getUniformInt(room.yOfMap + 1, room.yOfMap + room.height - 2);
            x = room.xOfMap + room.width + 1;
            door = x - 1;
        } else if (wall == right) {
            y = getUniformInt(room.yOfMap + 1, room.yOfMap + room.height - 2);
            x = room.xOfMap - 2;
            door = x + 1;
        } else if (wall == down) {
            x = getUniformInt(room.xOfMap + 1, room.xOfMap + room.width - 2);
            y = room.yOfMap + room.height + 1;
            door = y - 1;
        } else if (wall == up) {
            x = getUniformInt(room.xOfMap + 1, room.xOfMap + room.width - 2);
            y = room.yOfMap - 2;
            door = y + 1;
        }

        if (wall == left || wall == right) {
            map[door.toUint()][x.toUint()] = mapOn;
        } else if (wall == down || wall == up) {
            map[y.toUint()][door.toUint()] = mapOn;
        }

        point.x = x;
        point.y = y;
    }

    function _drawCorridor(Point memory start, Point memory end, int16[][] memory map) internal view {
        int16 xDistance = start.x - end.x;
        xDistance = xDistance < 0 ? -xDistance : xDistance;
        int16 yDistance = start.y - end.y;
        yDistance = yDistance < 0 ? -yDistance : yDistance;

        int16 percent = int16(getItem(uint16(10)));

        int16[2][] memory moves = new int16[2][](3);

        if (xDistance > yDistance) {
            int16 distance = (xDistance * percent) / 100;
            moves[0] = [start.x - end.x < 0 ? left : right, distance];
            moves[1] = [start.y - end.y < 0 ? down : up, yDistance];
            moves[2] = [start.x - end.x < 0 ? left : right, yDistance - distance];
        } else {
            int16 distance = (yDistance * percent) / 100;
            moves[0] = [start.y - end.y < 0 ? down : up, distance];
            moves[1] = [start.x - end.x < 0 ? left : right, xDistance];
            moves[2] = [start.y - end.y < 0 ? down : up, xDistance - distance];
        }

        int16 x = start.x;
        int16 y = start.y;
        map[x.toUint()][y.toUint()] = mapOn;
        int16 length = int16(uint16(moves.length));
        while (length > 0) {
            int16[2] memory move = moves[length.toUint() - 1];
            length--;
            while (move[1] > 0) {
                x += move[0];
                y += move[1];
                map[x.toUint()][y.toUint()] = mapOn;
                move[1]--;
            }
        }
    }
}
