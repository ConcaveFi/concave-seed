// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// ============ Imports ============

import { ERC20 } from "@solmate/tokens/ERC20.sol"; // Solmate: ERC20
import { MerkleProof } from "@openzeppelin/utils/cryptography/MerkleProof.sol"; // OZ: MerkleProof
import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol"; // OZ: IERC20

/// @title MerkleClaimERC20
/// @notice ERC20 claimable by members of a merkle tree
/// @author Anish Agnihotri <contact@anishagnihotri.com>
/// @dev Solmate ERC20 includes unused _burn logic that can be removed to optimize deployment cost
contract MerkleClaimERC20 is ERC20 {

  /// ============ Immutable storage ============

  mapping(address => bool) public approvedDeposits;
  uint256 public constant ratio = 3;
  address public immutable treasury;

  /// @notice ERC20-claimee inclusion root
  bytes32 public immutable merkleRoot;

  /// ============ Mutable storage ============

  /// @notice Mapping of addresses who have claimed tokens
  mapping(address => bool) public hasClaimed;

  /// ============ Errors ============

  /// @notice Thrown if address has already claimed
  error AlreadyClaimed();
  /// @notice Thrown if address/amount are not part of Merkle tree
  error NotInMerkle();

  error NotValidDepositToken();

  /// ============ Constructor ============

  /// @notice Creates a new MerkleClaimERC20 contract
  /// @param _name of token
  /// @param _symbol of token
  /// @param _decimals of token
  /// @param _merkleRoot of claimees
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
    approvedDeposits[_FRAX] = true;
    approvedDeposits[_DAI] = true;
    treasury = _treasury;
  }

  /// ============ Events ============

  /// @notice Emitted after a successful token claim
  /// @param to recipient of claim
  /// @param amount of tokens claimed
  event Claim(address indexed to, uint256 amount);

  /// ============ Functions ============

  /// @notice Allows claiming tokens if address is part of merkle tree
  /// @param to address of claimee
  /// @param amount of tokens owed to claimee
  /// @param proof merkle proof to prove address and amount are in tree
  function claim(address to, uint256 amount, address token, bytes32[] calldata proof) external {
    // Throw if address has already claimed tokens
    if (hasClaimed[to]) revert AlreadyClaimed();

    if (!approvedDeposits[token]) revert NotValidDepositToken();

    // Verify merkle proof, or revert if not in tree
    bytes32 leaf = keccak256(abi.encodePacked(to, amount));
    bool isValidLeaf = MerkleProof.verify(proof, merkleRoot, leaf);
    if (!isValidLeaf) revert NotInMerkle();

    // Set address to claimed
    hasClaimed[to] = true;

    // Mint tokens to address
    _mint(to, amount);

    IERC20(token).transferFrom(msg.sender,treasury,amount*ratio);
    // Emit claim event
    emit Claim(to, amount);
  }
}
