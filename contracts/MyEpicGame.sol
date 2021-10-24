// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract MyEpicGame {
    struct CharacterAttributes {
        uint256 characterIndes;
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
        uint256 level;
    }

    CharacterAttributes[] defautCharacters;

    constructor() {
        console.log("This is my game contract. NOICE!");
    }
}
