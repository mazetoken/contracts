// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract DarkLegendsDemons is ERC721, ERC721Enumerable, Ownable {
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    string public uri;
    uint256 public maxSupply; // 601

    constructor(string memory _uri, uint256 _maxSupply) ERC721("DARK LEGENDS DEMONS", "LEGENDS") {
        uri = _uri;
        maxSupply = _maxSupply;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return string(abi.encodePacked(uri, Strings.toString(tokenId), ".json"));
    }

    function setNewURI(string memory _uri) external onlyOwner {
        uri = _uri;
    }

    function safeMint(address to) public onlyOwner returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        require(_tokenIdCounter.current() <= maxSupply -1, "Max amount minted");
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        return tokenId;
    }

    function batchMint(address to, uint256 number) external onlyOwner {
        for(uint256 i=0; i < number; i++) {
            safeMint(to);
        }
    }

    // The following functions are overrides required by Solidity

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function safeBatchTransferFrom(address _from, address _to, uint256[] memory _tokenIds) external {
    }
    
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}