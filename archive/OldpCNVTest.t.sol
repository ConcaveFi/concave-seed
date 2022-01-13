
/// @title Tests
/// @notice pCNV tests
/// @author Anish Agnihotri <contact@anishagnihotri.com>
contract Tests is pCNVTest, pCNVWhitelist {

    address constant FRAX = 0x853d955aCEf822Db058eb8505911ED77F175b99e;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    uint256 constant initial_mCNV_supply = 333000e18;

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



    function xtest_vesting() public {

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

    // percent vested = 1e18 * elapsed / two years

    // amountIn (pTOKENS) * percentVested (ether) / 1e18 (1 whole ether, denominator)


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

    function test_onlyConcave_modifier() public {
        vm.expectRevert("!CONCAVE");
        TOKEN.newRound(
            0x6a0b89fc219e9e72ad683e00d9c152532ec8e5c559600e04160d310936400a00,
            0,
            3e18,
            block.timestamp+1000000
        );

        vm.expectRevert("!CONCAVE");
        TOKEN.reduceRoundDebt(0,0);

        vm.expectRevert("!CONCAVE");
        TOKEN.setRedeemable(address(0));

    }


    function test_claim_all_users() public {
        newRound(
            whitelist_merkleroot,
            whitelist_maxDebt,
            whitelist_rate,
            whitelist_deadline
        );
        for (uint i; i < whitelist_addresses.length; i++) {
            claim_player(i);
        }
        require(IStable(DAI).balanceOf(_treasury) == whitelist_maxDebt_in_stables);
        // claim_player(0);
        // claim_player(1);
    }

    function test_reduceRoundDebt() public {
        newRound(
            whitelist_merkleroot,
            whitelist_maxDebt,
            whitelist_rate,
            whitelist_deadline
        );
        claim_player(0);
        // reduceRoundDebt(1,amounts[0]*1e18+1);
        reduceRoundDebt(1,whitelist_maxDebt - ((amounts[0]*1e18 * 1e18 / whitelist_rate)));
        // vm.expectRevert("!LIQUIDITY");
        claim_player_revert(1);
    }
    function test_reduceRoundDebt_cannot_reduce_already_issued_debt() public {
        newRound(
            whitelist_merkleroot,
            whitelist_maxDebt,
            whitelist_rate,
            whitelist_deadline
        );
        claim_player(0);
        // reduceRoundDebt(1,amounts[0]*1e18+1);
        vm.expectRevert("!MAX_DEBT");
        reduceRoundDebt(1,whitelist_maxDebt);
        // claim_player(1);
    }

    function newRound(
        bytes32 merkleRoot,
        uint256 maxDebt,
        uint256 rate,
        uint256 deadline
    ) public {
        vm.startPrank(_treasury);
        TOKEN.newRound(
            merkleRoot,
            maxDebt,
            rate,
            deadline
        );
        vm.stopPrank();
    }

    function reduceRoundDebt(uint256 roundId, uint256 debt) public {
        vm.startPrank(_treasury);
        TOKEN.reduceRoundDebt(roundId,debt);
        vm.stopPrank();
    }

    function claim_player(uint256 ix) public {
        address addy = whitelist_addresses[ix];
        uint256 maxAmount = amounts[ix]*1e18;
        uint256 amountIn = maxAmount;

        uint256 proofLength;
        for (uint256 i; i < 7; i++) {
            if (proofs[ix][i] != 0x0)  {
                proofLength+=1;
            }
        }
        bytes32[] memory aliceProof = new bytes32[](proofLength);
        // aliceProof[0] = 0x4aa8314bb6a7011f02a48f7fb529a59401ef1cdb4bf593af93a44a8fbf477500;
        for (uint256 i; i < proofLength; i++) {
            aliceProof[i] = bytes32(proofs[ix][i]);
        }
        vm.startPrank(DAI_WHALE);
        IERC20(_DAI).transfer(addy,maxAmount);
        vm.stopPrank();

        // require(IStable(DAI).balanceOf(addy) == maxAmount,"DAIO");
        vm.startPrank(addy);
        IStable(DAI).approve(address(TOKEN),maxAmount);
        TOKEN.mint(
            addy,
            DAI,
            1,
            maxAmount,
            amountIn,
            aliceProof
        );
        vm.stopPrank();
    }

    function claim_player_revert(uint256 ix) public {
        address addy = whitelist_addresses[ix];
        uint256 maxAmount = amounts[ix]*1e18;
        uint256 amountIn = maxAmount;

        uint256 proofLength;
        for (uint256 i; i < 7; i++) {
            if (proofs[ix][i] != 0x0)  {
                proofLength+=1;
            }
        }
        bytes32[] memory aliceProof = new bytes32[](proofLength);
        // aliceProof[0] = 0x4aa8314bb6a7011f02a48f7fb529a59401ef1cdb4bf593af93a44a8fbf477500;
        for (uint256 i; i < proofLength; i++) {
            aliceProof[i] = bytes32(proofs[ix][i]);
        }
        vm.startPrank(DAI_WHALE);
        IERC20(_DAI).transfer(addy,maxAmount);
        vm.stopPrank();

        // require(IStable(DAI).balanceOf(addy) == maxAmount,"DAIO");
        vm.startPrank(addy);
        IStable(DAI).approve(address(TOKEN),maxAmount);
        vm.expectRevert("!LIQUIDITY");
        TOKEN.mint(
            addy,
            DAI,
            1,
            maxAmount,
            amountIn,
            aliceProof
        );
        vm.stopPrank();
    }

    function test_wip_transferTO() public {
        // maxRedemption
        newRound(
            whitelist_merkleroot,
            whitelist_maxDebt,
            whitelist_rate,
            whitelist_deadline
        );
        // for (uint i; i < whitelist_addresses.length; i++) {
        //     claim_player(i);
        // }
        // require(IStable(DAI).balanceOf(_treasury) == whitelist_maxDebt_in_stables);
        claim_player(0);
        claim_player(1);
        uint256 twoYears = 365 days * 2;
        vm.warp(block.timestamp + twoYears);

        MockCNV mCNV = new MockCNV(333000e18);
        vm.startPrank(_treasury);
        TOKEN.setRedeemable(address(mCNV));
        vm.stopPrank();


        emit log_uint(TOKEN.maxRedemption(whitelist_addresses[0]));
        emit log_uint(TOKEN.maxRedemption(whitelist_addresses[1]));
    }

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

    function test_wipi() public {
        emit log("---");
        newRound(
            whitelist_merkleroot,
            whitelist_maxDebt,
            whitelist_rate,
            whitelist_deadline
        );

        claim_player(0);
        // claim_player(1);
        uint256 vestingTime = 365 days * 1;
        vm.warp(block.timestamp + vestingTime);

        MockCNV mCNV = new MockCNV(333000e18);
        vm.startPrank(_treasury);
        TOKEN.setRedeemable(address(mCNV));
        vm.stopPrank();

        // Calculate percentage of two years that has elapsed since contract deployment
        uint256 purchaseVested = elapsed > TWO_YEARS ? 1e18 : 1e18 * elapsed / TWO_YEARS;
        emit log("purchase vested");
        emit log_uint(purchaseVested());
        emit log("pTokensIn");
        emit log_uint("");

        // Calculate totalAmount of pCNV that can be burned minus previous redemptions
        uint256 pTokensIn = participant.purchased * purchaseVested / 1e18 - participant.redeemed;

        // Calculate percentage of supply vested
        uint256 supplyVested = elapsed > TWO_YEARS ? 1e17 : 1e17 * elapsed / TWO_YEARS;

        // Calculate supplyVested percentage of total CNV supply
        uint256 amountVested = CNV.totalSupply * supplyVested / 1e18;

        // Calculate percentage of pCNV that sender is redeeming
        uint256 percentToRedeem = 1e18 * pTokensIn / maxSupply;

        // Calculate the pCNV/CNV redemption rate
        uint256 cnvOut = amountVested * percentToRedeem / 1e18;

        // Increase redeemed amount to account for newly redeemed tokens
        participant.reedeemed += pTokensIn;



    }

    uint256 GENESIS = block.timestamp;
    function percentVested() public view returns (uint256) {
        // Calculate amount of time that has passed since the contract was created
        uint256 elapsed = block.timestamp - GENESIS;

        // Return perc of two years that has elapsed denominated in ether
        // elapsed > 365 days * 2 ? return 1e18 : return 1e18 * elapsed / (365 days * 2);
        if (elapsed > (365 days * 2)) return 1e18;
        return 1e18 * elapsed / (365 days * 2);
    }

    function test_transfers_vesting() public {
        // newRound(
        //     whitelist_merkleroot,
        //     whitelist_maxDebt,
        //     whitelist_rate,
        //     whitelist_deadline
        // );

        // claim_player(0);
        // claim_player(1);

        // address p1 = whitelist_addresses[0];
        // address p2 = whitelist_addresses[1];

        // uint256 a_starting_purchased = TOKEN.balanceOf(p1);
        // uint256 b_starting_purchased = TOKEN.balanceOf(p2);


        // vm.warp(current_block_timestap + 30 days * 12);




    }

    function test_transfers() public {
        // maxRedemption
        newRound(
            whitelist_merkleroot,
            whitelist_maxDebt,
            whitelist_rate,
            whitelist_deadline
        );
        // for (uint i; i < whitelist_addresses.length; i++) {
        //     claim_player(i);
        // }
        // require(IStable(DAI).balanceOf(_treasury) == whitelist_maxDebt_in_stables);

        claim_player(0);
        claim_player(1);

        // uint256 twoYears = 365 days * 2;
        // uint256 twoYears = 30 days;
        // vm.warp(block.timestamp + twoYears);
        uint256 current_block_timestap = block.timestamp;

        MockCNV mCNV = new MockCNV(333000e18);
        vm.startPrank(_treasury);
        TOKEN.setRedeemable(address(mCNV));
        vm.stopPrank();

        address p1 = whitelist_addresses[0];
        address p2 = whitelist_addresses[1];

        uint256 player_1_balance = TOKEN.balanceOf(p1);
        uint256 player_2_balance = TOKEN.balanceOf(p2);

        emit log_uint(player_1_balance/1e18); // 100,000 pCNV balance
        // emit log_uint(player_2_balance/1e18); //  5,000

        emit log("----");

        for (uint256 i; i < 30; i++) {
            vm.warp(current_block_timestap + 30 days * i);
            mCNV.mint(address(this),10000000e18);
            emit log_uint(TOKEN.maxRedemption(whitelist_addresses[0])/1e18);
        }




        // emit log_uint(TOKEN.maxRedemption(whitelist_addresses[0])/1e18); // 912
        // emit log_uint(TOKEN.maxRedemption(whitelist_addresses[1])/1e18); // 456
        // emit log("----");
        // emit log_uint(TOKEN.maxAvailableToRedeem(whitelist_addresses[0])/1e18); // 912
        // emit log_uint(TOKEN.maxAvailableToRedeem(whitelist_addresses[1])/1e18); // 456
        // emit log("----");
        // emit log("----");
        // emit log("----");

    }






























    // @TODO: v,r,s signature
    // function test_vesting() public {
    //     require(ALICE.tokenBalance() == 0,"oh oh alice");
    //     claim_alice();
    //     uint256 amountToClaim = 99e18;
    //     // alice has 33e18 tokens
    //     require(ALICE.tokenBalance() == amountToClaim * 1e18 / 3e18,"alice u naughty");
    //     //
    //     MockCNV mCNV = new MockCNV(100e18);
    //     vm.startPrank(_treasury);
    //     TOKEN.setRedeemable(address(mCNV));
    //     vm.stopPrank();
    //     //
    //     //
    //     // vm.warp(block.timestamp + 365 days);
    //     // emit log_uint(TOKEN.redeemAmountOut(ALICE.tokenBalance()));
    //     //
    //     // uint256 twoYears = 365 days * 2;
    //     // vm.warp(block.timestamp + twoYears);
    //     // emit log_uint(TOKEN.redeemAmountOut(ALICE.tokenBalance()));
    //
    //     uint256 startTime = block.timestamp;
    //
    //     for (uint256 i = 1; i < 25; i++) {
    //         vm.warp(startTime + i*30 days);
    //         emit log_uint(TOKEN.redeemAmountOut(ALICE.tokenBalance())/10e18);
    //     }
    //     //
    //     // ALICE.redeem(ALICE.tokenBalance());
    //     //
    //     // require(mCNV.balanceOf(address(ALICE)) == 10e18, "INCORRECT CNV AMOUNT OUT");
    // }


    // @TODO: v,r,s signature
    // function test_claim_with_permit() public {
    //
    //     address player_address = 0x0132e6a13583DF322a170227a0Fb1E3a1adB284B;
    //     bytes32[] memory aliceProof = new bytes32[](2);
    //     aliceProof[0] = 0x9018731ca14af64a42701f3b89d7c0e4f4a9b9f3254ef9349bfda7dd21bb5410;
    //     aliceProof[1] = 0xaedf37d0aa7b74f119af05a775eed7eaaeb240df9421651c74449500713ea7a0;
    //
    //     uint256 maxAmount = 10e18;
    //     // uint256 amountToClaim = 10e18;
    //     uint256 DAI_AmountIn = maxAmount;
    //
    //     vm.startPrank(DAI_WHALE);
    //     IERC20(DAI).transfer(player_address,1000e18);
    //     vm.stopPrank();
    //
    //     // vm.startPrank(player_address);
    //     // IERC20(DAI).approve(address(TOKEN),1000e18);
    //     // Claim tokens
    //     TOKEN.claimWithPermit(
    //         player_address,
    //         DAI,
    //         1,
    //         maxAmount,
    //         DAI_AmountIn,
    //         aliceProof,
    //         block.timestamp+1000,
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
