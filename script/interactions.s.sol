// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol"; 
import {HelperConfig} from "script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from '@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol';

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns(uint256, address) {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCordinatorV2 = helperConfig.getConfig().vrfCoordinatorV2;

        //create subscription
        (uint256 subId, ) = createSubscription(vrfCordinatorV2); // Added call to createSubscription
        return (subId, vrfCordinatorV2);
    }

    function createSubscription(address vrfCoordinator) public returns (uint256, address){
        console.log("Creating subscription on chainId: ", block.chainid);
        vm.broadcast();
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();
        console.log("Your subscription Id is: ", subId);
        console.log("Please update the subscription Id in your HelperConfig.s.sol");
        return (subId, vrfCoordinator);
    }

    function run() public {
        createSubscriptionUsingConfig(); 
    }
}

contract FundSubscription is Script {
    uint256 public constant FUND_AMOUNT = 3 ether; // 3 LINK

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinatorV2;
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
    }

    function fundSubscription() public {

    }

    function run() public {
        fundSubscriptionUsingConfig();
    }
}