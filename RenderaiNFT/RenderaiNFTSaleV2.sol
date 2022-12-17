// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RenderaiNFTSaleV2 is Ownable {
    address public nft;
    address public token;
    address public dead = 0x000000000000000000000000000000000000dEaD;
    uint256 public price;
    uint256 public tokenAmount;
    uint256 public tokenBurnPercent;

    constructor(address _nft, address _token, uint256 _price, uint256 _tokenAmount, uint256 _tokenBurnPercent) {
        nft = _nft;
        token = _token;
        price = _price;
        tokenAmount = _tokenAmount;
        tokenBurnPercent = _tokenBurnPercent; //default: 2500 (25%)
    }

    function newNft(address _nft) external onlyOwner() {
        nft = _nft;
    }

    function newToken(address _token) external onlyOwner() {
        token = _token;
    }

    function newPrice(uint256 _price) external onlyOwner() {
        price = _price;
    }

    function newTokenAmount(uint256 _tokenAmount) external onlyOwner() {
        tokenAmount = _tokenAmount;
    }

    // Buy for coins

    function buyNft(address recipient, uint256 tokenId) external payable {
        require(msg.value >= price, "Not enough coins sent, check price");
        require(IERC721(nft).balanceOf(address(this)) >= 1, "Not enough NFTs in the market");
        IERC721(nft).safeTransferFrom(address(this), recipient, tokenId);     
    }

    // Buy for tokens

    function buyNft2(address recipient, uint256 tokenId, uint256 tokenPayAmount, uint256 tokenBurnAmount) external {
        require(tokenAmount >= 0, "token amount can not be 0");
        tokenBurnAmount = tokenAmount * tokenBurnPercent / 10000;
        tokenPayAmount = tokenAmount - tokenBurnAmount;
        IERC20(token).transferFrom(msg.sender, address(this), tokenPayAmount);
        IERC20(token).transferFrom(msg.sender, address(dead), tokenBurnAmount);
        require(IERC721(nft).balanceOf(address(this)) >= 1, "Not enough NFTs in the market");
        IERC721(nft).safeTransferFrom(address(this), recipient, tokenId);     
    }

    // Withdraw from the contract

    function withdrawNft(uint256 tokenId) external onlyOwner {
        IERC721(nft).safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function withdrawToken() external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, balance);
    }

    function transferValue(address payable _to) external onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = _to.call{value: amount}("");
        require(success, "Failed to send coins");
    }
}