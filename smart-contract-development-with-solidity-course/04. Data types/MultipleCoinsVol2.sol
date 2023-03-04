pragma solidity 0.4.24;

contract MultipleCoinsVol2 {
    enum CoinType {
        RedCoin,
        GreenCoin,
        BlueCoin,
        PurpleCoin,
        YellowCoin,
        VioletCoin,
        IndigoCoin
    }

    mapping(address => mapping(uint8 => uint256)) public coinBalances;

    constructor() public {
        for(uint8 i = 0; i <= uint(CoinType.IndigoCoin); i++) {
            coinBalances[msg.sender][i] = 10000;
        }
    }

    event Transaction(CoinType coinType, address indexed sender, address indexed recever, uint256 amount);

    function sendCoins(CoinType _type, address _receiver, uint256 _amount) public {
        uint256 senderBalance = coinBalances[msg.sender][uint8(_type)];

        require(senderBalance >= _amount, "You do not have enough coins to make this transaciton!");

        coinBalances[msg.sender][uint8(_type)] -= _amount;
        coinBalances[_receiver][uint8(_type)] += _amount;

        emit Transaction(_type, msg.sender, _receiver, _amount);
    }
}