// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.8.24;

import "../src/NFTMarketplace.sol";
import "../src/RejectETH.sol";
import "forge-std/Test.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract MockNFT is ERC721 {
    constructor() ERC721("MockNFT", "MNFT") {}

    function mint(address to_, uint256 tokenId_) external {
        _mint(to_, tokenId_);
    }
}

contract NFTMarketplaceTest is Test {
    MockNFT nft;
    NFTMarketplace marketplace;
    address deployer = vm.addr(1);
    address seller = vm.addr(2);
    address buyer = vm.addr(3);
    address randomUser = vm.addr(4);
    uint256 tokenId = 0;
    uint256 price = 1 ether;

    function setUp() public {
        vm.startPrank(deployer);
        marketplace = new NFTMarketplace();
        nft = new MockNFT();
        vm.stopPrank();

        nft.mint(seller, tokenId);
    }

    function testMintNFT() public view {
        address nftOwner = nft.ownerOf(tokenId);
        assert(nftOwner == seller);
    }

    function testListingShouldRevertIfPriceIsZero() public {
        vm.startPrank(seller);
        vm.expectRevert("Price cannot be zero");
        marketplace.listNFT(address(nft), tokenId, 0);
        vm.stopPrank();
    }

    function testListingShouldRevertIfUserIsNotNFTOwner() public {
        uint256 tokenId_ = 1;
        nft.mint(randomUser, tokenId_);

        vm.startPrank(seller);
        vm.expectRevert("You are not the owner of the NFT");
        marketplace.listNFT(address(nft), tokenId_, price);
        vm.stopPrank();
    }

    function testListNFTCorrectly() public {
        vm.startPrank(seller);

        (address sellerBefore,,,) = marketplace.listing(address(nft), tokenId);
        marketplace.listNFT(address(nft), tokenId, price);
        (address sellerAfter,,,) = marketplace.listing(address(nft), tokenId);

        assert(sellerBefore == address(0) && sellerAfter == seller);

        vm.stopPrank();
    }

    function testCancelListShouldRevertIfUserDidNotList() public {
        vm.startPrank(seller);
        marketplace.listNFT(address(nft), tokenId, price);
        vm.stopPrank();

        vm.startPrank(randomUser);
        vm.expectRevert("You did not list this token");
        marketplace.cancelListing(address(nft), tokenId);
        vm.stopPrank();
    }

    function testCancelListCorrectly() public {
        vm.startPrank(seller);
        marketplace.listNFT(address(nft), tokenId, price);
        (address sellerBefore,,,) = marketplace.listing(address(nft), tokenId);
        marketplace.cancelListing(address(nft), tokenId);
        (address sellerAfter,,,) = marketplace.listing(address(nft), tokenId);
        assert(sellerBefore == seller && sellerAfter == address(0));
        vm.stopPrank();
    }

    function testBuyNFTShouldRevertIfNotListed() public {
        vm.startPrank(buyer);
        vm.deal(buyer, price);
        vm.expectRevert("Listing not found");
        marketplace.buyNFT(address(nft), tokenId);
        vm.stopPrank();
    }

    function testBuyNFTShouldRevertIfIncorrectAmount() public {
        vm.startPrank(seller);
        marketplace.listNFT(address(nft), tokenId, price);
        vm.stopPrank();

        uint256 incorrectPrice_ = 2 ether;

        vm.startPrank(buyer);
        vm.deal(buyer, incorrectPrice_);
        vm.expectRevert("Incorrect amount");
        marketplace.buyNFT{value: incorrectPrice_}(address(nft), tokenId);
        vm.stopPrank();
    }

    function testBuyNFTCorrectly() public {
        vm.startPrank(seller);
        marketplace.listNFT(address(nft), tokenId, price);
        nft.approve(address(marketplace), tokenId);
        vm.stopPrank();
        uint256 balanceBefore = seller.balance;

        vm.startPrank(buyer);
        vm.deal(buyer, price);
        (address sellerBefore,,,) = marketplace.listing(address(nft), tokenId);
        marketplace.buyNFT{value: price}(address(nft), tokenId);
        (address sellerAfter,,,) = marketplace.listing(address(nft), tokenId);
        vm.stopPrank();

        uint256 balanceAfter = seller.balance;

        assert(sellerBefore == seller && sellerAfter == address(0));
        assert(nft.ownerOf(tokenId) == buyer);
        assert(balanceAfter == balanceBefore + price);
    }

    function testShouldRevertIfTransferFails() public {
        RejectETH badReceiver = new RejectETH();
        uint256 tokenId_ = 1;
        nft.mint(address(badReceiver), tokenId_);

        vm.startPrank(address(badReceiver));
        marketplace.listNFT(address(nft), tokenId_, price);
        nft.approve(address(marketplace), tokenId_);
        vm.stopPrank();

        vm.startPrank(buyer);
        vm.deal(buyer, price);
        vm.expectRevert("Transfer failed");
        marketplace.buyNFT{value: price}(address(nft), tokenId_);
        vm.stopPrank();
    }
}
