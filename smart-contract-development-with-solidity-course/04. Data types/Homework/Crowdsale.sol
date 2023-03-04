pragma solidity 0.4.24;

contract Crowdsale {
    address public owner;

    uint256 public tokenBallance;
    uint public creationTimestamp;

    mapping(address => uint256) public balances;
    
    address[] tokenHolders;
    mapping(address => bool) tokenHoldersMapping;

    constructor() public {
        owner = msg.sender;
        creationTimestamp = block.timestamp;
    }

    modifier onlyDuringFirstFiveMinutes {
        require(creationTimestamp + 5 minutes > block.timestamp, 
            "This action can only be performed during the first 5 minutes after the creation of the contract!");
            _;
    }

    modifier onlyAfterFirstFiveMinutes {
        require(creationTimestamp + 5 minutes <= block.timestamp, 
            "This action can only be performed only after 5 minutes have passed since the creation of the contract!");
        _;
    }

    modifier onlyAfterOneYear {
        require(creationTimestamp + 365 days <= block.timestamp, 
            "This action can only be performed after 1 year has passed since the creation of the contract!");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "This action can only be perfomed by the contract owner!");
        _;
    }

    modifier onlyNonOwner {
        require(msg.sender != owner, "This action can only be perfomed by non owners of the contract!");
        _;
    }

    event BoughtTokens(address indexed buyer, uint256 amount);
    event TransferedTokens(address indexed sender, address indexed receiver, uint256 amount);
    event OwnerWithdrew(uint256 amonut);

    function buyTokens() public payable onlyNonOwner onlyDuringFirstFiveMinutes {
        require(msg.value >= 1 ether, "The minumum ammount to invest is 1 ether!");
        require(msg.value % 1 ether == 0, "The value that you want to invest must be a round ether value! ");

        uint256 boughtTokens = msg.value / 1 ether * 5;

        tokenBallance += boughtTokens;
        balances[msg.sender] += boughtTokens;
        tokenHolders.push(msg.sender);
        tokenHoldersMapping[msg.sender] = true;

        emit BoughtTokens(msg.sender, msg.value);
    }

    function transferTokens(address receiver, uint amount) public onlyAfterFirstFiveMinutes {
        require(balances[msg.sender] >= amount, "You do not have enought tokens to make this transfer!");

        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        if(tokenHoldersMapping[receiver]) {
            tokenHolders.push(receiver);
            tokenHoldersMapping[receiver] = true;
        }

        emit TransferedTokens(msg.sender, receiver, amount);
    }

    function isInvolved(address target) public view returns(bool) {
        return tokenHoldersMapping[target];
    }

    function getAllInvolvedAddresses() public view returns(address[]) {
        return tokenHolders;
    }

    function withdrawFunds() public payable onlyOwner onlyAfterOneYear {
        uint256 contractBalance = address(this).balance;

        owner.transfer(contractBalance);

        emit OwnerWithdrew(contractBalance);
    }
}