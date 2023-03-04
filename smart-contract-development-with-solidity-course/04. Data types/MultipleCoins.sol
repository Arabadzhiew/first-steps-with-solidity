pragma solidity 0.4.24;

contract MultipleCoins {
    
    struct Balance {
        uint256 redCoins;
        uint256 greenCoins;
    }

    address public owner;

    mapping(address => Balance) public coinBalances;

    event RedCoinsTransaction(address indexed sender, address indexed receiver, uint256 amout);
    event GreenCoinsTransaction(address indexed sender, address indexed receiver, uint256 amout);

    constructor() public {
        owner = msg.sender;

        coinBalances[owner].redCoins = 10000;
        coinBalances[owner].greenCoins = 5000;
    }

    function sendRedCoins(address receiver, uint256 amount) public {
        require(coinBalances[msg.sender].redCoins >= amount, 
            "You do not have enough red coins to make this transaction!");
        
        coinBalances[msg.sender].redCoins -= amount;
        coinBalances[receiver].redCoins += amount;

        emit RedCoinsTransaction(msg.sender, receiver, amount);
    }

    function sendGreenCoins(address receiver, uint256 amount) public {
        require(coinBalances[msg.sender].greenCoins >= amount, 
            "You do not have enough green coins to make this transaction!");
        
        coinBalances[msg.sender].greenCoins -= amount;
        coinBalances[receiver].greenCoins += amount;

        emit GreenCoinsTransaction(msg.sender, receiver, amount);
    }
}