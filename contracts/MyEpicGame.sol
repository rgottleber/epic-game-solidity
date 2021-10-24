// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./libraries/Base64.sol";

import "hardhat/console.sol";

contract MyEpicGame is ERC721 {
    struct CharacterAttributes {
        uint256 characterIndex;
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
        uint256 level;
    }

    struct BigBoss {
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
    }
    BigBoss public bigBoss;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    CharacterAttributes[] defautCharacters;

    mapping(uint256 => CharacterAttributes) public nftHolderAttributs;

    mapping(address => uint256) public nftHolders;

    constructor(
        string[] memory _characterNames,
        string[] memory _characterImageURIs,
        uint256[] memory _characterHP,
        uint256[] memory _characterAttackDmg,
        string memory _bossName,
        string memory _bossImageURI,
        uint256 _bossHP,
        uint256 _bossAttackDmg
    ) ERC721("DAO Punkz", "PUNKZ") {
        bigBoss = BigBoss({
            name: _bossName,
            imageURI: _bossImageURI,
            hp: _bossHP,
            maxHp: _bossHP,
            attackDamage: _bossAttackDmg
        });
        console.log(
            "Done initializing boss %s w/ HP %s, img %s",
            bigBoss.name,
            bigBoss.hp,
            bigBoss.imageURI
        );

        for (uint256 i = 0; i < _characterNames.length; i += 1) {
            defautCharacters.push(
                CharacterAttributes({
                    characterIndex: i,
                    name: _characterNames[i],
                    imageURI: _characterImageURIs[i],
                    hp: _characterHP[i],
                    maxHp: _characterHP[i],
                    attackDamage: _characterAttackDmg[i],
                    level: 1
                })
            );
            CharacterAttributes memory c = defautCharacters[i];
            console.log(
                "Done initializing %s w/ HP %s, img %s",
                c.name,
                c.hp,
                c.imageURI
            );
        }
        _tokenIds.increment();
    }

    function mintCharacterNFT(uint256 _characterIndex) external {
        uint256 newItemId = _tokenIds.current();

        _safeMint(msg.sender, newItemId);

        nftHolderAttributs[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defautCharacters[_characterIndex].name,
            imageURI: defautCharacters[_characterIndex].imageURI,
            hp: defautCharacters[_characterIndex].hp,
            maxHp: defautCharacters[_characterIndex].hp,
            attackDamage: defautCharacters[_characterIndex].attackDamage,
            level: defautCharacters[_characterIndex].level
        });

        console.log(
            "Minted NFT w/ tokenId %s and characterIndex %s",
            newItemId,
            _characterIndex
        );

        nftHolders[msg.sender] = newItemId;
        _tokenIds.increment();
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        CharacterAttributes memory charAttributes = nftHolderAttributs[
            _tokenId
        ];
        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDmg = Strings.toString(
            charAttributes.attackDamage
        );
        string memory strLevel = Strings.toString(charAttributes.level);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        charAttributes.name,
                        " -- NFT #: ",
                        Strings.toString(_tokenId),
                        '", "description": "This is an NFT that lets people play in the game DAO PUNKZ", "image": "',
                        charAttributes.imageURI,
                        '", "attributes": [ { "trait_type": "Health Points", "value": ',
                        strHp,
                        ', "max_value":',
                        strMaxHp,
                        '}, { "trait_type": "Attack Damage", "value": ',
                        strAttackDmg,
                        '}, { "trait_type": "Level", "value": ',
                        strLevel,
                        "} ]}"
                    )
                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        return output;
    }

    function attackBoss() public {
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributs[
            nftTokenIdOfPlayer
        ];
        console.log(
            "\nPlayer w/ character %s about to attack. Has %s HP and %s AD",
            player.name,
            player.hp,
            player.attackDamage
        );
        console.log(
            "Boss %s has %s HP and %s AD",
            bigBoss.name,
            bigBoss.hp,
            bigBoss.attackDamage
        );
        require(player.hp > 0, "Error: character must have HP to attack boss");
        require(bigBoss.hp > 0, "Error: boss must have HP to attack character");
        if (bigBoss.hp < player.attackDamage) {
            console.log("Boss is dead");
            bigBoss.hp = 0;
            return;
        } else {
            bigBoss.hp -= player.attackDamage;
            console.log("Boss has %s HP left", bigBoss.hp);
        }
        if (player.hp < bigBoss.attackDamage) {
            console.log("Player is dead");
            player.hp = 0;
            return;
        } else {
            player.hp -= bigBoss.attackDamage;
            console.log("Player has %s HP left", player.hp);
        }
        if (player.hp == 0) {
            player
                .imageURI = "http://cliparts.co/cliparts/rTj/KGa/rTjKGajec.gif";
            return;
        }
    }
}
