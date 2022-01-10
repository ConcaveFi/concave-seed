// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.7.5;
/// ============ Imports ============

import { DSTest } from "ds-test/test.sol"; // DSTest
import { DAI } from "../mocks/DAI.sol";
import { FRAX } from "../mocks/FRAX.sol";

contract Random_pCNVTest is DSTest {


    function test_wip() public {
        address FRAX = 0x3C0a7EC8c962A85bfB1e4FcfD4bB71C8128dE6f7;
        address DAI = 0x448C56C5eA442908238072eFb7f5Ce58E22C161C;
        address TREASURY = 0xB1DF8b1E93172235eEB8Bbb60D4356f046dff3AF;

        // DAI dai = new DAI(1);
        // dai.mint(0x0132e6a13583DF322a170227a0Fb1E3a1adB284B,10000000e18);
        // require(dai.balanceOf(0x0132e6a13583DF322a170227a0Fb1E3a1adB284B) == 10000000e18);
        //
        // FRAX frax = new FRAX(1);
        // frax.mint(0x0132e6a13583DF322a170227a0Fb1E3a1adB284B,10000000e18);
        // require(frax.balanceOf(0x0132e6a13583DF322a170227a0Fb1E3a1adB284B) == 10000000e18);
    }

    // bytes32[] public hashes;
    //
    // function setUp() public virtual {
    //     address[5] memory transactions = [
    //         // "alice -> bob",
    //         // "bob -> dave",
    //         // "carol -> alice",
    //         // "dave -> bob"
    //         0x0132e6a13583DF322a170227a0Fb1E3a1adB284B,
    //         0x08212DFFb0FAA20073511f87526547cAE00b7a64,
    //         0xB1DF8b1E93172235eEB8Bbb60D4356f046dff3AF,
    //         0xf1A1e46463362C0751Af4Ff46037D1815d66bB4D,
    //         0x109F93893aF4C4b0afC7A9e97B59991260F98313
    //
    //     ];
    //     uint256[5] memory values = [
    //         uint256(10e18),
    //         uint256(20e18),
    //         uint256(30e18),
    //         uint256(40e18),
    //         uint256(60e18)
    //     ];
    //
    //     for (uint i = 0; i < transactions.length; i++) {
    //         hashes.push(keccak256(abi.encodePacked(transactions[i],values[i])));
    //     }
    //
    //     uint n = transactions.length;
    //     uint offset = 0;
    //
    //     while (n > 0) {
    //         for (uint i = 0; i < n - 1; i += 2) {
    //             hashes.push(
    //                 keccak256(
    //                     abi.encodePacked(hashes[offset + i], hashes[offset + i + 1])
    //                 )
    //             );
    //         }
    //         offset += n;
    //         n = n / 2;
    //     }
    // }
    //
    // // Proper Merkle Root
    // // 0xed22b1673d04a64fa29ed896e69fc972e29ca396c2cbf5d400544729c6eb0a20
    //
    // function test_wip_getRoot() public {
    //     // for (uint i; i < hashes.length; i++) {
    //     //     emit log_bytes32(hashes[i]);
    //     // }
    //     emit log_bytes32(hashes[hashes.length - 1]);
    //     // return hashes[hashes.length - 1];
    // }


    // 0xe826e58f53e8fdd8a73454629ce1e846e33eef5d929d5602334ce06e14298eb3
    // 0xe826e58f53e8fdd8a73454629ce1e846e33eef5d929d5602334ce06e14298eb3

    // 0xe826e58f53e8fdd8a73454629ce1e846e33eef5d929d5602334ce06e14298eb3






    // 0x4f10ef13d2889068e1ee8c44679d6f9f954003fc89c03b78a81a4e70542d915e
    // 0x0c8507be0254f1dd0c00949ba01bd75385fcbb6c9d276624c4de628ad12159fe


}
