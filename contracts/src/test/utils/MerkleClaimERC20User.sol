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

  function mint(
      address to,
      address tokenIn,
      uint256 roundId,
      uint256 maxAmount,
      uint256 amountIn,
      bytes32[] calldata proof
  ) public {
    TOKEN.mint(
        to,
        tokenIn,
        roundId,
        maxAmount,
        amountIn,
        proof
    );
  }

}
