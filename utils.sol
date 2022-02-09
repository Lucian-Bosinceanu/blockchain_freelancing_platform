// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

function compareStrings(string memory a, string memory b) returns (bool) {
    return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
}
