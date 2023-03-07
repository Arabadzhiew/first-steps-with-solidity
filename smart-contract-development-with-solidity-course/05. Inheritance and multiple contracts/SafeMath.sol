pragma solidity 0.4.24;

contract SafeMath {
    function add(uint256 numberOne, uint256 numberTwo) pure public returns(uint256 result) {
        result = numberOne + numberTwo;

        if(result < numberOne || result < numberTwo) {
            revert();
        }
    }

    function subtract(uint256 numberOne, uint256 numberTwo) pure public returns(uint256 result) {
        result = numberOne - numberTwo;

        if(result > numberOne) {
            revert();
        }
    }

    function multiply(uint256 numberOne, uint256 numberTwo) pure public returns(uint256 result) {
        if(numberOne == 0 || numberTwo == 0) {
            return 0;
        }

        result = numberOne * numberTwo;

        if(result < numberOne || result < numberTwo) {
            revert();
        }
    }
}

contract Owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "This action can only be performed by the owner of the contract!");
        _;
    }

    function changeOwner(address _newOwner) onlyOwner public {
        owner = _newOwner;
    }
}

contract StateHolder is SafeMath, Owned{
    uint256 public state;
    
    uint256 private lastStateChangeTime;

    function updateState() onlyOwner public {
        state = add(state, block.gaslimit);
        state = multiply(state, lastStateChangeTime != 0 ? block.timestamp - lastStateChangeTime : 1);
        state = subtract(state, block.timestamp % 256);

        lastStateChangeTime = block.timestamp;
    }
}