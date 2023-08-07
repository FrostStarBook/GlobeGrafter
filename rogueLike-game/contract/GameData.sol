// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./GameAttrProof.sol";

contract GameData {
    mapping(address => data) private players;

    Groth16Verifier private gameAttrProof;

    constructor() {
        gameAttrProof = Groth16Verifier(0x627a72bbE16416Ae722BA05876C5cB2dcb0Dc6BB);
    }

    struct data {
        uint _dungeons_level;
        uint _level;
        uint _exp;
        uint _damage;
        uint _attack;
        uint _gold;
    }

    function verifyAndSave(
        uint[2] memory _pA,
        uint[2][2] memory _pB,
        uint[2] memory _pC,
        uint[1] memory _pubSignals,
        uint dungeons_level, uint level, uint exp, uint damage, uint attack, uint gold
    ) public {
        require(
            gameAttrProof.verifyProof(_pA, _pB, _pC, _pubSignals),
            "Invalid proof"
        );
        save(dungeons_level, level, exp, damage, attack, gold);
    }

    function save(uint dungeons_level, uint level, uint exp, uint damage, uint attack, uint gold) private {
        data storage playerData = players[msg.sender];
        playerData._dungeons_level = dungeons_level;
        playerData._level = level;
        playerData._exp = exp;
        playerData._damage = damage;
        playerData._attack = attack;
        playerData._gold = gold;
    }

    function getData() public view returns (data memory) {
        return players[msg.sender];
    }
}