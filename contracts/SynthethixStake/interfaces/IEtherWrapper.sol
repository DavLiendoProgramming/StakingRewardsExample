// SPDX-License-Identifier: MIT

pragma solidity >=0.8;

import "./IWETH.sol";

// https://docs.synthetix.io/contracts/source/interfaces/ietherwrapper
abstract contract IEtherWrapper {
    function mint(uint amount) external virtual;

    function burn(uint amount) external virtual;

    function distributeFees() external virtual;

    function capacity() external virtual view returns (uint);

    function getReserves() external virtual view returns (uint);

    function totalIssuedSynths() external virtual view returns (uint);

    function calculateMintFee(uint amount) public virtual view returns (uint);

    function calculateBurnFee(uint amount) public virtual view returns (uint);

    function maxETH() public virtual view returns (uint256);

    function mintFeeRate() public virtual view returns (uint256);

    function burnFeeRate() public virtual view returns (uint256);

    function weth() public virtual view returns (IWETH);
}