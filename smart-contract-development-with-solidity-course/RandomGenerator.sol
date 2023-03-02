pragma solidity 0.4.24;

contract RandomGenerator {

    function getRandom() public pure returns(uint256) {
        return block.timestamp * block.chainId;
    } 
}