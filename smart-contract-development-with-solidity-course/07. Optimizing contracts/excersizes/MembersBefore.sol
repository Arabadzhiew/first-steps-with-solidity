pragma solidity 0.4.24;

contract Members {
    struct Member {
        address adr;
        uint256 joinedAt; //timestamp
    }

    mapping(address => Member) public members;

    constructor(address[] addresses) public {
        //first, try to optimize the contract publishing and execution as much as possible
        //the loop cannot be avoided in this case
        //however, think of a way to do as little as possible in the loop body
        for (uint256 i = 0; i < addresses.length; i++) {
            Member currMember = members[addresses[i]];
            currMember.adr = addresses[i];
            currMember.joinedAt = now;

            members[addresses[i]] = currMember;
        }
    }
}
