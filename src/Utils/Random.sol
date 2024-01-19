// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

library Random {
    function _randomBytes32() internal view returns (bytes32) {
        return keccak256(abi.encode(
            tx.origin,
            block.number,
            block.timestamp,
            block.coinbase,
            address(this).codehash,
            gasleft()
        ));
    }

    function _randomUint256() internal view returns (uint256) {
        return uint256(_randomBytes32());
    }
}