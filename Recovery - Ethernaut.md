## 0x01 Task

```javascript
pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';

contract Recovery {

  //generate tokens
  function generateToken(string _name, uint256 _initialSupply) public {
    new SimpleToken(_name, msg.sender, _initialSupply);
  
  }
}

contract SimpleToken {

  using SafeMath for uint256;
  // public variables
  string public name;
  mapping (address => uint) public balances;

  // constructor
  constructor(string _name, address _creator, uint256 _initialSupply) public {
    name = _name;
    balances[_creator] = _initialSupply;
  }

  // collect ether in return for tokens
  function() public payable {
    balances[msg.sender] = msg.value.mul(10);
  }

  // allow transfers of tokens
  function transfer(address _to, uint _amount) public { 
    require(balances[msg.sender] >= _amount);
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    balances[_to] = _amount;
  }

  // clean up after ourselves
  function destroy(address _to) public {
    selfdestruct(_to);
  }
}
```

A contract creator has built a very simple token factory contract. Anyone can create new tokens with ease. After deploying the first token contract, the creator sent `0.5` ether to obtain more tokens. They have since lost the contract address.

This level will be completed if you can recover (or remove) the `0.5` ether from the lost contract address.

## 0x02 need2know

这一关要求拿到丢失的合约地址，并且拿回剩余的0.5eth

关于合约地址的找回，有两个方法可以实现：

### 计算合约地址

合约地址其实是被确切地计算出来的，文档中：

> The address of the new account is defined as being the rightmost 160 bits of the Keccak hash of the RLP encoding of the structure containing only the sender and the account nonce. Thus we define the resultant address for the new account `a ≡ B96..255 KEC RLP (s, σ[s]n − 1）`

用公式表达就是

```javascript
address = rightmost_20_bytes(keccak(RLP(sender address, nonce)))
```

- `sender address`: is the contract or wallet address that created this new contract
- `nonce`: is the number of transactions sent from the `sender address` OR, **if the sender is a factory contract, the** `nonce` **is the number of contract-creations made by this account.**
- `RLP`: is an encoder on data structure, and is the default to serialize objects in Ethereum.
- `keccak`: is a cryptographic primitive that compute the Ethereum-SHA-3 (Keccak-256) hash of any input.

根据文档，新的合约地址计算可以写作：

```javascript
address public a = address(keccak256(0xd6, 0x94, YOUR_ADDR, 0x01));
```

[Document](https://github.com/ethereum/wiki/wiki/RLP)

### Etherscan

当然可以直接拿Etherscan看：

![image-20200509102915981](https://picturefac.oss-cn-hangzhou.aliyuncs.com/img/20200509102916.png)

1. In Etherscan, look up your current contract by address.
2. Inside the `Internal Txns` tab, locate the latest contract creation, and click on the link into the new contract.
3. The new contract address should now show at the top left hand corner.

## 0x03 Solution

首先创建题目实例，拿到实例地址：

`0x63e76164fc5c0ddc7039847a05a00a59fd535e67`

计算：

```javascript
web3.sha3("0xd6", "0x94", "0x63e76164fc5c0ddc7039847a05a00a59fd535e67", "0x01")
```

得到：

`0x0fa38d5bb7c6919658f12eb7c38d4483c52ca32d3780b47ea31c09f52d953583`

取最右20个字节：c38d4483c52ca32d3780b47ea31c09f52d953583

这里和Etherscan得出来的结论不一样，选择Etherscan的结果。

（我在做这系列题目的时候，可能web3库改动较大）

`0x16c06E2B4547556FE78788422A10da831BE66613`

exp:

```javascript
pragma solidity ^0.6.6;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
contract SimpleToken {

  using SafeMath for uint256;
  // public variables
  string public name;
  mapping (address => uint) public balances;

  // constructor
  constructor(string memory _name, address _creator, uint256 _initialSupply) public {
    name = _name;
    balances[_creator] = _initialSupply;
  }

  // collect ether in return for tokens
  fallback() external payable {
    balances[msg.sender] = msg.value.mul(10);
  }

  // allow transfers of tokens
  function transfer(address _to, uint _amount) public { 
    require(balances[msg.sender] >= _amount);
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    balances[_to] = _amount;
  }

  // clean up after ourselves
  function destroy(address payable _to) public {
    selfdestruct(_to);
  }
}

contract Destroy{
    address payable receiver = msg.sender;
    SimpleToken killMeplease;
    
    function destroySimpleToken(address payable simpleTokenAddress) public{
        killMeplease = SimpleToken(simpleTokenAddress);
        killMeplease.destroy(receiver);
    }
    
}
```



