// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";
import { SD59x18, sd, convert } from "@prb/math/src/SD59x18.sol";
import "./Utils.sol";

contract SelfSovereignToken is ERC20, ERC20Burnable, AccessControl, Utils {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    event Minted(string value);
    //event Burned(string value);
    
    constructor() ERC20("SelfSovereignToken", "SST") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function grantMintRole(address minter) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(MINTER_ROLE, minter);
    }

    function revokeMintRole(address minter) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(MINTER_ROLE, minter);
    }

    function totalSupplyStr() public returns(string memory) {
        SD59x18 a = sd(int(totalSupply()));
        return SDtoString(a);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
        SD59x18 a = sd(int(amount));
        emit Minted(SDtoString(a));
        // uint256 b = amount / (10 ** 18);
        // console.log("Minted ", b);
    }
}