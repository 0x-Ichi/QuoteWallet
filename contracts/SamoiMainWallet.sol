// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import './IERC721Receiver.sol';
import './IERC1155Receiver.sol';
import './IERC1155.sol';
import './IERC721.sol';
import './IERC20.sol';

interface UserWallet {
    function transfer(TransactionInfo calldata transactionInfo) external;
}

interface Quote {
    function setURI(uint id, string calldata uri) external;

    function mint(uint id, uint amount) external;
}

struct VerifyInfo {
    uint256 protocol;
    address target;
    address wallet;   
    uint256 tokenId;
    uint256 id;
    uint256 value;
}

struct TransactionInfo {
    uint256 protocol;
    address target;
    address to;
    uint256 tokenId;
    uint256 id;
    uint256 value;
}

contract SamoiMainWallet {
    error CallerIsNotSamoi();
    error InvalidProtocol();
    error ZeroAddress();

    event UserWalletAddress(address[] indexed addr);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    address public owner;
    Quote public quote;

    constructor() {
        _transferOwnerShip(msg.sender);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function _checkOwner() internal view {
        if (msg.sender != owner) {
            revert CallerIsNotSamoi();
        } 
    }

    function _transferOwnerShip(address newOwner) internal {
        address oldOwner = owner;
        owner = newOwner;

        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function transferOwnerShip(address newOwner) public onlyOwner {
        if (newOwner == address(0)) {
            revert ZeroAddress();
        }
        _transferOwnerShip(newOwner);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external pure returns (bytes4) {
        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external pure returns (bytes4) {
        return IERC1155Receiver.onERC1155BatchReceived.selector;
    }

    function transfer(
        address walletAddress,
        TransactionInfo calldata txInfo
    ) external onlyOwner {
        UserWallet(walletAddress).transfer(txInfo);
    }

    function transfer(TransactionInfo calldata txInfo) external {
        if (msg.sender != address(this)) {
            revert CallerIsNotSamoi();
        }

        if (txInfo.protocol == 721) {
            IERC721(txInfo.target).safeTransferFrom(
                address(this),
                txInfo.to,
                txInfo.tokenId
            );
        } else if (txInfo.protocol == 1155) {
            IERC1155(txInfo.target).safeTransferFrom(
                address(this),
                txInfo.to,
                txInfo.id,
                txInfo.value,
                ""
            );           
        } else if (txInfo.protocol == 20) {
            IERC20(txInfo.target).transfer(txInfo.to, txInfo.value);
        } else {
            revert InvalidProtocol();
        }
    }

    function verify(VerifyInfo calldata verifyInfo) external view returns (bool) {
        if (verifyInfo.protocol == 721) {
            return 
                IERC721(verifyInfo.target).ownerOf(verifyInfo.tokenId) == 
                verifyInfo.wallet;
        } 
        if (verifyInfo.protocol == 1155) {
            return 
                IERC1155(verifyInfo.target).balanceOf(verifyInfo.wallet, verifyInfo.id) >= 
                verifyInfo.value;
        }  
        if (verifyInfo.protocol == 20) {
            return 
                IERC20(verifyInfo.target).balanceOf(verifyInfo.wallet) >= verifyInfo.value;
        }
        return false;
    }
    
    function setQuote(address _quote) external onlyOwner {
        quote = Quote(_quote);
    }

    function setURI(uint id, string calldata uri) external onlyOwner {
        quote.setURI(id, uri);
    }

    function mint(uint id, uint amount) external onlyOwner {
        quote.mint(id, amount);        
    }
}