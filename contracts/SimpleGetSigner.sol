pragma solidity ^0.4.24;

library ECRecovery {
  function recover(bytes32 _hash, bytes _signature) internal pure returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;

    assembly {
      r := mload(add(_signature, 32))
      s := mload(add(_signature, 64))
      v := byte(0, mload(add(_signature, 96)))
    }

    if (v < 27) {
      v += 27;
    }

    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      return ecrecover(_hash, v, r, s);
    }
  }
}

contract SimpleGetSigner {
    using ECRecovery for bytes32;

    function getSigner(bytes32 _hash, bytes _signature) public pure returns (address) {
        return _hash.recover(_signature);
    }

    function isValidSigner(address _address, bytes32 _hash, bytes _signature) public pure returns(bool) {
        return _address == getSigner(_hash, _signature);
    }
}