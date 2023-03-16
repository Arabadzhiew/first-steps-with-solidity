pragma solidity 0.4.24;

contract Ownable {
    address public owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract Counter is Ownable {
    uint256 times = 0;
    uint256 value = 0;

    function count(uint256 incrementBy)
        public
        onlyOwner
        returns (uint256, uint256)
    {
        value += incrementBy;
        times++;

        return (times, value);
    }

    function getCounter() public view returns (uint256, uint256) {
        return (times, value);
    }
}
