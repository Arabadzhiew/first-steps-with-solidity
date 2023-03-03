pragma solidity 0.4.24;

contract Service {

    address public owner; 
    uint256 public lastBuyTime;
    uint256 public lastWithdrawTime;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "This action can only be performed by the owner of the contract!");
        _;
    }

    modifier onlyNonOwner {
        require(msg.sender != owner, "This action can only be performed by the non owners of the contract!");
        _;
    }

    modifier onlyMatchingBuyPrice {
        require(msg.value >= 1 ether, "The buy price of the service is 1 ether!");
        _;
    }

    // For buys
    modifier onlyOncePerTwoMinutes {
        require(block.timestamp - lastBuyTime > 60 * 2, "This action can only be performed once per two minutes!");
        _;
    }

    // For withdraws
    modifier onlyOncePerHour {
        require((block.timestamp - lastWithdrawTime) / 60 > 60, "This action can only be performed once per hour!");
        _;
    }


    event BoughtService(address buyer);
    event OwnerWithdrew(uint256 withdrawAmmount);

    function buyService() payable public onlyNonOwner onlyMatchingBuyPrice onlyOncePerTwoMinutes {
        if(msg.value > 1 ether) {
            uint256 valueToReturnBack = msg.value - 1 ether;

            msg.sender.transfer(valueToReturnBack); 
        }

        lastBuyTime = block.timestamp;

        emit BoughtService(msg.sender);
    }

    function withdraw(uint256 withdrawAmmount) payable public onlyOwner onlyOncePerHour {
        if(withdrawAmmount > 5 ether) {
            withdrawAmmount = 5 ether;
        }

        owner.transfer(withdrawAmmount);

        lastWithdrawTime = block.timestamp;

        emit OwnerWithdrew(withdrawAmmount);
    }
}