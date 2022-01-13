// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;



/**
    pCNV to CNV mechanics
    ---------------------
    The contract features two vesting schedules to redeem pCNV into CNV. Both
    schedules are linear, and have a duration of 2 years.

    The first vesting schedule determines how many pCNV a holder can redeem at
    any point in time. At contract inception - 0% of a holder's pCNV can be 
    redeemed. At the end of 2 years, 100% of a holder's pCNV can be redeemed.
    It goes from 0% to 100% in a linear fashion.

    The second vesting schedule determines the percent of CNV supply that pCNV
    corresponds to. This vesting schedule also begins at 0% on day one, and
    advances linearly to reach 10% at the end of year two.

    The following is a breakdown of a pCNV to CNV redemption:

    Assumptions:
        - Alice holds 100 pCNV
        - pCNV total supply is 200
        - CNV total supply is 1000
        - 1 year has passed and Alice has not made any previous redemptions
    
    Then:
        - The first vesting schedule tells us that users may redeem 50% of their
          holdings, so Alice may redeem 50 pCNV.
        - The second vesting schedule tells us that pCNV total supply corresponds
          to 5% of total CNV supply.
        - Since total CNV supply is 1000, 5% of it is 50, so 50 CNV are what
          correspond to the 200 pCNV supply.
        - Alice has 50% of total pCNV supply
        - Thus, Alice is entitled to 50% of the claimable CNV supply, i.e Alice
          is entitled to 25 CNV

    Conclusion:
        - Alice burns 50 pCNV
        - Alice mints 25 CNV
        
*/

/* -------------------------------------------------------------------------- */
/*                                   IMPORTS                                  */
/* -------------------------------------------------------------------------- */

import { ERC20 } from "@solmate/tokens/ERC20.sol";
import { SafeTransferLib } from "@solmate/utils/SafeTransferLib.sol";
import { MerkleProof } from "@openzeppelin/utils/cryptography/MerkleProof.sol";
import { ICNV } from "./interfaces/ICNV.sol";

/// @notice Concave Presale Token
/// @author Convex & Dionysus (ConcaveFi)
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
    uint256 public immutable TWO_YEARS = 365 days * 2; // fetch in seconds

    /// @notice FRAX tokenIn address
    ERC20 public immutable FRAX = ERC20(0x853d955aCEf822Db058eb8505911ED77F175b99e);

    /// @notice DAI tokenIn address
    ERC20 public immutable DAI = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    /* ---------------------------------------------------------------------- */
    /*                              MUTABLE STATE                             */
    /* ---------------------------------------------------------------------- */

    /// @notice CNV ERC20 token
    /// @dev will be address(0) until redeemable = true
    ICNV public CNV;

    /// @notice Address that is recipient of raised funds + access control
    address public treasury = msg.sender;

    /// @notice Returns the current merkle root being used
    bytes32 public merkleRoot;

    /// @notice Returns an array of all merkle roots used
    bytes32[] public roots;

    /// @notice Returns the current pCNV price in DAI/FRAX
    uint256 public rate;

    /// @notice Returns the max supply that is allowed to be minted (in total)
    uint256 public maxSupply = 33_000_000 * 10 ** 18;

    /// @notice Returns the total amount of pCNV that has cummulativly been minted
    uint256 public totalMinted;

    /// @notice Returns if pCNV are redeemable for CNV
    bool public redeemable;

    /* ---------------------------------------------------------------------- */
    /*                              STRUCTURED STATE                          */
    /* ---------------------------------------------------------------------- */

    /// @notice Structure of Participant storage
    struct Participant {
        uint256 purchased; // amount (in total) that user has purchased
        uint256 redeemed;  // amount (in total) that user has redeemed
    }

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
    /*                                MODIFIERS                               */
    /* ---------------------------------------------------------------------- */

    /// @notice only allows Concave treasury
    modifier onlyConcave() {
        require(msg.sender == treasury, "!CONCAVE");
        _;
    }

    /* ---------------------------------------------------------------------- */
    /*                              ONLY CONCAVE                              */
    /* ---------------------------------------------------------------------- */

    /// @notice Set a new treasury address if treasury
    function setTreasury(
        address _treasury
    ) external onlyConcave {
        treasury = _treasury;
    }

    /// @notice allow pCNV to be redeemed for CNV by setting redeemable as true and setting CNV address
    /// @param  _CNV address of CNV
    function setRedeemable(
        address _CNV
    ) external onlyConcave {
        // Allow tokens to be redeemed for CNV
        redeemable = true;
        // Set CNV address so tokens can be minted
        CNV = ICNV(_CNV);
    }

    /// @notice Update
    /// @param _merkleRoot  root of merkle tree
    /// @param _rate        rate ...
    function setRound(
        bytes32 _merkleRoot,
        uint256 _rate
    ) external onlyConcave {
        require(_rate > 0, "!RATE");
        // push new root to array of all roots - for viewing
        roots.push(_merkleRoot);
        // update merkle root
        merkleRoot = _merkleRoot;
        // update rate
        rate = _rate;
    }

    /// @notice Reduce an "amount" of available supply or mint it to "target"
    /// @param amount to reduce from max supply or mint to "target"
    function manage(
        address target,
        uint256 amount
    ) external onlyConcave {
        // if target is address 0, reduce supply
        if (target == address(0)) {
            // Make sure there's enough unminted supply to allow for supply reduction
            require(maxSupply - amount >= totalMinted, "!AMOUNT");
            // Reduce max supply by "amount"
            maxSupply -= amount;
            // end the function
            return;
        }
        // make sure total minted + amount is less than or equal to maximum supply
        require(totalMinted + amount <= maxSupply, "!AMOUNT");
        // mint target amount
        _mint(target, amount);
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
    function mintWithPermit(
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

    /// @notice transfer "amount" of tokens from msg.sender to "to"
    /// @param to address tokens are being sent to
    /// @param amount number of tokens being transfered
    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        // update vesting storage for both users
        _beforeTransfer(msg.sender, to, amount);
        // default ERC20 transfer
        return super.transfer(to, amount);
    }

    /// @notice transfer "amount" of tokens from "from" to "to"
    /// @param from address tokens are being transfered from
    /// @param to address tokens are being sent to
    /// @param amount number of tokens being transfered
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

    /// @notice redeem a specific amount of pCNV for CNV
    /// @param amount amount of pCNV to be redeemed
    function redeem(uint256 amount) external {

        // Make sure tokens are redeemable first
        require(redeemable, "!REDEEMABLE");

        // store amountIn and amountOut before mutating state
        uint256 amountIn = redeemAmountIn(msg.sender);
        
        
        uint256 amountOut = redeemAmountOut(msg.sender);
        
        require(amount <= amountIn, "!VESTED");
        
        Participant storage participant = participants[msg.sender];
        
        participant.redeemed += amount;
        
        _burn(msg.sender, amount);
        
        // Mint sender amountOut
        CNV.mint(msg.sender, amountOut);
    }

    function redeem(uint256 amountIn) external {
        Participant storage participant = participants[msg.sender];

        require(amountIn <= redeemAmountIn(msg.sender), "!AMOUNT");
        
        uint256 ratio = 1e18 * amountIn / redeemAmountIn(msg.sender);

        uint256 amountOut = redeemAmountOut * ratio / 1e18;

        participant.redeemed += amountIn;

        _burn(msg.sender, amountIn);

        CNV.mint(msg.sender, amountOut);
    }


    /* ---------------------------------------------------------------------- */
    /*                               PUBLIC VIEW                              */
    /* ---------------------------------------------------------------------- */

    /// @notice amount of pCNV that user can redeem
    /// @param who address to check
    function redeemAmountIn(
        address who
    ) public view returns (uint256) {
        
        if (!redeemable) return 0;

        if (CNV.totalSupply() == 0) return 0;

        // Access sender's participant memory
        Participant memory participant = participants[who];
        // return maximum amount of pCNV "who" can currently redeem
        return participant.purchased * purchaseVested() / 1e18 - participant.redeemed;
    }

    /// @notice Returns amount of CNV that an account can currently redeem for
    /// @param who address to check
    function redeemAmountOut(
        address who
    ) public view returns (uint256) {
        return amountVested() * percentToRedeem(who) / 1e18;
    }

    /// @notice Returns amount of CNV that an account can currently redeem for
    /// @param who address to check
    function redeemAmountOutForAmountIn(
        address who,
        uint256 amountIn
    ) public view returns (uint256) {
        return amountVested() * (1e18 * amountIn / maxSupply) / 1e18;
    }

    /// @notice Returns percentage (denominated in ether) of pCNV supply
    /// that a given account can currently redeem
    /// @param who address to check
    function percentToRedeem(
        address who
    ) public view returns (uint256) {
        return 1e18 * redeemAmountIn(who) / maxSupply;
    }

    /// @notice Returns the amount of time (in seconds) that has passed
    /// since the contract was created
    function elapsed() public view returns (uint256) {
        return block.timestamp - GENESIS;
    }

    /// @notice Returns the percentage of CNV supply (denominated in ether)
    /// that all pCNV is currently redeemable for
    function supplyVested() public view returns (uint256) {
        return elapsed() > TWO_YEARS ? 1e17 : 1e17 * elapsed() / TWO_YEARS;
    }

    /// @notice Returns the percent of pCNV that is redeemable
    function purchaseVested() public view returns (uint256) {
        return elapsed() > TWO_YEARS ? 1e18 : 1e18 * elapsed() / TWO_YEARS;
    }

    /// @notice Returns total amount of CNV supply that is vested
    function amountVested() public view returns (uint256) {
        return CNV.totalSupply() * supplyVested() / 1e18;
    }

    /* ---------------------------------------------------------------------- */
    /*                             INTERNAL LOGIC                             */
    /* ---------------------------------------------------------------------- */

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
        // make sure total minted + amount is less than or equal to maximum supply
        require(totalMinted + amountIn <= maxSupply, "!AMOUNT");

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

        // Increase totalMinted to account for newly minted supply
        totalMinted += amountOut;

        // Transfer amountIn*ratio of tokenIn to treasury address
        ERC20(tokenIn).safeTransferFrom(sender, treasury, amountIn);

        // Mint tokens to address after pulling
        _mint(to, amountOut);
    }

    /// @notice Maintains total amount of redeemable tokens when pCNV is being transfered
    /// @param from address tokens are being transfered from
    /// @param to address tokens are being sent to
    /// @param amount number of tokens being transfered
    function _beforeTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
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

