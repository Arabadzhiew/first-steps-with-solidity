pragma solidity 0.4.24;
pragma experimental ABIEncoderV2; //ignore this for now

//This is hands down the worst voting contract that could ever exist.
//Optimize execution costs
//Fix all compile warnings

contract Voting {
    event LogStartedVote(uint256 ID);
    event LogEndedVote(uint256 ID, bool successful);

    struct Vote {
        uint256 ID;
        uint256 votesFor;
        uint256 votesAgainst;
        bool finished;
    }

    Vote[] public votes;

    address[] public voters;

    modifier onlyVoter() {
        for (uint256 idx = 0; idx < voters.length; idx++) {
            if (voters[idx] == msg.sender) {
                _;
                return;
            }
        }

        require(false);
    }

    function Voting(address[] _voters) public {
        require(_voters.length >= 2);
        voters = _voters;
    }

    uint256 voteID;

    function startVote() public onlyVoter returns (uint256) {
        voteID = votes.length + 1;
        Vote memory vote;
        vote.ID = voteID;
        vote.votesFor = 0;
        vote.votesAgainst = 0;

        votes.push(vote);

        LogStartedVote(vote.ID);

        return vote.ID;
    }

    uint256 tempID;
    uint256 tempVotesFor;
    uint256 tempVotesAgainst;

    function vote(uint256 id, bool voteFor) public onlyVoter {
        for (uint256 i = 0; i < votes.length; i++) {
            if (votes[i].ID == id) {
                require(!votes[i].finished);

                Vote memory oldVote = votes[i];
                (tempID, tempVotesFor, tempVotesAgainst) = this.actuallyVote(
                    oldVote,
                    voteFor
                );
                Vote memory updatedVote;
                updatedVote.ID = tempID;
                updatedVote.votesFor = tempVotesFor;
                updatedVote.votesAgainst = tempVotesAgainst;
                votes[i] = updatedVote;

                if (this.checkForVoteCompletion(votes[i])) {
                    votes[i].finished = true;
                }
            }
        }
    }

    function actuallyVote(Vote vote, bool voteFor)
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        if (voteFor) {
            vote.votesFor++;
        } else {
            vote.votesAgainst++;
        }

        return (vote.ID, vote.votesFor, vote.votesAgainst);
    }

    //returns true if vote is completed
    function checkForVoteCompletion(Vote vote) returns (bool) {
        if (vote.votesFor > voters.length / 2) {
            LogEndedVote(vote.ID, true);
            return true;
        } else if (vote.votesAgainst >= voters.length / 2) {
            LogEndedVote(vote.ID, false);
            return true;
        }

        return false;
    }
}
