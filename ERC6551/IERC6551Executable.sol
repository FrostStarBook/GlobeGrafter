// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC6551Executable {
    function execute(
        address to,
        uint256 value,
        bytes calldata data,
        uint256 operation
    ) external payable returns (bytes memory);
}
