pragma solidity 0.4.24;

contract Emits {
    event Transfer(address to, address from, uint256 value);
    event IndexedTransfer(address indexed to, address indexed from, uint256 value);

    function transfer(address to, address from, uint256 value) public {
        emit Transfer(to, from, value);
    }

    function transferIndexed(address to, address from, uint256 value) public {
        emit IndexedTransfer(to, from, value);
    }
}