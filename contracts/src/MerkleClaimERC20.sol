// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// ============ Imports ============

import { ERC20 } from "@solmate/tokens/ERC20.sol"; // Solmate: ERC20
import { MerkleProof } from "@openzeppelin/utils/cryptography/MerkleProof.sol"; // OZ: MerkleProof
import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol"; // OZ: IERC20


/// @title MerkleClaimERC20
/// @notice ERC20 claimable by members of a merkle tree
/// @author Concave
/// @dev Inspired from MerkleClaimERC20 by Anish Agnihotri <contact@anishagnihotri.com>
/// @dev Solmate ERC20 includes unused _burn logic that can be removed to optimize deployment cost
contract MerkleClaimERC20 is ERC20 {

  /// ============ Immutable storage ============


  /// @notice FRAX token address
  address public immutable FRAX;
  /// @notice DAI token address
  address public immutable DAI;
  /// @notice treasury address to which deposited FRAX or DAI are sent
  address public immutable treasury;
  /// @notice ERC20-claimee inclusion root
  bytes32 public immutable merkleRoot;
  /// @notice ratio of deposits to claimed tokens (i.e: to claim 1 token, must deposit 3*1 of approvedDeposits)
  uint256 public constant ratio = 3;

  /// ============ Mutable storage ============

  /// @notice map claimed amount by users
  mapping(address => uint256) public claimedAmount;


  /// ============ Constructor ============

  /// @notice Creates a new MerkleClaimERC20 contract
  /// @param _name of token
  /// @param _symbol of token
  /// @param _decimals of token
  /// @param _merkleRoot of claimees
  /// @param _FRAX address of FRAX
  /// @param _DAI address of DAI
  /// @param _treasury address
  constructor(
    string memory _name,
    string memory _symbol,
    uint8 _decimals,
    bytes32 _merkleRoot,
    address _FRAX,
    address _DAI,
    address _treasury
  ) ERC20(_name, _symbol, _decimals) {
    merkleRoot = _merkleRoot; // Update root
    FRAX = _FRAX;
    DAI = _DAI;
    treasury = _treasury; // set treasury address
  }

  /// ============ Events ============

  /// @notice Emitted after a successful token claim
  /// @param to recipient of claim
  /// @param amount of tokens claimed
  event Claim(address indexed to, uint256 amount);

  /// ============ Functions ============

  /// @notice Allows claiming tokens if address+amount is part of merkle tree
  /// @param to             address of claimee
  /// @param amountToClaim  amount of tokens claimee wishes to claim
  /// @param maxAmount      max amount of tokens claimee can claim
  /// @param token          address of token user wishes to deposit
  /// @param proof          merkle proof to prove address and amount are in tree
  function claim(
      address to,
      uint256 amountToClaim,
      uint256 maxAmount,
      address token,
      bytes32[] calldata proof
  ) external {
    // Require token to be DAI or FRAX
    require(token == DAI || token == FRAX, "NOT_APPROVED_TOKEN");

    // Require merkle proof with `to` and `maxAmount` to be successfully verified
    require(
        MerkleProof.verify(
            proof,
            merkleRoot,
            keccak256(abi.encodePacked(to, maxAmount))
        ),
        "NOT_IN_MERKLE"
    );
    // add amountToClaim to total claimedAmount for `to`
    claimedAmount[to] += amountToClaim;
    // Verify amount claimed by user does not surpass maxAmount
    require(claimedAmount[to] <= maxAmount, "EXCEEDS_AMOUNT");


    // Mint tokens to address
    _mint(to, amountToClaim);
    // Transfer amountToClaim*ratio of token to treasury address
    IERC20(token).transferFrom(msg.sender, treasury, amountToClaim*ratio);
    // Emit claim event
    emit Claim(to, amountToClaim);
  }
}