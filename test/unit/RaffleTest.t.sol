// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract RaffleTest is Test {
    Raffle public raffle;
    HelperConfig public helperConfig;  

    //Config Variables
    uint256 entranceFee;
    uint256 interval;
    uint256 subscriptionId;
    uint32 callbackGasLimit;
    bytes32 gasLane;
    address vrfCoordinatorV2 ;

    //Player
    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.deployContract();  
        HelperConfig.NetworkConfig memory networkConfig = helperConfig.getConfig();
        entranceFee  = networkConfig.entranceFee;
        interval = networkConfig.interval;
        subscriptionId = networkConfig.subscriptionId;
        callbackGasLimit = networkConfig.callbackGasLimit;
        gasLane = networkConfig.gasLane;
        vrfCoordinatorV2 = networkConfig.vrfCoordinatorV2;
    }

    function test__RaffleInitializesInOpenState() public view {
        assertEq(uint256(raffle.getRaffleState()), uint256(Raffle.RaffleState.OPEN));
    }
    
}