// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
import "./../skinnft/ISkinNft.sol";

library SbtLib {
    bytes32 constant SBT_STRUCT_POSITION = keccak256("chaininsight");

    struct SbtStruct {
        address admin;
        string name;
        string symbol;
        string baseURI;
        bytes32 validator;
        mapping(bytes4 => bool) interfaces;
        mapping(uint256 => address) owners; // token_id -> address
        mapping(address => uint) favos; // favoした回数
        mapping(address => uint) makis;
        mapping(address => uint) grades;
        mapping(address => uint) makiMemorys;
        mapping(address => uint) referrals; // リファラルした回数
        mapping(address => uint) nftPoints; // nft付与権限数
        mapping(address => address) referralMap; // mapping(to => from)
        uint16 mintIndex;
        uint16 burnNum;
        uint16 favoNum;
        uint8[] referralRate; // grade 1, 2, 3, 4, 5
        uint8[] nftNumRate; // grade 1, 2, 3, 4, 5
        uint8 lastUpdatedMonth;
        address nftAddress;
        uint256 sbtPrice;
        uint256 sbtReferralPrice;
        uint256 sbtReferralIncentive;
    }

    // get struct stored at posititon
    //https://solidity-by-example.org/app/write-to-any-slot/
    function sbtStorage() internal pure returns (SbtStruct storage sbtstruct) {
        /** メモ: @shion
         * slot: storageは32バイトの領域を確保するが，その領域をslotと呼ぶ
         * positionのstrunctを参照する
         */
        bytes32 position = SBT_STRUCT_POSITION;
        assembly {
            sbtstruct.slot := position
        }
    }
}
