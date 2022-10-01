// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract DeadHeadzNFT is ERC721, ERC721Enumerable, Ownable {
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    string public uri;
    uint256 public maxSupply;
    uint256 public mintPrice;
    address private _royaltiesReceiver;
    uint256 public royaltiesPercentage;

    constructor(string memory _uri, uint256 _maxSupply, uint256 _mintPrice, address initialRoyaltiesReceiver, uint256 _royaltiesPercentage) ERC721("DEAD HEADZ NFT", "DEADHEADZ") {
        uri = _uri;
        maxSupply = _maxSupply;
        mintPrice = _mintPrice;
        _royaltiesReceiver = initialRoyaltiesReceiver;
        royaltiesPercentage = _royaltiesPercentage;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return string(abi.encodePacked(uri, Strings.toString(tokenId), ".json"));
    }

    function setNewURI(string memory _uri) external onlyOwner {
        uri = _uri;
    }

    function newMintPrice(uint256 _mintPrice) external onlyOwner {
        mintPrice = _mintPrice;
    }

    function royaltiesReceiver() external view returns(address) {
        return _royaltiesReceiver;
    }

    function setRoyaltiesReceiver(address newRoyaltiesReceiver) external onlyOwner {
        require(newRoyaltiesReceiver != _royaltiesReceiver);
        _royaltiesReceiver = newRoyaltiesReceiver;
    }

    function setRoyaltiesPercentage(uint256 _newRoyaltiesPercentage) external onlyOwner {
        require(_newRoyaltiesPercentage <= 4);
        royaltiesPercentage = _newRoyaltiesPercentage;
    }

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (uint256 token, address receiver, uint256 royaltyAmount) {
        uint256 _royalties = (_salePrice * royaltiesPercentage) / 100;
        return (_tokenId, _royaltiesReceiver, _royalties);
    }

    function safeMint(address to) public payable returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        require(_tokenIdCounter.current() <= maxSupply -1, "Max amount minted");
        _tokenIdCounter.increment();
        require(msg.value >= mintPrice, "Not enough WDOGE sent, check price");
        _safeMint(to, tokenId);
        return tokenId;
    }

    function batchMint(address to, uint256 number) external payable {
        for(uint256 i=0; i < number; i++) {
            require(number < 6);
            require(msg.value >= mintPrice * number, "Not enough WDOGE sent, check price");
            safeMint(to);
        }
    }

    // The following functions are overrides required by Solidity

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // Withdraw WDOGE from contract

    function transferValue(address payable _to) external onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = _to.call{value: amount}("");
        require(success, "Failed to send WDOGE");
    }
}