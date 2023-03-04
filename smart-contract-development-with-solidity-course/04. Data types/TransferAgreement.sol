pragma solidity 0.4.24;

contract TransferAgreement {

    struct TransferProposal {
        address target;
        uint256 amount;
        uint256 creationTime;
        uint256 currentAcceptorIndex;
    }

    address[] public owners;
    mapping(address => bool) public ownersMapping;
    TransferProposal public proposal;

    constructor(address[] _owners) public {
        owners = _owners;

        for(uint256 i = 0; i < owners.length; i++) {
            ownersMapping[owners[i]] = true;
        }
    }

    event TransferProposed(address indexed target, uint256 amount);
    event TransferAccepted(address owner);
    event TransferSucceeded();

    modifier onlyOwners {
        require(ownersMapping[msg.sender] , "Only the owners of this contract can perform this action!");
        _;
    }

    function makeTransferProposal(address target, uint256 amount) public onlyOwners {
        require(address(this).balance >= amount, "The contract does not have enough funds to furfill this transfer!");

        proposal = TransferProposal(target, amount, block.timestamp, 0);

        emit TransferProposed(target, amount);
    }

    function accept() payable public {
        require(proposal.currentAcceptorIndex < owners.length, "The transfer has already been completed!");
        require(msg.sender == owners[proposal.currentAcceptorIndex], 
            "Only the current acceptor of the proposal can accept it!");


        address acceptor = owners[proposal.currentAcceptorIndex];
        proposal.currentAcceptorIndex++;

        emit TransferAccepted(acceptor);

        if(proposal.currentAcceptorIndex == owners.length) {
            require(proposal.creationTime + 5 minutes >= block.timestamp, "This transfer proposal has already expired!");

            proposal.target.transfer(proposal.amount);
            emit TransferSucceeded();
        }
    }

    function() payable public {}
}