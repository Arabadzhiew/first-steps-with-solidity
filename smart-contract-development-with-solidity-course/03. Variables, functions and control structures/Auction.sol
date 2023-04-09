pragma solidity 0.4.24;

contract Auction {
    
    uint256 public startTime;
    uint256 public endTime; 
    uint256 public minimumBidRaise;
    address public owner;
    bool public isCanceled;

    address private highestBidder;
    uint256 private highestBid;


    mapping(address => uint256) public bids;
    mapping(address => uint256) public lastBidTimes;

    constructor(uint256 _startTime, uint256 _endTime, uint256 _minimumBidRaise) public {
        owner = msg.sender;

        require(_startTime >= block.timestamp, "The start time of the auction must not be in the past!");
        require(_endTime > _startTime, "The end time of the auction must be greater than the start time!");

        startTime = _startTime;
        endTime = _endTime;
        minimumBidRaise = _minimumBidRaise;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "This method can only be invoked by the owner addresses.");
        _;
    }

    modifier onlyNonOwner {
        require(msg.sender != owner, "This method can only be invoked by the non-owner addresses.");
        _;
    }

    modifier onlyOncePerMinute {
        // Checking whether one minute has passed after the last bid of the sender
        require(block.timestamp - lastBidTimes[msg.sender]  > 60, "You can place a new bid, only after a minute has passed after your last one!");
        _;
    }

    event PlacedBid(address indexed bidder, uint256 bidValue);
    event Withdrew(address indexed withdrawer, uint256 withdrawedAmmount);
    event CanceledAuction();

    function placeBid() public payable onlyNonOwner onlyOncePerMinute {
        require(startTime <= block.timestamp, "The auction has not yet started.");
        require(block.timestamp < endTime, "The auction has already ended");
        require(!isCanceled, "The auction has been canceled by the owner.");
        require(bids[msg.sender] + msg.value >= highestBid + minimumBidRaise,
             "The bid should be raised to a value, that is at least equal to the current bid plus the minimum bid raise!");

        address bidder = msg.sender;
        uint256 bidValue = bids[bidder] + msg.value;

        require(bidValue > highestBid, "The new bid shoud be greater than the current highest one!");

        bids[bidder] = bidValue;
        lastBidTimes[bidder] = block.timestamp;
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
            emit Withdrew(owner, highestBid);
            
            return;
        }else {
            require(isCanceled || hasAuctionEnded, "The auction must come to an end, before you can withdraw your bid!");

            msg.sender.transfer(bids[msg.sender]);
            emit Withdrew(msg.sender, bids[msg.sender]);
        }


    }

    function cancel() public onlyOwner {
        isCanceled = true;

        emit CanceledAuction();
    }
}