// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.0;



/**

     ██████╗ ██████╗ ███╗   ██╗ ██████╗ █████╗ ██╗   ██╗██████╗
    ██╔════╝██╔═══██╗████╗  ██║██╔════╝██╔══██╗██║   ██║╚════██╗
    ██║     ██║   ██║██╔██╗ ██║██║     ███████║██║   ██║ █████╔╝
    ██║     ██║   ██║██║╚██╗██║██║     ██╔══██║╚██╗ ██╔╝ ╚═══██╗
    ╚██████╗╚██████╔╝██║ ╚████║╚██████╗██║  ██║ ╚████╔╝ ██████╔╝
     ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝  ╚═══╝  ╚═════╝

    Concave A Token

*/

/* -------------------------------------------------------------------------- */
/*                                   IMPORTS                                  */
/* -------------------------------------------------------------------------- */

import { ERC20 } from "@solmate/tokens/ERC20.sol";
import { SafeTransferLib } from "@solmate/utils/SafeTransferLib.sol";
import { MerkleProof } from "@openzeppelin/utils/cryptography/MerkleProof.sol";
import { ICNV } from "./interfaces/ICNV.sol";

/// @notice Concave A Token
/// @author 0xBarista & Dionysus (ConcaveFi)
contract aCNV is ERC20("Concave A Token (aCNV)", "aCNV", 18) {

    /* ---------------------------------------------------------------------- */
    /*                                DEPENDENCIES                            */
    /* ---------------------------------------------------------------------- */

    using SafeTransferLib for ERC20;

    /* ---------------------------------------------------------------------- */
    /*                             IMMUTABLE STATE                            */
    /* ---------------------------------------------------------------------- */

    /// @notice FRAX tokenIn address
    ERC20 public immutable FRAX = ERC20(0x853d955aCEf822Db058eb8505911ED77F175b99e);

    /// @notice DAI tokenIn address
    ERC20 public immutable DAI = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    /// @notice Error related to amount
    string constant AMOUNT_ERROR = "!AMOUNT";

    /// @notice Error related to token address
    string constant TOKEN_IN_ERROR = "!TOKEN_IN";

    /// @notice Error minting exceeds supply
    string constant EXCEEDS_SUPPLY = "EXCEEDS_SUPPLY";

    /// @notice Error transfers paused
    string constant PAUSED = "PAUSED";

    /* ---------------------------------------------------------------------- */
    /*                              MUTABLE STATE                             */
    /* ---------------------------------------------------------------------- */

    /// @notice CNV ERC20 token
    /// @dev will be address(0) until redeemable = true
    // ICNV public CNV;

    /// @notice Address that is recipient of raised funds + access control
    address public treasury = 0x226e7AF139a0F34c6771DeB252F9988876ac1Ced;

    /// @notice Returns the current merkle root being used
    bytes32 public merkleRoot;

    /// @notice Returns an array of all merkle roots used
    bytes32[] public roots;

    /// @notice Returns the current pCNV price in DAI/FRAX
    uint256 public rate;

    /// @notice Returns the max supply of pCNV that is allowed to be minted (in total)
    uint256 public maxSupply = 333_000 * 1e18;

    /// @notice Returns the total amount of pCNV that has cumulatively been minted
    uint256 public totalMinted;

    /// @notice Returns whether transfers are paused
    bool public transfersPaused = true;

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

    /// @notice                 Emitted when Concave changes max supply
    /// @param  oldMax          old max supply
    /// @param  newMax          new max supply
    event SupplyChanged(uint256 oldMax, uint256 newMax);

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

    /// @notice         mint amount to target
    /// @param target   address to which to mint; if address(0), will burn
    /// @param amount   to reduce from max supply or mint to "target"
    function manage(
        address target,
        uint256 amount
    ) external onlyConcave {
        uint256 newAmount = totalMinted + amount;
        require(newAmount <= maxSupply,EXCEEDS_SUPPLY);
        totalMinted = newAmount;
        // mint target amount
        _mint(target, amount);
        emit Managed(target, amount, totalMinted);
    }

    /// @notice             manage max supply
    /// @param _maxSupply   new max supply
    function manageSupply(uint256 _maxSupply) external onlyConcave {
        require(_maxSupply >= totalMinted, "LOWER_THAN_MINT");
        emit SupplyChanged(maxSupply, _maxSupply);
        maxSupply = _maxSupply;
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
        require(!transfersPaused,PAUSED);
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
        require(!transfersPaused,PAUSED);
        // default ERC20 transfer
        return super.transferFrom(from, to, amount);
    }

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
        require(totalMinted + amountOut <= maxSupply, EXCEEDS_SUPPLY);

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

    /// @notice         Rescues accidentally sent tokens and ETH
    /// @param token    address of token to rescue, if address(0) rescue ETH
    function rescue(address token) external onlyConcave {
        if (token == address(0)) payable(treasury).transfer( address(this).balance );
        else ERC20(token).transfer(treasury, ERC20(token).balanceOf(address(this)));
    }
}

/**

    "someone spent a lot of computational power and time to bruteforce that contract address
    so basically to have that many leading zeros
    you can't just create a contract and get that, the odds are 1 in trillions to get something like that
    there's a way to guess which contract address you will get, using a script.. and you have to bruteforce for a very long time to get that many leading 0's
    fun fact, the more leading 0's a contract has, the cheaper gas will be for users to interact with the contract"

        - some solidity dev

    © 2022 WTFPL – Do What the Fuck You Want to Public License.
*/
