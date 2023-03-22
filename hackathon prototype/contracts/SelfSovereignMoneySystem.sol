// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./SelfSovereignToken.sol";
import "./PooledDebtToken.sol";

contract SelfSovereignMoneySystem {

  SelfSovereignToken public SST;
  PooledDebtToken public PDT;

  constructor(SelfSovereignToken _addrSST, PooledDebtToken _addrPDT) public {
    SST = _addrSST;
    PDT = _addrPDT;
  }
}
