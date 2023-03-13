import * as React from "react";

import { Button, TextField } from "@mui/material";
import Web3 from "web3";

const web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:7545"));

function App() {
  const [mainAccount, setMainAccount] = React.useState("");
  const [counterContractInstance, setCounterContractInstance] =
    React.useState(undefined);
  const [increment, setIncrement] = React.useState(0);
  let secondaryAccount;
  const counterContractAbi = [
    {
      constant: false,
      inputs: [
        {
          name: "incrementBy",
          type: "uint256",
        },
      ],
      name: "count",
      outputs: [
        {
          name: "",
          type: "uint256",
        },
        {
          name: "",
          type: "uint256",
        },
      ],
      payable: false,
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      constant: true,
      inputs: [],
      name: "getCounter",
      outputs: [
        {
          name: "",
          type: "uint256",
        },
        {
          name: "",
          type: "uint256",
        },
      ],
      payable: false,
      stateMutability: "view",
      type: "function",
    },
    {
      constant: true,
      inputs: [],
      name: "owner",
      outputs: [
        {
          name: "",
          type: "address",
        },
      ],
      payable: false,
      stateMutability: "view",
      type: "function",
    },
    {
      constant: false,
      inputs: [
        {
          name: "newOwner",
          type: "address",
        },
      ],
      name: "transferOwnership",
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
          name: "previousOwner",
          type: "address",
        },
        {
          indexed: true,
          name: "newOwner",
          type: "address",
        },
      ],
      name: "OwnershipTransferred",
      type: "event",
    },
  ];

  React.useEffect(() => {
    web3.eth.getAccounts().then((allAccounts) => {
      setMainAccount(allAccounts[0]);
      secondaryAccount = allAccounts[1];
    });

    setCounterContractInstance(
      new web3.eth.Contract(
        counterContractAbi,
        "0x4d5E0843e813f8CF7ae922322e8573faF90eB199"
      )
    );
  }, []);

  React.useEffect(() => {
    if (counterContractInstance !== undefined) {
      counterContractInstance.methods
        .getCounter()
        .call({ from: secondaryAccount })
        .then((newState) => setCounter(newState[1]));
    }
  }, [counterContractInstance]);

  const [counter, setCounter] = React.useState(0);

  return (
    <div className="App">
      Increment by:{" "}
      <TextField
        type={"number"}
        onChange={(event) => setIncrement(event.target.value)}
      />
      <br />
      Current counter value: {counter}
      <br />
      <Button
        onClick={() => {
          counterContractInstance.methods
            .count(increment)
            .send({ from: mainAccount })
            .then(() => {
              counterContractInstance.methods
                .getCounter()
                .call({ from: secondaryAccount })
                .then((newState) => setCounter(newState[1]));
            });
        }}
      >
        Update counter
      </Button>
    </div>
  );
}

export default App;
