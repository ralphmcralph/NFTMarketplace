// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.8.24;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract NFTMarketplace is Ownable, ReentrancyGuard {
    // === Structs ===
    struct Listing {
        address seller; // NFT Seller
        address nftAddress; // NFT collection address
        uint256 tokenId; // NFT TokenId
        uint256 price; // Price
    }

    // === Mappings ===
    // mapping(uint => MyStruct) public items;
    mapping(address => mapping(uint256 => Listing)) public listing;

    // === Events ===
    // event SomethingHappened(...);
    event NFTListed(address indexed seller, address indexed nftAddress, uint256 indexed tokenId, uint256 price);
    event NFTCancelled(address indexed seller, address indexed nftAddress, uint256 indexed tokenId);
    event NFTBought(address indexed buyer, address indexed seller, address indexed nftAddress, uint256 tokenId);

    // === Constructor ===
    constructor() Ownable(msg.sender) {}

    // === External functions ===

    // List NFTs
    function listNFT(address nftAddress_, uint256 tokenId_, uint256 price_) external nonReentrant {
        require(price_ > 0, "Price cannot be zero");
        address owner_ = IERC721(nftAddress_).ownerOf(tokenId_);
        require(owner_ == msg.sender, "You are not the owner of the NFT");

        Listing memory listing_ =
            Listing({seller: msg.sender, nftAddress: nftAddress_, tokenId: tokenId_, price: price_});

        listing[nftAddress_][tokenId_] = listing_;

        emit NFTListed(msg.sender, nftAddress_, tokenId_, price_);
    }

    // Buy NFTs
    function buyNFT(address nftAddress_, uint256 tokenId_) external payable nonReentrant {
        Listing memory listing_ = listing[nftAddress_][tokenId_];
        require(listing_.price > 0, "Listing not found");
        require(msg.value == listing_.price, "Incorrect amount");

        delete listing[nftAddress_][tokenId_];

        IERC721(nftAddress_).safeTransferFrom(listing_.seller, msg.sender, listing_.tokenId);

        (bool success,) = listing_.seller.call{value: msg.value}("");
        require(success, "Transfer failed");

        emit NFTBought(msg.sender, listing_.seller, nftAddress_, tokenId_);
    }

    // Cancel listing
    function cancelListing(address nftAddress_, uint256 tokenId_) external nonReentrant {
        Listing memory listing_ = listing[nftAddress_][tokenId_];

        require(listing_.seller == msg.sender, "You did not list this token");

        delete listing[nftAddress_][tokenId_];

        emit NFTCancelled(msg.sender, nftAddress_, tokenId_);
    }
}
