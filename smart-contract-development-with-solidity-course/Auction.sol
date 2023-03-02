pragma solidity 0.4.24;

contract Auction {
    
    uint256 public startTime;
    uint256 public endTime; 
    address public owner;
    bool public isCanceled;

    address private highestBidder;
    uint256 private highestBid;

    mapping(address => uint256) public bids;

    constructor(uint256 startTimeValue, uint256 endTimeValue) public {
        owner = msg.sender;

        require(startTimeValue >= block.timestamp, "The start time of the auction must not be in the past!");
        require(endTimeValue > startTimeValue, "The end time of the auction must be greater than the start time!");

        startTime = startTimeValue;
        endTime = endTimeValue;
    }

    event PlacedBid(address indexed bidder, uint256 bidValue);
    event Withdrawed(address indexed withdrawer, uint256 withdrawedAmmount);
    event AuctionCanceled();

    function placeBid() public payable onlyNonOwner {
        require(startTime <= block.timestamp, "The auction has not yet started.");
        require(block.timestamp < endTime, "The auction has already ended");
        require(!isCanceled, "The auction has been canceled by the owner.");

        address bidder = msg.sender;
        uint256 bidValue = bids[bidder] + msg.value;

        require(bidValue > highestBid, "The new bid shoud be greater than the current highest one!");

        bids[bidder] = bidValue;
        highestBid = bids[bidder];
        highestBidder = bidder;

        emit PlacedBid(bidder, bidValue);
    }

    function getHighestBidder() public view returns(address) {
        return highestBidder; 
    }

    function getHighestBid() public view returns(uint256) {
        return highestBid;
    }

    function withdraw() public payable {
        bool hasAuctionEnded = endTime <= block.timestamp;
        bool isOwner = owner == msg.sender;

        require(!hasAuctionEnded || msg.sender != highestBidder, "You can not withdraw your bid, because you have won this auction!");

        if(isOwner) {
            require(hasAuctionEnded && !isCanceled, "The owner can withdraw the highest bid, only when the auction has ended non abruptly!");
            owner.transfer(highestBid);
            emit Withdrawed(owner, highestBid);
            
            return;
        }else {
            require(isCanceled || hasAuctionEnded, "The auction must come to an end, before you can withdraw your bid!");

            msg.sender.transfer(bids[msg.sender]);
            emit Withdrawed(msg.sender, bids[msg.sender]);
        }


    }

    function cancel() public onlyOwner {
        isCanceled = true;

        emit AuctionCanceled();
    }


    modifier onlyOwner {
        require(msg.sender == owner, "This method can only be invoked by the owner addresses.");
        _;
    }

    modifier onlyNonOwner {
        require(msg.sender != owner, "This method can only be invoked by the non-owner addresses.");
        _;
    }
}