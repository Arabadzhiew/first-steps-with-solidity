const PokemonGame = artifacts.require("PokemonGame");

const windTimeForward = (seconds) => {
  return new Promise((resolve, reject) => {
    web3.currentProvider.send(
      {
        jsonrpc: "2.0",
        method: "evm_increaseTime",
        params: [seconds],
        id: new Date().getTime(),
      },
      (err, res) => {
        if (err) {
          return reject(err);
        }

        web3.currentProvider.send(
          {
            jsonrpc: "2.0",
            method: "evm_mine",
            id: new Date().getTime(),
          },
          (err, res) => {
            return err ? reject(err) : resolve(res);
          }
        );
      }
    );
  });
};

contract("PokemonGame", (accounts) => {
  beforeEach(async () => {
    gameInstance = await PokemonGame.new();
  });

  it("should catch pokemon", async () => {
    await gameInstance.catchPokemon(3, { from: accounts[0] });

    const catchedPokemons = await gameInstance.listCatchedPokemons.call(
      accounts[0]
    );

    assert.equal(
      catchedPokemons[0],
      3,
      "The first addres shoould have catched pokemon 3!"
    );
  });

  it("should NOT catch pokemon, when 15 seconds haven't passed since the last catch", async () => {
    await gameInstance.catchPokemon(3, { from: accounts[0] });
    await windTimeForward(1);

    try {
      await gameInstance.catchPokemon(2, { from: accounts[0] });
      assert.fail();
    } catch (err) {
      const catchedPokemons = await gameInstance.listCatchedPokemons.call(
        accounts[0]
      );

      assert.equal(
        catchedPokemons.length,
        1,
        "The first addres should only have one catched pokemon!"
      );
    }
  });

  it("should catch pokemon, when 15 seconds have passed since the last catch", async () => {
    await gameInstance.catchPokemon(3, { from: accounts[0] });
    await windTimeForward(15);

    await gameInstance.catchPokemon(2, { from: accounts[0] });

    const catchedPokemons = await gameInstance.listCatchedPokemons.call(
      accounts[0]
    );

    assert.equal(
      catchedPokemons.length,
      2,
      "The first addres should have two catched pokemons!"
    );
  });
});
