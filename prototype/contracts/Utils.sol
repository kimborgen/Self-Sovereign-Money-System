// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "truffle/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import { SD59x18, sd, convert } from "@prb/math/src/SD59x18.sol";

abstract contract Utils {


    function SDtoString(SD59x18 n) public view  returns(string memory) {
        SD59x18 tmp;
        string memory sign = "";
        if (n.lt(sd(0))) {
          tmp = n.abs();
          sign = "-";
        } else {
          tmp = n;
        }
        // console.log(tmp.intoUint256());
        SD59x18 intValue = tmp.floor();
        // console.log(intValue.intoUint256());
        SD59x18 decValue = tmp.sub(intValue);
        // console.log(decValue.intoUint256());
        string memory sInt = Strings.toString(uint(convert(intValue)));
        // console.log("sInt:",sInt);
        string memory sDec = Strings.toString(decValue.intoUint256());
        // console.log("sDec", sDec);
        bytes memory bDec = bytes(sDec);
        bytes memory b = new bytes(18);
        // console.log("lenbDec", bDec.length);
        if (bDec.length < 18) {
            uint startI = 18 - bDec.length;
            for (uint i = 0; i < 18; i++) {
                if (startI <= i) {
                    b[i] = bDec[i-startI];
                } else {
                    b[i] = "0";
                }
            }
          string memory newDec = string(b);
          return string.concat(sign, sInt, ".", newDec);
        } else {
          // It seems like if the decimals are repeating or longer than what can be stored, the array will be 19 decimals or longer?? 
          // Ex: 100 mill / 90 mill causes this. TODO investigate!
          return string.concat(sign,sInt, ".", sDec);
        }
        

    }

    function testSDtoString() public view returns(string memory) {

        //SD59x18 n = convert(100000000).div(convert(90000000));
        SD59x18 n = sd(1.0111111111111111e18);
        return SDtoString(n);
    } 


    function consoleLogSD(string memory s, SD59x18 n) public view {
        console.log(string.concat(s, " ", SDtoString(n)));
    }

}
