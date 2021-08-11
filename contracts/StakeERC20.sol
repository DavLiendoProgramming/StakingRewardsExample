// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakeERC20 is ERC20 {
    constructor() ERC20("DLINE","DLS") {
        _mint(msg.sender, 100000000000); 
    }
} 