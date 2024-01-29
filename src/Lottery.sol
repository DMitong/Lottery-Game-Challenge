// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// Challenge: This is part of a 15 day smart contract writing challenge, with 5 days for each level of difficulty, basic, intermediate and advanced.

/*
Write a smart contract that can implement a simple lottery game. 
The contract should have an array that stores the addresses of the players. 
The contract should also have a function to allow players to join the game, by sending a fixed amount of ether to the contract. 
The contract should also have a function to randomly select a winner, based on a pseudo-random number generator. 
The contract should also have a function to send the prize money to the winner, and reset the game.
*/

contract LotteryChallenge {
    address public manager; // The account that deploys the contract and controls lottery operations.
    address[] public players; // A dynamically-sized array of addresses representing the players.
    address public winner; // The last determined winner's address.
    uint256 public minimumBet; // The minimum amount of ether required to participate in the lottery.
    bool public isGameActive; // A boolean to denote whether a game is actively accepting new players.
    bytes32 public prevrandao; // A bytes32 variable to hold external randomness data for random number generation.

    // The constructor is run when the contract is deployed and initializes the state variables.
    constructor(uint256 _minimumBet) {
        manager = msg.sender; // The deploying address is set as the manager.
        minimumBet = _minimumBet; // Sets the minimum bet required to join the game.
        isGameActive = false; // Initializes the game as inactive.
    }

    // Modifiers are used to add preconditions to function executions.

    // A custom modifier to require that the caller is the manager of the contract.
    modifier onlyManager() {
        require(
            msg.sender == manager,
            "Only the manager can call this function"
        );
        _;
    }

    // A custom modifier to require that the game is active.
    modifier gameIsActive() {
        require(isGameActive, "The game is not currently active");
        _;
    }

    // A custom modifier to require that the game is not active.
    modifier gameIsInactive() {
        require(!isGameActive, "The game is currently active");
        _;
    }

    // Allows the manager to update the prevrandao variable for enhanced random number generation.
    function setPrevRandao(bytes32 _prevrandao) external onlyManager {
        prevrandao = _prevrandao;
    }

    // Enables players to join the game, provided it's inactive and the minimum bet is met.
    function joinGame() external payable gameIsInactive {
        require(msg.value == minimumBet, "Invalid bet amount");
        players.push(msg.sender);
    }

    // Allows the manager to start the game, given that at least two players have joined.
    function startGame() external onlyManager gameIsInactive {
        require(
            players.length > 1,
            "At least two players required to start the game"
        );
        isGameActive = true;
    }

    // Ends the game, determines the winner using prevrandao for randomness, sends the prize, and resets the game.
    function endGame() external onlyManager gameIsActive {
        require(players.length > 0, "No players in the game");

        // Generates a pseudo-random index to determine the winner; not recommended for high-value situations.
        uint256 winnerIndex = uint256(
            keccak256(abi.encodePacked(block.timestamp, prevrandao))
        ) % players.length;
        winner = players[winnerIndex]; // Assigns the winner variable.
        payable(winner).transfer(address(this).balance); // Transfers the contract's balance to the winner.

        // Resets the players array and the game's active state.
        delete players;
        isGameActive = false;
    }

    // A view function to get the list of players.
    function getPlayers() external view returns (address[] memory) {
        return players;
    }

    // A view function to return the winner.
    function getWinner() external view returns (address) {
        return winner;
    }

    // A view function to get the minimum bet required to participate.
    function getMinimumBet() external view returns (uint256) {
        return minimumBet;
    }

    // A view function to get the contract's balance (the total prize pool).
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
