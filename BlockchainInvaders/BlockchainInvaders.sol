// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Blockchain Invaders on Dogechain

contract BlockchainInvaders is ERC20Burnable, Ownable {

    uint8 private _decimals; // 18
    uint256 public _maxSupply; // 60000000000000000000000000 (60 000 000 INVADERS)
    string private _imageURI;
    string private _externalURI;

    address public _token; // defualt: this address
    uint256 public _amount; // default: 1000000000000000000000 (1000 INVADERS)
    uint256 public _price; // default: 50000000000000000 (0.05 WDOGE)

    constructor(uint8 decimals_, uint256 maxSupply_, string memory imageURI_, string memory externalURI_, uint256 amount_, uint256 price_) ERC20("BLOCKCHAIN INVADERS", "INVADERS") {
        _decimals = decimals_;
        _maxSupply = maxSupply_;
        _imageURI = imageURI_;
        _externalURI = externalURI_;
        _amount = amount_;
        _price = price_;
         _mint(msg.sender, maxSupply_);
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function imageURI() public view virtual returns (string memory) {
        return _imageURI;
    }

    function externalURI() public view virtual returns (string memory) {
        return _externalURI;
    }

    function newImageURI(string memory imageURI_) public virtual onlyOwner {
        _imageURI = imageURI_;
    }

    function newExternalURI(string memory externalURI_) public virtual onlyOwner {
        _externalURI = externalURI_;
    }

    // Faucet

    function newToken(address token_) external onlyOwner() {
        _token = token_;
    }

    function newAmount(uint256 amount_) external onlyOwner() {
        _amount = amount_;
    }

    function newPrice(uint256 price_) external onlyOwner() {
        _price = price_;
    }

    mapping(address => uint256) public lockTime;

    function claimToken(address recipient) external payable {
        require(block.timestamp > lockTime[msg.sender], "Please try again later");
        require(msg.value >= _price, "Not enough WDOGE sent, check price");
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "Not enough tokens in the faucet");
        IERC20(_token).transfer(recipient, _amount);
        lockTime[msg.sender] = block.timestamp + 1 hours;      
    }

    function withdrawTokens() external onlyOwner {
        uint256 tokenbalance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(msg.sender, tokenbalance);
    }

    function transferValue(address payable _to) external onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = _to.call{value: amount}("");
        require(success, "Failed to send WDOGE");
    }
}