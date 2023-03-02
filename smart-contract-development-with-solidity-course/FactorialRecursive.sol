pragma solidity 0.4.24;

contract FactorialRecursive {
    
    function getFactorial(uint256 value) public pure returns(uint256) {
        if(value == 0 || value == 1) {
            return 1;
        }

        return value * getFactorial(value - 1);
    }
}