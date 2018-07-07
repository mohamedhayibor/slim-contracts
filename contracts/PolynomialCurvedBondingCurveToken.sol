pragma solidity ^0.4.24;

// heavily looked at https://github.com/CryptoAgainstHumanity/crypto-against-humanity/blob/master/ethereum/contracts
// No transfer or trading between accounts only through the smart contract

contract PolynomialCurvedBondingCurveToken {
    uint8 exponent;
    uint256 PRECISION;
    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals;

    // amount of wei the smart contract holds
    uint256 public poolBalance;

    constructor(string _name, string _symbol, uint8 _decimals, uint8 _exponent, uint256 _precision) public {
        totalSupply = 0;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        exponent = _exponent;        // usually 1
        PRECISION = _precision;      // example: 10 million
    }

    // tokens owned by each address
    mapping(address => uint256) public tokenBalances;

    // Calculate the integral from 0 to t (number to integrate to)
    function curveIntegral(uint256 _t) internal returns(uint256) {
        uint256 nexp = exponent + 1;
        // calculate integral t^exponent
        return ((PRECISION / nexp) * (_t ** nexp)) / PRECISION;
    }

    // minting new tokens
    function mint(uint256 _numTokens) public payable {
        uint256 priceForTokens = getMintingPrice(_numTokens);
        require(msg.value >= priceForTokens, "Not enough value for total price of tokens");

        totalSupply = totalSupply + _numTokens;
        tokenBalances[msg.sender] = tokenBalances[msg.sender] + _numTokens;
        poolBalance = poolBalance + priceForTokens;

        // send back the change
        if (msg.value > priceForTokens) {
            msg.sender.transfer(msg.value - priceForTokens);
        }
    }

    function getMintingPrice(uint256 _numTokens) public view returns(uint256) {
        return curveIntegral(totalSupply + _numTokens) - poolBalance;
    }

    // burning tokens >> eth to return
    function burn(uint256 _numTokens) public {
        require(tokenBalances[msg.sender] >= _numTokens, "Not enough owned tokens to burn");

        uint256 ethToReturn = getBurningReward(_numTokens);

        totalSupply = totalSupply - _numTokens;
        poolBalance = poolBalance - ethToReturn;
        msg.sender.transfer(ethToReturn);
    }

    function getBurningReward(uint256 _numTokens) public view returns(uint256) {
        return poolBalance - (curveIntegral(totalSupply - _numTokens));
    }
}