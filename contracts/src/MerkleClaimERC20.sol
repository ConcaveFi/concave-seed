// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// ============ Imports ============

import { ERC20 } from "@solmate/tokens/ERC20.sol"; // Solmate: ERC20
import { MerkleProof } from "@openzeppelin/utils/cryptography/MerkleProof.sol"; // OZ: MerkleProof
import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol"; // OZ: IERC20

import "./test/utils/console.sol";

/// @title MerkleClaimERC20
/// @notice ERC20 claimable by members of a merkle tree
/// @author Anish Agnihotri <contact@anishagnihotri.com>
/// @dev Solmate ERC20 includes unused _burn logic that can be removed to optimize deployment cost
contract MerkleClaimERC20 is ERC20 {

  /// ============ Immutable storage ============

  /// @notice Mapping of addresses of valid deposit tokens
  mapping(address => bool) public approvedDeposits;
  /// @notice ratio of deposits to claimed tokens (i.e: to claim 1 token, must deposit 3*1 of approvedDeposits)
  uint256 public constant ratio = 3;
  /// @notice treasury address to which deposited tokens are sent
  address public immutable treasury;

  /// @notice ERC20-claimee inclusion root
  bytes32 public immutable merkleRoot;

  /// ============ Mutable storage ============

  /// @notice Mapping of addresses who have claimed tokens
  mapping(address => bool) public hasClaimed;

  /// @TODO: remove hasClaimed, add commenting to claimedAmount;
  mapping(address => uint256) public claimedAmount;

  /// ============ Errors ============

  /// @notice Thrown if address has already claimed
  error AlreadyClaimed();
  /// @notice Thrown if address/amount are not part of Merkle tree
  error NotInMerkle();
  /// @notice Thrown in deposit token is not approved
  error NotValidDepositToken();

  /// ============ Constructor ============

  /// @notice Creates a new MerkleClaimERC20 contract
  /// @param _name of token
  /// @param _symbol of token
  /// @param _decimals of token
  /// @param _merkleRoot of claimees
  /// @param _FRAX address of FRAX to set as approvedDeposit
  /// @param _DAI address of DAI to set as approvedDeposit
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
    approvedDeposits[_FRAX] = true; // set FRAX as an approvedDeposit
    approvedDeposits[_DAI] = true; // set DAI as an approvedDeposit
    treasury = _treasury; // set treasury address
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
  /// @param token address of token user wishes to deposit
  /// @param proof merkle proof to prove address and amount are in tree
  function claim(address to, uint256 desiredAmount, uint256 amount, address token, bytes32[] calldata proof) external {
    // Throw if address has already claimed tokens
    // if (hasClaimed[to]) revert AlreadyClaimed();
    // Throw if deposit token isn't approved (i.e isn't FRAX or DAI)
    if (!approvedDeposits[token]) revert NotValidDepositToken();

    // Verify merkle proof, or revert if not in tree
    bytes32 leaf = keccak256(abi.encodePacked(to, amount));
    bool isValidLeaf = MerkleProof.verify(proof, merkleRoot, leaf);
    if (!isValidLeaf) revert NotInMerkle();

    // Set address to claimed
    // hasClaimed[to] = true;
    require(claimedAmount[to]+desiredAmount <= amount, "EXCEEDS_AMOUNT");
    claimedAmount[to]+=desiredAmount;

    // Mint tokens to address
    _mint(to, desiredAmount);
    // Transfer amount*ratio of token to treasury address
    IERC20(token).transferFrom(msg.sender,treasury,desiredAmount*ratio);
    // Emit claim event
    emit Claim(to, desiredAmount);
  }
}
