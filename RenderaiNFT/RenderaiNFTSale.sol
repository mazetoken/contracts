// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RenderaiNFTSale is Ownable {
    address public nft;
    uint256 public price;

    constructor(address _nft, uint256 _price) {
        nft = _nft;
        price = _price;
    }

    function newNft(address _nft) external onlyOwner() {
        nft = _nft;
    }

    function newPrice(uint256 _price) external onlyOwner() {
        price = _price;
    }

    function buyNft(address recipient, uint256 tokenId) external payable {
        require(msg.value >= price, "Not enough WDOGE sent, check price");
        require(IERC721(nft).balanceOf(address(this)) >= 1, "Not enough NFTs in the market");
        IERC721(nft).safeTransferFrom(address(this), recipient, tokenId);     
    }

    function withdrawNft(uint256 tokenId) external onlyOwner {
        IERC721(nft).safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function transferValue(address payable _to) external onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = _to.call{value: amount}("");
        require(success, "Failed to send WDOGE");
    }
}