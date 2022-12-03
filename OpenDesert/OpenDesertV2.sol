// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OpenDesertV2 is IERC721Receiver, ERC721Holder, Ownable {

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
		uint256 id;
		address tokenContract;
		uint256 tokenId;
		address creator;
		uint256 salePrice;
	}

	mapping(uint256 => Listing) public getListing;

	receive() external payable {}

	function list(address tokenContract, uint256 tokenId, uint256 salePrice) external returns (uint256) {
		Listing memory listing = Listing({
			id: saleCounter,
			tokenContract: tokenContract,
			tokenId: tokenId,
			salePrice: salePrice,
			creator: msg.sender
		});
		getListing[saleCounter] = listing;
		IERC721(listing.tokenContract).safeTransferFrom(msg.sender, address(this), listing.tokenId);
		emit NewListing(listing);
		return saleCounter++;
	}

	function cancelListing(uint256 listingId) external {
		Listing memory listing = getListing[listingId];
		if (listing.creator != msg.sender) revert Unauthorized();
		IERC721(listing.tokenContract).safeTransferFrom(address(this), msg.sender, listing.tokenId);
		emit ListingRemoved(listing);
        delete getListing[listingId];
	}

	function buyListing(uint256 listingId) external payable {
		Listing memory listing = getListing[listingId];
		if (listing.creator == address(0)) revert ListingNotFound();
		require(msg.value >= listing.salePrice, "Not enough coins sent, check salePrice");
		uint256 fee = listing.salePrice * feePercent / 10000;
		payable(listing.creator).transfer(listing.salePrice - fee);
        payable(address(this)).transfer(fee);
		IERC721(listing.tokenContract).safeTransferFrom(address(this), msg.sender, listing.tokenId);
		emit ListingBought(msg.sender, listing);
		delete getListing[listingId];
	}

    function transferValue(address payable _to) external onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = _to.call{value: amount}("");
        require(success, "Failed to send value");
    }
}