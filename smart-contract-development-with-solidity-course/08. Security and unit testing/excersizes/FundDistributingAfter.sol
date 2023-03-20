pragma solidity 0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

library VotingLib {
    struct Voting {
        address targetAdr;
        uint256 value;
        mapping(address => bool) voted;
        uint256 votedFor;
        uint256 votedAgainst;
        uint256 targetVotes;
        bool exists;
        bool successful;
        bool finished;
    }

    function createVoting(
        address targetAdr,
        uint256 value,
        uint256 targetVotes
    ) internal pure returns (Voting) {
        return
            Voting({
                targetAdr: targetAdr,
                value: value,
                votedFor: 0,
                votedAgainst: 0,
                targetVotes: targetVotes,
                exists: true,
                successful: false,
                finished: false
            });
    }

    function voteAndHasFinished(
        Voting storage self,
        bool voteFor,
        uint256 importance
    ) internal returns (bool) {
        if (voteFor) {
            self.votedFor = self.votedFor + importance;

            if (self.votedFor >= self.targetVotes) {
                self.finished = true;
                self.successful = true;
            }
        } else {
            self.votedAgainst = self.votedAgainst + importance;

            if (self.votedAgainst > self.targetVotes) {
                self.finished = true;
                self.successful = false;
            }
        }

        return self.finished;
    }
}

contract MemberVoter is Ownable {
    using VotingLib for VotingLib.Voting;

    event VotingStarted(
        uint256 indexed ID,
        address indexed targetAdr,
        uint256 value
    );
    event Voted(uint256 indexed ID, address indexed adr, bool voteFor);
    event VotingEnded(uint256 indexed ID, bool successful);
    event Withdrawal(address indexed from, uint256 value);

    // no access modifiers were previously defined

    mapping(uint256 => VotingLib.Voting) public votings;
    uint256 public votingsCount;

    struct Member {
        address adr;
        uint256 importance;
    }

    mapping(address => Member) private members;
    mapping(address => uint256) private memberBallances;

    uint256 private totalImportance;

    bool private isInitialized;

    modifier onlyMember() {
        require(members[msg.sender].importance > 0);
        _;
    }

    function init(address[] membersAdr, uint256[] importance) public onlyOwner {
        // Previously, we were not checking if the contract was already initialized
        require(!isInitialized);

        //If this condition is not satisfied we may end up throwing an exception
        require(membersAdr.length == importance.length);

        uint256 totalImp = 0;

        for (uint256 i = 0; i < membersAdr.length; i++) {
            members[membersAdr[i]].adr = membersAdr[i];
            members[membersAdr[i]].importance = importance[i];
            totalImp += importance[i];
        }

        totalImportance = totalImp; //memory caching

        isInitialized = true;
    }

    function startVote(address targetAdr, uint256 value)
        public
        onlyOwner
        returns (uint256 ID)
    {
        // now and block.timestamp cna be manipulated by the miner, so there we have a vlunerability when using them
        // for genereting the unique ID of the voting. An alternative mechanism has been provided.

        ID = votingsCount + 1;

        VotingLib.Voting memory voting = VotingLib.createVoting(
            targetAdr,
            value,
            totalImportance / 2
        );

        votings[ID] = voting;

        votingsCount += 1;

        emit VotingStarted(ID, targetAdr, value);
    }

    function castVote(uint256 ID, bool voteFor) public onlyMember {
        VotingLib.Voting storage voting = votings[ID];

        if (
            voting.voteAndHasFinished(voteFor, members[msg.sender].importance)
        ) {
            emit VotingEnded(ID, voting.successful);

            if (voting.successful) {
                // There was a reentrancy vulnerability in the prior version of this block
                memberBallances[voting.targetAdr] = voting.value;
                voting.value = 0;
            }
        }

        emit Voted(ID, msg.sender, voteFor);
    }

    // Adding pull withdraw mechanism
    function withdraw() public payable onlyMember {
        uint256 withdrawAmount = memberBallances[msg.sender];

        require(withdrawAmount > 0, "You do not have any funds to withdraw!");

        memberBallances[msg.sender] = 0;

        require(
            msg.sender.call.value(withdrawAmount)(),
            "Something went wrong while sending the transaction."
        );
    }

    // No fallback function was defined, so it was not able to receive any funds.
    function() public payable {}
}
