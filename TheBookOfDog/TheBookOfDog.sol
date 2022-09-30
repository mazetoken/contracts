// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TheBookOfDog is ERC20, Ownable {
    uint8 private _decimals;
    uint256 public mintAmount1;
    uint256 public mintAmount2;
    uint256 public postPrice;
    string public sender;
    string public message;
    uint public messageCount = 0;
    address public guest;

    mapping(uint => Message) public messages;

    struct Message {
        uint id;
        string sender;
        string message;
        address guest;
    }

    event MessageCreated(
        uint id,
        string sender,
        string message,
        address guest
    );

    constructor(
        uint8 decimals_,
        uint256 _mintAmount1,
        uint256 _mintAmount2,
        uint256 _postPrice) ERC20("THE BOOK OF DOG", "BODO") {
        _decimals = decimals_;
        mintAmount1 = _mintAmount1;
        mintAmount2 = _mintAmount2;
        postPrice = _postPrice;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function newMintAmount1(uint256 _mintAmount1) external onlyOwner {
        mintAmount1 = _mintAmount1;
    }

    function newMintAmount2(uint256 _mintAmount2) external onlyOwner {
        mintAmount2 = _mintAmount2;
    }

    function newPostPrice(uint256 _postPrice) external onlyOwner() {
        postPrice = _postPrice;
    }

    function sendMessage(string memory _sender, string memory _message) external payable {    
        sender = _sender;
        message = _message;
        guest = msg.sender;
        require(bytes(_sender).length > 0);
        require(bytes(_message).length > 0);
        messageCount ++;
        messages[messageCount] = Message(messageCount, _sender, _message, guest);
        emit MessageCreated(messageCount, _sender, _message, guest);
        require(msg.value >= postPrice, "Not enough WDOGE sent, check postPrice");
        _mint(msg.sender, mintAmount1);
        _mint(address(this), mintAmount2);
    }

    // Transfer WDOGE from contract 

    function transferValue(address payable _to) external onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = _to.call{value: amount}("");
        require(success, "Failed to send WDOGE");
    }

    // Transfer tokens (BODO or accidentally sent) from contract

    function transferTokens(address tokenAddress) external onlyOwner {
        uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).transfer(msg.sender, balance);
    }
}