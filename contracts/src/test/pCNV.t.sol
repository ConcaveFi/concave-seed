// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

/// ============ Imports ============

import { DSTest } from "ds-test/test.sol"; // DSTest
import "./utils/VM.sol";
// import { pCNVTest } from "./utils/pCNVTest.sol"; // Test scaffolding
import { pCNVWhitelist } from "./utils/pCNVWhitelist.sol";
import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol"; // OZ: IERC20
import { MockCNV } from "./MockCNV.sol"; // Test scaffolding
import { pCNV } from "../pCNV_v2.sol"; // Test scaffolding


interface IStable {


    // --- Auth ---
  function wards() external returns ( uint256 );

  function rely(address guy) external;

  function deny(address guy) external;

    // --- Token ---
  function transfer(address dst, uint wad) external returns (bool);

  function transferFrom(address src, address dst, uint wad) external returns (bool);

  function mint(address usr, uint wad) external;

  function burn(address usr, uint wad) external;

  function approve(address usr, uint wad) external returns (bool);

    // --- Alias ---
  function push(address usr, uint wad) external;

  function pull(address usr, uint wad) external;

  function move(address src, address dst, uint wad) external;

    // --- Approve by signature ---
  function permit(address holder, address spender, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s) external;


  function balanceOf(address account) external view returns (uint256);
}



contract pCNVTest is DSTest, pCNVWhitelist {

    address immutable FRAX = 0x853d955aCEf822Db058eb8505911ED77F175b99e;
    address immutable DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address immutable treasury = 0x0877497b4A2674e818234a691bc4d2Dffcf76e73;
	// address treasury = address(100);
	uint256 immutable MAX_SUPPLY = 33_000_000 * 10 ** 18;

    bytes32 immutable merkleRoot = whitelist_merkleroot;
	
    uint256 immutable rate = whitelist_rate;

    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);


    pCNV PCNV;
    MockCNV CNV;

    function setUp() public virtual {
        PCNV = new pCNV();
		PCNV.setTreasury(treasury);
        CNV = new MockCNV(333000e18);
    }

    /* ---------------------------------------------------------------------- */
    /*                              ONLY CONCAVE                              */
    /* ---------------------------------------------------------------------- */

    /// @notice onlyConcave may set treasury, else fails with "!CONCAVE". Verifies if value is set correctly.
    function test_setTreasury() public {
        vm.startPrank(treasury);
        PCNV.setTreasury(address(0));
        vm.stopPrank();
        
        require(PCNV.treasury() == address(0));

        vm.expectRevert("!CONCAVE");
        PCNV.setTreasury(treasury);

        require(PCNV.treasury() == address(0));
    }

    /// @notice onlyConcave may setRedeemable, else fails with "!CONCAVE". Verifies if value is set correctly.
    function test_setRedeemable() public {
        vm.expectRevert("!CONCAVE");
        PCNV.setRedeemable(address(CNV));

        require(address(PCNV.CNV()) == address(0));
        require(PCNV.redeemable() == false);

        vm.startPrank(treasury);
        PCNV.setRedeemable(address(CNV));
        vm.stopPrank();

        require(address(PCNV.CNV()) == address(CNV));
        require(PCNV.redeemable() == true);

    }

	// @notice onlyConcave may setRound, else fails with "!CONCAVE". Verifies if value is set correctly.
    function test_setRound() public {
        vm.expectRevert("!CONCAVE");
        PCNV.setRound(merkleRoot,rate);

        require(PCNV.merkleRoot() == 0x0000000000000000000000000000000000000000000000000000000000000000);
        require(PCNV.rate() == 0);

		vm.startPrank(treasury);
        PCNV.setRound(merkleRoot,rate);
        vm.stopPrank();

		require(PCNV.merkleRoot() == merkleRoot);
        require(PCNV.rate() == rate);

    }

	/// @notice manage with address(0) should burn tokens
	function test_manage_wip() public {
		uint256 maxSupply = PCNV.maxSupply();

		uint256 amount = 1e18;

		vm.expectRevert("!CONCAVE");
        PCNV.manage(address(0),amount);

		require(PCNV.maxSupply() == maxSupply);

		vm.startPrank(treasury);
		PCNV.manage(address(0),amount);
		vm.stopPrank();

		require(PCNV.maxSupply() == maxSupply - amount);

		// require(amount - amount*2 < 10,"BLAMO");
		vm.startPrank(treasury);
		vm.expectRevert("!SUPPLY");
		PCNV.manage(address(0),MAX_SUPPLY+1);
		vm.stopPrank();

		require(PCNV.maxSupply() == maxSupply - amount);

		// emit log("----");
		// uint256 maxAmountOut = 55e18;
		// uint256 ratio = 1e18 * 333e18 / 333e18;
		// emit log_uint((maxAmountOut * ratio / 1e18));
		// emit log_uint(maxAmountOut);



	}

	// function 


	/* ---------------------------------------------------------------------- */
    /*                          PUBLIC LOGIC: mint()                          */
    /* ---------------------------------------------------------------------- */

	/// @notice fails with "!AMOUNT" when minting more than maxSupply
	function test_mint_should_fail_with_amount() public {
		setRound(merkleRoot,rate);

		uint256 userIndex = 0;
		address userAddress = getUserAddress(userIndex);
		uint256 userMaxAmount = getUserMaxAmount(userIndex);
		bytes32[] memory proof = getUserProof(userIndex);

		uint256 amountIn = userMaxAmount*333000e18;

        vm.startPrank(userAddress);
		vm.expectRevert("!AMOUNT");
        PCNV.mint(
            userAddress,
            DAI,
            userMaxAmount,
            amountIn,
            proof
        );
        vm.stopPrank();
	}


	/// @notice fails with "!TOKEN_IN" when `tokenIn` is not FRAX or DAI
	function test_mint_should_fail_with_tokenIn() public {
		setRound(merkleRoot,rate);

		uint256 userIndex = 0;
		address userAddress = getUserAddress(userIndex);
		uint256 userMaxAmount = getUserMaxAmount(userIndex);
		bytes32[] memory proof = getUserProof(userIndex);

		uint256 amountIn = userMaxAmount;

		vm.expectRevert("!TOKEN_IN");
        PCNV.mint(
            userAddress,
            address(0),
            userMaxAmount,
            amountIn,
            proof
        );
	}

	/// @notice fails with "!PROOF" when `proof` is not correct user's proof
	function test_mint_should_fail_with_proof_on_wrong_proof() public {
		setRound(merkleRoot,rate);

		uint256 userIndex = 0;
		address userAddress = getUserAddress(userIndex);
		uint256 userMaxAmount = getUserMaxAmount(userIndex);
		// get proof for incorrect user
		bytes32[] memory proof = getUserProof(1);

		uint256 amountIn = userMaxAmount;

		vm.startPrank(userAddress);
		vm.expectRevert("!PROOF");
        PCNV.mint(
            userAddress,
            DAI,
            userMaxAmount,
            amountIn,
            proof
        );
		vm.stopPrank();
	}

	/// @notice fails with "!PROOF" when `to` is not correct
	function test_mint_should_fail_with_proof_on_wrong_to() public {
		setRound(merkleRoot,rate);

		uint256 userIndex = 0;
		address userAddress = getUserAddress(userIndex);
		uint256 userMaxAmount = getUserMaxAmount(userIndex);
		bytes32[] memory proof = getUserProof(userIndex);

		uint256 amountIn = userMaxAmount;

		vm.startPrank(userAddress);
		vm.expectRevert("!PROOF");
        PCNV.mint(
            address(0), // enter incorrect "to" address
            DAI,
            userMaxAmount,
            amountIn,
            proof
        );
		vm.stopPrank();
	}

	/// @notice fails with "!PROOF" when `maxAmount` is not correct
	function test_mint_should_fail_with_proof_on_wrong_amount() public {
		setRound(merkleRoot,rate);

        uint256 userIndex = 0;
		address userAddress = getUserAddress(userIndex);
		uint256 userMaxAmount = getUserMaxAmount(userIndex);
		bytes32[] memory proof = getUserProof(userIndex);

		uint256 amountIn = userMaxAmount+1;
		
        vm.startPrank(userAddress);
		vm.expectRevert("!PROOF");
		PCNV.mint(
            userAddress,
            DAI,
            userMaxAmount+1, // send incorrect maxAmount
            amountIn,
            proof
        );
        vm.stopPrank();
		
	}

	/// @notice fails with "!AMOUNT_IN" when `amountIn` is larger than `maxAmount`
	function test_mint_should_fal_with_amountin() public { 
        setRound(merkleRoot,rate);

        uint256 userIndex = 0;
		address userAddress = getUserAddress(userIndex);
		uint256 userMaxAmount = getUserMaxAmount(userIndex);
		bytes32[] memory proof = getUserProof(userIndex);

		uint256 amountIn = userMaxAmount+1;
		
        vm.startPrank(userAddress);
		vm.expectRevert("!AMOUNT_IN");
		PCNV.mint(
            userAddress,
            DAI,
            userMaxAmount,
            amountIn,
            proof
        );
        vm.stopPrank();

	}

	/// @notice fails with "Dai/insufficient-balance" if user does not have enough DAI
	function test_mint_should_fail_if_insufficient_DAI() public {
		setRound(merkleRoot,rate);

        uint256 userIndex = 0;
		address userAddress = getUserAddress(userIndex);
		uint256 userMaxAmount = getUserMaxAmount(userIndex);
		bytes32[] memory proof = getUserProof(userIndex);

		uint256 amountIn = userMaxAmount;

		require(IERC20(DAI).balanceOf(userAddress) < amountIn);
		
        vm.startPrank(userAddress);
		vm.expectRevert("Dai/insufficient-balance");
		PCNV.mint(
            userAddress,
            DAI,
            userMaxAmount,
            amountIn,
            proof
        );
        vm.stopPrank();
	}

	/// @notice fails with "ERC20: transfer amount exceeds balance" if user does not have enough FRAX
	function test_mint_should_fail_if_insufficient_FRAX() public {
		setRound(merkleRoot,rate);

        uint256 userIndex = 0;
		address userAddress = getUserAddress(userIndex);
		uint256 userMaxAmount = getUserMaxAmount(userIndex);
		bytes32[] memory proof = getUserProof(userIndex);

		uint256 amountIn = userMaxAmount;

		require(IERC20(FRAX).balanceOf(userAddress) < amountIn);
		
        vm.startPrank(userAddress);
		vm.expectRevert("ERC20: transfer amount exceeds balance");
		PCNV.mint(
            userAddress,
            FRAX,
            userMaxAmount,
            amountIn,
            proof
        );
        vm.stopPrank();
	}


	/// @notice fails with "Dai/insufficient-allowance" if user has not approved enough DAI
	function test_mint_should_fail_if_DAI_not_approved() public {
		setRound(merkleRoot,rate);

        uint256 userIndex = 0;
		address userAddress = getUserAddress(userIndex);
		uint256 userMaxAmount = getUserMaxAmount(userIndex);
		bytes32[] memory proof = getUserProof(userIndex);

		uint256 amountIn = userMaxAmount;

		deposit_DAI(userAddress,amountIn);

		require(IERC20(DAI).balanceOf(userAddress) >= amountIn);
		
        vm.startPrank(userAddress);
		vm.expectRevert("Dai/insufficient-allowance");
		PCNV.mint(
            userAddress,
            DAI,
            userMaxAmount,
            amountIn,
            proof
        );
        vm.stopPrank();
	}

	/// @notice fails with "ERC20: transfer amount exceeds allowance" if user has not approved enough FRAX
	function test_mint_should_fail_if_FRAX_not_approved() public {
		setRound(merkleRoot,rate);

        uint256 userIndex = 0;
		address userAddress = getUserAddress(userIndex);
		uint256 userMaxAmount = getUserMaxAmount(userIndex);
		bytes32[] memory proof = getUserProof(userIndex);

		uint256 amountIn = userMaxAmount;

		deposit_FRAX(userAddress,amountIn);

		require(IERC20(FRAX).balanceOf(userAddress) >= amountIn);
		
        vm.startPrank(userAddress);
		vm.expectRevert("ERC20: transfer amount exceeds allowance");
		PCNV.mint(
            userAddress,
            FRAX,
            userMaxAmount,
            amountIn,
            proof
        );
        vm.stopPrank();
	}


	/// @notice mint of maxAmount succeeds, checks totalSupply, totalMinted, user pCNV balance, user DAI balance, treasury DAI balance
	function test_mint_DAI_maxAmount_passes() public {
		setRound(merkleRoot,rate);

		uint256 initialTreasuryStableBalance  = IERC20(DAI).balanceOf(treasury);

        uint256 userIndex = 0;
		address userAddress = getUserAddress(userIndex);
		uint256 userMaxAmount = getUserMaxAmount(userIndex);
		bytes32[] memory proof = getUserProof(userIndex);

		uint256 amountIn = userMaxAmount;

		deposit_DAI(userAddress,amountIn);
		

		uint256 initialUserStableBalance = IERC20(DAI).balanceOf(userAddress);
		require(initialUserStableBalance >= amountIn);
		
        vm.startPrank(userAddress);
		IERC20(DAI).approve(address(PCNV),amountIn);
		PCNV.mint(
            userAddress,
            DAI,
            userMaxAmount,
            amountIn,
            proof
        );
        vm.stopPrank();

		uint256 amountOut = amountIn * 1e18 / rate;

		require(PCNV.totalSupply() == amountOut,"TESTFAIL:1");
		require(PCNV.totalMinted() == amountOut,"TESTFAIL:2");
		require(PCNV.balanceOf(userAddress) == amountOut,"TESTFAIL:3");
		require(IERC20(DAI).balanceOf(userAddress) == initialUserStableBalance - amountIn,"TESTFAIL:4");
		require(IERC20(DAI).balanceOf(treasury) == initialTreasuryStableBalance + amountIn,"TESTFAIL:4");
	}

	/// @notice mint of maxAmount succeeds, checks totalSupply, totalMinted, user pCNV balance, user FRAX balance, treasury FRAX balance
	function test_mint_FRAX_maxAmount_passes() public {
		setRound(merkleRoot,rate);

		uint256 initialTreasuryStableBalance  = IERC20(FRAX).balanceOf(treasury);

        uint256 userIndex = 0;
		address userAddress = getUserAddress(userIndex);
		uint256 userMaxAmount = getUserMaxAmount(userIndex);
		bytes32[] memory proof = getUserProof(userIndex);

		uint256 amountIn = userMaxAmount;

		deposit_FRAX(userAddress,amountIn);
		

		uint256 initialUserStableBalance = IERC20(FRAX).balanceOf(userAddress);
		require(initialUserStableBalance >= amountIn);
		
        vm.startPrank(userAddress);
		IERC20(FRAX).approve(address(PCNV),amountIn);
		PCNV.mint(
            userAddress,
            FRAX,
            userMaxAmount,
            amountIn,
            proof
        );
        vm.stopPrank();

		uint256 amountOut = amountIn * 1e18 / rate;

		require(PCNV.totalSupply() == amountOut,"TESTFAIL:1");
		require(PCNV.totalMinted() == amountOut,"TESTFAIL:2");
		require(PCNV.balanceOf(userAddress) == amountOut,"TESTFAIL:3");
		require(IERC20(FRAX).balanceOf(userAddress) == initialUserStableBalance - amountIn,"TESTFAIL:4");
		require(IERC20(FRAX).balanceOf(treasury) == initialTreasuryStableBalance + amountIn,"TESTFAIL:4");
	}

	/// @notice user may mint up to maxAmount in multiple mint calls
	function test_mint_in_multiple_amounts() public {
		setRound(merkleRoot,rate);

		uint256 initialTreasuryStableBalance  = IERC20(FRAX).balanceOf(treasury);

        uint256 userIndex = 0;
		address userAddress = getUserAddress(userIndex);
		uint256 userMaxAmount = getUserMaxAmount(userIndex);
		bytes32[] memory proof = getUserProof(userIndex);

		uint256 amountIn = userMaxAmount;

		deposit_FRAX(userAddress,amountIn);
		

		uint256 initialUserStableBalance = IERC20(FRAX).balanceOf(userAddress);
		require(initialUserStableBalance >= amountIn);
		
        vm.startPrank(userAddress);
		IERC20(FRAX).approve(address(PCNV),amountIn);


		PCNV.mint(
            userAddress,
            FRAX,
            userMaxAmount,
            amountIn - 10e18,
            proof
        );

		PCNV.mint(
            userAddress,
            FRAX,
            userMaxAmount,
            10e18,
            proof
        );

        vm.stopPrank();

		uint256 amountOut = amountIn * 1e18 / rate;

		require(PCNV.totalSupply() == amountOut,"TESTFAIL:1");
		require(PCNV.totalMinted() == amountOut,"TESTFAIL:2");
		require(PCNV.balanceOf(userAddress) == amountOut,"TESTFAIL:3");
		require(IERC20(FRAX).balanceOf(userAddress) == initialUserStableBalance - amountIn,"TESTFAIL:4");
		require(IERC20(FRAX).balanceOf(treasury) == initialTreasuryStableBalance + amountIn,"TESTFAIL:5");
	}




	/// @notice if second mint exceeds `maxAmount`, call should revert with "!AMOUNT"
	function test_second_mint_should_fail_if_amount_in_would_exceed_maxamount() public {
		setRound(merkleRoot,rate);

		uint256 initialTreasuryStableBalance  = IERC20(FRAX).balanceOf(treasury);

        uint256 userIndex = 0;
		address userAddress = getUserAddress(userIndex);
		uint256 userMaxAmount = getUserMaxAmount(userIndex);
		bytes32[] memory proof = getUserProof(userIndex);

		uint256 amountIn = userMaxAmount;

		deposit_FRAX(userAddress,amountIn);
		

		uint256 initialUserStableBalance = IERC20(FRAX).balanceOf(userAddress);
		require(initialUserStableBalance >= amountIn);
		
        vm.startPrank(userAddress);
		IERC20(FRAX).approve(address(PCNV),amountIn);


		PCNV.mint(
            userAddress,
            FRAX,
            userMaxAmount,
            amountIn - 10e18,
            proof
        );
		vm.expectRevert("!AMOUNT_IN");
		PCNV.mint(
            userAddress,
            FRAX,
            userMaxAmount,
            10e18+1,
            proof
        );

        vm.stopPrank();
	}

	/// @notice mint all users
	function test_mint_all_users() public {
		setRound(merkleRoot,rate);
		uint256 treasuryBalance = IERC20(FRAX).balanceOf(treasury);
		uint256 totalSupply;
		uint256 totalMinted;
		for (uint256 i; i < whitelist_addresses.length; i++) {
			//Collect current users address, max donation for seed, and merkle proof
			uint256 userIndex = i;
			address userAddress = getUserAddress(userIndex);
			uint256 userMaxAmount = getUserMaxAmount(userIndex);
			bytes32[] memory proof = getUserProof(userIndex);

			uint256 initialUserStableBalance = IERC20(FRAX).balanceOf(userAddress);

			uint256 amountIn = userMaxAmount;
			deposit_FRAX(userAddress,amountIn);
			vm.startPrank(userAddress);
			IERC20(FRAX).approve(address(PCNV),amountIn);
			PCNV.mint(
				userAddress,
				FRAX,
				userMaxAmount,
				amountIn,
				proof
			);
			vm.stopPrank();
			uint256 amountOut = amountIn * 1e18 / rate;
			totalSupply+=amountOut;
			treasuryBalance+=amountIn;
			// require(PCNV.totalSupply() == totalSupply,"TESTFAIL:1");
			// require(PCNV.totalMinted() == totalSupply,"TESTFAIL:2");
			// require(PCNV.balanceOf(userAddress) == amountOut,"TESTFAIL:3");
			// require(IERC20(FRAX).balanceOf(userAddress) == initialUserStableBalance - amountIn,"TESTFAIL:4");
			// require(IERC20(FRAX).balanceOf(treasury) == treasuryBalance,"TESTFAIL:5");
		}
		// require(IERC20(FRAX).balanceOf(treasury) == whitelist_maxDebt_in_stables,"TESTFAIL:6");
		// require(PCNV.totalMinted() == PCNV.totalSupply(),"TESTFAIL:6");
		// require(PCNV.totalMinted() == whitelist_maxDebt,"TESTFAIL:6");
	}
            

	/* ---------------------------------------------------------------------- */
    /*                         PUBLIC LOGIC: redeem()                         */
    /* ---------------------------------------------------------------------- */

	function test_sanity_check() public {
		setRound(merkleRoot,rate);
		        
		setRedeemable();
		claim_user(0);
		

		uint256 initialTimestamp = block.timestamp;
		emit log_uint(PCNV.balanceOf(getUserAddress(0))/1e18);
		for (uint256 i; i < 30; i++) {
			vm.warp(initialTimestamp+(30 days * i));
			emit log_uint(PCNV.maxRedeemAmountIn(getUserAddress(0))/1e18);
		}
		// 100000 initial balance
		// amount of tokens available to redeem in the next 24 months
		// 0
		// 4109
		// 8219
		// 12328
		// 16438
		// 20547
		// 24657
		// 28767
		// 32876
		// 36986
		// 41095
		// 45205
		// 49315
		// 53424
		// 57534
		// 61643
		// 65753
		// 69863
		// 73972
		// 78082
		// 82191
		// 86301
		// 90410
		// 94520
		// 98630
		// 100000
		// 100000
		// 100000
		// 100000
		// 100000
		emit log_uint(CNV.totalSupply()/1e18);
		for (uint256 i; i < 30; i++) {
			vm.warp(initialTimestamp+(30 days * i));
			emit log_uint(PCNV.amountVested()/1e18);
			// emit log_uint(CNV.totalSupply());
		}
		// 333,000 initial CNV totalSupply
		// amount of CNV supply claimable by pCNV holders in the next 24 months
		// 0
		// 1368
		// 2736
		// 4105
		// 5473
		// 6842
		// 8210
		// 9579
		// 10947
		// 12316
		// 13684
		// 15053
		// 16421
		// 17790
		// 19158
		// 20527
		// 21895
		// 23264
		// 24632
		// 26001
		// 27369
		// 28738
		// 30106
		// 31475
		// 32843
		// 33300
		// 33300
		// 33300
		// 33300
		// 33300
	}

	/// @notice when a user redeems an `amountIn` - the following should hold:
	/// - redeemable amount should decrease by `amountIn`
	/// - pCNV balance of user should decrease by `amountIn`
	/// - pCNV totalSupply should decrease by `amountIn`
	/// - CNV total supply should increase by `amountOut`
	/// - CNV balance of user should increase by `amountOut`
	function test_redeem_redeemable_amount_reduces_after_redemption_wip() public {
		// setup
		setRound(merkleRoot,rate);
		setRedeemable();
		claim_user(0);
		address userAddress = getUserAddress(0);
		uint256 initialTimestamp = block.timestamp;

		uint256 initialPCNVBalance = PCNV.balanceOf(userAddress);
		uint256 initialPCNVSupply = PCNV.totalSupply();
		uint256 initialCNVBalance = CNV.balanceOf(userAddress);
		uint256 initialCNVSupply = CNV.totalSupply();


		// we warp to future `time1`
		uint256 time = 30 days * 12;
		vm.warp(initialTimestamp+time);

		// check the redeemable amount
		uint256 amountIn = PCNV.maxRedeemAmountIn(userAddress);
		uint256 amountOut = PCNV.maxRedeemAmountOut(userAddress);

		// redeemable amount must be larger than 0
		require(amountIn > 0,"ERR:1");

		// user redeems full amount
		redeemMax(0);

		// - redeemable amount should decrease by `amountIn`
		require(PCNV.maxRedeemAmountIn(userAddress) == 0,"ERR:2");
		// - pCNV balance of user should decrease by `amountIn`
		require(PCNV.balanceOf(userAddress) == initialPCNVBalance - amountIn,"ERR:3");
		// - pCNV totalSupply should decrease by `amountIn`
		require(PCNV.totalSupply() == initialPCNVSupply - amountIn,"ERR:4");

		//  - CNV total supply should increase by `amountOut`
		require(CNV.totalSupply() == initialCNVSupply + amountOut, "ERR:5");
		// - CNV balance of user should increase by `amountOut`
		require(CNV.balanceOf(userAddress) == initialCNVBalance + amountOut, "ERR:6");
	}

	// TODO manage function test
	// TODO calculat TWO_YEARS in seconds
	// TODO coverage for redeemable

	function test_redeem_redeemable_values_2() public {
		// Round is Set
		// setRound(merkleRoot,rate);
		// // CONCAVE sets redeemable
		// setRedeemable();
		// // User #0 claims their pCNV
		// claim_user(0);
		// address userAddress = getUserAddress(0);
		// // we get current pCNV balance (10,000)
		// uint pcnvBalance = PCNV.balanceOf(userAddress);
		// // at current time, 0 tokens should be vestable
		// require(0 == PCNV.redeemAmountIn(userAddress));
		// 
		// for (uint256 i; i < 30; i++) {
		// vm.warp(initialTimestamp+(30 days * i));
		// 	// the amount vested should be equal to expect
		// 	// require(
		// 	// 	PCNV.redeemAmountIn(userAddress) == pcnvBalance * purchaseVested() / 1e18,
		// 	// );
		// }
		// // uint256 initialTimestamp = block.timestamp;
		// // vm.warp(initialTimestamp+(30 days * 25));
		// // emit log_uint(PCNV.amountVested()/1e18);
	}

	function test_tata() public {
		emit log_uint(365 days * 2);
	}

	function test_transfer_wip() public {

		uint256 initialTimestamp = block.timestamp;

		setRound(merkleRoot,rate);
		setRedeemable();

		address player1 = getUserAddress(0);
		address player2 = getUserAddress(1);

		claim_user(0);
		claim_user(1);

		uint256 player1Balance = PCNV.balanceOf(player1);
		uint256 player2Balance = PCNV.balanceOf(player2);

		require(player1Balance == amounts[0]*1e18,"ERR:1");
		require(player2Balance == amounts[1]*1e18,"ERR:2");

		uint256 time = 365 days;
		vm.warp(initialTimestamp+time);
		// redeem 10% of player 1
		// redeem 20% of player 2
		uint player1Redeemed = player1Balance/10;
		uint player2Redeemed = player2Balance/20;
		redeem(0,player1Redeemed);
		redeem(1,player2Redeemed);

		uint256 a_starting_redeemable = PCNV.maxRedeemAmountIn(player1);
		uint256 b_starting_redeemable = PCNV.maxRedeemAmountIn(player2);

		require(a_starting_redeemable/player1Balance == b_starting_redeemable/player2Balance, "ERR:3");

		uint256 transferAmount = player1Balance/2;

		vm.startPrank(player1);
		PCNV.transfer(player2,transferAmount);
		vm.stopPrank();

		uint256 a_ending_redeemable = PCNV.maxRedeemAmountIn(player1);
		uint256 b_ending_redeemable = PCNV.maxRedeemAmountIn(player2);

		require(PCNV.balanceOf(player1) == player1Balance - player1Redeemed - transferAmount);
		require(PCNV.balanceOf(player2) == player2Balance - player2Redeemed + transferAmount);

		require(
			a_starting_redeemable + b_starting_redeemable == a_ending_redeemable + b_ending_redeemable,
			"NOT SAFU!"
		);
	}


	

	/**
	TEST STORIES
	 // Contract should distribute proper amount to each holder after 2 year
	 // Sender+Receiver should have redemption ratio adjusted after transfer
	*/
		function test_ratio_calibration_logic() public {
		// address from = getUserAddress(0);
		// address to = getUserAddress(1);


		// setRound(merkleRoot,rate);
		// setRedeemable();
		// uint256 time = 30 days;
		// vm.warp(initialTimestamp+time);
		// claim_user(userAddress);
		// uint256 initialTimestamp = block.timestamp;

    // function _beforeTransfer(
    //     address from,
    //     address to,
    //     uint256 amount
    // ) internal {
 

    //     // calculate amount to adjust redeem amounts by
    //     uint256 adjustedAmount = amount * fromParticipant.redeemed / fromParticipant.purchased;

    //     // reduce "from" redeemed by amount * "from" redeem purchase ratio
    //     fromParticipant.redeemed -= adjustedAmount;

    //     // reduce "from" purchased amount by the amount being sent
    //     fromParticipant.purchased -= amount;

    //     // increase "to" redeemed by amount * "from" redeem purchase ratio
    //     toParticipant.redeemed += adjustedAmount;

    //     // increase "to" purchased by amount received
    //     toParticipant.purchased += amount;
    // }
		}
	



    /* ---------------------------------------------------------------------- */
    /*                              HELPERS                                   */
    /* ---------------------------------------------------------------------- */

// 	we cannot mint more than pCNV supplyusre aaddress and amount must be in merkle root
// 	user cannot mint  more than  they are allowed (no double minting)
// only msg.sender can mint for their whitelist address (i.e no pranking)
	
	

	function redeemMax(uint256 ix) public {
		
		vm.startPrank(getUserAddress(ix));
		PCNV.redeem(
			getUserAddress(ix),
			PCNV.maxRedeemAmountIn(getUserAddress(ix))
		);
		vm.stopPrank();
	}

	function redeem(uint256 ix, uint256 amount) public {
		
		vm.startPrank(getUserAddress(ix));
		PCNV.redeem(getUserAddress(ix),amount);
		vm.stopPrank();
	}
	

	function claim_user(uint256 userIndex) public {
		setRound(merkleRoot,rate);

		uint256 initialTreasuryStableBalance  = IERC20(FRAX).balanceOf(treasury);

		address userAddress = getUserAddress(userIndex);
		uint256 userMaxAmount = getUserMaxAmount(userIndex);
		bytes32[] memory proof = getUserProof(userIndex);

		uint256 amountIn = userMaxAmount;

		deposit_FRAX(userAddress,amountIn);
		

		uint256 initialUserStableBalance = IERC20(FRAX).balanceOf(userAddress);
		require(initialUserStableBalance >= amountIn,"TESTFAIL:6");
		
        vm.startPrank(userAddress);
		IERC20(FRAX).approve(address(PCNV),amountIn);
		PCNV.mint(
            userAddress,
            FRAX,
            userMaxAmount,
            amountIn,
            proof
        );
        vm.stopPrank();

		uint256 amountOut = amountIn * 1e18 / rate;

		// require(PCNV.totalSupply() == amountOut,"TESTFAIL:1");
		// require(PCNV.totalMinted() == amountOut,"TESTFAIL:2");
		// require(PCNV.balanceOf(userAddress) == amountOut,"TESTFAIL:3");
		// require(IERC20(FRAX).balanceOf(userAddress) == initialUserStableBalance - amountIn,"TESTFAIL:4");
		// require(IERC20(FRAX).balanceOf(treasury) == initialTreasuryStableBalance + amountIn,"TESTFAIL:5");
	}



	/// @notice treasury sets round
	function setRound(
		bytes32 _merkleRoot,
        uint256 _rate
	) public {
		vm.startPrank(treasury);
		PCNV.setRound(
			merkleRoot,
			rate
		);
		vm.stopPrank();
	}

	function setRedeemable() public {
		vm.startPrank(treasury);
		PCNV.setRedeemable(address(CNV));
		vm.stopPrank();
	}




	function getUserAddress(uint256 ix) public returns(address) {
		return whitelist_addresses[ix];
	}

	function getUserMaxAmount(uint256 ix) public returns(uint256) {
		return amounts[ix]*1e18;
	}

	function getUserProof(uint256 ix) public returns(bytes32[] memory proof) {
		uint256 proofLength;
        for (uint256 i; i < 7; i++) {
            if (proofs[ix][i] != 0x0)  {
                proofLength+=1;
            }
        }
        bytes32[] memory userProof = new bytes32[](proofLength);
        // userProof[0] = 0x4aa8314bb6a7011f02a48f7fb529a59401ef1cdb4bf593af93a44a8fbf477500;
        for (uint256 i; i < proofLength; i++) {
            userProof[i] = bytes32(proofs[ix][i]);
        }
		return userProof;
	}


    /// @notice transfer `amount` of DAI to `to`
    function deposit_DAI(address to, uint256 amount) public {
        address DAI_WHALE = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;
        vm.startPrank(DAI_WHALE);
        IERC20(DAI).transfer(to,amount);
        vm.stopPrank();
		require(IStable(DAI).balanceOf(to) >= amount,"DAIO");
    }

    /// @notice transfer `amount` of FRAX to `to`
    function deposit_FRAX(address to, uint256 amount) public {
        address FRAX_WHALE = 0xd632f22692FaC7611d2AA1C0D552930D43CAEd3B;
        vm.startPrank(FRAX_WHALE);
        IERC20(FRAX).transfer(to,amount);
        vm.stopPrank();
		require(IStable(FRAX).balanceOf(to) >= amount,"DAIO");
    }

}
