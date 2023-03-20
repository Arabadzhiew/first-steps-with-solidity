pragma solidity >=0.4.22 <0.7.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/PokemonGame.sol";

contract TestPokemonGame {
    function testSholdHaveNoCatchedPokemonsWhenCreated() public {
        PokemonGame pokemonGame = PokemonGame(DeployedAddresses.PokemonGame());

        uint256 expectedLength = 0;

        Assert.equal(
            pokemonGame.listCatchedPokemons(tx.origin).length,
            expectedLength,
            "No address should initially have catched pokemons!"
        );
    }

    // function testSholdCatchPokemon() public {
    //     PokemonGame pokemonGame = PokemonGame(DeployedAddresses.PokemonGame());

    //     pokemonGame.catchPokemon(PokemonGame.Pokemon.Checheneca);

    //     uint256 expectedPokemon = uint256(PokemonGame.Pokemon.Checheneca);

    //     Assert.equal(
    //         uint256(pokemonGame.listCatchedPokemons(tx.origin).length),
    //         expectedPokemon,
    //         "No address should initially have catched pokemons!"
    //     );
    // }
}
