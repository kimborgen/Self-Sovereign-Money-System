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

        SD59x18 intValue = tmp.floor();
        SD59x18 decValue = tmp.sub(intValue);
        string memory sInt = Strings.toString(uint(convert(intValue)));
        string memory sDec = Strings.toString(decValue.intoUint256());
        bytes memory bDec = bytes(sDec);
        bytes memory b = new bytes(18);
        if (bDec.length < 18) {
            uint startI = 18 - bDec.length;
            for (uint i = 0; i < 18; i++) {
                if (startI <= i) {
                    b[i] = bDec[i-startI];
                } else {
                    b[i] = "0";
                }
            }
        }
        
        string memory newDec = string(b);
        return string.concat(sign, sInt, ".", newDec);
    }

    function testSDtoString() public view returns(string memory) {
        SD59x18 n = sd(10.01e18);
        return SDtoString(n);
    } 


    function consoleLogSD(string memory s, SD59x18 n) public view {
        SD59x18 tmp;
        string memory sign = "";
        if (n.lt(sd(0))) {
          tmp = n.abs();
          sign = "-";
        } else {
          tmp = n;
        }

        string memory converted = string.concat("Original: ", sign, Strings.toString(uint256(convert(tmp))));
        string memory original = string.concat("Converted: ", sign, Strings.toString(tmp.intoUint256()));

        console.log(string.concat(s, converted, original));
    }

}
