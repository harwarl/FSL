// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title A Raffle contract
 * @author ErenArchy
 * @notice You can use this contract for creating a raffle
 * @dev Implements Chainlink VRF
 */
contract Raffle is VRFConsumerBaseV2Plus{
    /*Errors*/
    error Raffle__SendMoreEtherToEnterRaffle();
    error Raffle__RaffleIsNotOpen();
    error Raffle__TransferFailed();

    /*Type Declarations*/
    enum RaffleState{
        OPEN,
        CALCULATING
    }

    /*State Variables*/
    //Chainlink Variables
    bytes32 private immutable i_keyHash;
    uint32 private immutable i_callbackGasLimit;
    uint256 private immutable i_subscriptionId;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    //Lottery Variables
    uint256 private immutable i_entranceFee;
    // @dev the duration of the lottery in seconds
    uint256 private i_interval;
    uint256 private s_lastTimeStamp;
    address payable[] private s_players;
    RaffleState private s_raffleState;
    address private s_recentWinner;
    

    /*Events*/
    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);

    /*functions*/
    constructor(
        uint256 entranceFee,
        uint256 interval,
        uint256 subscriptionId,
        uint32 callbackGasLimit,
        bytes32 gasLane,
        address vrfCoordinatorV2
    )  VRFConsumerBaseV2Plus(vrfCoordinatorV2){
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        i_keyHash = gasLane;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable {
        if(msg.value < i_entranceFee){
            revert Raffle__SendMoreEtherToEnterRaffle();
        }
        if(s_raffleState != RaffleState.OPEN){
            revert Raffle__RaffleIsNotOpen();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    // 1. Get a random number 
    // 2. Pick a winner
    // 3. Transfer the prize to the winner
    // 4. Be Called Automatically
    function pickWinner() external {
        //Check to see if enough time has passed
        if((block.timestamp - s_lastTimeStamp) < i_interval){
            revert Raffle__RaffleIsNotOpen();
        }

        s_raffleState = RaffleState.CALCULATING;

        uint256 requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({
                        nativePayment: false
                    })
                )
            })
        );
    }

    function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override {
        // pick a winner
        uint indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if(!success){
            revert Raffle__TransferFailed();
        }

        emit WinnerPicked(s_recentWinner);
    }

    /*Getter Functions*/
    function getEntranceFee() external view returns(uint256){
        return i_entranceFee;
    }  

    function getNoOfPlayers() external view returns(uint256){
        return s_players.length;
    } 

    
}