## 0x01 Task

```javascript
pragma solidity ^0.4.24;

contract MagicNum {

  address public solver;

  constructor() public {}

  function setSolver(address _solver) public {
    solver = _solver;
  }

  /*
    ____________/\\\_______/\\\\\\\\\_____        
     __________/\\\\\_____/\\\///////\\\___       
      ________/\\\/\\\____\///______\//\\\__      
       ______/\\\/\/\\\______________/\\\/___     
        ____/\\\/__\/\\\___________/\\\//_____    
         __/\\\\\\\\\\\\\\\\_____/\\\//________   
          _\///////////\\\//____/\\\/___________  
           ___________\/\\\_____/\\\\\\\\\\\\\\\_ 
            ___________\///_____\///////////////__
  */
}
```

To solve this level, you only need to provide the Ethernaut with a "Solver", a contract that responds to "whatIsTheMeaningOfLife()" with the right number.

Easy right? Well... there's a catch.

The solver's code needs to be really tiny. Really reaaaaaallly tiny. Like freakin' really really itty-bitty tiny: 10 opcodes at most.

Hint: Perhaps its time to leave the comfort of the Solidity compiler momentarily, and build this one by hand O_o. That's right: Raw EVM bytecode.

Good luck!

## 0x02 need2know

这一关需要用到汇编来往EVM中部署小合约。

![image-20200509134810033](https://picturefac.oss-cn-hangzhou.aliyuncs.com/img/20200509134811.png)

### 合约的初始化过程

- 首先，用户或者合约向Ethereum网络发送交易请求（Transaction），交易请求里包含数据，但不包含接受方的地址。EVM会把这样的交易请求格式当作一个`contract creation`，而不是常规的send/call transaction。

- 其次，EVM会把合约中的solidity代码编译成字节码，字节码可以直接翻译成opcode，从而可以在调用栈中被执行。

> *Important to note:* `contract creation` *bytecode contains both 1)*`initialization code` *and 2) the contract’s actual* `runtime code`*, concatenated in sequential order.*

- 在合约创建的过程中，EVM只会执行初始化代码`initialization code`，直到在栈中执行了`STOP`或者`RETURN`指令。在这个阶段，合约的构造函数被执行，并且合约拥有地址。
- 在初始化代码执行完后，只有运行时代码`runtime code`会保留在栈上。运行时opcodes会被复制到内存中，并返回给EVM。

- 最后，EVM把返回的剩余代码以`storage`的方式存储，并与新的合约地址关联在一起。

对于这关来说，需要两组opcodes：

- `Initialization opcodes`: to be run immediately by the EVM to create your contract and store your future runtime opcodes, and
- `Runtime opcodes`: to contain the actual execution logic you want. This is the main part of your code that should **return** `0x2a` **and be under 10 opcodes.**

## 0x03 Solution

首先的话搞清楚运行时代码的逻辑。

我们需要返回一个简单的`0x2a`，返回值需要用到的opcode是`RETURN`，需要两个参数：

- `p`: the position where your value is stored in memory, i.e. 0x0, 0x40, 0x50 (see figure). *Let’s arbitrarily pick the 0x80 slot.*
- `s`: the size of your stored data. *Recall your value is 32 bytes long (or 0x20 in hex).*

Ethereum的内存看起来像这样：

![image-20200509192220462](https://picturefac.oss-cn-hangzhou.aliyuncs.com/img/20200509192221.png)

在`RETURN`之前，还得存储数，需要用到的指令是`mstore(p, v)`，其中p指代位置，v指代数据值。

```
602a    // v: push1 0x2a (value is 0x2a)
6080    // p: push1 0x80 (memory slot is 0x80)
52      // mstore
```

```
6020    // s: push1 0x20 (value is 32 bytes in size)
6080    // p: push1 0x80 (value was stored in slot 0x80)
f3      // return
```

得到opcode序列`602a60805260206080f3`，刚好10bytes满足题目要求。

上面的是`runtime opcodes`，还需要编写一个初始化合约opcodes，来实现在返回到EVM之前将`runtime opcodes`复制到内存。在这之后EVM会把`runtime opcodes`自动保存到区块链上。

复制代码用到的opcode是`codecopy`，需要三个参数：

- `t`: the destination position of the code, in memory. *Let’s arbitrarily save the code to the 0x00 position.*
- `f`: the current position of the `runtime opcodes`, in reference to the entire bytecode. Remember that `f` starts after `initialization opcodes` end. *What a chicken and egg problem! This value is currently unknown to you.*
- `s`: size of the code, in bytes. *Recall that* `*602a60805260206080f3*` is 10 bytes long (or 0x0a in hex).

```
600a    // s: push1 0x0a (10 bytes)
60??    // f: push1 0x?? (current position of runtime opcodes)
6000    // t: push1 0x00 (destination memory index 0)
39      // CODECOPY
```

这里`runtime opcodes`的位置现在是不知道的

之后，把在内存中的`runtime opcodes`返回给EVM：

```
600a    // s: push1 0x0a (runtime opcode length)
6000    // p: push1 0x00 (access memory index 0)
f3      // return to EVM
```

现在整理一遍，初始化opcode总共占据了12bytes（0x0c），这其实意味着`runtime opcodes`的开始位置为`0x0c`。这样就可以补全之前的填空了：

```
600a    // s: push1 0x0a (10 bytes)
600c    // f: push1 0x?? (current position of runtime opcodes)
6000    // t: push1 0x00 (destination memory index 0)
39      // CODECOPY
```

整理一下`initialization opcodes`和`runtime opcodes`。

```
0x600a600c600039600a6000f3602a60805260206080f3
```

poc:

```javascript
var bytecode = "0x600a600c600039600a6000f3602A60805260206080f3";
web3.eth.sendTransaction({ from: player, data: bytecode }, function(err,res){console.log(res)});
await contract.setSolver("contract address");
```