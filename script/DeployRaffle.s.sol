// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Raffle} from '../src/Raffle.sol';
import {Script} from 'forge-std/Script.sol';
import {HelperConfig} from '../script/HelperConfig.s.sol';
import {CreateSubscription} from '../script/interactions.s.sol';

contract DeployRaffle is Script{
    Raffle raffle;
    HelperConfig helperConfig;

    function run() external returns (Raffle) {
    //    (raffle, helperConfig) = deployContract();
    //    return raffle;
    }

    function deployContract() public returns ( Raffle, HelperConfig){
        helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory networkConfig = helperConfig.getConfig();

        if(networkConfig.subscriptionId == 0){
            // Create a subscription
            CreateSubscription createSubscription = new CreateSubscription();
            (networkConfig.subscriptionId, networkConfig.vrfCoordinatorV2 ) = createSubscription.createSubscription(networkConfig.vrfCoordinatorV2);
        }

        vm.startBroadcast();
        raffle = new Raffle(
            networkConfig.entranceFee, 
            networkConfig.interval, 
            networkConfig.subscriptionId, 
            networkConfig.callbackGasLimit, 
            networkConfig.gasLane, 
            networkConfig.vrfCoordinatorV2
        );              
        vm.stopBroadcast();
        return (raffle, helperConfig);  
    }
}