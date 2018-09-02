pragma solidity ^0.4.24;

contract SimpleHashLock {
    bytes32 hashedSecret;

    constructor(bytes32 _hashedSecret) public {
        hashedSecret = _hashedSecret;
    }

    modifier hashLocked(string _secret) {
        require(keccak256(_secret) == hashedSecret);
        _;
    }

    function deposit() payable public { }

    // example use case
    function hashLockedWithdraw(string _secret) hashLocked(_secret) public {
        // transfer all funds to sender
        msg.sender.transfer(address(this).balance);
    }
}