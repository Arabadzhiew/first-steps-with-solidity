pragma solidity 0.4.24;

contract DistributedTransfer {
    mapping(address => bool) public isMember;
    uint256 public memberCount;

    mapping(address => uint256) public memberTotalWithdrawed;
    uint256 public possibleWithdrawPerMember;

    uint256 public contractBallance;

    address public owner;

    bool public isInitialized;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyMember() {
        require(isMember[msg.sender]);
        _;
    }

    modifier onlyWhenInitialied() {
        require(isInitialized);
        _;
    }

    event MemberWithdrawed(address member, uint256 amount);
    event ContractBallanceWithdrawed(uint256 amount);

    function initialize(address[] _members) public onlyOwner {
        require(!isInitialized);
        for (uint256 i = 0; i < _members.length; i++) {
            isMember[_members[i]] = true;
        }
        memberCount = _members.length;

        isInitialized = true;
    }

    function withdraw() public onlyMember onlyWhenInitialied {
        uint256 withdrawAmount = possibleWithdrawPerMember -
            memberTotalWithdrawed[msg.sender];

        require(withdrawAmount > 0);

        msg.sender.transfer(withdrawAmount);
        memberTotalWithdrawed[msg.sender] += withdrawAmount;

        emit MemberWithdrawed(msg.sender, withdrawAmount);
    }

    function withdrawContractBallance() public onlyOwner onlyWhenInitialied {
        require(contractBallance > 0);

        owner.transfer(contractBallance);

        emit ContractBallanceWithdrawed(contractBallance);
        contractBallance = 0;
    }

    function() public payable onlyWhenInitialied {
        possibleWithdrawPerMember += msg.value / memberCount;
        contractBallance += msg.value % memberCount;
    }
}
