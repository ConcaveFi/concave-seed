// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.0;



/**

     ██████╗ ██████╗ ███╗   ██╗ ██████╗ █████╗ ██╗   ██╗██████╗
    ██╔════╝██╔═══██╗████╗  ██║██╔════╝██╔══██╗██║   ██║╚════██╗
    ██║     ██║   ██║██╔██╗ ██║██║     ███████║██║   ██║ █████╔╝
    ██║     ██║   ██║██║╚██╗██║██║     ██╔══██║╚██╗ ██╔╝ ╚═══██╗
    ╚██████╗╚██████╔╝██║ ╚████║╚██████╗██║  ██║ ╚████╔╝ ██████╔╝
     ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝  ╚═══╝  ╚═════╝

    Concave Presale Token

*/

/* -------------------------------------------------------------------------- */
/*                                   IMPORTS                                  */
/* -------------------------------------------------------------------------- */

import { ERC20 } from "@solmate/tokens/ERC20.sol";
import { SafeTransferLib } from "@solmate/utils/SafeTransferLib.sol";
import { MerkleProof } from "@openzeppelin/utils/cryptography/MerkleProof.sol";
import { ICNV } from "./interfaces/ICNV.sol";

/// @notice Concave Presale Token
/// @author 0xBarista & Dionysus (ConcaveFi)
contract bbtCNV is ERC20("Concave Presale Token (BBT)", "bbtCNV", 18) {

    /* ---------------------------------------------------------------------- */
    /*                                DEPENDENCIES                            */
    /* ---------------------------------------------------------------------- */

    using SafeTransferLib for ERC20;

    /* ---------------------------------------------------------------------- */
    /*                             IMMUTABLE STATE                            */
    /* ---------------------------------------------------------------------- */

    /// @notice FRAX tokenIn address
    // ERC20 public immutable FRAX = ERC20(0x853d955aCEf822Db058eb8505911ED77F175b99e);
    ERC20 public immutable FRAX = ERC20(0xE7E9F348202f6EDfFF2607025820beE92F51cdAA); // TESTNET

    /// @notice DAI tokenIn address
    // ERC20 public immutable DAI = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    ERC20 public immutable DAI = ERC20(0x7B731FFcf1b9C6E0868dA3F1312673A12Da28dc5); // TESTNET

    /// @notice Error related to amount
    string constant AMOUNT_ERROR = "!AMOUNT";

    /// @notice Error related to token address
    string constant TOKEN_IN_ERROR = "!TOKEN_IN";

    /* ---------------------------------------------------------------------- */
    /*                              MUTABLE STATE                             */
    /* ---------------------------------------------------------------------- */

    /// @notice CNV ERC20 token
    /// @dev will be address(0) until redeemable = true
    // ICNV public CNV;

    /// @notice Address that is recipient of raised funds + access control
    // address public treasury = 0x226e7AF139a0F34c6771DeB252F9988876ac1Ced;
    address public treasury = 0xB1DF8b1E93172235eEB8Bbb60D4356f046dff3AF; // TESTNET

    /// @notice Returns the current merkle root being used
    bytes32 public merkleRoot;

    /// @notice Returns an array of all merkle roots used
    bytes32[] public roots;

    /// @notice Returns the current pCNV price in DAI/FRAX
    uint256 public rate;

    /// @notice Returns the max supply of pCNV that is allowed to be minted (in total)
    // uint256 public maxSupply = 33000000000000000000000000;

    /// @notice Returns the total amount of pCNV that has cumulatively been minted
    uint256 public totalMinted;

    /// @notice Returns if pCNV are redeemable for CNV
    // bool public redeemable;

    /// @notice Returns whether transfers are paused
    bool public transfersPaused;

    /* ---------------------------------------------------------------------- */
    /*                              STRUCTURED STATE                          */
    /* ---------------------------------------------------------------------- */

    /// @notice Structure of Participant vesting storage
    struct Participant {
        uint256 purchased; // amount (in total) of pCNV that user has purchased
        uint256 redeemed;  // amount (in total) of pCNV that user has redeemed
    }

    /// @notice             maps an account to vesting storage
    /// address             - account to check
    /// returns Participant - Structured vesting storage
    mapping(address => Participant) public participants;

    /// @notice             amount of DAI/FRAX user has spent for a specific root
    /// bytes32             - merkle root
    /// address             - account to check
    /// returns uint256     - amount in DAI/FRAX (denominated in ether) spent purchasing pCNV
    mapping(bytes32 => mapping(address => uint256)) public spentAmounts;

    /* ---------------------------------------------------------------------- */
    /*                                  EVENTS                                */
    /* ---------------------------------------------------------------------- */

    /// @notice Emitted when treasury changes treasury address
    /// @param  treasury address of new treasury
    event TreasurySet(address treasury);

    /// @notice             Emitted when a new round is set by treasury
    /// @param  merkleRoot  new merkle root
    /// @param  rate        new price of pCNV in DAI/FRAX
    event NewRound(bytes32 merkleRoot, uint256 rate);

    /// @notice             Emitted when maxSupply of pCNV is burned or minted to target
    /// @param  target      target to which to mint pCNV or burn if target = address(0)
    /// @param  amount      amount of pCNV minted to target or burned
    /// @param  totalMinted amount of pCNV minted to target or burned
    event Managed(address target, uint256 amount, uint256 totalMinted);

    /// @notice                 Emitted when pCNV minted via "mint()" or "mintWithPermit"
    /// @param  depositedFrom   address from which DAI/FRAX was deposited
    /// @param  mintedTo        address to which pCNV were minted to
    /// @param  amount          amount of pCNV minted
    /// @param  deposited       amount of DAI/FRAX deposited
    /// @param  totalMinted     total amount of pCNV minted so far
    event Minted(
        address indexed depositedFrom,
        address indexed mintedTo,
        uint256 amount,
        uint256 deposited,
        uint256 totalMinted
    );

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

        emit TreasurySet(_treasury);
    }

    /// @notice             Update merkle root and rate
    /// @param _merkleRoot  root of merkle tree
    /// @param _rate        price of pCNV in DAI/FRAX
    function setRound(
        bytes32 _merkleRoot,
        uint256 _rate
    ) external onlyConcave {
        // push new root to array of all roots - for viewing
        roots.push(_merkleRoot);
        // update merkle root
        merkleRoot = _merkleRoot;
        // update rate
        rate = _rate;

        emit NewRound(merkleRoot,rate);
    }

    /// @notice         Reduce an "amount" of available supply of pCNV or mint it to "target"
    /// @param target   address to which to mint; if address(0), will burn
    /// @param amount   to reduce from max supply or mint to "target"
    function manage(
        address target,
        uint256 amount
    ) external onlyConcave {

        totalMinted += amount;
        // mint target amount
        _mint(target, amount);

        emit Managed(target, amount, totalMinted);
    }

    /// @notice         Allows Concave to pause transfers in the event of a bug
    /// @param paused   if transfers should be paused or not
    function setTransfersPaused(bool paused) external onlyConcave {
        transfersPaused = paused;
    }

    /* ---------------------------------------------------------------------- */
    /*                              PUBLIC LOGIC                              */
    /* ---------------------------------------------------------------------- */

    /// @notice               mint pCNV by providing merkle proof and depositing DAI/FRAX
    /// @param to             whitelisted address pCNV will be minted to
    /// @param tokenIn        address of tokenIn user wishes to deposit (DAI/FRAX)
    /// @param maxAmount      max amount of DAI/FRAX sender can deposit for pCNV, to verify merkle proof
    /// @param amountIn       amount of DAI/FRAX sender wishes to deposit for pCNV
    /// @param proof          merkle proof to prove "to" and "maxAmount" are in merkle tree
    function mint(
        address to,
        address tokenIn,
        uint256 maxAmount,
        uint256 amountIn,
        bytes32[] calldata proof
    ) external returns (uint256 amountOut) {
        return _purchase(msg.sender, to, tokenIn, maxAmount, amountIn, proof);
    }

    /// @notice               mint pCNV by providing merkle proof and depositing DAI; uses EIP-2612 permit to save a transaction
    /// @param to             whitelisted address pCNV will be minted to
    /// @param tokenIn        address of tokenIn user wishes to deposit (DAI)
    /// @param maxAmount      max amount of DAI sender can deposit for pCNV, to verify merkle proof
    /// @param amountIn       amount of DAI sender wishes to deposit for pCNV
    /// @param proof          merkle proof to prove "to" and "maxAmount" are in merkle tree
    /// @param permitDeadline EIP-2612 : time when permit is no longer valid
    /// @param v              EIP-2612 : part of EIP-2612 signature
    /// @param r              EIP-2612 : part of EIP-2612 signature
    /// @param s              EIP-2612 : part of EIP-2612 signature
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
    ) external returns (uint256 amountOut) {
        // Make sure payment tokenIn is DAI
        require(tokenIn == address(DAI), TOKEN_IN_ERROR);
        // Approve tokens for spender - https://eips.ethereum.org/EIPS/eip-2612
        ERC20(tokenIn).permit(msg.sender, address(this), amountIn, permitDeadline, v, r, s);
        // allow sender to mint for "to"
        return _purchase(msg.sender, to, tokenIn, maxAmount, amountIn, proof);
    }

    /// @notice         transfer "amount" of tokens from msg.sender to "to"
    /// @dev            calls "_beforeTransfer" to update vesting storage for "from" and "to"
    /// @param to       address tokens are being sent to
    /// @param amount   number of tokens being transfered
    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        require(!transfersPaused,"PAUSED");
        // update vesting storage for both users
        // _beforeTransfer(msg.sender, to, amount);
        // default ERC20 transfer
        return super.transfer(to, amount);
    }

    /// @notice         transfer "amount" of tokens from "from" to "to"
    /// @dev            calls "_beforeTransfer" to update vesting storage for "from" and "to"
    /// @param from     address tokens are being transfered from
    /// @param to       address tokens are being sent to
    /// @param amount   number of tokens being transfered
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        require(!transfersPaused,"PAUSED");
        // update vesting storage for both users
        // _beforeTransfer(from, to, amount);
        // default ERC20 transfer
        return super.transferFrom(from, to, amount);
    }

    // /// @notice         redeem pCNV for CNV
    // /// @param to       address that will receive redeemed CNV
    // /// @param amountIn amount of pCNV to redeem
    // function redeem(
    //     address to,
    //     uint256 amountIn
    // ) external {
    //     // Make sure pCNV is currently redeemable for CNV
    //     require(redeemable, "!REDEEMABLE");
    //
    //     // Access participant storage
    //     Participant storage participant = participants[msg.sender];
    //
    //     // Calculate CNV owed to sender for redeeming "amountIn"
    //     uint256 amountOut = redeemAmountOut(msg.sender, amountIn);
    //
    //     // Increase participant.redeemed by amount being redeemed
    //     participant.redeemed += amountIn;
    //
    //     // Burn users pCNV
    //     _burn(msg.sender, amountIn);
    //
    //     // Mint user CNV
    //     CNV.mint(to, amountOut);
    //
    //     emit Redeemed(msg.sender, to, amountIn, amountOut);
    // }

    /* ---------------------------------------------------------------------- */
    /*                               PUBLIC VIEW                              */
    /* ---------------------------------------------------------------------- */

    // /// @notice         Returns the amount of CNV a user will receive for redeeming `amountIn` of pCNV
    // /// @param who      address that will receive redeemed CNV
    // /// @param amountIn amount of pCNV
    // function redeemAmountOut(address who, uint256 amountIn) public view returns (uint256) {
    //     // Make sure amountIn is less than participants maximum redeem amount in
    //     require(amountIn <= maxRedeemAmountIn(who), AMOUNT_ERROR);
    //
    //     // Calculate percentage of maxRedeemAmountIn that participant is redeeming
    //     uint256 ratio = 1e18 * amountIn / maxRedeemAmountIn(who);
    //
    //     // Calculate portion of maxRedeemAmountOut to mint using above percentage
    //     return maxRedeemAmountOut(who) * ratio / 1e18;
    // }

    // /// @notice     Returns amount of pCNV that user can redeem according to vesting schedule
    // /// @dev        Returns redeem * percentageVested / (eth normalized) - total already redeemed
    // /// @param who  address to check
    // function maxRedeemAmountIn(
    //     address who
    // ) public view returns (uint256) {
    //     // Make sure pCNV is currently redeemable for CNV
    //     if (!redeemable) return 0;
    //     // Make sure there's CNV supply
    //     if (CNV.totalSupply() == 0) return 0;
    //     // Access sender's participant memory
    //     Participant memory participant = participants[who];
    //     // return maximum amount of pCNV "who" can currently redeem
    //     return participant.purchased * purchaseVested() / 1e18 - participant.redeemed;
    // }

    // /// @notice     Returns amount of CNV that an account can currently redeem for
    // /// @param who  address to check
    // function maxRedeemAmountOut(
    //     address who
    // ) public view returns (uint256) {
    //     return amountVested() * percentToRedeem(who) / 1e18;
    // }

    // /// @notice     Returns percentage (denominated in ether) of pCNV supply that a given account can currently redeem
    // /// @param who  address to check
    // function percentToRedeem(
    //     address who
    // ) public view returns (uint256) {
    //     return 1e18 * maxRedeemAmountIn(who) / maxSupply;
    // }

    // /// @notice Returns the amount of time (in seconds) that has passed since the contract was created
    // function elapsed() public view returns (uint256) {
    //     return block.timestamp - GENESIS;
    // }

    // /// @notice Returns the percentage of CNV supply (denominated in ether) that all pCNV is currently redeemable for
    // function supplyVested() public view returns (uint256) {
    //     return elapsed() > TWO_YEARS ? 1e17 : 1e17 * elapsed() / TWO_YEARS;
    // }
    //
    // /// @notice Returns the percent of pCNV that is redeemable
    // function purchaseVested() public view returns (uint256) {
    //     return elapsed() > TWO_YEARS ? 1e18 : 1e18 * elapsed() / TWO_YEARS;
    // }

    // /// @notice Returns total amount of CNV supply that is vested
    // function amountVested() public view returns (uint256) {
    //     return CNV.totalSupply() * supplyVested() / 1e18;
    // }

    /* ---------------------------------------------------------------------- */
    /*                             INTERNAL LOGIC                             */
    /* ---------------------------------------------------------------------- */

    /// @notice               Deposits FRAX/DAI for pCNV if merkle proof exists in specified round
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
        require(tokenIn == address(DAI) || tokenIn == address(FRAX), TOKEN_IN_ERROR);

        // Require merkle proof with `to` and `maxAmount` to be successfully verified
        require(MerkleProof.verify(proof, merkleRoot, keccak256(abi.encodePacked(to, maxAmount))), "!PROOF");

        // Verify amount claimed by user does not surpass "maxAmount"
        uint256 newAmount = spentAmounts[merkleRoot][to] + amountIn; // save gas
        require(newAmount <= maxAmount, AMOUNT_ERROR);
        spentAmounts[merkleRoot][to] = newAmount;

        // Calculate rate of pCNV that should be returned for "amountIn"
        amountOut = amountIn * 1e18 / rate;

        // make sure total minted + amount is less than or equal to maximum supply
        // require(totalMinted + amountOut <= maxSupply, AMOUNT_ERROR);

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

        emit Minted(sender, to, amountOut, amountIn, totalMinted);
    }

    // /// @notice         Maintains total amount of redeemable tokens when pCNV is being transfered
    // /// @param from     address tokens are being transfered from
    // /// @param to       address tokens are being sent to
    // /// @param amount   number of tokens being transfered
    // function _beforeTransfer(
    //     address from,
    //     address to,
    //     uint256 amount
    // ) internal {
    //     // transfers must not be paused
    //     require(!transfersPaused, "PAUSED");

    //     // Interface "to" participant storage
    //     Participant storage toParticipant = participants[to];

    //     // Interface "from" participant storage
    //     Participant storage fromParticipant = participants[from];

    //     // calculate amount to adjust redeem amounts by
    //     uint256 adjustedAmount = amount * fromParticipant.redeemed / fromParticipant.purchased;

    //     // reduce "from" redeemed by amount * "from" redeem purchase ratio
    //     fromParticipant.redeemed -= adjustedAmount;

    //     // reduce "from" purchased amount by the amount being sent
    //     fromParticipant.purchased -= amount;

    //     // increase "to" redeemed by amount * "from" redeem purchase ratio
    //     toParticipant.redeemed += adjustedAmount;

    //     // increase "to" purchased by amount received
    //     toParticipant.purchased += amount;
    // }

    /// @notice         Rescues accidentally sent tokens and ETH
    /// @param token    address of token to rescue, if address(0) rescue ETH
    function rescue(address token) external onlyConcave {
        if (token == address(0)) payable(treasury).transfer( address(this).balance );
        else ERC20(token).transfer(treasury, ERC20(token).balanceOf(address(this)));
    }
}

// © 2022 WTFPL – Do What the Fuck You Want to Public License.
