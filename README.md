# 🛒 NFT Marketplace – Minimal On-Chain Marketplace in Solidity

![Solidity](https://img.shields.io/badge/Solidity-0.8.24-blue?style=flat&logo=solidity)
![License](https://img.shields.io/badge/License-LGPL--3.0--only-green?style=flat)
![Tested](https://img.shields.io/badge/Tested%20With-Foundry-orange?style=flat)
![Coverage](https://img.shields.io/badge/Coverage-100%25-brightgreen?style=flat)

---

## 📌 Project Overview

**NFT Marketplace** is a professionally crafted, gas-efficient smart contract project enabling the secure listing, purchasing, and cancellation of ERC721 (NFT) tokens on-chain. It showcases robust Solidity engineering practices including:

- CEI (Checks-Effects-Interactions) pattern
- Non-reentrancy protection via `ReentrancyGuard`
- Access control using OpenZeppelin's `Ownable`
- Extensive testing and revert condition coverage using **Foundry**

This project is designed to be modular, easily extendable, and a solid base for real-world decentralized NFT trading platforms.

---

## 🧱 Core Features

- **NFT Listing**: Owners can list their NFTs with a custom price.
- **NFT Purchase**: Buyers can purchase NFTs using exact ETH payments.
- **Listing Cancellation**: Sellers can cancel listings anytime before a sale.
- **Ownership Check**: Only NFT owners can list or cancel.
- **ETH Transfer Handling**: Robust payment flow with fallback protection.

---

## 📁 File structure

```
├── src/
│   ├── NFTMarketplace.sol     # Marketplace logic
│   └── RejectETH.sol          # Utility contract to simulate ETH transfer reverts
├── test/
│   └── NFTMarketplace.t.sol   # Full test suite using Foundry
```

---

## 🧱 Contract Overview

### Struct: `Listing`

```solidity
struct Listing {
    address seller;
    address nftAddress;
    uint256 tokenId;
    uint256 price;
}
```

---

## 🚀 Features

- ✅ List NFTs with custom price
- 💸 Buy listed NFTs by paying exact ETH amount
- ❌ Cancel listing if still owner
- 🔐 ReentrancyGuard and CEI pattern for safe value transfer
- 🧪 Comprehensive testing including transfer reverts

---

## 🔐 Access Control

- Only the NFT owner can list
- Only the original lister can cancel
- Anyone can buy if price matches listing

---

## ⚠️ Error Handling

- `Price cannot be zero`
- `You are not the owner of the NFT`
- `Listing not found`
- `Incorrect amount`
- `You did not list this token`
- `Transfer failed`

---

## 🧪 Testing

Tested with **Foundry**, including:

- Valid and invalid listings
- Successful and failing purchases
- Owner validation and reverts
- Transfer failure handling using `RejectETH`

Test Coverage: ✅ 100%

---

## 📄 License

Licensed under the **GNU Lesser General Public License v3.0** – see the [`LICENSE`](./LICENSE) file.

---

## 🙋‍♂️ Maintainer

This repository is maintained by an independent Solidity developer focused on clear, secure, and testable smart contract design.
