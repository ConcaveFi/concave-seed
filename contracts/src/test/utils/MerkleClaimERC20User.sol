// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// ============ Imports ============

import { MerkleClaimERC20 } from "../../MerkleClaimERC20.sol"; // MerkleClaimERC20
import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol"; // OZ: IERC20

/// @title MerkleClaimERC20User
/// @notice Mock MerkleClaimERC20 user
/// @author Anish Agnihotri <contact@anishagnihotri.com>
contract MerkleClaimERC20User {

  /// ============ Immutable storage ============

  /// @dev MerkleClaimERC20 contract
  MerkleClaimERC20 immutable internal TOKEN;
  address immutable STABLE;

  /// ============ Constructor ============

  /// @notice Creates a new MerkleClaimERC20User
  /// @param _TOKEN MerkleClaimERC20 contract
  constructor(MerkleClaimERC20 _TOKEN, address _STABLE) {
    TOKEN = _TOKEN;
    STABLE = _STABLE;
  }

  /// ============ Helper functions ============

  /// @notice Returns users' token balance
  function tokenBalance() public view returns (uint256) {
    return TOKEN.balanceOf(address(this));
  }

  function stableBalance() public view returns(uint256) {
      return IERC20(STABLE).balanceOf(address(this));
  }

  /// ============ Inherited functionality ============

  /// @notice Allows claiming tokens if address is part of merkle tree
  /// @param to address of claimee
  /// @param amountToClaim amount of tokens claimee wishes to claim
  /// @param maxAmount max amount of tokens claimee can claim
  /// @param token address of token user wishes to deposit
  /// @param proof merkle proof to prove address and amount are in tree
  function claim(
      address to,
      uint256 amountToClaim,
      uint256 maxAmount,
      address token,
      bytes32[] calldata proof
  ) public {
    TOKEN.claim(to, amountToClaim, maxAmount, token, proof);
  }

}
