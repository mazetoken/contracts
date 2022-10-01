// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract DeadHeadzNFTStake is ERC721Holder, Ownable {
    address public token;
    address public nft;
    uint256 public emission_rate;
    uint256 public price;
    mapping(uint256 => address) public tokenOwnerOf;
    mapping(uint256 => uint256) public tokenStakedAt;

    constructor(address _token, address _nft, uint256 _emission_rate, uint256 _price) {
        token = _token;
        nft = _nft;
        emission_rate = _emission_rate;
        price = _price;
    }

    function newToken(address _token) external onlyOwner() {
        token = _token;
    }

    function newNft(address _nft) external onlyOwner() {
        nft = _nft;
    }

    function newEmissionRate(uint256 _emission_rate) external onlyOwner() {
        emission_rate = _emission_rate;
    }

    function newPrice(uint256 _price) external onlyOwner() {
        price = _price;
    }

    function stake(uint256 tokenId) external payable {
        require(msg.value >= price, "Not enough WDOGE sent, check price");
        IERC721(nft).safeTransferFrom(msg.sender, address(this), tokenId);
        tokenOwnerOf[tokenId] = msg.sender;
        tokenStakedAt[tokenId] = block.timestamp;
    }

    function calculateTokens(uint256 tokenId) public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - tokenStakedAt[tokenId];
        return timeElapsed * emission_rate;
    }

    function unstake(uint256 tokenId) external payable {
        require(tokenOwnerOf[tokenId] == msg.sender, "You can't unstake");
        require(msg.value >= price, "Not enough WDOGE sent, check price");
        require(IERC20(token).balanceOf(address(this)) >= calculateTokens(tokenId));
        IERC20(token).transfer(msg.sender, calculateTokens(tokenId));
        IERC721(nft).transferFrom(address(this), msg.sender, tokenId);
        delete tokenOwnerOf[tokenId];
        delete tokenStakedAt[tokenId];
    }

    function withdrawTokens() external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, balance);
    }

    function transferValue(address payable _to) external onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = _to.call{value: amount}("");
        require(success, "Failed to send WDOGE");
    }
}