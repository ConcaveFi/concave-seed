// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

/// ============ Imports ============

import { MerkleClaimERC20Test } from "./utils/MerkleClaimERC20Test.sol"; // Test scaffolding
import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol"; // OZ: IERC20

/// @title Tests
/// @notice MerkleClaimERC20 tests
/// @author Anish Agnihotri <contact@anishagnihotri.com>
contract Tests is MerkleClaimERC20Test {

    address constant FRAX = 0x853d955aCEf822Db058eb8505911ED77F175b99e;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    uint256 constant ratio = 3;

    /// @notice Allow Alice to claim maxAmount tokens
    function test_alice_claim_max_amount() public {
        // Setup correct proof for Alice
        bytes32[] memory aliceProof = new bytes32[](1);
        aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;

        // Collect Alice balance of tokens before claim
        uint256 alicePreBalance = ALICE.tokenBalance();
        uint256 aliceDAIPreBalance = ALICE.stableBalance();

        uint256 maxAmount = 100e18;
        // uint256 amountToClaim = 10e18;
        uint256 amountToClaim = maxAmount;

        // Claim tokens
        // ALICE.mint(
        //     address(ALICE),
        //     DAI,
        //     0,
        //     maxAmount,
        //     amountToClaim,
        //     aliceProof
        // );

        // // Collect Alice balance of tokens after claim
        // uint256 alicePostBalance = ALICE.tokenBalance();
        //
        // // Assert Alice balance before + 100 tokens = after balance
        // // assertEq(alicePostBalance, alicePreBalance + amountToClaim);
        // require(
        //     alicePostBalance == alicePreBalance + amountToClaim,
        //     "TOKEN_BALANCE_ERROR"
        // );
        // require(
        //     ALICE.stableBalance() == aliceDAIPreBalance - amountToClaim*ratio,
        //     "USER_DAI_BALANCE_ERROR"
        // );
        // require(
        //     IERC20(DAI).balanceOf(_treasury) == amountToClaim*ratio,
        //     "TOKEN_DAI_BALANCE_ERROR"
        // );
    }

    // /// @notice Allow Alice to claim maxAmount tokens
    // function test_prevent_claim_if_not_enough_balance() public {
    //     // Setup correct proof for Alice
    //     bytes32[] memory aliceProof = new bytes32[](1);
    //     aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
    //
    //     // Collect Alice balance of tokens before claim
    //     uint256 alicePreBalance = ALICE.tokenBalance();
    //     uint256 aliceDAIPreBalance = ALICE.stableBalance();
    //
    //     uint256 maxAmount = 100e18;
    //     // uint256 amountToClaim = 10e18;
    //     uint256 amountToClaim = maxAmount;
    //     vm.startPrank(address(ALICE));
    //     IERC20(DAI).transfer(address(0),IERC20(DAI).balanceOf(address(ALICE)));
    //     vm.stopPrank();
    //     // Claim tokens
    //     vm.expectRevert("Dai/insufficient-balance");
    //     ALICE.claim(
    //         address(ALICE),
    //         amountToClaim,
    //         maxAmount,
    //         DAI,
    //         aliceProof
    //     );
    // }
    //
    // /// @notice Allow Alice to claim maxAmount in multiple claims
    // function test_alice_claim_max_amount_in_two_calls() public {
    //     // Setup correct proof for Alice
    //     bytes32[] memory aliceProof = new bytes32[](1);
    //     aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
    //
    //     // Collect Alice balance of tokens before claim
    //     uint256 alicePreBalance = ALICE.tokenBalance();
    //     uint256 aliceDAIPreBalance = ALICE.stableBalance();
    //
    //     uint256 maxAmount = 100e18;
    //     uint256 amountToClaim = 10e18;
    //
    //     // Claim tokens
    //     ALICE.claim(
    //         address(ALICE),
    //         amountToClaim,
    //         maxAmount,
    //         DAI,
    //         aliceProof
    //     );
    //     require(
    //         TOKEN.claimedAmount(address(ALICE)) == amountToClaim,
    //         "DISPLAYS_WRONG_CLAIMED_AMOUNT"
    //     );
    //     // Collect Alice balance of tokens after claim
    //     uint256 alicePostBalance = ALICE.tokenBalance();
    //
    //     // Assert Alice balance before + 100 tokens = after balance
    //     // assertEq(alicePostBalance, alicePreBalance + amountToClaim);
    //     require(
    //         alicePostBalance == alicePreBalance + amountToClaim,
    //         "TOKEN_BALANCE_ERROR"
    //     );
    //     require(
    //         ALICE.stableBalance() == aliceDAIPreBalance - amountToClaim*ratio,
    //         "USER_DAI_BALANCE_ERROR"
    //     );
    //     require(
    //         IERC20(DAI).balanceOf(_treasury) == amountToClaim*ratio,
    //         "TOKEN_DAI_BALANCE_ERROR"
    //     );
    //
    //     uint256 amountToClaim2 = 90e18;
    //
    //     // claim next amount
    //     ALICE.claim(
    //         address(ALICE),
    //         amountToClaim2,
    //         maxAmount,
    //         DAI,
    //         aliceProof
    //     );
    //
    //     // Collect Alice balance of tokens after claim
    //     alicePostBalance = ALICE.tokenBalance();
    //
    //     // Assert Alice balance before + 100 tokens = after balance
    //     // assertEq(alicePostBalance, alicePreBalance + amountToClaim);
    //     require(
    //         alicePostBalance == alicePreBalance + amountToClaim + amountToClaim2,
    //         "TOKEN_BALANCE_ERROR"
    //     );
    //     require(
    //         ALICE.stableBalance() == aliceDAIPreBalance - amountToClaim*ratio - amountToClaim2*ratio,
    //         "USER_DAI_BALANCE_ERROR"
    //     );
    //     require(
    //         IERC20(DAI).balanceOf(_treasury) == amountToClaim*ratio+amountToClaim2*ratio,
    //         "TOKEN_DAI_BALANCE_ERROR"
    //     );
    // }
    //
    //
    // /// @notice revert alice from claiming more
    // function test_alice_revert_more_than_max() public {
    //     // Setup correct proof for Alice
    //     bytes32[] memory aliceProof = new bytes32[](1);
    //     aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
    //
    //     // Collect Alice balance of tokens before claim
    //     uint256 alicePreBalance = ALICE.tokenBalance();
    //     uint256 aliceDAIPreBalance = ALICE.stableBalance();
    //
    //     uint256 maxAmount = 100e18;
    //     // uint256 amountToClaim = 10e18;
    //     uint256 amountToClaim = maxAmount+1;
    //
    //     // Claim tokens
    //     vm.expectRevert("EXCEEDS_AMOUNT");
    //     ALICE.claim(
    //         address(ALICE),
    //         amountToClaim,
    //         maxAmount,
    //         DAI,
    //         aliceProof
    //     );
    // }
    // /// @notice Prevent Alice from claiming with invalid proof
    // function test_alice_revert_invalid_proof() public {
    //     vm.expectRevert("NOT_IN_MERKLE");
    //     // Setup incorrect proof for Alice
    //     bytes32[] memory aliceProof = new bytes32[](1);
    //     aliceProof[0] = 0xc11ae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
    //
    //     uint256 maxAmount = 100e18;
    //     uint256 amountToClaim = 100e18;
    //
    //     ALICE.claim(
    //         address(ALICE),
    //         amountToClaim,
    //         maxAmount,
    //         DAI,
    //         aliceProof
    //     );
    // }
    // /// @notice Prevent Alice from claiming with invalid amount
    // function test_alice_revert_invalid_max_amount() public {
    //     vm.expectRevert("NOT_IN_MERKLE");
    //     // Setup correct proof for Alice
    //     bytes32[] memory aliceProof = new bytes32[](1);
    //     aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
    //
    //     uint256 maxAmount = 101e18;
    //     uint256 amountToClaim = 100e18;
    //
    //     // Claim tokens
    //     ALICE.claim(
    //         address(ALICE),
    //         amountToClaim,
    //         maxAmount,
    //         DAI,
    //         aliceProof
    //     );
    // }
    // /// @notice Prevent Bob from claiming
    // function test_prevent_bob_from_claiming() public {
    //     vm.expectRevert("NOT_IN_MERKLE");
    //     // Setup correct proof for Alice
    //     bytes32[] memory aliceProof = new bytes32[](1);
    //     aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
    //
    //     // Claim tokens
    //     BOB.claim(
    //         // Claiming for Bob
    //         address(BOB),
    //         100e18,
    //         100e18,
    //         DAI,
    //         aliceProof
    //     );
    // }
    // /// @notice Let Bob claim on behalf of Alice
    // function test_bob_claim_for_alice() public {
    //     // Setup correct proof for Alice
    //     bytes32[] memory aliceProof = new bytes32[](1);
    //     aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
    //
    //     // Collect Alice balance of tokens before claim
    //     uint256 alicePreBalance = ALICE.tokenBalance();
    //
    //     // Claim tokens
    //     BOB.claim(
    //         // Claiming for Alice
    //         address(ALICE),
    //         100e18,
    //         100e18,
    //         FRAX,
    //         aliceProof
    //     );
    //
    //     // Collect Alice balance of tokens after claim
    //     uint256 alicePostBalance = ALICE.tokenBalance();
    //
    //     // Assert Alice balance before + 100 tokens = after balance
    //     assertEq(alicePostBalance, alicePreBalance + 100e18);
    // }
    //
    // function test_prevent_unapproved_token() public {
    //
    //     bytes32[] memory aliceProof = new bytes32[](1);
    //     aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
    //
    //     // Collect Alice balance of tokens before claim
    //     uint256 alicePreBalance = ALICE.tokenBalance();
    //
    //     vm.expectRevert("NOT_APPROVED_TOKEN");
    //     // Claim tokens
    //     BOB.claim(
    //         // Claiming for Alice
    //         address(ALICE),
    //         100e18,
    //         100e18,
    //         address(this),
    //         aliceProof
    //     );
    // }

}





// /// @notice Allow Alice to claim 100e18 tokens
// function testAliceClaim() public {
//   // Setup correct proof for Alice
//   bytes32[] memory aliceProof = new bytes32[](1);
//   aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
//
//   // Collect Alice balance of tokens before claim
//   uint256 alicePreBalance = ALICE.tokenBalance();
//
//   // Claim tokens
//   ALICE.claim(
//     // Claiming for Alice
//     address(ALICE),
//     // 100 tokens
//     100e18,
//     // With valid proof
//     aliceProof
//   );
//
//   // Collect Alice balance of tokens after claim
//   uint256 alicePostBalance = ALICE.tokenBalance();
//
//   // Assert Alice balance before + 100 tokens = after balance
//   assertEq(alicePostBalance, alicePreBalance + 100e18);
// }
//
// /// @notice Prevent Alice from claiming twice
// function testFailAliceClaimTwice() public {
//   // Setup correct proof for Alice
//   bytes32[] memory aliceProof = new bytes32[](1);
//   aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
//
//   // Claim tokens
//   ALICE.claim(
//     // Claiming for Alice
//     address(ALICE),
//     // 100 tokens
//     100e18,
//     // With valid proof
//     aliceProof
//   );
//
//   // Claim tokens again
//   ALICE.claim(
//     // Claiming for Alice
//     address(ALICE),
//     // 100 tokens
//     100e18,
//     // With valid proof
//     aliceProof
//   );
// }
//
// /// @notice Prevent Alice from claiming with invalid proof
// function testFailAliceClaimInvalidProof() public {
//   // Setup incorrect proof for Alice
//   bytes32[] memory aliceProof = new bytes32[](1);
//   aliceProof[0] = 0xc11ae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
//
//   // Claim tokens
//   ALICE.claim(
//     // Claiming for Alice
//     address(ALICE),
//     // 100 tokens
//     100e18,
//     // With valid proof
//     aliceProof
//   );
// }
//
// /// @notice Prevent Alice from claiming with invalid amount
// function testFailAliceClaimInvalidAmount() public {
//   // Setup correct proof for Alice
//   bytes32[] memory aliceProof = new bytes32[](1);
//   aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
//
//   // Claim tokens
//   ALICE.claim(
//     // Claiming for Alice
//     address(ALICE),
//     // Incorrect: 1000 tokens
//     1000e18,
//     // With valid proof (for 100 tokens)
//     aliceProof
//   );
// }
//
// /// @notice Prevent Bob from claiming
// function testFailBobClaim() public {
//   // Setup correct proof for Alice
//   bytes32[] memory aliceProof = new bytes32[](1);
//   aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
//
//   // Claim tokens
//   BOB.claim(
//     // Claiming for Bob
//     address(BOB),
//     // 100 tokens
//     100e18,
//     // With valid proof (for Alice)
//     aliceProof
//   );
// }
//
// /// @notice Let Bob claim on behalf of Alice
// function testBobClaimForAlice() public {
//   // Setup correct proof for Alice
//   bytes32[] memory aliceProof = new bytes32[](1);
//   aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
//
//   // Collect Alice balance of tokens before claim
//   uint256 alicePreBalance = ALICE.tokenBalance();
//
//   // Claim tokens
//   BOB.claim(
//     // Claiming for Alice
//     address(ALICE),
//     // 100 tokens
//     100e18,
//     // With valid proof (for Alice)
//     aliceProof
//   );
//
//   // Collect Alice balance of tokens after claim
//   uint256 alicePostBalance = ALICE.tokenBalance();
//
//   // Assert Alice balance before + 100 tokens = after balance
//   assertEq(alicePostBalance, alicePreBalance + 100e18);
// }
