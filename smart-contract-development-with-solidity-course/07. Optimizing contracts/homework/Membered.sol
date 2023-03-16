pragma solidity 0.4.24;

//this contract is optimized, don't touch it.
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

contract Membered is Ownable {
    struct Member {
        address adr;
        uint256 joinedAt;
        uint256 fundsDonated;
    }

    mapping(address => Member) members;

    modifier onlyMember() {
        require(members[msg.sender].adr != 0);
        _;
    }

    function addMember(address adr) public onlyOwner {
        members[adr] = Member({
            adr: msg.sender,
            joinedAt: block.timestamp,
            fundsDonated: 0
        });
    }

    function donate() public payable onlyMember {
        require(msg.value > 0);

        members[msg.sender].fundsDonated += msg.value;
    }
}
