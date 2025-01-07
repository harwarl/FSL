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

     /*Events*/
    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);
    event RequestedRaffleWinner(uint256 indexed requestId);

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

        vm.deal(PLAYER, STARTING_PLAYER_BALANCE);
    }

    function testRaffleInitializesInOpenState() public view {
        assertEq(uint256(raffle.getRaffleState()), uint256(Raffle.RaffleState.OPEN));
    }
    
    function testRaffleInitializesWithCorrectEntranceFee() public view {
        assertEq(raffle.getEntranceFee(), entranceFee);
    }

    function testRaffleInitializesWithCorrectInterval() public view {
        assertEq(raffle.getInterval(), interval);
    }

    /*//////////////////////////////////////////////////////////////
                              ENTER RAFFLE
    //////////////////////////////////////////////////////////////*/
    function testRaffleRevertsWhenNotEnoughEtherIsSent() public {
        //Arrange
        vm.prank(PLAYER);
        //Act / Assert
        vm.expectRevert(Raffle.Raffle__SendMoreEtherToEnterRaffle.selector);
        raffle.enterRaffle();
    }

    function testRaffleFunderIsAddedToPlayers() public {
        //Arrange
        vm.prank(PLAYER);
        // Act
        raffle.enterRaffle{value: entranceFee}();
        // Assert
        address playerRecorded = raffle.getPlayer(0);
        assertEq(PLAYER, playerRecorded);
    }

    function testRaffleEmitsAEnteredEvent() public {
        // Arrange
        vm.prank(PLAYER);
        // Act
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(PLAYER);

        //Assert
        raffle.enterRaffle{value: entranceFee}(); 
    }

    function testRaffleDontAllowPlayersToEnterWhileRaffleIsCalculating() public {
        //Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();

        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        raffle.performUpkeep("");
        //Act / Assert
        vm.expectRevert(Raffle.Raffle__RaffleIsNotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }
}