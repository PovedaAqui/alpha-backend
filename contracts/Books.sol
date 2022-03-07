// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Bookverse is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    uint public constant MAX_SUPPLY = 100;
    uint public constant PRICE = 0.01 ether;
    uint public constant MAX_PER_MINT = 5;
    
    string public baseTokenURI;


    constructor(string memory baseURI) ERC721("Bookverse", "BOOKS") {
        setBaseURI(baseURI);
    }

    function reserveNFTs() public onlyOwner {
        uint totalMinted = _tokenIdCounter.current();
        require(
            totalMinted.add(10) < MAX_SUPPLY, "Not enough NFTs"
        );
        for (uint i = 0; i < 10; i++) {
            _mintSingleNFT();
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function mintNFTs(uint _count) public payable {
        uint totalMinted = _tokenIdCounter.current();

        require(totalMinted.add(_count) <= MAX_SUPPLY, "Not enough NFTs left!");
        require(_count >0 && _count <= MAX_PER_MINT, "Cannot mint specified number of NFTs.");
        require(msg.value >= PRICE.mul(_count), "Not enough ether to purchase NFTs.");

        for (uint i = 0; i < _count; i++) {
            _mintSingleNFT();
        }
    }
    
    function _mintSingleNFT() private {
        uint newTokenID = _tokenIdCounter.current();
        _safeMint(msg.sender, newTokenID);
        _tokenIdCounter.increment();
    }

    function tokensOfOwner(address _owner) external view returns (uint[] memory) {
        uint tokenCount = balanceOf(_owner);
        uint[] memory tokensId = new uint256[](tokenCount);

        for (uint i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }
    
    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");
        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}