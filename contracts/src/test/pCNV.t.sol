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

    bytes32 immutable merkleRoot = whitelist_merkleroot;
	
    uint256 immutable rate = whitelist_rate;

    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);


    pCNV PCNV;
    MockCNV CNV;

    function setUp() public virtual {
        PCNV = new pCNV(treasury);
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

	/// TODO: finish this test
	function xtest_manage() public {
		address target = address(0);
		uint256 amount = 0;

		vm.expectRevert("!CONCAVE");
        PCNV.manage(target,amount);


	}


	/* ---------------------------------------------------------------------- */
    /*                              PUBLIC LOGIC                              */
    /* ---------------------------------------------------------------------- */

	/// TODO: write this test
	function xtest_mint_should_fail_with_amount() public {
		vm.expectRevert("!AMOUNT");
	}

	/// TODO: write this test
	function xtest_mint_should_fail_with_tokenIn() public {
		vm.expectRevert("!TOKEN_IN");
	}

	/// TODO: write this test
	function xtest_mint_should_fail_with_proof_on_wrong_proof() public {
		vm.expectRevert("!PROOF");
	}

	/// TODO: write this test
	function xtest_mint_should_fail_with_proof_on_wrong_to() public {
		vm.expectRevert("!PROOF");
	}

	/// @notice 
	function test_mint_should_fail_with_proof_on_wrong_amount() public {
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

	/// TODO: write this test
	function test_mint_should_fal_with_amountin() public { 
        setRound(merkleRoot,rate);

        uint256 userIndex = 0;
		address userAddress = getUserAddress(userIndex);
		uint256 userMaxAmount = getUserMaxAmount(userIndex);
		bytes32[] memory proof = getUserProof(userIndex);

		uint256 amountIn = userMaxAmount+1;
        
         // Verify amount claimed by user does not surpass maxAmount
		
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

	/// TODO: write this test
	function xtest_mint_totalMinted_is_increased_and_totalSupply_is_increased() public {
		uint256 mintedAmount = 0;
		require(PCNV.totalMinted() == mintedAmount);

		require(PCNV.totalSupply() == mintedAmount);
	}




    /* ---------------------------------------------------------------------- */
    /*                              HELPERS                                   */
    /* ---------------------------------------------------------------------- */



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
