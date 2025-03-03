// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract RealEstate is ERC721URIStorage {
    uint256 private tokenCounter;

    constructor() ERC721("Real Estate", "REAL") {
        tokenCounter = 0;
    }

    function mint(string memory tokenURI) public returns (uint256) {
        tokenCounter += 1;
        uint256 newItemId = tokenCounter;
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    function totalSupply() public view returns (uint256) {
        return tokenCounter;
    }
}
