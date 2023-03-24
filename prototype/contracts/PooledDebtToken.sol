// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./SelfSovereignMoneySystem.sol";

contract PooledDebtToken is ERC20, Ownable {
    constructor() ERC20("PooledDebtToken", "PDT") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}