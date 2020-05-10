## 0x01 Task

```javascript
pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';

 contract NaughtCoin is StandardToken {
  
  using SafeMath for uint256;
  string public constant name = 'NaughtCoin';
  string public constant symbol = '0x0';
  uint public constant decimals = 18;
  uint public timeLock = now + 10 years;
  uint public INITIAL_SUPPLY = (10 ** decimals).mul(1000000);
  address public player;

  function NaughtCoin(address _player) public {
    player = _player;
    totalSupply_ = INITIAL_SUPPLY;
    balances[player] = INITIAL_SUPPLY;
    Transfer(0x0, player, INITIAL_SUPPLY);
  }
  
  function transfer(address _to, uint256 _value) lockTokens public returns(bool) {
    super.transfer(_to, _value);
  }

  // Prevent the initial owner from transferring tokens until the timelock has passed
  modifier lockTokens() {
    if (msg.sender == player) {
      require(now > timeLock);
      _;
    } else {
     _;
    }
  } 
} 
```

根据题意，需要将自己的 balance 清空。合约里提供了 `transfer()` 函数来进行转账操作，但注意到有一个 modifier `lockTokens()`，限制了只有十年后才能调用 `transfer()` 函数。需要解题者 bypass it

## 0x02 Solution

在子合约中找不出更多信息的时候，把目光更多放到父合约和接口上

注意到该合约是 `StandardToken` 的子合约，在接口规范里能看到，除了 `transfer()` 之外，还有 `transferFrom()` 函数也可以进行转账操作。

![image-20200508195704799](https://picturefac.oss-cn-hangzhou.aliyuncs.com/img/20200508195706.png)

由于 NaughtCoin 子合约中并没有实现该接口，我们可以直接调用，从而绕开了 `lockTokens()` ，题目的突破口就在此。
需要注意的是，与 `transfer()` 不同，调用 `transferFrom()` 需要 `msg.sender` 获得授权。由于我们本就是合约的 owner，可以自己给自己授权。授权操作在接口文档里也有

直接在console操作即可

> (await contract.balanceOf(player)).toString() // 查看balance
>
> await contract.transferFrom(player, "0x8973D74F318f914F305fb71dD7a55d057D29df1f", "1e+24")
>
> await contract.increaseApproval(player, "1e+24")

