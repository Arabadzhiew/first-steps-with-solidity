pragma solidity 0.4.24;

contract Agent {
    address public master;

    mapping(string => uint256) private orderStartTimes;
    mapping(string => bool) private orderNameExists;

    uint256 private lastOrderTime;

    constructor(address _master) public {
        master = _master;
    }

    modifier onlyMaster {
        require(msg.sender == master, "This action can only be performed by the master of this agent contract!");
        _;
    }

    function createOrder(string _name) public onlyMaster {
        require(!orderNameExists[_name], "An order with the specified name already exists!");
        require(lastOrderTime + 15 seconds <= block.timestamp, "An order can be placed only once per 15 seconds!");
        
        lastOrderTime = block.timestamp;
        orderStartTimes[_name] = lastOrderTime;
        orderNameExists[_name] = true;
    }

    function isOrderDone(string _name) public view onlyMaster returns(bool) {
        return orderNameExists[_name] && orderStartTimes[_name] + 15 seconds <= block.timestamp;
    }
}

contract Master {
    address public owner;

     Agent[] public agents;

     constructor() public {
         owner = msg.sender;
     }

     modifier onlyOwner {
         require(msg.sender == owner, "This action can only be performed of the owner of the contract!");
         _;
     }

     function createAgent() public onlyOwner {
         agents.push(new Agent(this));
     }

     function addAgent(address _agentAddress) public onlyOwner {
         agents.push(Agent(_agentAddress));
     }

     function makeOrder(uint256 _agentIndex, string _orderName) public onlyOwner {
         agents[_agentIndex].createOrder(_orderName);
     }

     function isOrderDone(uint256 _agentIndex, string _orderName) public view returns(bool) {
         return agents[_agentIndex].isOrderDone(_orderName);
     }
}