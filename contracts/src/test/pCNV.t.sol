// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

/// ============ Imports ============

import { pCNVTest } from "./utils/pCNVTest.sol"; // Test scaffolding
import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol"; // OZ: IERC20
import { MockCNV } from "./MockCNV.sol"; // Test scaffolding


/// @title Tests
/// @notice pCNV tests
/// @author Anish Agnihotri <contact@anishagnihotri.com>
contract Tests is pCNVTest {

    address constant FRAX = 0x853d955aCEf822Db058eb8505911ED77F175b99e;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    uint256 constant ratio = 3;

    /// @notice Allow Alice to claim maxAmount tokens
    function test_alice_claim_max_amount() public {
        
        
        uint256 initialTresuryBalance = IERC20(DAI).balanceOf(_treasury);
        // Setup correct proof for Alice
        bytes32[] memory aliceProof = new bytes32[](1);
        aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;

        // Collect Alice balance of tokens before claim
        uint256 alicePreBalance = ALICE.tokenBalance();
        uint256 aliceDAIPreBalance = ALICE.stableBalance();

        uint256 maxAmount = 100e18;
        // uint256 amountToClaim = 10e18;
        uint256 DAI_AmountIn = maxAmount;

        // Claim tokens
        ALICE.mint(
            address(ALICE),
            DAI,
            0,
            maxAmount,
            DAI_AmountIn,
            aliceProof
        );

        // Collect Alice balance of tokens after claim
        uint256 alicePostBalance = ALICE.tokenBalance();
        
        // Assert Alice balance before + 100 tokens = after balance
        // assertEq(alicePostBalance, alicePreBalance + amountToClaim);
        require(
            alicePostBalance == alicePreBalance + DAI_AmountIn * 1e18 / 3e18,
            "PTOKEN_BALANCE_ERROR"
        );

        require(
            ALICE.stableBalance() == aliceDAIPreBalance - DAI_AmountIn,
            "USER_DAI_BALANCE_ERROR"
        );

        require(
            IERC20(DAI).balanceOf(_treasury) == initialTresuryBalance + DAI_AmountIn,
            "TOKEN_DAI_BALANCE_ERROR"
        );
    }

    // // @notice Allow Alice to claim maxAmount tokens
    function test_prevent_claim_if_not_enough_balance() public {
        // Setup correct proof for Alice
        bytes32[] memory aliceProof = new bytes32[](1);
        aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
    
        // Collect Alice balance of tokens before claim
        uint256 alicePreBalance = ALICE.tokenBalance();
        uint256 aliceDAIPreBalance = ALICE.stableBalance();
    
        uint256 maxAmount = 100e18;
        // uint256 amountToClaim = 10e18;
        uint256 amountToClaim = maxAmount;
        vm.startPrank(address(ALICE));
        IERC20(DAI).transfer(address(0),IERC20(DAI).balanceOf(address(ALICE)));
        vm.stopPrank();
        // Claim tokens
        vm.expectRevert("Dai/insufficient-balance");
        ALICE.mint(
            address(ALICE),
            DAI,
            0,
            maxAmount,
            amountToClaim,
            aliceProof
        );
    }
    
    /// @notice Allow Alice to claim maxAmount in multiple claims
    function test_alice_claim_max_amount_in_two_calls() public {
        // Setup correct proof for Alice
        bytes32[] memory aliceProof = new bytes32[](1);
        aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
    
        // Collect Alice balance of tokens before claim
        uint256 alicePreBalance = ALICE.tokenBalance();
        uint256 aliceDAIPreBalance = ALICE.stableBalance();
    
        uint256 maxAmount = 100e18;
        uint256 amountToClaim = 10e18;
    
        ALICE.mint(
            address(ALICE),
            DAI,
            0,
            maxAmount,
            amountToClaim,
            aliceProof
        );
        // require(
        //     TOKEN.claimedAmount(address(ALICE)) == amountToClaim*3e18/1e18,
        //     "DISPLAYS_WRONG_CLAIMED_AMOUNT"
        // );
        // Collect Alice balance of tokens after claim
        uint256 alicePostBalance = ALICE.tokenBalance();
    
        // Assert Alice balance before + 100 tokens = after balance
        // assertEq(alicePostBalance, alicePreBalance + amountToClaim);
        require(
            alicePostBalance == alicePreBalance + amountToClaim*1e18/3e18,
            "TOKEN_BALANCE_ERROR"
        );
        require(
            ALICE.stableBalance() == aliceDAIPreBalance - amountToClaim,
            "USER_DAI_BALANCE_ERROR"
        );
        require(
            IERC20(DAI).balanceOf(_treasury) == amountToClaim,
            "TOKEN_DAI_BALANCE_ERROR"
        );
    
        uint256 amountToClaim2 = 90e18;
    
        // claim next amount
        ALICE.mint(
            address(ALICE),
            DAI,
            0,
            maxAmount,
            amountToClaim2,
            aliceProof
        );
    
        // Collect Alice balance of tokens after claim
        alicePostBalance = ALICE.tokenBalance();
    
        // Assert Alice balance before + 100 tokens = after balance
        // assertEq(alicePostBalance, alicePreBalance + amountToClaim);
        require(
            alicePostBalance == alicePreBalance + amountToClaim * 1e18 / 3e18 + amountToClaim2 * 1e18 / 3e18,
            "TOKEN_BALANCE_ERROR"
        );
        require(
            ALICE.stableBalance() == aliceDAIPreBalance - amountToClaim - amountToClaim2,
            "USER_DAI_BALANCE_ERROR"
        );
        require(
            IERC20(DAI).balanceOf(_treasury) == amountToClaim + amountToClaim2,
            "TOKEN_DAI_BALANCE_ERROR"
        );
    }
    
    
    /// @notice revert alice from claiming more
    function test_alice_revert_more_than_max() public {
        // Setup correct proof for Alice
        bytes32[] memory aliceProof = new bytes32[](1);
        aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
    
        // Collect Alice balance of tokens before claim
        uint256 alicePreBalance = ALICE.tokenBalance();
        uint256 aliceDAIPreBalance = ALICE.stableBalance();
    
        uint256 maxAmount = 100e18;
        // uint256 amountToClaim = 10e18;
        uint256 amountToClaim = maxAmount+1;
    
        // Claim tokens
        vm.expectRevert("!AMOUNT_IN");
        ALICE.mint(
            address(ALICE),
            DAI,
            0,
            maxAmount,
            amountToClaim,
            aliceProof
        );
    }

    /// @notice Prevent Alice from claiming with invalid proof
    function test_alice_revert_invalid_proof() public {
        vm.expectRevert("!PROOF");
        // Setup incorrect proof for Alice
        bytes32[] memory aliceProof = new bytes32[](1);
        aliceProof[0] = 0xc11ae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
    
        uint256 maxAmount = 100e18;
        uint256 amountToClaim = 100e18;
    
        ALICE.mint(
            address(ALICE),
            DAI,
            0,
            maxAmount,
            amountToClaim,
            aliceProof
        );
    }
    
    /// @notice Prevent Alice from claiming with invalid amount
    function test_alice_revert_invalid_max_amount() public {
        vm.expectRevert("!PROOF");
        // Setup correct proof for Alice
        bytes32[] memory aliceProof = new bytes32[](1);
        aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
    
        uint256 maxAmount = 101e18;
        uint256 amountToClaim = 100e18;
    
        // Claim tokens
        ALICE.mint(
            address(ALICE),
            DAI,
            0,
            maxAmount,
            amountToClaim,
            aliceProof
        );
    }
    
    /// @notice Prevent Bob from claiming
    function test_prevent_bob_from_claiming() public {
        vm.expectRevert("!PROOF");
        // Setup correct proof for Alice
        bytes32[] memory aliceProof = new bytes32[](1);
        aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
   
        BOB.mint(
            address(BOB),
            FRAX,
            0,
            100e18,
            100e18,
            aliceProof
        );
    }

    /// @notice Let Bob claim on behalf of Alice
    function test_bob_claim_for_alice() public {
        // Setup correct proof for Alice
        bytes32[] memory aliceProof = new bytes32[](1);
        aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
    
        // Collect Alice balance of tokens before claim
        uint256 alicePreBalance = ALICE.tokenBalance();
        uint256 amountToClaim = 100e18;
        // Claim tokens

        BOB.mint(
            address(ALICE),
            FRAX,
            0,
            100e18,
            100e18,
            aliceProof
        );
    
        // Collect Alice balance of tokens after claim
        uint256 alicePostBalance = ALICE.tokenBalance();
    
        // Assert Alice balance before + 100 tokens = after balance
        require(
            alicePostBalance == alicePreBalance + amountToClaim * 1e18 / 3e18,
            "TOKEN_BALANCE_ERROR"
        );
    }
    
    function test_prevent_unapproved_token() public {
    
        bytes32[] memory aliceProof = new bytes32[](1);
        aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
    
        // Collect Alice balance of tokens before claim
        uint256 alicePreBalance = ALICE.tokenBalance();
    
        vm.expectRevert("!TOKEN_IN");
        // Claim tokens
        BOB.mint(
            // Claiming for Alice
            address(ALICE),
            address(this),
            0,
            100e18,
            100e18,
            aliceProof
        );
    }

    /// @notice cannot test past deadline
    function test_cannot_claim_past_deadline() public {
        // Setup correct proof for Alice
        bytes32[] memory aliceProof = new bytes32[](1);
        aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
    
        // Collect Alice balance of tokens before claim
        uint256 alicePreBalance = ALICE.tokenBalance();
    
        vm.warp(block.timestamp+1000000);
        // Claim tokens
        vm.expectRevert("!DEADLINE");
        BOB.mint(
            address(ALICE),
            FRAX,
            0,
            100e18,
            100e18,
            aliceProof
        );
    }

    /// @notice cannot test past deadline
    function test_cannot_exceed_liquidity() public {
        // Setup correct proof for Alice
        bytes32[] memory aliceProof = new bytes32[](1);
        aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;
    
        // Collect Alice balance of tokens before claim
        uint256 alicePreBalance = ALICE.tokenBalance();

        vm.startPrank(_treasury);
            TOKEN.newRound(
            0x6a0b89fc219e9e72ad683e00d9c152532ec8e5c559600e04160d310936400a00,
            0,
            3e18,
            block.timestamp+1000000
        );
        vm.stopPrank();

        // Claim tokens
        vm.expectRevert("!LIQUIDITY");
        BOB.mint(
            address(ALICE),
            FRAX,
            1,
            100e18,
            100e18,
            aliceProof
        );
    }

    // give bob/alice some pTokens

    // deploy mock cnv

    // setRedeemable()

    // wait some time

    // check that percent vested = time elapsed / 2 years
    
    function test_vesting() public {
        require(ALICE.tokenBalance() == 0,"oh oh alice");
        claim_alice();
        uint256 amountToClaim = 99e18;
        require(ALICE.tokenBalance() == amountToClaim * 1e18 / 3e18,"alice u naughty");

        MockCNV mCNV = new MockCNV(100e18);
        vm.startPrank(_treasury);
        TOKEN.setRedeemable(address(mCNV));
        vm.stopPrank();
        uint256 twoYears = 365 days * 2;
        vm.warp(block.timestamp + twoYears);
        ALICE.redeem(ALICE.tokenBalance());

        require(mCNV.balanceOf(address(ALICE)) == 10e18, "INCORRECT CNV AMOUNT OUT");
    }


    function claim_alice() public {
        bytes32[] memory aliceProof = new bytes32[](1);
        aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;

        uint256 maxAmount = 100e18;
        // uint256 amountToClaim = 10e18;
        uint256 DAI_AmountIn = 99e18;

        // Claim tokens
        ALICE.mint(
            address(ALICE),
            DAI,
            0,
            maxAmount,
            DAI_AmountIn,
            aliceProof
        );
    }

    function test_many_players() public {
        vm.startPrank(_treasury);
        TOKEN.newRound(
            0xed22b1673d04a64fa29ed896e69fc972e29ca396c2cbf5d400544729c6eb0a20,
            1000e18,
            3e18,
            block.timestamp+100
        );
        claim_player();
        claim_player_two();
        claim_player_three();
        claim_player_four();
    }

    function claim_player() public {
        
        address player_address = 0x0132e6a13583DF322a170227a0Fb1E3a1adB284B;
        bytes32[] memory aliceProof = new bytes32[](2);
        aliceProof[0] = 0x9018731ca14af64a42701f3b89d7c0e4f4a9b9f3254ef9349bfda7dd21bb5410;
        aliceProof[1] = 0xaedf37d0aa7b74f119af05a775eed7eaaeb240df9421651c74449500713ea7a0;

        uint256 maxAmount = 10e18;
        // uint256 amountToClaim = 10e18;
        uint256 DAI_AmountIn = maxAmount;

        vm.startPrank(DAI_WHALE);
        IERC20(DAI).transfer(player_address,1000e18);
        vm.stopPrank();

        vm.startPrank(player_address);
        IERC20(DAI).approve(address(TOKEN),1000e18);
        // Claim tokens
        TOKEN.mint(
            player_address,
            DAI,
            1,
            maxAmount,
            DAI_AmountIn,
            aliceProof
        );
    }
    function claim_player_two() public {
        
        address player_address = 0x08212DFFb0FAA20073511f87526547cAE00b7a64;
        bytes32[] memory aliceProof = new bytes32[](2);
        aliceProof[0] = 0x0fee1b61deaa50da332226f1328ba6340fbe217ea046adc832b80fee426fbfc9;
        aliceProof[1] = 0xaedf37d0aa7b74f119af05a775eed7eaaeb240df9421651c74449500713ea7a0;

        uint256 maxAmount = 20e18;
        // uint256 amountToClaim = 10e18;
        uint256 DAI_AmountIn = maxAmount;

        vm.startPrank(DAI_WHALE);
        IERC20(DAI).transfer(player_address,1000e18);
        vm.stopPrank();

        vm.startPrank(player_address);
        IERC20(DAI).approve(address(TOKEN),1000e18);
        // Claim tokens
        TOKEN.mint(
            player_address,
            DAI,
            1,
            maxAmount,
            DAI_AmountIn,
            aliceProof
        );
    }
    function claim_player_three() public {
        
        address player_address = 0xB1DF8b1E93172235eEB8Bbb60D4356f046dff3AF;
        bytes32[] memory aliceProof = new bytes32[](2);
        aliceProof[0] = 0xd1d56c98137faf2f30507c1f006e7c6bc0ba4d0c94bf6c267944f1294ec62a16;
        aliceProof[1] = 0xe826e58f53e8fdd8a73454629ce1e846e33eef5d929d5602334ce06e14298eb3;

        uint256 maxAmount = 30e18;
        // uint256 amountToClaim = 10e18;
        uint256 DAI_AmountIn = maxAmount;

        vm.startPrank(DAI_WHALE);
        IERC20(DAI).transfer(player_address,1000e18);
        vm.stopPrank();

        vm.startPrank(player_address);
        IERC20(DAI).approve(address(TOKEN),1000e18);
        // Claim tokens
        TOKEN.mint(
            player_address,
            DAI,
            1,
            maxAmount,
            DAI_AmountIn,
            aliceProof
        );
    }
    
    function claim_player_four() public {
        
        address player_address = 0xf1A1e46463362C0751Af4Ff46037D1815d66bB4D;
        bytes32[] memory aliceProof = new bytes32[](2);
        aliceProof[0] = 0x3d875c16cd4a4cf82b46cea198ed9d18560bc6f12bec6376c1abb6036d7e80f5;
        aliceProof[1] = 0xe826e58f53e8fdd8a73454629ce1e846e33eef5d929d5602334ce06e14298eb3;

        uint256 maxAmount = 40e18;
        // uint256 amountToClaim = 10e18;
        uint256 DAI_AmountIn = maxAmount;

        vm.startPrank(DAI_WHALE);
        IERC20(DAI).transfer(player_address,1000e18);
        vm.stopPrank();

        vm.startPrank(player_address);
        IERC20(DAI).approve(address(TOKEN),1000e18);
        // Claim tokens
        TOKEN.mint(
            player_address,
            DAI,
            1,
            maxAmount,
            DAI_AmountIn,
            aliceProof
        );
    }
    // function claim_bob() public {
    //     bytes32[] memory aliceProof = new bytes32[](1);
    //     aliceProof[0] = 0xc11ae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;

    //     uint256 maxAmount = 100e18;
    //     uint256 DAI_AmountIn = maxAmount;

    //     // Claim tokens
    //     ALICE.mint(
    //         address(ALICE),
    //         DAI,
    //         0,
    //         maxAmount,
    //         DAI_AmountIn,
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
