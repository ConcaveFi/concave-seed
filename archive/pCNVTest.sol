// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// ============ Imports ============

import { DSTest } from "ds-test/test.sol"; // DSTest
import { pCNV } from "../../pCNV.sol"; // pCNV
import { pCNVUser } from "./pCNVUser.sol"; // pCNV user
import { ERC20 } from "@solmate/tokens/ERC20.sol"; // Solmate: ERC20
import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol"; // OZ: IERC20

import "./VM.sol";


/// @title pCNVTest
/// @notice Scaffolding for pCNV tests
/// @author Anish Agnihotri <contact@anishagnihotri.com>
contract pCNVTest is DSTest {

  /// ============ Storage ============


  /// ============ Concave ============
  address constant _FRAX = 0x853d955aCEf822Db058eb8505911ED77F175b99e;
  address constant _DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  address constant _treasury = 0x0877497b4A2674e818234a691bc4d2Dffcf76e73; // pkey: 0x305a3443329fec7e58ca427987dbca937df0404813b4f268d19f65d9ee634fb4

  address constant DAI_WHALE = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;
  address constant FRAX_WHALE = 0xd632f22692FaC7611d2AA1C0D552930D43CAEd3B;

  Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
  /// =================================


  /// @dev pCNV contract
  pCNV internal TOKEN;
  /// @dev User: Alice (in merkle tree)
  pCNVUser internal ALICE;
  /// @dev User: Bob (not in merkle tree)
  pCNVUser internal BOB;

  /// ============ Setup test suite ============

  function setUp() public virtual {
    // Create airdrop token
    TOKEN = new pCNV(
      // "My Token",
      // "MT",
      // 18,
      // Merkle root containing ALICE with 100e18 tokens but no BOB
      // 0x6a0b89fc219e9e72ad683e00d9c152532ec8e5c559600e04160d310936400a00,
      ERC20(_FRAX),
      ERC20(_DAI),
      _treasury
    );

    // Setup airdrop users
    ALICE = new pCNVUser(TOKEN, _DAI); // 0x109f93893af4c4b0afc7a9e97b59991260f98313
    BOB = new pCNVUser(TOKEN, _FRAX); // 0x689856e2a6eb68fc33099eb2ccba0a5a4e8be52f

    vm.startPrank(DAI_WHALE);
    IERC20(_DAI).transfer(address(ALICE),3000e18);
    vm.stopPrank();
    vm.startPrank(FRAX_WHALE);
    IERC20(_FRAX).transfer(address(BOB),3000e18);
    vm.stopPrank();
    vm.startPrank(address(ALICE));
    IERC20(_DAI).approve(address(TOKEN),3000e18);
    vm.stopPrank();
    vm.startPrank(address(BOB));
    IERC20(_FRAX).approve(address(TOKEN),3000e18);
    vm.stopPrank();

    vm.startPrank(_treasury);
    uint256 maxDebt = 200e18;
    uint256 rate = 3e18;
    uint256 deadline = block.timestamp+1000;
    TOKEN.newRound(
        0x6a0b89fc219e9e72ad683e00d9c152532ec8e5c559600e04160d310936400a00,
        maxDebt,
        rate,
        deadline
    );
    vm.stopPrank();
    // emit log_uint(IERC20(_DAI).balanceOf(address(ALICE)));
  }
}
