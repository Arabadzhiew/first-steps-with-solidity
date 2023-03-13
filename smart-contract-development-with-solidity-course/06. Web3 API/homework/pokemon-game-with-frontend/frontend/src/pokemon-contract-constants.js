export const pokemonContractAddress =
  "0xd3b9bCBdfCE09008E89D65c0e65Fa631d7d7dC28";

export const pokemonContractAbi = [
  {
    constant: false,
    inputs: [
      {
        name: "_pokemonType",
        type: "uint8",
      },
    ],
    name: "catchPokemon",
    outputs: [],
    payable: false,
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        name: "playerAddress",
        type: "address",
      },
      {
        indexed: true,
        name: "pokemonType",
        type: "uint8",
      },
    ],
    name: "PokemonCatched",
    type: "event",
  },
  {
    constant: true,
    inputs: [
      {
        name: "_playerAddress",
        type: "address",
      },
    ],
    name: "listCatchedPokemons",
    outputs: [
      {
        name: "",
        type: "uint8[]",
      },
    ],
    payable: false,
    stateMutability: "view",
    type: "function",
  },
  {
    constant: true,
    inputs: [
      {
        name: "_pokemonType",
        type: "uint8",
      },
    ],
    name: "listPokemonHolders",
    outputs: [
      {
        name: "",
        type: "address[]",
      },
    ],
    payable: false,
    stateMutability: "view",
    type: "function",
  },
];
