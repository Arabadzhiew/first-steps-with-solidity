pragma solidity 0.4.24;

contract OwnedContract {
    address public owner;

    address private ownerCandidate;
    uint256 private ownerCandidateAssignmentTimestamp;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Can only be invoked by the owner of the contract!");
        _;
    }

    modifier onlyNonStaleOwnerCandidate {
        uint8 secondsBeforeStaling = 10; 

        require(msg.sender == ownerCandidate && block.timestamp - ownerCandidateAssignmentTimestamp <= secondsBeforeStaleing, 
            "Can only be invoked by the candidate owner of the contract and not later than 10 seconds after he was assigned!");
        _;
    }

    event OwnerChange(address oldOwner, address newOwner);
    event FallbackCall(address sender, uint256 value);

    function changeOwner(address newOwnerCandidate) public onlyOwner {
        ownerCandidate = newOwnerCandidate;
        ownerCandidateAssignmentTimestamp = block.timestamp;
    }

    function acceptOwnership() public onlyNonStaleOwnerCandidate {
        address oldOwner = owner;

        owner = ownerCandidate;

        emit OwnerChange(oldOwner, owner);
    }

    function() public payable {
        emit FallbackCall(msg.sender, msg.value);
    }
}