// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

/// ============ Imports ============

import { DSTest } from "ds-test/test.sol"; // DSTest
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

}
