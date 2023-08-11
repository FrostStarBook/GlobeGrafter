// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Constant.sol";

contract SetupManager is Constant{

    Constant private _constant;

    constructor() {
        _constant = Constant(0x26E93649076Db1AcA99939318b6095eCE3905D14);
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
}