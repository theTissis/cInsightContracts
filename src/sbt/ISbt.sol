// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface ISbt {

    event adminChanged(address _newOwner);

    function setImplementation(
        bytes4[] calldata _sigs,
        address[] calldata _impAddress
    ) external;

    function admin() external view returns (address);

    function supportsInterface(bytes4 _interfaceID) external view returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 _tokenId) external view returns (string memory);
    
    function ownerOf(uint256 _tokenId) external view returns (address);

    function setAdmin(address _newContactOwner) external;

    function favoOf(address _address) external view returns (uint);

    function makiOf(address _address) external view returns (uint);

    function gradeOf(address _address) external view returns (uint);
    
    function makiMemoryOf(address _address) external view returns (uint);

    function referralOf(address _address) external view returns (uint);
    
    function monthlyDistributedFavoNum() external view returns (uint);
    
    function referralRate() external view returns (uint8[] memory);
    
    function lastUpdatedMonth() external view returns (uint);
    
    function sbtPrice(bool isReferral) external view returns (uint256);

    function setBaseUri(string memory _newBaseURI) external;

    function setMonthlyDistributedFavoNum(uint16 _monthlyDistributedFavoNum) external;

    function setGradePriseRates(
        uint8[] memory _referralRate,
        uint8[] memory _skinnftNumRate,
        uint8[] memory _gradeRate
    ) external;

}
