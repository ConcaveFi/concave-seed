// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/* -------------------------------------------------------------------------- */
/*                                   IMPORTS                                  */
/* -------------------------------------------------------------------------- */

import { ERC20 } from "@solmate/tokens/ERC20.sol";
import { SafeTransferLib } from "@solmate/utils/SafeTransferLib.sol";

import { MerkleProof } from "@openzeppelin/utils/cryptography/MerkleProof.sol";

interface ICNV {
    function mint(address to, uint256 amount) external returns (uint256);

    function totalSupply() external view returns (uint256);
}

/// @title pCNV
/// @notice ERC20 claimable by members of a merkle tree
/// @author Concave
/// @dev Inspired from pCNV by Anish Agnihotri <contact@anishagnihotri.com>
contract pCNV is ERC20("Concave Presale tokenIn", "pCNV", 18) {

    /* -------------------------------------------------------------------------- */
    /*                                DEPENDENCIES                                */
    /* -------------------------------------------------------------------------- */

    using SafeTransferLib for ERC20;

    /* -------------------------------------------------------------------------- */
    /*                              IMMUTABLE STORAGE                             */
    /* -------------------------------------------------------------------------- */

    uint256 public immutable GENESIS = block.timestamp;

    /// @notice FRAX tokenIn address
    ERC20 public immutable FRAX;

    /// @notice DAI tokenIn address
    ERC20 public immutable DAI;

    /// @notice treasury address to which deposited FRAX or DAI are sent
    address public immutable treasury;

    /* -------------------------------------------------------------------------- */
    /*                               MUTABLE STORAGE                              */
    /* -------------------------------------------------------------------------- */

    struct InvestorRound {
        bytes32 merkleRoot;
        uint256 maxDebt;    // maximum amount of debt being issued in round
        uint256 totalDebt;  // total amount of debt issued so far in round
        uint256 rate;       // amount of DAI/FRAX WL user must send per pCNV
        uint256 deadline;   // latest that whitelisted user can participate
    }

    mapping(uint256 => mapping(address => uint256)) public claimedAmounts;

    mapping(bytes32 => uint256) public rootToRoundId;

    InvestorRound[] public rounds;

    ICNV public CNV;

    uint256 public totalMinted; // cummulatively

    bool public redeemable;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /// @notice Creates a new pCNV contract
    /// @param _FRAX address of FRAX
    /// @param _DAI address of DAI
    /// @param _treasury address
    constructor(
        ERC20 _FRAX,
        ERC20 _DAI,
        address _treasury
    ) {
        FRAX = _FRAX;
        DAI = _DAI;
        treasury = _treasury; // set treasury address
    }

    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */

    /// @notice Emmited after a new round investor round is started
    /// @param maxDebt amount of pCNV to be issued
    /// @param rate amount of pCNV returned per input token
    event NewRound(uint256 maxDebt, uint256 rate);

    /// @notice Emmitted after a rounds maximum debt is decreased by "amount"
    /// @param roundId id of round that whose debt was reduced
    /// @param amount of pCNV debt reduced
    event RoundDebtReduced(uint256 roundId, uint256 amount);

    /// @notice Emitted when tokens are redeemable for CNV
    event SetRedeemable(address CNV);

    /* -------------------------------------------------------------------------- */
    /*                                  MODIFIER                                  */
    /* -------------------------------------------------------------------------- */

    modifier onlyConcave() {
        require(msg.sender == treasury, "!CONCAVE");
        _;
    }

    /* -------------------------------------------------------------------------- */
    /*                                ONLY CONCAVE                                */
    /* -------------------------------------------------------------------------- */

    /// @notice allow pCNV to be redeemed for CNV
    /// @param _CNV address of CNV tokenIn
    function setRedeemable(
        address _CNV
    ) external onlyConcave {
        // Allow tokens to be redeemed for CNV
        redeemable = true;

        // Set CNV address so tokens can be minted
        CNV = ICNV(_CNV);

        // Emit the event
        emit SetRedeemable(_CNV);
    }

    /// @notice Start new investor round, where we issue pTokens for $1
    /// @param merkleRoot root that stores list of users and claimable amounts
    /// @param maxDebt maximum amount of pTokens to issue
    /// @param deadline time when whitelisted users can no longer participate in round
    function newRound(
        bytes32 merkleRoot,
        uint256 maxDebt,
        uint256 rate,
        uint256 deadline
    ) external onlyConcave {
        // Interface storage for round
        // InvestorRound storage round = rounds[rounds.length];

        // // update relevant storage
        // round.merkleRoot = merkleRoot;
        // round.maxDebt = maxDebt;
        // round.rate = rate;
        // round.deadline = deadline;

        rounds.push(InvestorRound(
            merkleRoot,
            maxDebt,
            0,
            rate,
            deadline
        ));
        
        rootToRoundId[merkleRoot] = rounds.length - 1;

        // Emit the event
        emit NewRound(maxDebt, rate);
    }

    /// @notice Reduce the amount of issueable debt by "amount" for given investor round
    /// @param amount that issuable debt will decrease by
    function reduceRoundDebt(
        uint256 roundId,
        uint256 amount
    ) external onlyConcave {
        // Interface storage for round
        InvestorRound storage round = rounds[roundId];

        // Make sure we can only remove debt that hasn't been issued/sold
        require(amount <= round.maxDebt - round.totalDebt, "!MAX_DEBT");

        // Reduce rounds debt by "amount"
        round.maxDebt -= amount;

        // Emit the event
        emit RoundDebtReduced(roundId, amount);
    }

    /* -------------------------------------------------------------------------- */
    /*                               PUBLIC METHODS                               */
    /* -------------------------------------------------------------------------- */

    /// @notice mint using EIP-2612 permit to save a transaction
    /// @param to whitelisted address purchased pCNV will be sent to
    /// @param amountIn amount of tokens sender wants to purchase on behalf of "to"
    /// @param maxAmount max amount of tokens whitelistd user can mint
    /// @param tokenIn address of tokenIn user wishes to deposit
    /// @param proof merkle proof to prove address and amount are in tree
    /// @param permitDeadline time when permit is no longer valid
    /// @param v part of EIP-2612 signature
    /// @param r part of EIP-2612 signature
    /// @param s part of EIP-2612 signature
    function claimWithPermit(
        address to,
        address tokenIn,
        uint256 roundId,
        uint256 maxAmount,
        uint256 amountIn,
        bytes32[] calldata proof,
        uint256 permitDeadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        // Approve tokens for spender - https://eips.ethereum.org/EIPS/eip-2612
        ERC20(tokenIn).permit(msg.sender, address(this), amountIn, permitDeadline, v, r, s);
        // allow sender to mint for "to"
        _purchase(msg.sender, to, tokenIn, roundId, maxAmount, amountIn, proof);
    }

    /// @notice Allows claiming tokens if address+amount is part of merkle tree
    /// @param to whitelisted address purchased pCNV will be sent to
    /// @param amountIn amount of tokens sender wants to purchase on behalf of "to"
    /// @param maxAmount max amount of tokens whitelistd user can mint
    /// @param tokenIn address of tokenIn user wishes to deposit
    /// @param proof merkle proof to prove address and amount are in tree
    function mint(
        address to,
        address tokenIn,
        uint256 roundId,
        uint256 maxAmount,
        uint256 amountIn,
        bytes32[] calldata proof
    ) external returns (uint256 amountOut) {
        return _purchase(msg.sender, to, tokenIn, roundId, maxAmount, amountIn, proof);
    }

    /// @notice redeem pTokens for CNV, if redeemable
    /// @param amount of pCNV to burn for CNV
    function redeem(
        uint256 amount
    ) external returns (uint256 amountOut) {
        // make sure pCNV is redeemable for CNV
        require(redeemable, "!REDEEMABLE");

        // burn users pCNV
        _burn(msg.sender, amount);

        // // calculate amount of CNV to mint based on vesting
        amountOut = redeemAmountOut(amount);

        // // mint users CNV
        CNV.mint(msg.sender, amountOut);
    }

    /* -------------------------------------------------------------------------- */
    /*                                VIEW METHODS                                */
    /* -------------------------------------------------------------------------- */

    /// @notice retuns the amount you will receive in CNV for redeeming "amount" of pTokens
    /// @param amount of pCNV supply being redeemed
    function redeemAmountOut(
        uint256 amount
    ) public view returns (uint256) {
        // If tokens are not redeemable return 0
        if (!redeemable) return 0;

        // If CNV has no supply return 0
        if (CNV.totalSupply() == 0) return 0;

        // Make sure amount is less than or equal to max supply
        require(amount <= totalMinted, "amount");

        // Calculate total amount of CNV that "maxSupply" of pCNV are claimable for
        // X = (10% of current CNV supply * percent vested)
        uint256 totalClaimable = CNV.totalSupply() / 10 * percentVested() / 1e18;

        // return "totalClaimable" / pecentage of pCNV supply being redeemed
        return totalClaimable * amount / totalMinted;
    }

    /// @notice returns percent vested denominated in ether (18 decimals)
    function percentVested() public view returns (uint256) {
        // Calculate amount of time that has passed since the contract was created
        uint256 elapsed = block.timestamp - GENESIS;

        // Return precentage of two years that has elapsed denominated in ether
        return 1e18 * elapsed / (365 days * 2);
    }

    /* -------------------------------------------------------------------------- */
    /*                               INTERNAL LOGIC                               */
    /* -------------------------------------------------------------------------- */

    

    /// @notice Allows claiming tokens if address+amount is part of merkle tree
    /// @param sender address sending transaction
    /// @param to whitelisted address purchased pCNV will be sent to
    /// @param amountIn amount of tokens sender wants to purchase on behalf of "to"
    /// @param maxAmount max amount of tokens whitelistd user can mint
    /// @param tokenIn address of tokenIn user wishes to deposit
    /// @param proof merkle proof to prove address and amount are in tree
    function _purchase(
        address sender,
        address to,
        address tokenIn,
        uint256 roundId,
        uint256 maxAmount,
        uint256 amountIn,
        bytes32[] calldata proof
    ) internal returns (uint256 amountOut) {
        // Interface storage for round
        InvestorRound storage round = rounds[roundId];

        // Make sure payment tokenIn is either DAI or FRAX
        require(tokenIn == address(DAI) || tokenIn == address(FRAX), "!TOKEN_IN");

        // Make sure roundId is equal rootToRoundId to make sure user only interacts with intended round
        require(roundId == rootToRoundId[round.merkleRoot], "!ROUND_ID");

        // Make sure "round.deadline" hasn't been exceeded
        require(block.timestamp <= round.deadline, "!DEADLINE");

        // Require merkle proof with `to` and `maxAmount` to be successfully verified
        require(MerkleProof.verify(proof, round.merkleRoot, keccak256(abi.encodePacked(to, maxAmount))), "!PROOF");

        // Calculate rate of CNV that should be returned for "amountIn"
        amountOut = amountIn * 1e18 / round.rate;

        // Make sure totalDebt does not exceed maxdebt (ie make sure we don't mint more than intended)
        round.totalDebt += amountOut;
        require(round.totalDebt <= round.maxDebt, "!LIQUIDITY");

        // Verify amount claimed by user does not surpass maxAmount
        claimedAmounts[roundId][to] += amountIn;
        require(claimedAmounts[roundId][to] <= maxAmount, "!AMOUNT_IN");

        // Transfer amountIn*ratio of tokenIn to treasury address
        ERC20(tokenIn).safeTransferFrom(sender, treasury, amountIn);

        // Increase cummulative amount minted
        totalMinted += amountOut;

        // Increase amount minted for round
        round.totalDebt += amountOut;

        // Mint tokens to address after pulling
        _mint(to, amountOut);
    }
}
