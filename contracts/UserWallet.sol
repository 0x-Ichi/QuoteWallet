// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import './IERC721.sol';
import './IERC721Receiver.sol';
import './IERC1155Receiver.sol';
import './IERC1155.sol';
import './IERC20.sol';

contract UserWallet {
    error CallerIsNotSamoi();
    error InvalidProtocol();

    struct TransactionInfo {
        uint256 protocol;
        address target;
        address to;
        uint256 tokenId;
        uint256 id;
        uint256 value;
    }

    address private constant samoiMainWallet = 0xc0B493BAC89DD41B8c6F9da862895145cFCF7f6A; 
    
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

    function transfer(TransactionInfo calldata txInfo) external {
        if (msg.sender != samoiMainWallet) {
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
}