pragma solidity 0.4.24;

contract Members {
    struct Member {
        address adr;
        uint256 joinedAt; //timestamp
    }

    address private owner;
    bool private isInitialized;

    mapping(address => Member) public members;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function initialize(address[] addresses) public onlyOwner {
        require(!isInitialized);

        uint256 currentTimestamp = now;

        for (uint256 i = 0; i < addresses.length; i++) {
            Member memory currMember = members[addresses[i]];
            currMember.adr = addresses[i];
            currMember.joinedAt = currentTimestamp;

            members[addresses[i]] = currMember;
        }

        isInitialized = true;
    }
}
