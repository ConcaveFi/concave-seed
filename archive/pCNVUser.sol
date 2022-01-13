// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// ============ Imports ============

import { pCNV } from "../../pCNV.sol"; // pCNV
import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol"; // OZ: IERC20

/// @title pCNVUser
/// @notice Mock pCNV user
/// @author Anish Agnihotri <contact@anishagnihotri.com>
contract pCNVUser {

  /// ============ Immutable storage ============

  /// @dev pCNV contract
  pCNV immutable internal TOKEN;
  address immutable STABLE;

  /// ============ Constructor ============

  /// @notice Creates a new pCNVUser
  /// @param _TOKEN pCNV contract
  constructor(pCNV _TOKEN, address _STABLE) {
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

  function redeem(
    uint256 amount
  ) public {
    TOKEN.redeem(amount);
  }

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
