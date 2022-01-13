// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/* -------------------------------------------------------------------------- */
/*                                   IMPORTS                                  */
/* -------------------------------------------------------------------------- */

import { ERC20 } from "@solmate/tokens/ERC20.sol";

contract MockCNV is ERC20("MOCK CNV", "mCNV", 18) {

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    constructor(uint256 startingSupply) {
        _mint(address(0), startingSupply);
    }

    /* -------------------------------------------------------------------------- */
    /*                               PUBLIC METHODS                               */
    /* -------------------------------------------------------------------------- */

    function mint(address who, uint256 amount) external returns (uint256) {
        _mint(who, amount);
        return amount;
    }
}