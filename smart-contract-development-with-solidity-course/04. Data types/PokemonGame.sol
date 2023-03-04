pragma solidity 0.4.24;

contract PokemonGame {

    enum Pokemon { Pikatchu, Bullseye, Solidity, Checheneca }

    struct Player {
        Pokemon[] pokemons;
        mapping(uint8 => bool) pokemonsCatched;
        uint256 lastCatchTime;
    }

    mapping (address => Player) private players;
    mapping(uint8 => address[]) private pokemonHolders;

    modifier onlyOncePerQuarterMinute {
        require(players[msg.sender].lastCatchTime + 15 seconds <= block.timestamp, 
            "You can only perform this action once per 15 seconds!");
        _;
    }

    event PokemonCatched(address indexed playerAddress, Pokemon indexed pokemonType);

    function catchPokemon(Pokemon _pokemonType) public onlyOncePerQuarterMinute {
        require(!players[msg.sender].pokemonsCatched[uint8(_pokemonType)], "You have already have this type of pokemon!");

        players[msg.sender].pokemons.push(_pokemonType);
        players[msg.sender].pokemonsCatched[uint8(_pokemonType)] = true;
        players[msg.sender].lastCatchTime = block.timestamp;
        
        pokemonHolders[uint8(_pokemonType)].push(msg.sender);

        emit PokemonCatched(msg.sender, _pokemonType);
    }

    function listCatchedPokemons(address _playerAddress) public view returns(Pokemon[]) {
        return players[_playerAddress].pokemons;
    }

    function listPokemonHolders(Pokemon _pokemonType) public view returns(address[]) {
        return pokemonHolders[uint8(_pokemonType)];
    }
}