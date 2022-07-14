// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import { IERC721MintableBurnable } from '../interfaces/IERC721MintableBurnable.sol';
import { NftLinker } from './NftLinker.sol';

contract NftLinkerMintBurn is NftLinker {
    error TransferFailed();
    error TransferFromFailed();

    address public immutable operatorAddress;

    constructor(address gatewayAddress_, address operatorAddress_) NftLinker(gatewayAddress_) {
        operatorAddress = operatorAddress_;
    }

    function _giveNft(address to, uint256 tokenId) internal override {
        (bool success, bytes memory returnData) = operatorAddress.call(
            abi.encodeWithSelector(IERC721MintableBurnable.mint.selector, to, tokenId)
        );
        bool transferred = success && (returnData.length == uint256(0) || abi.decode(returnData, (bool)));

        if (!transferred || operatorAddress.code.length == 0) revert TransferFailed();
    }

    function _takeNft(
        address, /*from*/
        uint256 tokenId
    ) internal override {
        (bool success, bytes memory returnData) = operatorAddress.call(
            abi.encodeWithSelector(IERC721MintableBurnable.burn.selector, tokenId)
        );
        bool transferred = success && (returnData.length == uint256(0) || abi.decode(returnData, (bool)));

        if (!transferred || operatorAddress.code.length == 0) revert TransferFromFailed();
    }
}
