// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract RenderaiNFT is ERC721, ERC721Enumerable, Ownable {
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    string public uri;
    uint256 public maxSupply; // 1001

    constructor(string memory _uri, uint256 _maxSupply) ERC721("RENDERAI NFT", "RENDERAI") {
        uri = _uri;
        maxSupply = _maxSupply;
    }

    function safeMint(address to) public onlyOwner returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        require(_tokenIdCounter.current() <= maxSupply, "Max amount minted");
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        return tokenId;
    }

    function batchMint(address to, uint256 number) external onlyOwner {
        for(uint256 i=0; i < number; i++) {
        safeMint(to);
        }
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        string memory json = Base64.encode(abi.encodePacked('{"name": "RENDERAI NFT #', Strings.toString(_tokenId), '","description": "An unpredictable blockchain machine has opened a portal to a parallel world. Those who entered the portal have changed. They are called RENDERAI.","image": "', string(abi.encodePacked(uri, Strings.toString(_tokenId), ".png")), '","attributes": [{ "trait_type": "Genre","value": "AI artwork" },{ "trait_type": "Model","value": "Stable Diffusion" }]}'));
        string memory jsonUri = string(abi.encodePacked("data:application/json;base64,", json));
        return jsonUri;
    }

    function newURI(string memory _uri) external onlyOwner {
        uri = _uri;
    }

    // The following functions are overrides required by Solidity

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}