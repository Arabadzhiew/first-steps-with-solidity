pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

contract Voting {
    event LogStartedVote(uint256 ID);
    event LogEndedVote(uint256 ID, bool successful);

    struct Vote {
        uint256 ID;
        uint256 votesFor;
        uint256 votesAgainst;
        bool finished;
    }

    address private owner;
    bool private isInitialized;

    mapping(uint256 => Vote) public votesById;
    uint256 public votesCount;

    mapping(address => bool) public isVoter;
    uint256 public votersCount;

    mapping(bytes32 => bool) private hasVoterVotedFor;

    modifier onlyVoter() {
        require(isVoter[msg.sender]);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function initialize(address[] _voters) public onlyOwner {
        require(!isInitialized);
        require(_voters.length >= 2);

        votersCount = _voters.length;
        for (uint256 i = 0; i < votersCount; i++) {
            isVoter[_voters[i]] = true;
        }

        isInitialized = true;
    }

    function startVote() public onlyVoter returns (uint256) {
        uint256 voteID = votesCount + 1;
        Vote memory vote;
        vote.ID = voteID;
        vote.votesFor = 0;
        vote.votesAgainst = 0;

        votesById[voteID] = vote;
        votesCount++;

        emit LogStartedVote(vote.ID);

        return vote.ID;
    }

    function vote(uint256 id, bool voteFor) public onlyVoter {
        require(id <= votesCount);
        require(!votesById[id].finished);
        require(
            !hasVoterVotedFor[keccak256(abi.encodePacked(msg.sender, id))],
            "You have already voted for this voting!"
        );

        uint256 tempID;
        uint256 tempVotesFor;
        uint256 tempVotesAgainst;

        Vote memory oldVote = votesById[id];
        (tempID, tempVotesFor, tempVotesAgainst) = actuallyVote(
            oldVote,
            voteFor
        );
        Vote memory updatedVote;
        updatedVote.ID = tempID;
        updatedVote.votesFor = tempVotesFor;
        updatedVote.votesAgainst = tempVotesAgainst;
        votesById[id] = updatedVote;
        hasVoterVotedFor[keccak256(abi.encodePacked(msg.sender, id))] = true;

        if (checkForVoteCompletion(votesById[id])) {
            votesById[id].finished = true;
        }
    }

    function actuallyVote(Vote _vote, bool voteFor)
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        if (voteFor) {
            _vote.votesFor++;
        } else {
            _vote.votesAgainst++;
        }

        return (_vote.ID, _vote.votesFor, _vote.votesAgainst);
    }

    //returns true if vote is completed
    function checkForVoteCompletion(Vote _vote) private returns (bool) {
        if (_vote.votesFor > votersCount / 2) {
            emit LogEndedVote(_vote.ID, true);
            return true;
        } else if (_vote.votesAgainst > votersCount / 2) {
            emit LogEndedVote(_vote.ID, false);
            return true;
        }

        return false;
    }
}
