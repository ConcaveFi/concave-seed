// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/* -------------------------------------------------------------------------- */
/*                                   IMPORTS                                  */
/* -------------------------------------------------------------------------- */

import { ERC20 } from "@solmate/tokens/ERC20.sol";
import { SafeTransferLib } from "@solmate/utils/SafeTransferLib.sol";
import { MerkleProof } from "@openzeppelin/utils/cryptography/MerkleProof.sol";
import { ICNV } from "./interfaces/ICNV.sol";


// IDEA: include a function that allows treasury to mint any unsold supply or 
//outright remove it from maxSupply (thus increasing benefits for current holders)


contract pCNV is ERC20("Concave Presale token", "pCNV", 18) {

    /* ---------------------------------------------------------------------- */
    /*                                DEPENDENCIES                            */
    /* ---------------------------------------------------------------------- */

    using SafeTransferLib for ERC20;

    

    /* ---------------------------------------------------------------------- */
    /*                             IMMUTABLE STATE                            */
    /* ---------------------------------------------------------------------- */

    /// @notice UNIX timestamp when contact was created
    uint256 public immutable GENESIS = block.timestamp;

    /// @notice Two years in seconds
    uint256 public immutable TWO_YEARS = 365 days * 2;

    /// @notice FRAX tokenIn address
    ERC20 public immutable FRAX = ERC20(0x853d955aCEf822Db058eb8505911ED77F175b99e);

    /// @notice DAI tokenIn address
    ERC20 public immutable DAI = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    /// @notice treasury address to which deposited FRAX or DAI are sent
    address public immutable treasury;

    /* ---------------------------------------------------------------------- */
    /*                              MUTABLE STATE                             */
    /* ---------------------------------------------------------------------- */

    /// @notice 
    struct Participant {
        uint256 purchased;
        uint256 redeemed;
    }

    uint256 public maxSupply = 333000e18;

    /// @notice Returns the current pCNV price in DAI/FRAX
    uint256 public rate = 1e18;
    
    /// @notice Returns the current merkle root being used
    bytes32 public merkleRoot;

    /// @notice Returns an array of all merkle roots used
    bytes32[] public roots;
    
    /// @notice CNV ERC20 token
    ICNV public CNV;

    /// @notice whether pCNV are redeemable for CNV
    bool public redeemable;



    /// @notice maps an account to vesting storage
    /// address         - account to check
    /// Participant     - Structured vesting storage
    mapping(address => Participant) public participants;

    /// @notice amount of DAI/FRAX user has spent for a specific root
    /// bytes32         - markleRoot
    /// address         - account to check
    /// returns uint256 - amount in stables (denominated in ether) spent purchasing pCNV
    mapping(bytes32 => mapping(address => uint256)) public spentAmounts;

    /* ---------------------------------------------------------------------- */
    /*                                MODIFIER                                */
    /* ---------------------------------------------------------------------- */

    /// @notice only allows Concave treasury
    modifier onlyConcave() {
        require(msg.sender == treasury, "!CONCAVE");
        _;
    }

    /* ---------------------------------------------------------------------- */
    /*                              ONLY CONCAVE                              */
    /* ---------------------------------------------------------------------- */

    /// @notice allow pCNV to be redeemed for CNV by setting redeemable as true and setting CNV address
    /// @param  _CNV address of CNV
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

    /// @notice 
    /// @param _merkleRoot
    /// @param _rate
    function setRound(
        bytes32 _merkleRoot,
        uint256 _rate
    ) external onlyConcave {
        roots.push(_merkleRoot);
        merkleRoot = _merkleRoot;
        rate = _rate;
    }


    /* ---------------------------------------------------------------------- */
    /*                              PUBLIC LOGIC                              */
    /* ---------------------------------------------------------------------- */

    /// @notice mint pCNV for a specific round by giving merkle proof;
    /// @param to             whitelisted address purchased pCNV will be sent to
    /// @param tokenIn        address of tokenIn user wishes to deposit
    /// @param maxAmount      max amount of DAI/FRAX sender can deposit for pCNV
    /// @param amountIn       amount of DAI/FRAX sender wishes to deposit for pCNV
    /// @param proof          merkle proof to prove address and amount are in tree
    function mint(
        address to,
        address tokenIn,
        uint256 maxAmount,
        uint256 amountIn,
        bytes32[] calldata proof
    ) external returns (uint256 amountOut) {
        return _purchase(msg.sender, to, tokenIn, maxAmount, amountIn, proof);
    }
    
    /// @notice mint pCNV for a specific round by giving merkle proof; uses EIP-2612 permit to save a transaction
    /// @param to             whitelisted address purchased pCNV will be sent to
    /// @param tokenIn        address of tokenIn user wishes to deposit
    /// @param maxAmount      max amount of DAI/FRAX sender can deposit for pCNV
    /// @param amountIn       amount of DAI/FRAX sender wishes to deposit for pCNV
    /// @param proof          merkle proof to prove address and amount are in tree
    /// @param permitDeadline time when permit is no longer valid
    /// @param v              part of EIP-2612 signature
    /// @param r              part of EIP-2612 signature
    /// @param s              part of EIP-2612 signature
    function claimWithPermit(
        address to,
        address tokenIn,
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
        _purchase(msg.sender, to, tokenIn, maxAmount, amountIn, proof);
    }

    function transfer(
        address to, 
        uint256 amount
    ) public virtual override returns (bool) {
        // update vesting storage for both users
        _beforeTransfer(msg.sender, to, amount);
        // default ERC20 transfer
        return super.transfer(to, amount);
    }

    function transferFrom(
        address from, 
        address to, 
        uint256 amount
    ) public virtual override returns (bool) {
        // update vesting storage for both users
        _beforeTransfer(from, to, amount);
        // default ERC20 transfer
        return super.transferFrom(from, to, amount);
    }

    function redeem() external {
        // Access sender's participant storage
        Participant storage participant = participants[msg.sender];

        // Increase redeemed amount to account for newly redeemed tokens
        participant.reedeemed += redeemAmountIn(msg.sender);
        
        // Burn "redeemAmountIn(msg.sender)" from sender        
        _burn(msg.sender, redeemAmountIn(msg.sender));

        // Mint sender "cnvOut" in CNV
        CNV.mint(msg.sender, redeemAmountOut(msg.sender));
    }

    /* ---------------------------------------------------------------------- */
    /*                               PUBLIC VIEW                              */
    /* ---------------------------------------------------------------------- */

    /// @notice Returns amount of CNV that an account can currently redeem for
    /// @param who address to check
    function redeemAmountOut(
        address who
    ) public view returns (uint256) {
        return amountVested() * percentToRedeem(msg.sender) / 1e18;
    }

    /// @notice Returns percentage (denominated in ether) of pCNV supply
    /// that a given account can currently redeem
    /// @param who address to check
    function percentToRedeem(
        address who
    ) public view returns (uint256) {
        return 1e18 * redeemAmountIn(who) / maxSupply;
    }

    /// @notice amount of pCNV that user can redeem
    /// @param who address to check
    function redeemAmountIn(
        address who
    ) public view returns (uint256) {
        // Access sender's participant memory
        Participant memory participant = participants[who];
        // return maximum amount of pCNV "who" can currently redeem
        return participant.purchased * purchaseVested() / 1e18 - participant.redeemed;
    }

    /// @notice Returns the amount of time (in seconds) that has passed
    /// since the contract was created
    function elapsed() public view returns (uint256) {
        return block.timestamp - GENESIS;
    }

    /// @notice Returns the percentage of CNV supply (denominated in ether)
    /// that all pCNV is currently redeemable for
    /// @dev scales up
    function supplyVested() public view returns (uint256) {
        return elapsed() > TWO_YEARS ? 1e17 : 1e17 * elapsed() / TWO_YEARS;
    }

    /// @notice
    function purchaseVested() public view returns (uint256) {
        return elapsed() > TWO_YEARS ? 1e18 : 1e18 * elapsed() / TWO_YEARS; 
    }

    /// @notice
    function amountVested() public view returns (uint256) {
        return CNV.totalSupply() * supplyVested() / 1e18;
    }

    /* ----------------------------------------------------------------------- */
    /*                             INTERNAL LOGIC                              */
    /* ----------------------------------------------------------------------- */

    /// @notice Deposits FRAX/DAI for pCNV if merkle proof exists in specified round
    /// @param sender         address sending transaction
    /// @param to             whitelisted address purchased pCNV will be sent to
    /// @param tokenIn        address of tokenIn user wishes to deposit
    /// @param maxAmount      max amount of DAI/FRAX sender can deposit for pCNV
    /// @param amountIn       amount of DAI/FRAX sender wishes to deposit for pCNV
    /// @param proof          merkle proof to prove address and amount are in tree
    function _purchase(
        address sender,
        address to,
        address tokenIn,
        uint256 maxAmount,
        uint256 amountIn,
        bytes32[] calldata proof
    ) internal returns(uint256 amountOut) {
        // Make sure payment tokenIn is either DAI or FRAX
        require(tokenIn == address(DAI) || tokenIn == address(FRAX), "!TOKEN_IN");
        
        // Require merkle proof with `to` and `maxAmount` to be successfully verified
        require(MerkleProof.verify(proof, merkleRoot, keccak256(abi.encodePacked(to, maxAmount))), "!PROOF");
        
        // Verify amount claimed by user does not surpass maxAmount
        spentAmounts[merkleRoot][to] += amountIn;
        require(spentAmounts[merkleRoot][to] <= maxAmount, "!AMOUNT_IN");

        // Calculate rate of CNV that should be returned for "amountIn"
        amountOut = amountIn * 1e18 / rate;

        // Interface storage for participant
        Participant storage participant = participants[to];

        // Increase participant.purchased to account for newly purchased tokens
        participant.purchased += amountOut;

        // Transfer amountIn*ratio of tokenIn to treasury address
        ERC20(tokenIn).safeTransferFrom(sender, treasury, amountIn);

        // Mint tokens to address after pulling
        _mint(to, amountOut);
    }

    function _beforeTransfer(address from, address to, uint256 amount) internal {

        // Interface "to" participant storage
        Participant storage toParticipant = participants[to];

        // Interface "from" participant storage
        Participant storage fromParticipant = participants[from];

        // calculate amount to adjust redeem amounts by
        uint256 adjustedAmount = amount * fromParticipant.redeemed / fromParticipant.purchased;

        // reduce "from" redeemed by amount * "from" redeem purchase ratio
        fromParticipant.redeemed -= adjustedAmount;

        // reduce "from" purchased amount by the amount being sent
        fromParticipant.purchased -= amount;

        // increase "to" redeemed by amount * "from" redeem purchase ratio
        toParticipant.redeemed += adjustedAmount;

        // increase "to" purchased by amount received
        toParticipant.purchased += amount;
    }
}