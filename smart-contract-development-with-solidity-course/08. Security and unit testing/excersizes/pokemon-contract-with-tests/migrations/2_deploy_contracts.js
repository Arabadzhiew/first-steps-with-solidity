const PokemonGame = artifacts.require("PokemonGame");

module.exports = function (deployer) {
  deployer.deploy(PokemonGame);
};
