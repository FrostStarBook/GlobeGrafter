// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Constant.sol";

contract Rng is Constant {

    uint256 public seed = 0;

    function getUniformInt(
        int16 lowerBound,
        int16 upperBound
    ) public returns (int16 result) {
        int16 max = lowerBound > upperBound ? lowerBound : upperBound;
        int16 min = lowerBound > upperBound ? upperBound : lowerBound;
        // result = (int16(getItem(11)) * (max - min + 1)) / 10 + min;
        return int16(getItem(uint16(max - min + 1)) + uint16(min));
    }
    
    function shuffle(int16[] memory array) internal returns (int16[] memory) {
        int16[] memory result = new int16[](array.length);
        
        uint16 tempIndex = uint16(array.length) - 1;
        uint16[] memory indexRecord = new uint16[](array.length);
        for (uint16 i = 0; i <= tempIndex; i++) {
            indexRecord[i] = i;
        }
        
        uint16 index;
        while (tempIndex > 0) {
            index = getItem(tempIndex);
            
            result[result.length - 1 - tempIndex] = array[indexRecord[index]];
            
            for (uint16 i = 0; i < tempIndex; i++) {
                if (i >= index) {
                    indexRecord[i] = indexRecord[i + 1];
                }
            }
            
            tempIndex--;
        }
        result[result.length - 1 - tempIndex] = array[indexRecord[index]];
        
        return result;
    }
    
    function getItem(uint16 length) public returns (uint16) {
        if (length == 0) {return 0;}
        uint16 random = uint16(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) + seed) % length;
        seed = seed++ % 10;
        return random;
    }
    
    function shufflePoint(Point[] memory array) internal returns (Point[] memory) {
        Point[] memory result = new Point[](array.length);
        
        uint16 tempIndex = uint16(array.length) - 1;
        uint16[] memory indexRecord = new uint16[](array.length);
        for (uint16 i = 0; i <= tempIndex; i++) {
            indexRecord[i] = i;
        }
        
        uint16 index;
        while (tempIndex > 0) {
            index = getItem(tempIndex);
            
            result[result.length - 1 - tempIndex] = array[indexRecord[index]];
            
            for (uint16 i = 0; i < tempIndex; i++) {
                if (i >= index) {
                    indexRecord[i] = indexRecord[i + 1];
                }
            }
            
            tempIndex--;
        }
        result[result.length - 1 - tempIndex] = array[indexRecord[index]];
        
        return result;
    }
}
