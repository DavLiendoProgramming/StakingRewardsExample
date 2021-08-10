// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract RewardERC20 is ERC20PresetMinterPauser {
    constructor() ERC20PresetMinterPauser("DLINER","DLR") {
        _mint(msg.sender, 500); 
    }
}