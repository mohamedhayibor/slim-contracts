pragma solidity ^0.4.24;

contract SimpleHashLock {
    // declaring the hashed password variable
    bytes32 hashedSecret;

    // Instantiating the contract by providing the hashed password as an argument
    // This runs at contract creation
    constructor(bytes32 _hashedSecret) public {
        // nobody can guess the password just looking at the hash
        hashedSecret = _hashedSecret;
    }

    // This modifier runs first, before `hashLockedWithdraw` is run
    modifier hashLocked(string _secret) {
        require(keccak256(_secret) == hashedSecret);
        _;
    }

    // anybody can deposit whatever amount of money into the contract
    function deposit() payable public { }

    // This function can be only run provided that the sender has the password
    // which would result in the same hash
    function hashLockedWithdraw(string _secret) hashLocked(_secret) public {
        // transfer all funds to whoever is calling the function (and has the correct password)
        msg.sender.transfer(address(this).balance);
    }
}
