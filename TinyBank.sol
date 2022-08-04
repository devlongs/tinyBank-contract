// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

/// you are not the owner
error NotOwner();

contract TinyBank {
    address public bankManager;

    mapping(address => uint256) public addressToAmountDeposited;
    address[] public depositors;

    constructor() {
        bankManager = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != bankManager) revert NotOwner();
        _;
    }

    function deposit() public payable {
        addressToAmountDeposited[msg.sender] += msg.value;
        depositors.push(msg.sender);
    }

    function withdraw() public payable onlyOwner {
        for (
            uint256 depositorIndex = 0;
            depositorIndex < depositors.length;
            depositorIndex++
        ) {
            address depositor = depositors[depositorIndex];
            addressToAmountDeposited[depositor] = 0;
        }
        depositors = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    function getBankBalance() public view onlyOwner returns(uint256) {
        return address(this).balance;
    }

    fallback() external payable {
        deposit();
    }

    receive() external payable {
        deposit();
    }
}
