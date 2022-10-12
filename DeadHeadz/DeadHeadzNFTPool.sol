// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DeadHeadzNFTPool is IERC721Receiver, ERC721Holder, Ownable {
    address public nft;
    uint256 public price;
    uint256 public pricepool;

    constructor(address _nft, uint256 _price, uint256 _pricepool) {
        nft = _nft;
        price = _price;
        pricepool = _pricepool;
    }

    function newNft(address _nft) external onlyOwner() {
        nft = _nft;
    }

    function newPrice(uint256 _price) external onlyOwner() {
        price = _price;
    }

    function newPricePool(uint256 _pricepool) external onlyOwner() {
        pricepool = _pricepool;
    }

    function buyNft(address recipient, uint256 tokenId) external payable {
        require(msg.value >= price, "Not enough WDOGE sent, check price");
        require(IERC721(nft).balanceOf(address(this)) >= 1, "Not enough NFTs in the market");
        IERC721(nft).safeTransferFrom(address(this), recipient, tokenId);     
    }

    receive() external payable {}

    function sellNft(address payable _seller, uint256 _amount, uint256 tokenId) external {
        require(IERC721(nft).balanceOf(msg.sender) >= 1, "Not enough NFTs");
        require(IERC721(nft).ownerOf(tokenId) == msg.sender, "Not your NFT");
        IERC721(nft).safeTransferFrom(msg.sender, address(this), tokenId);
        require(address(this).balance >= pricepool, "Not enough WDOGE");
        (bool success, ) = _seller.call{value: _amount}("");
        require(success, "Failed to send WDOGE");
    }

    function withdrawNft(uint256 tokenId) external onlyOwner {
        IERC721(nft).safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function transferValue(address payable _to, uint256 _amount) external onlyOwner {
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send WDOGE");
    }
}