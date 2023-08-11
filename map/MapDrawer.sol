// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Constant.sol";
import "./MathUtil.sol";
import "./Rng.sol";

contract MapDrawer is Constant{
    Constant private _constant;
    Rng private rng;
    MathUtil private mathUtil;

    constructor() {
        _constant = Constant(0x26E93649076Db1AcA99939318b6095eCE3905D14);
        rng = Rng(0xB19108002A01aECC326F56d9DaF66C7d1b1d7BBc);
        mathUtil = MathUtil(0x935602fd8D2cB4A547D9214d0FD4cb2B53709F4F);
    }

    function _fillMap(int16 value, int16 width, int16 height) public pure returns (int16[][] memory map_) {
        uint16 _width = (uint16)(width);
        uint16 _height = (uint16)(height);

        map_ = new int16[][](_width);

        for (uint16 i = 0; i < _width; i++) {
            map_[i] = new int16[](_height);
            for (uint16 j = 0; j < _height; j++) {
                map_[i][j] = int16(value);
            }
        }
    }



    function _createRooms(int16[][] memory map, Setup memory setup, Room[][] memory rooms) public  {
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

                int16 roomWidth = rng.getUniformInt(setup.roomWidthRange[0], setup.roomWidthRange[1]);
                int16 roomHeight = rng.getUniformInt(setup.roomHeightRange[0], setup.roomHeightRange[1]);

                if (j > 0) {
                    Room memory otherRoom = rooms[mathUtil.toUint(i)][mathUtil.toUint(j) - 1];
                    while (assumeY - otherRoom.yOfMap - otherRoom.height < 3) {
                        assumeY++;
                    }
                }

                if (i > 0) {
                    Room memory otherRoom = rooms[mathUtil.toUint(i) - 1][mathUtil.toUint(j)];
                    while (assumeX - otherRoom.xOfMap - otherRoom.width < 3) {
                        assumeX++;
                    }
                }

                int16 offsetHoricontal = rng.getUniformInt(0, averageRoomWidth - roomWidth) / 2;
                int16 offsetVertical = rng.getUniformInt(0, averageRoomHeight - roomHeight) / 2;

                while (assumeX + offsetHoricontal + roomWidth >= setup.width) {
                    offsetHoricontal > 0 ? offsetHoricontal-- : roomWidth--;
                }

                while (assumeY + offsetVertical + roomHeight >= setup.height) {
                    offsetVertical > 0 ? offsetVertical-- : roomHeight--;
                }

                assumeX += offsetHoricontal;
                assumeY += offsetVertical;

                rooms[mathUtil.toUint(i)][mathUtil.toUint(j)].xOfMap = assumeX;
                rooms[mathUtil.toUint(i)][mathUtil.toUint(j)].yOfMap = assumeY;
                rooms[mathUtil.toUint(i)][mathUtil.toUint(j)].width = roomWidth;
                rooms[mathUtil.toUint(i)][mathUtil.toUint(j)].height = roomHeight;

                for (uint16 k = mathUtil.toUint(assumeX); k < mathUtil.toUint((assumeX + roomWidth)); k++) {
                    for (uint16 l = mathUtil.toUint(assumeY); l < mathUtil.toUint((assumeY + roomHeight)); l++) {
                        map[k][l] = mapOn;
                    }
                }
            }
        }
    }

    function _createCorridors(Setup memory setup, Room[][] memory rooms, int16[][] memory map) public  {
        for (int16 i = 0; i < setup.roomCountHorizontally; i++) {
            for (int16 j = 0; j < setup.roomCountVertically; j++) {
                Room memory room = rooms[mathUtil.toUint(i)][mathUtil.toUint(j)];

                for (uint16 k = 0; k < room.connectedPointsCount; k++) {
                    Point memory point16 = room.connectedPoints[k];

                    Room memory otherRoom = rooms[mathUtil.toUint(point16.x)][mathUtil.toUint(point16.y)];

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

    returns (Point memory point)
    {
        int16 x;
        int16 y;
        int16 door;
        if (wall == left) {
            y = rng.getUniformInt(room.yOfMap + 1, room.yOfMap + room.height - 2);
            x = room.xOfMap + room.width + 1;
            door = x - 1;
        } else if (wall == right) {
            y = rng.getUniformInt(room.yOfMap + 1, room.yOfMap + room.height - 2);
            x = room.xOfMap - 2;
            door = x + 1;
        } else if (wall == down) {
            x = rng.getUniformInt(room.xOfMap + 1, room.xOfMap + room.width - 2);
            y = room.yOfMap + room.height + 1;
            door = y - 1;
        } else if (wall == up) {
            x = rng.getUniformInt(room.xOfMap + 1, room.xOfMap + room.width - 2);
            y = room.yOfMap - 2;
            door = y + 1;
        }

        if (wall == left || wall == right) {
            map[mathUtil.toUint(door)][mathUtil.toUint(y)] = mapOn;
        } else if (wall == down || wall == up) {
            map[mathUtil.toUint(x)][mathUtil.toUint(door)] = mapOn;
        }

        point.x = x;
        point.y = y;
    }

    function _drawCorridor(Point memory start, Point memory end, int16[][] memory map) internal  {
        int16 xDistance = start.x - end.x;
        xDistance = xDistance < 0 ? -xDistance : xDistance;
        int16 yDistance = start.y - end.y;
        yDistance = yDistance < 0 ? -yDistance : yDistance;

        int16 percent = int16(rng.getItem(uint16(10)));

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
        map[mathUtil.toUint(x)][mathUtil.toUint(y)] = mapOn;
        int16 length = int16(uint16(moves.length));
        while (length > 0) {
            int16[2] memory move = moves[mathUtil.toUint(length) - 1];
            length--;
            while (move[1] > 0) {
                x += move[0];
                y += move[1];
                map[mathUtil.toUint(x)][mathUtil.toUint(y)] = mapOn;
                move[1]--;
            }
        }
    }
}