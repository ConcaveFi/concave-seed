// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

// TODO make sure interface is correct
interface ICNV {
    function mint(address to, uint256 amount) external returns (uint256);

    function totalSupply() external view returns (uint256);
}
