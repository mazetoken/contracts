// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OpenDesert is IERC721Receiver, ERC721Holder, Ownable {

    uint16 public feePercent;

    constructor(uint16 _feePercent) {
        require(_feePercent <= 500, "Input value is more than 5%");
        feePercent = _feePercent;
    }

	function newFeePercent (uint16 _feePercent) external onlyOwner {
		feePercent = _feePercent;
	}

	error Unauthorized();
	error ListingNotFound();

	event NewListing(Listing listing);
	event ListingRemoved(Listing listing);
	event ListingBought(address indexed buyer, Listing listing);

	uint256 public saleCounter = 1;

	struct Listing {
		address tokenContract;
		uint256 tokenId;
		address creator;
		uint256 askPrice;
	}

	mapping(uint256 => Listing) public getListing;

    receive() external payable {}

	function list(address tokenContract, uint256 tokenId, uint256 askPrice) external returns (uint256) {
		Listing memory listing = Listing({
			tokenContract: tokenContract,
			tokenId: tokenId,
			askPrice: askPrice,
			creator: msg.sender
		});
		getListing[saleCounter] = listing;
		emit NewListing(listing);
		ERC721(listing.tokenContract).safeTransferFrom(msg.sender, address(this), listing.tokenId);
		return saleCounter++;
	}

	function cancelListing(uint256 listingId) external {
		Listing memory listing = getListing[listingId];
		if (listing.creator != msg.sender) revert Unauthorized();
		emit ListingRemoved(listing);
		ERC721(listing.tokenContract).safeTransferFrom(address(this), msg.sender, listing.tokenId);
        delete getListing[listingId];
	}

	function buyListing(uint256 listingId) external payable {
		Listing memory listing = getListing[listingId];
		if (listing.creator == address(0)) revert ListingNotFound();
		emit ListingBought(msg.sender, listing);
		ERC721(listing.tokenContract).safeTransferFrom(address(this), msg.sender, listing.tokenId);
		delete getListing[listingId];
        uint256 fee = listing.askPrice * feePercent / 10000;
		payable(listing.creator).transfer(listing.askPrice - fee);
        payable(address(this)).transfer(fee);
	}

    function transferValue(address payable _to) external onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = _to.call{value: amount}("");
        require(success, "Failed to send value");
    }
}