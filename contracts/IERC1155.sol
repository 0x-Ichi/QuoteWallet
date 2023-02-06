// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IERC1155 {
    function balanceOf(address account, uint256 id) external view returns (uint256);

    function safeTransferFrom(
        address from, 
        address to, 
        uint256 id, 
        uint256 amount, 
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}