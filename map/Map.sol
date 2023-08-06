// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {MathUtil} from "./MathUtil.sol";

contract MapConstructor {
    using MathUtil for int16;
    
    function _fillMap(int16 value, int16 width, int16 height) public pure returns (int16[][] memory map_) {
        uint16 _width = (uint16)(width);
        uint16 _height = (uint16)(height);
        
        map_ = new int16[][](_width);
        
        for (uint16 i = 0; i < _width; i++) {
            map_[i] = new int16[](_height);
            for (uint16 j = 0; j < _height; j++) {
                map_[i][j] = value;
            }
        }
    }
}
