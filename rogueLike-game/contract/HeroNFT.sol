// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./GameAttrProof.sol";
import "./ERC721MetaData.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract HeroNFT is
Initializable,
UUPSUpgradeable,
ERC721Upgradeable,
ERC721URIStorageUpgradeable,
OwnableUpgradeable {

    uint256 public totalSupply;

    mapping(address => Attributes) private players;

    Groth16Verifier private gameAttrProof;
    ERC721MetaData private meta;

    function initialize() public initializer {
        __ERC721_init("Hero NFT", "H");
        __ERC721URIStorage_init();
        __UUPSUpgradeable_init();
        __Ownable_init();
        gameAttrProof = Groth16Verifier(0x627a72bbE16416Ae722BA05876C5cB2dcb0Dc6BB);
        meta = ERC721MetaData(0xa896d76635b0552Fd60074E9AB44d323cA58178A);
    }

    struct Attributes {
        uint _dungeons_level;
        uint _level;
        uint _exp;
        uint _damage;
        uint _attack;
        uint _gold;
    }

    function verifyAndMint(
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
        saveAttributes(dungeons_level, level, exp, damage, attack, gold);
        mint(dungeons_level, level, exp, damage, attack, gold);

    }

    function saveAttributes(uint dungeons_level, uint level, uint exp, uint damage, uint attack, uint gold) private {
        Attributes storage playerData = players[msg.sender];
        playerData._dungeons_level = dungeons_level;
        playerData._level = level;
        playerData._exp = exp;
        playerData._damage = damage;
        playerData._attack = attack;
        playerData._gold = gold;
    }

    function getAttributes() public view returns (Attributes memory) {
        return players[msg.sender];
    }

    event NFTMinted(
        uint256 tokenId,
        uint _dungeons_level,
        uint _level,
        uint _exp,
        uint _damage,
        uint _attack,
        uint _gold
    );

    function mint(uint dungeons_level, uint level, uint exp, uint damage, uint attack, uint gold) private {
        uint256 tokenId = totalSupply + 1;

        _safeMint(msg.sender, tokenId);

        if (exp > 5000) {
            _setTokenURI(tokenId, tokenURI(tokenId, meta.getImg(random(1, 4))));
        } else {
            _setTokenURI(tokenId, tokenURI(tokenId, meta.getImg(random(4, 8))));
        }

        totalSupply++;

        emit NFTMinted(
            tokenId,
            dungeons_level,
            level,
            exp,
            damage,
            attack,
            gold
        );
    }

    function random(uint min, uint max) private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, msg.sender))) % (max - min) + min;
    }

    function tokenURI(
        uint256 tokenId,
        string memory images
    ) internal view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        Attributes memory attributes = players[msg.sender];

        string memory json = string(
            abi.encodePacked(
                "{",
                '"name": "Hero NFT #',
                Strings.toString(tokenId),
                '",',
                '"attributes": [',
                '{ "trait_type": "_dungeons_level", "value": ',
                Strings.toString(attributes._dungeons_level),
                " },",
                '{ "trait_type": "_level", "value": ',
                Strings.toString(attributes._level),
                " },",
                '{ "trait_type": "_exp", "value": ',
                Strings.toString(attributes._exp),
                " },",
                '{ "trait_type": "_damage", "value": ',
                Strings.toString(attributes._damage),
                " },",
                '{ "trait_type": "_attack", "value": ',
                Strings.toString(attributes._attack),
                " },",
                '{ "trait_type": "_gold", "value": ',
                Strings.toString(attributes._gold),
                " }",
                "],",
                '"image": "',
                images,
                '",',
                '"background_color": "FFFFFF"',
                "}"
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json))));
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function _burn(uint256 id) internal override(ERC721Upgradeable, ERC721URIStorageUpgradeable) {
        super._burn(id);
    }

    function tokenURI(
        uint256 id
    ) public view override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (string memory) {
        return super.tokenURI(id);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (bool) {
    }
}