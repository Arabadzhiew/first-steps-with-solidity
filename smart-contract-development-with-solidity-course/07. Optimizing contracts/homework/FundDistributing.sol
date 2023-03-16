// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

library VotingLibrary {
    struct Vote {
        uint256 id;
        address receiver;
        uint256 transferAmount;
        mapping(address => bool) hasVoted;
        uint256 targetWeight;
        uint256 weightFor;
        uint256 weightAgainst;
        bool isActive;
        bool isSuccessfull;
    }

    event VoteEnded(
        uint256 indexed id,
        address indexed receiver,
        uint256 transferAmount,
        bool isSuccessfull
    );

    function update(
        Vote storage _self,
        bool _voteFor,
        uint256 _voteWeight
    ) public returns (uint256) {
        require(_self.isActive, "This voting has already ended!");
        require(
            !_self.hasVoted[msg.sender],
            "You have already submited your vote for this voting!"
        );

        if (_voteFor) {
            _self.weightFor += _voteWeight;
            _self.hasVoted[msg.sender] = true;

            if (_self.weightFor > _self.targetWeight) {
                _self.isActive = false;
                _self.isSuccessfull = true;

                emit VoteEnded(
                    _self.id,
                    _self.receiver,
                    _self.transferAmount,
                    _self.isSuccessfull
                );

                return _self.transferAmount;
            }
        } else {
            _self.weightAgainst += _voteWeight;
            _self.hasVoted[msg.sender] = true;

            if (_self.weightAgainst > _self.targetWeight) {
                _self.isActive = false;
                _self.isSuccessfull = false;

                emit VoteEnded(
                    _self.id,
                    _self.receiver,
                    _self.transferAmount,
                    _self.isSuccessfull
                );
            }
        }

        return 0;
    }
}

contract FundDistributing {
    using VotingLibrary for VotingLibrary.Vote;

    struct Member {
        address adr;
        uint256 importance;
    }

    uint256 public contractBallance;

    bool private isInitialized;

    address public owner;
    mapping(address => uint256) public memberImportances;
    uint256 public totalMemberWeight;

    mapping(uint256 => VotingLibrary.Vote) public votesById;
    uint256 public votesCount;

    mapping(address => uint256) public withdrawAmounts;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "This action can only be performed by the owner of the contract!"
        );
        _;
    }

    modifier onlyQualifiedMember() {
        require(
            memberImportances[msg.sender] > 0,
            "This action can only be performed by qualified members of the contract!"
        );
        _;
    }

    modifier onlyIfInitialized() {
        require(isInitialized, "The contract has not yet been initialized!");
        _;
    }

    event Donation(address donator, uint256 amount);
    event VoteStarted(uint256 id, address receiver, uint256 transferAmount);
    event Voted(address indexed voter, uint256 voteId, bool voteFor);
    event Withdrawed(address indexed withdrawer, uint256 amount);

    function initialize(Member[] memory _members) public onlyOwner {
        require(!isInitialized, "The contract has albeady been initialized");
        require(_members.length >= 3, "The minimum  amount of members is 3!");

        for (uint256 i = 0; i < _members.length; i++) {
            if (_members[i].adr == owner) {
                require(
                    false,
                    "The owner of the contract can not be a member of it!"
                );
            }

            memberImportances[_members[i].adr] = _members[i].importance;
            totalMemberWeight += _members[i].importance;
        }

        isInitialized = true;
    }

    function donate() public payable {
        contractBallance += msg.value;

        emit Donation(msg.sender, msg.value);
    }

    function startVote(address _receiver, uint256 _transferAmount)
        public
        onlyOwner
        onlyIfInitialized
    {
        votesCount++;

        votesById[votesCount].id = votesCount;
        votesById[votesCount].receiver = _receiver;
        votesById[votesCount].transferAmount = _transferAmount;
        votesById[votesCount].targetWeight = totalMemberWeight / 2;
        votesById[votesCount].weightFor = 0;
        votesById[votesCount].weightAgainst = 0;
        votesById[votesCount].isActive = true;
        votesById[votesCount].isSuccessfull = false;

        emit VoteStarted(votesCount, _receiver, _transferAmount);
    }

    function voteFor(uint256 _voteId, bool _voteFor)
        public
        onlyQualifiedMember
        onlyIfInitialized
    {
        VotingLibrary.Vote storage targetVote = votesById[_voteId];

        withdrawAmounts[targetVote.receiver] += targetVote.update(
            _voteFor,
            memberImportances[msg.sender]
        );

        emit Voted(msg.sender, _voteId, _voteFor);
    }

    function withdraw() public payable onlyIfInitialized {
        uint256 withdrawAmount = withdrawAmounts[msg.sender];

        require(withdrawAmount > 0, "You do not have any funds to withdraw!");
        require(
            contractBallance >= withdrawAmount,
            "The contract does not have enough funds to furfill this withdraw!"
        );

        payable(msg.sender).transfer(withdrawAmount);

        withdrawAmounts[msg.sender] = 0;

        emit Withdrawed(msg.sender, withdrawAmount);
    }
}
