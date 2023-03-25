// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "truffle/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import { SD59x18, sd, convert } from "@prb/math/src/SD59x18.sol";

abstract contract Utils {
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
