// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GameData {
    mapping(address => data) private players;

    struct data {
        uint _dungeons_level;
        uint _level;
        uint _exp;
        uint _x;
        uint _y;
        uint _damage;
        uint _attack;
        uint _gold;
        uint _ac;
        string _weapon;
    }

    function save(uint dungeons_level, uint level, uint exp, uint x, uint y, uint damage, uint attack, uint gold, uint ac, string memory weapon) public {
        data storage playerData = players[msg.sender];
        playerData._dungeons_level = dungeons_level;
        playerData._level = level;
        playerData._exp = exp;
        playerData._x = x;
        playerData._y = y;
        playerData._damage = damage;
        playerData._attack = attack;
        playerData._gold = gold;
        playerData._ac = ac;
        playerData._weapon = weapon;
    }

    function getData() public view returns (data memory) {
        return players[msg.sender];
    }
}