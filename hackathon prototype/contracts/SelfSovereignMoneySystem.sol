// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./SelfSovereignToken.sol";
import "./PooledDebtToken.sol";
import "./QualifiedLegalEntites.sol";
import "./DebtContracts.sol";
import { SD59x18, sd } from "@prb/math/src/SD59x18.sol";
import { UD60x18, ud } from "@prb/math/src/UD60x18.sol";

contract SelfSovereignMoneySystem {

  SelfSovereignToken public SST;
  PooledDebtToken public PDT;
  QualifiedLegalEntites public QLE;
  DebtContracts public DC;

  SD59x18 interestRate;

  constructor(SelfSovereignToken _addrSST, PooledDebtToken _addrPDT, QualifiedLegalEntites _addrQLE, DebtContracts _addrDC) public {
    SST = _addrSST;
    PDT = _addrPDT;
    QLE = _addrQLE;
    DC = _addrDC;

    interestRate = sd(0.03e18); // interest rate of 3% initialy?    

  }
}
