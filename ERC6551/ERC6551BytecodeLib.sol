// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library ERC6551BytecodeLib {
    function getCreationCode(
        address implementation_,
        uint256 chainId_,
        address tokenContract_,
        uint256 tokenId_,
        uint256 salt_
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(hex"", implementation_, hex"", abi.encode(salt_, chainId_, tokenContract_, tokenId_));
    }
}
