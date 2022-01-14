// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.0;

interface ICNV {
    function mint(address to, uint256 amount) external returns (uint256);

    function totalSupply() external view returns (uint256);
}
