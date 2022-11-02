// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import {ChainInsightLogicV1} from "src/governance/LogicV1.sol";
import {ChainInsightExecutorV1} from "src/governance/ExecutorV1.sol";
import {ChainInsightGovernanceProxyV1} from "src/governance/ProxyV1.sol";
import {Sbt} from "src/sbt/Sbt.sol";
import {SbtImp} from "src/sbt/SbtImp.sol";
import {SkinNft} from "src/skinnft/SkinNft.sol";
import {ISkinNft} from "src/skinnft/ISkinNft.sol";

contract cInsightScript is Script {
    ChainInsightLogicV1 logic;
    ChainInsightExecutorV1 executor;
    ChainInsightGovernanceProxyV1 proxy;
    Sbt sbt;
    SbtImp sbtImp;
    SkinNft skinNft;

    address admin = address(1);
    address vetoer = address(2);

    uint256 executingGracePeriod = 11520;
    uint256 executingDelay = 11520;
    uint256 votingPeriod = 5760;
    uint256 votingDelay = 1;
    uint8 proposalThreshold = 1;

    string baseURL = "https://thechaininsight.github.io/";

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPROYER_KEY");

        // excute operations as a deployer account until stop broadcast
        vm.startBroadcast(deployerPrivateKey);

        logic = new ChainInsightLogicV1();
        executor = new ChainInsightExecutorV1(address(logic));
        sbt = new Sbt();
        sbtImp = new SbtImp();
        skinNft = new SkinNft(string.concat(baseURL, "skinnft/"));

        proxy = new ChainInsightGovernanceProxyV1(
            address(logic),
            address(executor),
            address(sbt),
            admin,
            vetoer,
            executingGracePeriod,
            executingDelay,
            votingPeriod,
            votingDelay,
            proposalThreshold
        );

        address(proxy).call(abi.encodeWithSignature(
            "initialize(address,address,address,uint256,uint256,uint256,uint256,uint256)",
            address(executor),
            address(sbt),
            vetoer,
            executingGracePeriod,
            executingDelay,
            votingPeriod,
            votingDelay,
            proposalThreshold
        ));

        sbt.init(
            address(executor),
            "ChainInsight",
            "SBT",
            string.concat(baseURL, "sbt/"),
            address(skinNft),
            address(sbtImp)
        );
        skinNft.init(address(sbt));

        vm.stopBroadcast();
    }
}
