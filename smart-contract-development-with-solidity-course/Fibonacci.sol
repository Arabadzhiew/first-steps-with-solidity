pragma solidity 0.4.24;

contract Fibonacci {

    function getFibonacci(uint256 number) public pure returns(uint256) {
        if(number <= 1) {
            return 1;
        }

        return getFibonacci(number - 1) + getFibonacci(number - 2);
    }
}