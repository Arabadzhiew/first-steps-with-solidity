pragma solidity 0.4.24;

import { SafeMath, Owned } from "../SafeMathLibrary.sol";

library Members {
    struct Member {
        address memberAddress;
        uint256 totalDonationsAmount;
        uint256 lastDonationTimestamp;
        uint256 lastDonationAmount;
    }

    struct MemberProposal {
        address proposedAddress;
        uint256 aggreementCount;
        mapping(bytes32 => bool) isApprovedByMember; // The key here will be the keccak256 hash of the member address + proposed member address
    }

    struct Data {
        mapping(address => bool) isMemberAddress;
        mapping(address => Member) members;
        uint256 memberCount;
    }

    function addMember(Data storage self, address newMemberAddress) public {
        self.isMemberAddress[newMemberAddress] = true;
        self.members[newMemberAddress] = Member({
            memberAddress: newMemberAddress,
            totalDonationsAmount: 0,
            lastDonationTimestamp: 0, 
            lastDonationAmount: 0
        }); 
        self.memberCount++;
    }

    function removeMember(Data storage self, address memberAddress) public {
        require(self.isMemberAddress[memberAddress], "The specified address is not a contract member!");

        self.isMemberAddress[memberAddress] = false;
        delete self.members[memberAddress]; 
        self.memberCount--;
    }

    function addMemberDonation(Data storage self, address memberAddress, uint256 donationAmmount) public {
        self.members[memberAddress].totalDonationsAmount += donationAmmount;
        self.members[memberAddress].lastDonationTimestamp = block.timestamp;
        self.members[memberAddress].lastDonationAmount = donationAmmount;
    }

    function hasMemberDonatedInLastHour(Data storage self, address memberAddress) public view returns(bool) {
        return self.members[memberAddress].lastDonationTimestamp + 1 hours >= block.timestamp;
    }

    function isMember(Data storage self, address memberAddress) public view returns(bool) {
        return self.isMemberAddress[memberAddress];
    }

    function getMemberCount(Data storage self) public view returns(uint256) {
        return self.memberCount;
    }
}

contract Mortal {
    function kill() public {
        selfdestruct(msg.sender);
    }
}

contract Voting is Owned, Mortal  {
    using SafeMath for uint256;
    using Members for Members.Data;

    Members.Data private members;
    
    Members.MemberProposal memberProposal;
    bool hasActiveMemberProposal = false;

    constructor() public {
        members.addMember(owner);
    }

    modifier onlyMembers {
        require(members.isMember(msg.sender), "This action can only be performed by members of the contract!");
        _;
    }

    event MemberProposed(address indexed proposerAddress, address proposedAddress);
    event MemberAdded(address newMemberAddress);
    event MemberRemoved(address indexed removedMemberAddress);
    event MemberDonated(address indexed memberAddress, uint256 donationAmount);
    
    function removeMember(address memberToRemoveAddress) public onlyOwner {
        require(!members.hasMemberDonatedInLastHour(memberToRemoveAddress), 
            "A member can only be removed if they have not made a donation in more than one hour!");

        members.removeMember(memberToRemoveAddress);

        emit MemberRemoved(memberToRemoveAddress);
    }

    function proposeNewMember(address newMemberAddress) public onlyMembers {
        require(!hasActiveMemberProposal, "There is currently an ongoing member proposal!");
        require(!members.isMember(newMemberAddress), "The provided address is already a member of the contract!");

        memberProposal = Members.MemberProposal({proposedAddress: newMemberAddress, aggreementCount: 0});
        hasActiveMemberProposal = true;

        emit MemberProposed(msg.sender, newMemberAddress);

        approveMemberProposal();
    }

    function approveMemberProposal() public onlyMembers {
        require(
            !memberProposal.isApprovedByMember[getProposedMemberHash()],
            "You have already approved the proposal!"
        );
        require(hasActiveMemberProposal, "There is curently no ongoing new member proposal!");

        memberProposal.aggreementCount++;
        memberProposal.isApprovedByMember[getProposedMemberHash()] = true;

        if(memberProposal.aggreementCount > members.getMemberCount().divide(2)) {
            members.addMember(memberProposal.proposedAddress);
            delete memberProposal;
            hasActiveMemberProposal = false;

            emit MemberAdded(memberProposal.proposedAddress);
        }
    }

    function getProposedMemberHash() private view returns(bytes32) {
        return keccak256(abi.encodePacked(msg.sender, memberProposal.proposedAddress));
    }

    function kill() public onlyOwner {
        super.kill();
    }

    function() public payable onlyMembers{
        members.addMemberDonation(msg.sender, msg.value);

        emit MemberDonated(msg.sender, msg.value);
    }
}