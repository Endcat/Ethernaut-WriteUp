## 0x01 Task

一开始会给我20个token，想方设法拿到另外的token即为目标。

```javascript
pragma solidity ^0.4.18;

contract Token {

  mapping(address => uint) balances;
  uint public totalSupply;

  function Token(uint _initialSupply) public {
    balances[msg.sender] = totalSupply = _initialSupply;
  }

    // 给to送value个token
  function transfer(address _to, uint _value) public returns (bool) {
      // 保证caller有足够的token
    require(balances[msg.sender] - _value >= 0);
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    return true;
  }
	// 提供调用者查看特定地址的token拥有数
  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}
```

## 0x02 Solution

问题出在：

```javascript
require(balances[msg.sender] - _value >= 0);
```

`balances[msg.sender]`是一个`uint`类型数，`_value`也是。两者相减仍然是`uint`数，对于这个判定来说恒为真。看下面的表达式：

```javascript
balances[msg.sender] = 20 - 21;
```

这是一个典型的underflow，运算后的值将为`2^256-1`，而不是`-1`。

直接调用transfer即可，to地址可以为自己的第二个测试账户地址

