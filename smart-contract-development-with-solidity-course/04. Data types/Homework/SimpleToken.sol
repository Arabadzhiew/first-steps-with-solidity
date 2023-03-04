pragma solidity 0.4.24;

contract SimpleToken {
    address public owner;

    string public name;
    string public symbol;
    uint256 public decimals;

    uint256 public totalTokens;

    mapping(address => uint256) public balances;

    constructor(string _name, string _symbol, uint256 _totalTokens, uint256 _decimals) public {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalTokens = _totalTokens;
        balances[owner] = _totalTokens;
    }

    event TransferedTokens(address indexed sender, address indexed receiver, uint256 amount, uint256 decimals);

    function transferTokens(address _receiver, uint256 _amount, uint256 _decimals) public {
        require(_decimals <= decimals, 
        "You can not make a trasfer with a value that has more decimals than the token itself!");

        uint256 decimalDifference = decimals - _decimals;
        uint256 decimalAmonut = _amount * (10 ** decimalDifference);

        require(decimalAmonut <= balances[msg.sender], "You do not have enough tokens to make this transfer!");

        balances[msg.sender] -= decimalAmonut;
        balances[_receiver] +=  decimalAmonut;

        emit TransferedTokens(msg.sender, _receiver, _amount, _decimals);
    }

    function() public payable {
        assert(false);
    }
}