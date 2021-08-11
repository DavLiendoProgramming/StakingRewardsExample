// SPDX-License-Identifier: MIT
pragma solidity ^0.8;


import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract RewardERC20 is ERC20PresetMinterPauser {
    constructor() ERC20PresetMinterPauser("DLINER","DLR") {
        _mint(msg.sender, 100000000000); 
    }
}