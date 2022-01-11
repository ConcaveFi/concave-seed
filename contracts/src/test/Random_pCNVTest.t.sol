// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;
/// ============ Imports ============

import { DSTest } from "ds-test/test.sol"; // DSTest
// import { DAI } from "../mocks/DAI.sol";
// import { FRAX } from "../mocks/FRAX.sol";
import { pCNV } from "../pCNV.sol";
import "./utils/VM.sol";

interface IStable {


    // --- Auth ---
  function wards() external returns ( uint256 );

  function rely(address guy) external;

  function deny(address guy) external;

    // --- Token ---
  function transfer(address dst, uint wad) external returns (bool);

  function transferFrom(address src, address dst, uint wad) external returns (bool);

  function mint(address usr, uint wad) external;

  function burn(address usr, uint wad) external;

  function approve(address usr, uint wad) external returns (bool);

    // --- Alias ---
  function push(address usr, uint wad) external;

  function pull(address usr, uint wad) external;

  function move(address src, address dst, uint wad) external;

    // --- Approve by signature ---
  function permit(address holder, address spender, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s) external;
}

contract Random_pCNVTest is DSTest {

    // address FRAX = 0x3C0a7EC8c962A85bfB1e4FcfD4bB71C8128dE6f7;
    address FRAX = 0xE7E9F348202f6EDfFF2607025820beE92F51cdAA;
    // address DAI = 0x448C56C5eA442908238072eFb7f5Ce58E22C161C;
    address DAI = 0x7B731FFcf1b9C6E0868dA3F1312673A12Da28dc5;
    address TREASURY = 0xB1DF8b1E93172235eEB8Bbb60D4356f046dff3AF;
    // pCNV pcnv = pCNV(0xb6308694BfC72a558cD349c8878877524915E652);
    pCNV pcnv = pCNV(0x0256eBDd5A71c0D3819A61DfA02130fA1cdAb1cF);


    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address[73] whitelist_addresses = [
        0xcF10B967a9e422753812004Cd59990f62E360760,
        0x7287C2833d51b49Af4EBCceEc51c0635F14c72A7,
        0xF10a439c132fEfd08B45E24D6838B1E1dC31Fdf0,
        0xC86d15920f454933088e8a68bd36832C53705127,
        0x10B5BAAf2BB8878CF35FDEFfA5C3183D30Be5682,
        0xd53Db76369fBb6584E0BeC45d4e8D62eB46E5700,
        0xb3355Ee5E480794C51ea44f46c659f86ee75dd29,
        0x14B2bB6C897C31f803Fd0cba0E76AB43073b337d,
        0x3cb5560E8E4B666c01bBF74ffbAAabA88052F531,
        0x0efc6819167B7b3ca0DaEe2aaEc339cA9D55e0ca,
        0x1146f36Cf74fBB2971DcDA652d0a3f4289a39d53,
        0x85338a1BE31645972851B8d9d0936Ec8E1c45d40,
        0xD704cCd599f005C7c7Aa1cBFDDd01249D05a96EB,
        0xF9a25f8AB7a07d120E5C2E895Ee71B5e09Ed0fC7,
        0x21bBB085b58a94B86D8706262A4f04f76b860183,
        0xDF9cF2bD8e615Ad95879Af68594EE838E44Fc36A,
        0x35a214b13c9E223B8D511f343aC8Fa94293233a1,
        0xB5eB1cdda34E5a40bEbFE839dae65f3B42827721,
        0x859909d689164e650427f23c024C465BB6ceC2a3,
        0xf3e9848D5accE2f83b8078ee21f458e59ec4289A,
        0x268C3D74373E394470Ff89D49374b3a7E15b4fA4,
        0x1b9AD98ADe24595d5b02BF994e030b0058494A73,
        0xC2aD4a403668a2f5A60f95ef6B6B94e684372139,
        0xd5E09e5322A26A8159B67efbd8Eb462Ed9a297d8,
        0xED39cc08B5bFaBA3E41F58187cF908034Fe14d86,
        0xddd7477Ea9E1C5b2bc325097c1064d94595CE049,
        0xe3fccDEE131de98cB5dF3304508677Fa5fcDD6d4,
        0x0b0f171A90f2620062bC559255E90a914aD10A0e,
        0x83E84CC194E595B43dCEDfBFfC3e0358366307f1,
        0xB835367ae1CaFCEa58a10A51b17Fea25d16c3daB,
        0x1200Eb4fA3dF9903fC6EfF1d7A4a5D17502329b2,
        0xa2D638ADa840080dE73971e49A52EaF00ce18474,
        0xd3e38c017d441558135549719f9f9C398A64FDab,
        0x72a5Ba942a401C4BD08a32963B75f971292213a8,
        0x35aA3f733958b7416669303945093C98819F77A6,
        0x1eb322c016815EE5b29c071586C1B75Be5934576,
        0x90F99593761048F38E1B05fFC9807C50260ff578,
        0xbbE56bb006a28CdA016F7C599eFf4AAAdd07C21C,
        0x5F7476ACa630A79d89b8A1b4D92fc91c65c01abF,
        0x2aA48F410007b7380d2846D03142FebbBEDEb3d3,
        0x9ead5E6E90440e69B5F28fEF5942a5B273387c13,
        0xD3A5211477e05F93b632F45817b85dF4676b4bD6,
        0xCdD27fDF1B991E9DEB8647EE3D8Ac1bdB7D6b675,
        0x048aD0A6D74baDE422AE4080F17fC311d3AaEc83,
        0xc1D4BFD94909B589Bee19062e375D17Bbd5E6799,
        0x21Cf5649ee1a9362202EBfF266Ef7BBC8c26A917,
        0xbCdD2C687B2a7108DeabD863E97F3c91E255bee6,
        0x103CDE1a2F5eD7ce509a178F9cFb9E56553dc45b,
        0x7a116b21E0c8729B8B6939bd526274Da0208743D,
        0xcf0955Df076CA2F3c2f83ca0eb8502bFF5F0838A,
        0x5baa7640a5B174501A9BC84e7840B15E4BEb16Da,
        0xda5F5ded37d1f0557DD3368Ac01cACaCBedd894F,
        0xCFFE08BDf20918007f8Ab268C32f8756494fC8D8,
        0xf04946c11127A096Bcd6a572c01C89C164f2fa12,
        0xAE3D494962fDCf949C4730C57B01966B961dE739,
        0x9119d4944EDA5CE0DD3FEEDA56a480cDA84C298a,
        0x50f4E9255A2CAe88e722B979d6b3aE31f75c275f,
        0x34310d39bAc32e41692a90d26Dd2D302Fb28e1a8,
        0x7f5B215C995c4676a37584008D29E27CF9940333,
        0x23BA9199695f9A20450D08fDb486Ed74c6a1d5EB,
        0x971d45c96CcabF15189D5786bb4cA780CB7A7f0C,
        0x2d4eB91CdDeA03a2A55CcCa343147ECA764076e2,
        0xDF5DdB99e37A477C55c7e54C7Dca837aC584FaDC,
        0xF265405140576D919E2Cef2409eF9fC95d41800a,
        0xeF5C00882A09b86EE38dF6ebf522E3e2fa578C64,
        0x20C78abE2D3C77Cb9Dc08F3a41cB6542B803de7B,
        0x113Cc14036838713bf7cE46af8457F123cC39416,
        0xFcff35118952f1F69313d76f6c46a4ce83F75F3a,
        0x69aB6A84385743268b64bd985ACCf14fC13Fdd65,
        0xe0f4498F76bFf3516bE84A7995Aa28d581541f48,
        0x000000c7000cc57FD1BF6729849B9eDcC8fE9102,
        0x9D575A675De6a1cc125ECfC34439D17DcCe13Df7,
        0x02f98c63E6352C06Fa8D5F14c004926F165CEe74
    ];

    uint256[73] leafs = [
        0x4aa8314bb6a7011f02a48f7fb529a59401ef1cdb4bf593af93a44a8fbf477500,
        0x66fb91188a14ab90dbb2a8fcdec3185cfb20039c9e59c31818ab222aca67b805,
        0x4bedee810d1141aca2ad815a542aa35dd3d960f6ea7b1058aa397663c3b60b40,
        0xeed1bea13eaa5698be381cf1d86ad600632b893527ad0ebddf403fc8f0de8baf,
        0xce3e384e0fc8004dc325646f9146dab2151730f87028f9f8d55a1a75c4928c59,
        0x2401b91017cdcacbd8015b08a14ae2d3d502e9daf01d6284b80105f12eb316f4,
        0xe3d9dde9237feda4a6a5883a2ae291b2c9bbaaa8eede8cc8121d29e906703aa6,
        0x04c22309109c5f96a5d1dabd639999d4d21d6bf1b62af0680fd1ddc6ff964fdd,
        0x5bf0dd2ee24e10097dbb95be99067d914156371d542bcaf35de238f122ddf375,
        0x4cec690fd8424966007407a9298a2fae8a1e22a8b6d265f91e9d227669c863d5,
        0xdb4c42955788be0ff485f9fb4a3a907f137ee9a40e5ab910db95877c72643a00,
        0xcbcfcd286b03c1defaf9a5aba815a4c4fabef61945b9c97789578a10c4291b58,
        0x85d51e702f57fb958e8c71640f43633ee26751ef0d094281345b9355b7b5a277,
        0x5007e8fd8ed5b38da3e99f80760a525ac9a5642cccee911117b425556d1c50a2,
        0x0ba62b6530c43ab21c67c4ca2a12b018e9a6c278a130a74e7e48253bb3e40b26,
        0x8a219b508efd86983d5bf66de45a48eb70d743f20f84c2731d8c3f056b227461,
        0x62aba60cdf824a7649f7591e6aa2bc4515243e4c6cb1aa256d28f95167aa26d7,
        0x213a3d893f39039327cab238f591f63a88c170f2a544332f4ee1b82d69d3da6b,
        0x70738bf4958031ab6257405308cc6145cb52bc3091ad6b6c91501974b3c7e71b,
        0xea2465870e9d408dff1801f03f23a85fc0ab05164c99d44ba45dc2849443a4a6,
        0xe5463c804d85ab8eef65511e7b5710f794660178a03c7dd5ef18003d7f0fdc48,
        0x99a4642f3257c2aae0c7589da7df405612d056410898fff3d36c60230887afc5,
        0xf7e47127e898c839e61c7854c7126a3a73d6d1b8202d2638043de74f22962b6d,
        0x639dc0d8200bc76cff6de014684179df99576309e7d8391ed2cb80c881d9082f,
        0xa5fc64dc14669c3cd1330410ef774505dd03b3a26619b8d2c526b4743579d4f2,
        0xdbf36cf8a75e58165fc9f70ad2ab8e8bd0788e8f5924284665bbe0a9e9c94e02,
        0xe3a4495c217716bb261402c682da32b61b0b49003e4c2b5a6cf22255bd85ae06,
        0xa7caff8b6dd4c15eaff9d64fa0ae32bf4e748f5f678979518b03d04ef89f34ac,
        0xf8f7586849020e8de7ba550d9779823b2f5d9ae68a8ceb0effe56bada1c93f48,
        0x42fd570adcfe1d6026c3698defc336c6001035e0976eddb92a33f8e3c30c5025,
        0x958856bd6291c0fcb8a39a126fdb780f454dafde425f14b7539485b367c0f810,
        0x7c49133b6b7a5c94ae672d01bf2e752b6204e92e6475ab7a58d2c943d6b3cc27,
        0xd2408c49dbea40ec8af41412b0bea979f99401778ec9c4854b466b51d21ab362,
        0x83189b6db359f0471aa81a80e4c64723793790ecc03ef47b0f0214ad8ddd8a8c,
        0xb0400a1cf62387f0fd2d7f5ef1a3c58c65d727c9e5d1e48ab9989889083aa505,
        0x6ecfd22bde1c838aed3291b5bbcf70c580fddba54b3f6a001d4ccf358effed86,
        0x4a2b3f12e5e97adda93d3ef45d1fe5d1658e5c7e26bd00bd8820626276716940,
        0xad452ead4785e5526b1c84fc9fa4bba13af250f080e35b694f57a3dfa7f0a7d7,
        0x3ba2fe3be4355751e4ad2ad7ea2040c26fb5862036bdc23f474cbbb6355cf4da,
        0x914ecb54b55000c04b347ef8cc3deaf6eb22c305d37ad13265e9e48967e1c73b,
        0x67cc988babaafb98a0080cdf1c137192ba5c6a5bb303985fc3e40f5e203977e5,
        0xb9df6599ec1e2616e2b52917e16fe3d9a45bbbeb5cd9e3452c4b99ff253aaa8a,
        0xdb46f8931be65728f849ef60e07b9f55e461477ef6413e6046a2ebb27cedd191,
        0x748c2484a6246e1857027d16998c4b5080263a8b2dd451a450fb84a60c739693,
        0x4d7210a421c5fb1ab18fd3493f4d852a3d6df241a1b2a1c9bd133174ecdf4311,
        0xd07f7a200874b4b9f8b3ba3a6814ae662915f0daf5b47439c569db85e039e643,
        0x18334d142e9e9c36004b1d46fc752f23b261edd986e05033af2b14305338aa3d,
        0x25999d8818d5d13ebddf9c71459413cd578a4bf2528941d2a8c039036e07ad02,
        0xfa6fd5e3e0687b1a5c2900051cf6830a727d12e258f2c01dd5a7894b67c73807,
        0x7fa078980e0833ffa0f08471f16db4b0423e5759a7066b70671b798eb6b8385d,
        0x97750eee520b1bc748dfacace090776bafdd9d612386062717a314088d1c695b,
        0x69a06afa84f78515efd65efa9713f0595be6d49de44125d523e5ea13fba9be91,
        0x534f545bef4919674be9268273ca4f63d1bde8d83126cb13812b22525ca227b3,
        0x015068975f70c83277c98a5284d40343a4c794b2feba66ddb19063048574c590,
        0x88b4c3532765387d9359be8b5bd0502f21dfdd5e2598e633e7b70ab36b7a7116,
        0x874786f4ad965f02f8f4b8f434846ad7fd06c7bcc7c6ca41a397dacbc837d563,
        0x04ee92ec5efb20d69c9837ff7c40d18cc6473f22e40e453d5e506071a040754a,
        0x1f7cd5ec021fee600fa841648988ba3fdf587639c000a83f819a5ca7b1d10c98,
        0xd5de9c1eff0023e3a32d6e0ccb7b3c3c066604457d8bcbb0cb61b9897774531c,
        0xe14e2046c0fa20f869b78446db9e253187d46126c0a1a6a5908b084ded1590fc,
        0x9728752d0583fcd01632e94888cc91310d6ab3a56e07c4f085a1950377748e0a,
        0xda72136fc23b7c7f22edf68f97e52e88d94dcedc379fd4582e672a7df2dc190b,
        0x58a8f71ca7b8984826fa77d0ddf3582a70b48f2ea57b98eaeb588df9c380b538,
        0xc03917d050ffe1bdb75d6d08fc6b9bfbdae2a8ad2187ef3e31c337e216e99927,
        0xc2ac5abbf374934cb06112c992ef09793adb8d813be6fd0f3ccffe10d4553bcf,
        0x7601034b087230f9e34e62199ccf9dafeb743632c1da6665d8a36b51b8a9ba2e,
        0x2c4dbccbd5c5fe98958cfc4d407671fe07ede44acdac544ab672ce144e4d7de9,
        0xbf1d631defe2226c968907487f3ad913ac833ba1b388172027736588b7e3cf7e,
        0x157de65da1ff467e2c3a743a1237a4c635aee174ab3aad02e4b3829f5ab95008,
        0x2ce21d4d768c4f38494e4705e8a5b451d50805ed1ea694ad965674b00d64e0d9,
        0xe5a343f46013d8e2c055bad3fc55fefd7fb9249e34b5125cca48ca879428a8c9,
        0xd10039b0efdc71ca4b72aad4bb8f89b3934a062fd65d9710887370253afffed1,
        0xfe2650306d15414fec0db252f6b3f4a0539ec3c1a760af323e755348e80636cb
    ];

    uint256[73] amounts = [
        100000,  50000, 200000,  25000, 300000,  50000, 100000,
        150000,  25000, 100000,  10000,  10000,  10000,   1000,
        110000,  27000, 100000,  20000, 100000, 100000,  30000,
        500000,  30000,  12000, 100000, 100000,  20000, 300000,
        10000,  10000,  10000,  10000,  10000,  10000,  10000,
        10000,  10000,  10000,  10000,  10000,  10000,  10000,
        10000,  10000,  10000,  10000, 200000, 600000, 100000,
        125000, 125000,  50000,  50000,  45000,  10000,  10000,
        2000,   1000,   3000,   2000,   1000,   2000,   3000,
        1000,   4000,   5000,   1000,   5000,   1000, 150000,
        100000,   2000,  50000
    ];
    // function setUp() public {
    //
    // }
    function test_wip() public {
        newRound(
            0xfb81565e4c9084b6b582aef7a3f8fdc5cedc4a3c28de4e510baefbfea40ebd88,
            4508000e18,
            3e18,
            block.timestamp+1000
        );
        claim_player(0);
    }

    function claim_player(uint256 ix) public {
        address addy = whitelist_addresses[ix];
        uint256 maxAmount = amounts[ix]*1e18;
        uint256 amountIn = maxAmount;
        bytes32[] memory aliceProof = new bytes32[](1);
        aliceProof[0] = 0x4aa8314bb6a7011f02a48f7fb529a59401ef1cdb4bf593af93a44a8fbf477500;
        IStable(DAI).mint(addy,maxAmount);
        vm.startPrank(TREASURY);
        pcnv.mint(
            addy,
            DAI,
            0,
            maxAmount,
            amountIn,
            aliceProof
        );
        vm.stopPrank();

    }

    function newRound(
        bytes32 merkleRoot,
        uint256 maxDebt,
        uint256 rate,
        uint256 deadline
    ) public {
        vm.startPrank(TREASURY);
        pcnv.newRound(
            merkleRoot,
            maxDebt,
            rate,
            deadline
        );
        vm.stopPrank();
    }


    // function test_wip() public {
    //     address FRAX = 0x3C0a7EC8c962A85bfB1e4FcfD4bB71C8128dE6f7;
    //     address DAI = 0x448C56C5eA442908238072eFb7f5Ce58E22C161C;
    //     address TREASURY = 0xB1DF8b1E93172235eEB8Bbb60D4356f046dff3AF;
    //
    //     // DAI dai = new DAI(1);
    //     // dai.mint(0x0132e6a13583DF322a170227a0Fb1E3a1adB284B,10000000e18);
    //     // require(dai.balanceOf(0x0132e6a13583DF322a170227a0Fb1E3a1adB284B) == 10000000e18);
    //     //
    //     // FRAX frax = new FRAX(1);
    //     // frax.mint(0x0132e6a13583DF322a170227a0Fb1E3a1adB284B,10000000e18);
    //     // require(frax.balanceOf(0x0132e6a13583DF322a170227a0Fb1E3a1adB284B) == 10000000e18);
    // }

    // bytes32[] public hashes;
    //
    // function setUp() public virtual {
    //     address[5] memory transactions = [
    //         // "alice -> bob",
    //         // "bob -> dave",
    //         // "carol -> alice",
    //         // "dave -> bob"
    //         0x0132e6a13583DF322a170227a0Fb1E3a1adB284B,
    //         0x08212DFFb0FAA20073511f87526547cAE00b7a64,
    //         0xB1DF8b1E93172235eEB8Bbb60D4356f046dff3AF,
    //         0xf1A1e46463362C0751Af4Ff46037D1815d66bB4D,
    //         0x109F93893aF4C4b0afC7A9e97B59991260F98313
    //
    //     ];
    //     uint256[5] memory values = [
    //         uint256(10e18),
    //         uint256(20e18),
    //         uint256(30e18),
    //         uint256(40e18),
    //         uint256(60e18)
    //     ];
    //
    //     for (uint i = 0; i < transactions.length; i++) {
    //         hashes.push(keccak256(abi.encodePacked(transactions[i],values[i])));
    //     }
    //
    //     uint n = transactions.length;
    //     uint offset = 0;
    //
    //     while (n > 0) {
    //         for (uint i = 0; i < n - 1; i += 2) {
    //             hashes.push(
    //                 keccak256(
    //                     abi.encodePacked(hashes[offset + i], hashes[offset + i + 1])
    //                 )
    //             );
    //         }
    //         offset += n;
    //         n = n / 2;
    //     }
    // }
    //
    // // Proper Merkle Root
    // // 0xed22b1673d04a64fa29ed896e69fc972e29ca396c2cbf5d400544729c6eb0a20
    //
    // function test_wip_getRoot() public {
    //     // for (uint i; i < hashes.length; i++) {
    //     //     emit log_bytes32(hashes[i]);
    //     // }
    //     emit log_bytes32(hashes[hashes.length - 1]);
    //     // return hashes[hashes.length - 1];
    // }


    // 0xe826e58f53e8fdd8a73454629ce1e846e33eef5d929d5602334ce06e14298eb3
    // 0xe826e58f53e8fdd8a73454629ce1e846e33eef5d929d5602334ce06e14298eb3

    // 0xe826e58f53e8fdd8a73454629ce1e846e33eef5d929d5602334ce06e14298eb3






    // 0x4f10ef13d2889068e1ee8c44679d6f9f954003fc89c03b78a81a4e70542d915e
    // 0x0c8507be0254f1dd0c00949ba01bd75385fcbb6c9d276624c4de628ad12159fe


}
