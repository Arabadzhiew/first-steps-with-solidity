pragma solidity 0.4.24;

contract FactorialIterative {

    function getFactorial(uint256 value) public pure returns(uint256) {
        uint256 currentFactorial = 1;

        if(value == 0) {
            return currentFactorial;
        }

        for(uint256 i = 1; i <= value; i++) {
            currentFactorial *= i;
        }

        return currentFactorial;
    }
}