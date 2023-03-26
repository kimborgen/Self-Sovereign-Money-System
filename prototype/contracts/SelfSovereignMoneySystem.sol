// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./SelfSovereignToken.sol";
import "./PooledDebtToken.sol";
import "./QualifiedLegalEntites.sol";
import "./DebtContracts.sol";
import "truffle/console.sol";
import { SD59x18, sd, convert } from "@prb/math/src/SD59x18.sol";
//import { UD60x18, ud } from "@prb/math/src/UD60x18.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Utils.sol";

contract SelfSovereignMoneySystem is Utils {

  SelfSovereignToken public SST;
  PooledDebtToken public PDT;
  QualifiedLegalEntites public QLE;
  DebtContracts public DC;

  SD59x18 public monthlyTarget; //gdp in monthly
  SD59x18 public systemInterestRate;

  function getStatus() public returns(string memory) {
    string memory ir = string.concat("systemInterestRate ", SDtoString(systemInterestRate));
    string memory ts = string.concat("SSTTotalSupply ", SST.totalSupplyStr());
    string memory vpdc = string.concat("ValuePDC ", SDtoString(DC.pooledDebtContractValue()));
    return string.concat(ir, "; ", ts, "; ", vpdc);
  }

  SD59x18 public c_0;


  uint256 public startTimestamp;
  uint256 public periodicity; // one month in seconds
  bool public secondInitRan;

  event UpdatedSystemInterestRate(string newSIR);


  constructor(address _addrSST, address _addrPDT, address _addrQLE, address _addrDC) public {
    SST = SelfSovereignToken(_addrSST);
    PDT = PooledDebtToken(_addrPDT);
    QLE = QualifiedLegalEntites(_addrQLE);
    DC = DebtContracts(_addrDC);

    monthlyTarget = sd(0.0024662697723e18); // 3% anually in monthly interest rate
    updateSIR(monthlyTarget);
    startTimestamp = block.timestamp;

    // bruh time is wimey, and leap years can leap off a cliff, either way 3 normal years 1 leap year = 1461 days -> 31557600 seconds on average in a year, not counting leap seconds, other bs, and other leap year shenanigans. For a MVP, good enough :D
    //periodicity = 2629800; // 1 month in seconds
    periodicity = 60; // 60seconds
    secondInitRan = false;
  }
  
  function secondInit(address[] memory airdropDestination) public {
    require(secondInitRan == false);
    c_0 = convert(100000000); // lets say we begin with 100 mill
    // console.log("airdroplength", airdropDestination.length);
    SD59x18 toEach = c_0.div(convert(int(airdropDestination.length)));
    // consoleLogSD("toEach", toEach);
    for (uint i = 0; i < airdropDestination.length; i++) {
      SST.mint(airdropDestination[i], toEach.intoUint256());
    }
    secondInitRan = true;
  }

  function updateSIR(SD59x18 newIR) internal {
    systemInterestRate = newIR;
    
    DC.setSystemInterestRate(newIR);

    emit UpdatedSystemInterestRate(SDtoString(newIR));
  }

  // event Debug(string desc, string s);

  function updateSystemInterestRate() public {
    
    SD59x18 st = convert(int(startTimestamp));
    SD59x18 p = convert(int(periodicity));
    SD59x18 _now = convert(int(block.timestamp));
    SD59x18 mt = monthlyTarget.add(convert(1));
    // consoleLogSD("st", st);
    // consoleLogSD("p", p);
    // consoleLogSD("_now", _now);
    
    // amount of periods elapsed, we are currently in the n+1 period
    // emit Debug("p", SDtoString(p));
    SD59x18 nNow = _now.sub(st).div(p);
    // consoleLogSD("nNow", nNow);
    SD59x18 nLast = nNow.floor();
    // consoleLogSD("nLast", nLast);

    

    
    // calculate the money supply target of the last period n
    SD59x18 m_t_n = c_0.mul(mt.pow(nLast));
    // consoleLogSD("m_t_n", m_t_n);

    // calculate the money supply target of n+1
    SD59x18 m_t_np1 = c_0.mul(mt.pow(nLast.add(convert(1))));
    // consoleLogSD("m_t_np1", m_t_np1 );

    SD59x18 mIncrease = m_t_np1.sub(m_t_n);
    // consoleLogSD("mIncrease", mIncrease);

    
    // take a linear approach to figure out where we should be at this exact moment

    SD59x18 percentageToNext = nNow.sub(nLast);
    // consoleLogSD("ptn", percentageToNext);

    //SD59x18 m_t_now = m_t_np1.
    SD59x18 m_t_now = m_t_n.add(mIncrease.mul(percentageToNext));
    // consoleLogSD("m_t_now", m_t_now);

    // figure out the current money supply
    // m = sst + pdc.v
    // consoleLogSD("vPDC", DC.pooledDebtContractValue());
    // consoleLogSD("ts", sd(int(SST.totalSupply())));
    SD59x18 m = sd(int(SST.totalSupply())).add(DC.pooledDebtContractValue());    
    // consoleLogSD("m", m);

    // emit Debug("m", SDtoString(m));

    if (m.eq(sd(0))) {
      // consoleLogSD("m is 0", m);
      // consoleLogSD("m is 0", m);
      // consoleLogSD("m is 0", m);
      return;
    }
    // Factor
    SD59x18 factor1 = m_t_now.div(m);
    // consoleLogSD("factor1:", factor1);
    // console.log(factor1.intoUint256());


    SD59x18 factor2 = factor1.sub(convert(1));
    // consoleLogSD("factor2:", factor2);

    // Apply formula 11
    SD59x18 newIR = systemInterestRate.sub(factor2);
    if (newIR.lt(sd(0))) {
      newIR = sd(0);
    }
    // consoleLogSD("newIR", newIR);
    // consoleLogSD("oldIR", systemInterestRate);

    // set new interest rate and distribute
    updateSIR(newIR);
  }

}
