pragma solidity 0.4.24;

contract StateContract {
    enum State { Locked, Restricted, Unlocked }

    struct ContractProperties {
        uint256 counter;
        uint256 timestamp;
        address lastCaller;
    }

    address public owner;

    State public currentState = State.Locked;
    ContractProperties public properties;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(owner == msg.sender, "Only the owner of the contract can perform this action!");
        _;
    }

    modifier stateDependent {
        require(currentState != State.Locked, "No methods can be called by anyone while the contract is locked!");
        require(currentState != State.Restricted || msg.sender == owner, 
            "While the contract is in the restricted state, its methods can only be called by its owner!");
        _;
    }

    function changeState(State _state) public onlyOwner {
        currentState = _state;
    }

    function updateProperties() public stateDependent {
        properties = ContractProperties(properties.counter + 1, block.timestamp, msg.sender);
    }

    function() payable public stateDependent {}
}