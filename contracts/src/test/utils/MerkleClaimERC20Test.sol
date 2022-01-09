// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// ============ Imports ============

import { DSTest } from "ds-test/test.sol"; // DSTest
import { MerkleClaimERC20 } from "../../MerkleClaimERC20.sol"; // MerkleClaimERC20
import { MerkleClaimERC20User } from "./MerkleClaimERC20User.sol"; // MerkleClaimERC20 user
import { ERC20 } from "@solmate/tokens/ERC20.sol"; // Solmate: ERC20

/// @title MerkleClaimERC20Test
/// @notice Scaffolding for MerkleClaimERC20 tests
/// @author Anish Agnihotri <contact@anishagnihotri.com>
contract MerkleClaimERC20Test is DSTest {

  /// ============ Storage ============


  /// ============ Concave ============
  address constant _FRAX = 0x853d955aCEf822Db058eb8505911ED77F175b99e;
  address constant _DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  address constant _treasury = 0x0877497b4A2674e818234a691bc4d2Dffcf76e73; // pkey: 0x305a3443329fec7e58ca427987dbca937df0404813b4f268d19f65d9ee634fb4
  /// =================================


  /// @dev MerkleClaimERC20 contract
  MerkleClaimERC20 internal TOKEN;
  /// @dev User: Alice (in merkle tree)
  MerkleClaimERC20User internal ALICE;
  /// @dev User: Bob (not in merkle tree)
  MerkleClaimERC20User internal BOB;

  /// ============ Setup test suite ============

  function setUp() public virtual {
    // Create airdrop token
    TOKEN = new MerkleClaimERC20(
      "My Token",
      "MT",
      18,
      // Merkle root containing ALICE with 100e18 tokens but no BOB
      0x6a0b89fc219e9e72ad683e00d9c152532ec8e5c559600e04160d310936400a00,
      _FRAX,
      _DAI,
      _treasury
    );

    // Setup airdrop users
    ALICE = new MerkleClaimERC20User(TOKEN); // 0x109f93893af4c4b0afc7a9e97b59991260f98313
    BOB = new MerkleClaimERC20User(TOKEN); // 0x689856e2a6eb68fc33099eb2ccba0a5a4e8be52f
  }
}
