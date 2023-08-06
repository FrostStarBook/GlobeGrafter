// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Constant.sol";

contract Rng is Constant {
    
    function getUniformInt(int lowerBound, int upperBound) internal view returns (int result) {
        int max = lowerBound > upperBound ? lowerBound : upperBound;
        int min = lowerBound > upperBound ? upperBound : lowerBound;
        result = (int(getItem(10)) * (max - min + 1)) / 10 + min;
    }
    
    function shuffle(int[] memory array) internal view returns (int[] memory) {
        
        int[] memory result = new int[](array.length);
        
        uint tempIndex = array.length - 1;
        uint[] memory indexRecord = new uint[](array.length);
        for (uint i = 0; i <= tempIndex; i++) {
            indexRecord[i] = i;
        }
        
        uint index;
        while (tempIndex > 0) {
            index = getItem(tempIndex);
            
            result[result.length - 1 - tempIndex] = array[indexRecord[index]];
            
            for (uint i = 0; i < tempIndex; i++) {
                if (i >= index) {
                    indexRecord[i] = indexRecord[i + 1];
                }
            }
            
            tempIndex--;
        }
        result[result.length - 1 - tempIndex] = array[indexRecord[index]];
        
        return result;
        
    }
    
    function getItem(uint length) internal view returns (uint) {
        uint random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % length;
        return random;
    }
    
    function shufflePoint(Point[] memory array) internal view returns (Point[] memory) {
        
        Point[] memory result = new Point[](array.length);
        
        uint tempIndex = array.length - 1;
        uint[] memory indexRecord = new uint[](array.length);
        for (uint i = 0; i <= tempIndex; i++) {
            indexRecord[i] = i;
        }
        
        uint index;
        while (tempIndex > 0) {
            
            index = getItem(tempIndex);
            
            result[result.length - 1 - tempIndex] = array[indexRecord[index]];
            
            for (uint i = 0; i < tempIndex; i++) {
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
