// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./RoomManager.sol";
import "./SetupManager.sol";
import "./Constant.sol";
import "./MapDrawer.sol";

contract Rogue is Constant{
    Constant private _constant;
    SetupManager private setupManager;
    RoomManager private roomManager;
    MapDrawer private mapDrawer;


    constructor() {
        _constant = Constant(0x26E93649076Db1AcA99939318b6095eCE3905D14);
        setupManager = SetupManager(0x0d75325F532c1F7653217E2a1334aFaF060675Cb);
        roomManager = RoomManager(0x162cc7DE6eA7Cd4547c0CB5aDc7cdb35a0c8dBF9);
        mapDrawer = MapDrawer(0x3f1EE0df85726F7DEa1740BC517a63C96238B3ac);
    }

    function create(
        int16 width,
        int16 height,
        int16 roomCountHorizontally,
        int16 roomCountVertically,
        int16[2] memory roomWidthRange,
        int16[2] memory roomHeightRange
    ) public returns (int16[][] memory map, Room[][] memory rooms) {
        Setup memory setup;

        setup = setupManager._initSetup(width, height, roomCountHorizontally, roomCountVertically, roomWidthRange, roomHeightRange);
        map = mapDrawer._fillMap(1, width, height);
        rooms = roomManager._initRooms(setup);

        roomManager._connectRooms(setup, rooms);
        roomManager._connectUnconnectedRooms(setup, rooms);

        mapDrawer._createRooms(map, setup, rooms);
        mapDrawer._createCorridors(setup, rooms, map);
    }
}
