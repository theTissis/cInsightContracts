// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./../libs/SbtLib.sol";
import "./../skinnft/ISkinNft.sol";

contract Sbt {
    modifier onlyOwner() {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        require(msg.sender == sbtstruct.contractOwner, "OWNER ONLY");
        _;
    }
    event ContractOwnerChanged(address _newOwner);

    function init(
        address _contractOwner,
        string calldata _name,
        string calldata _symbol,
        string calldata _baseURI,
        bytes32 _validator,
        address _nftAddress
    ) external {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        require(sbtstruct.contractOwner == address(0), "INITIATED ALREADY");
        sbtstruct.contractOwner = _contractOwner;
        sbtstruct.name = _name;
        sbtstruct.symbol = _symbol;
        sbtstruct.baseURI = _baseURI;
        sbtstruct.validator = _validator;
        sbtstruct.nftAddress = _nftAddress;
        sbtstruct.skinNft = ISkinNft(_nftAddress);
        sbtstruct.interfaces[(bytes4)(0x01ffc9a7)] = true; //ERC165
        sbtstruct.interfaces[(bytes4)(0x5b5e139f)] = true; //ERC721metadata
    }

    mapping(bytes4 => address) public implementations;

    // storage type に calldataを用いると変数はimmutableになりガス代節約できる。
    function setImplementation(
        bytes4[] calldata _sigs,
        address[] calldata _impAddress
    ) external {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        require(msg.sender == sbtstruct.contractOwner, "OWNER ONLY");
        require(_sigs.length == _impAddress.length, "INVALID LENGTH");
        for (uint256 i = 0; i < _sigs.length; i++) {
            unchecked {
                implementations[_sigs[i]] = _impAddress[i];
            }
        }
    }

    function contractOwner() external view returns (address) {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        return sbtstruct.contractOwner;
    }

    // supportしているERCversionなど
    function supportsInterface(bytes4 _interfaceID)
        external
        view
        returns (bool)
    {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        return sbtstruct.interfaces[_interfaceID];
    }

    function name() external view returns (string memory) {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        return sbtstruct.name;
    }

    //0x95d89b41
    function symbol() external view returns (string memory) {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        return sbtstruct.symbol;
    }

    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        return
            string(
                abi.encodePacked(sbtstruct.baseURI, toString(_tokenId), ".json")
            );
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        return sbtstruct.owners[_tokenId];
    }

    function setBaseUri(string memory _newBaseURI) external onlyOwner {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        sbtstruct.baseURI = _newBaseURI;
    }

    function setContractOwner(address _newContactOwner) external onlyOwner {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        sbtstruct.contractOwner = _newContactOwner;
        emit ContractOwnerChanged(_newContactOwner);
    }

    function getFavo(address _address) external view returns (uint) {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        return sbtstruct.favos[_address];
    }

    function getMaki(address _address) external view returns (uint) {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        return sbtstruct.makis[_address];
    }

    function getGrade(address _address) external view returns (uint) {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        return sbtstruct.grades[_address];
    }

    function getRate(address _address) external view returns (uint) {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        return sbtstruct.rates[_address];
    }

    function getReferral(address _address) external view returns (uint) {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        return sbtstruct.referrals[_address];
    }

    function getNftPoint(address _address) external view returns (uint) {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        return sbtstruct.nftPoints[_address];
    }

    function getFavoNum() external view returns (uint) {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        return sbtstruct.favoNum;
    }

    function setFavoNum(uint8 _favoNum) external onlyOwner {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        sbtstruct.favoNum = _favoNum;
    }

    function getReferralRate() external view returns (uint8[] memory) {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        return sbtstruct.referralRate;
    }

    function setReferralRate(uint8[] memory _referralRate) external onlyOwner {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();

        // TODO: referralRateのサイズを大きくしたときの挙動
        for (uint i = 0; i < _referralRate.length; i++) {
            sbtstruct.referralRate[i] = _referralRate[i];
        }
    }

    function getLastUpdatedMonth() external view returns (uint) {
        SbtLib.SbtStruct storage sbtstruct = SbtLib.sbtStorage();
        return sbtstruct.lastUpdatedMonth;
    }

    // utility function from openzeppelin

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            unchecked {
                digits++;
                temp /= 10;
            }
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            unchecked {
                digits -= 1;
                // 48 は0のascii値
                buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
                value /= 10;
            }
        }
        return string(buffer);
    }

    fallback() external payable {
        address _imp = implementations[msg.sig];
        require(_imp != address(0), "Function does not exist");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _imp, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    receive() external payable {}
}
