import * as React from "react";
import { Button, TextField } from "@mui/material";
import { ethers } from "ethers";
import {
  pokemonContractAddress,
  pokemonContractAbi,
} from "./pokemon-contract-constants";

import "./App.css";

function App() {
  const [headerMessage, setHeaderMessage] = React.useState("");

  const [contractInstance, setContractInstance] = React.useState(undefined);

  const [pokemonIndex, setPokemonIndex] = React.useState(undefined);
  const [errorText, setErrorText] = React.useState(undefined);
  const [playerAddressToRead, setPlayerAddressToRead] =
    React.useState(undefined);
  const [catchedPokemons, setCatchedPokemons] = React.useState(undefined);
  const [pokemonHolders, setPokemonHolders] = React.useState(undefined);

  React.useEffect(() => {
    if (window.ethereum === undefined) {
      setHeaderMessage("Error! Are you sure you are using MetaMask?");
    } else {
      setHeaderMessage("Wellcome!");

      const newProvider = new ethers.providers.Web3Provider(window.ethereum);
      setContractInstance(
        new ethers.Contract(
          pokemonContractAddress,
          pokemonContractAbi,
          newProvider.getSigner()
        )
      );
    }
  }, []);

  return (
    <div>
      <h1>{headerMessage}</h1>
      <Button
        variant={"contained"}
        color={"success"}
        onClick={() => {
          window.ethereum
            .request({ method: "eth_requestAccounts" })
            .then(() => {
              window.ethereum.request({
                method: "eth_accounts",
              });
            });
        }}
      >
        Connect
      </Button>
      <br />
      <TextField
        type={"number"}
        label={"Pokemon index"}
        onChange={(event) => setPokemonIndex(event.target.value)}
      />
      <Button
        variant={"contained"}
        onClick={() => {
          contractInstance
            .catchPokemon(pokemonIndex)
            .then(() => setErrorText(undefined))
            .catch((error) => setErrorText(error.data.data.reason));
        }}
      >
        Catch Pokemon
      </Button>
      <div style={{ color: "red" }}>{errorText}</div>

      <TextField
        label={"Player address"}
        onChange={(event) => setPlayerAddressToRead(event.target.value)}
      />
      <Button
        variant={"contained"}
        onClick={() => {
          contractInstance
            .listCatchedPokemons(playerAddressToRead)
            .then(setCatchedPokemons);
        }}
      >
        List catched pokemons
      </Button>
      <div>{catchedPokemons}</div>
      <br />
      <TextField
        label={"Pokemon index"}
        onChange={(event) => setPlayerAddressToRead(event.target.value)}
      />
      <Button
        variant={"contained"}
        onClick={() => {
          contractInstance
            .listPokemonHolders(playerAddressToRead)
            .then(setPokemonHolders);
        }}
      >
        List pokemon holders
      </Button>
      <div>{pokemonHolders}</div>
    </div>
  );
}

export default App;
