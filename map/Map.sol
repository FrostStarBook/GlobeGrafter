// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {MathUtil} from "./MathUtil.sol";

contract MapConstructor {
    
    using MathUtil for int;
    
    function _fillMap(int value, int width, int height) public pure returns (int[][] memory map_) {
        
        uint _width = width.toUint();
        uint _height = height.toUint();
        
        map_ = new int[][](_width);
        
        for (uint i = 0; i < _width; i++) {
            map_[i] = new int[](_height);
            for (uint j = 0; j < _height; j++) {
                map_[i][j] = value;
            }
        }
        
    }
    
}
