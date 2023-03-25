// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import { SD59x18, sd, convert } from "@prb/math/src/SD59x18.sol";
// import { UD60x18, ud } from "@prb/math/src/UD60x18.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "truffle/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./SelfSovereignToken.sol";
import "./SelfSovereignMoneySystem.sol";
import "./Utils.sol";

// This contract is an MVP, a proper contract would be way more complex
contract DebtContracts is AccessControl, Ownable, Pausable, Utils {
    //using UD60x18 for uint256;
    //using SD59x18 for int256;
    /*
        Encapsulate all personal variables, such as credit history, income, employement, savings, debt-to-income ratio, personal liquid assets, personal illiquid assets, etc.. into a single metric (1) for simplicity and MVPiniess, (2) for privacy. Can these variables be zkified? This variable can be called creditwhortiness. Increase the decentralization of these variables, so that they cannot be manipulated, ex: get employement from employer, degree from university, value of liquid assets from wallet, etc etc.

        Assume montly payments happens exactly when they should, no early payback, exact repayments, etc
    */
    bytes32 public constant QLE_ROLE = keccak256("QLE_ROLE");

    // MVP: 256 variables because I like to pay for gas
    // Use SD59x18 for now for everything to make it simple
    struct DebtContract {
        bool activated;
        address borrower; // const
        // address qualifiedLegalEntity; // const
        //SD59x18 creditworthiness;
        //SD59x18 loanCategory;
        //SD59x18 collateralCategory; 
        //SD59x18 collateralValue;
        // address collateral;
        SD59x18 principalOriginal;
        SD59x18 principalTotal; // The principal at the start of the loan, how much money was borrowed?
        SD59x18 remainingDebt; // the remaining debt
        SD59x18 totalPaymentPeriods; // how many months
        SD59x18 remainingPaymentPeriods;
        SD59x18 lastMonthlyPaymentAmount;
        SD59x18 lastPresentValue;
        SD59x18 interestRateMultiplier;
    }

    uint256 private nonce;
    mapping(uint256 => DebtContract) debtContracts;
    uint[] public preliminaryDebtContracts;
    SD59x18 public systemInterestRate;
    SD59x18 public pooledDebtContractValue;

    SelfSovereignToken SST;
    SelfSovereignMoneySystem SSMS;
    
    bool secondInitRan;
    constructor(address _addrSST) {
        pooledDebtContractValue = sd(0);
        SST = SelfSovereignToken(_addrSST);
        console.log("Testing console.log");
        systemInterestRate = sd(0.0024662697723e18);
        secondInitRan = false;
    }

    function secondInit(address _addrSMSS) external onlyOwner {
        require(secondInitRan == false);
        SSMS = SelfSovereignMoneySystem(_addrSMSS);
        secondInitRan = true;
    }

    /**
    * @dev Pauses the creation of new debt contracts during a tau cycle to process new debt applications
    */
    function pauseSystem() external onlyOwner {
        _pause();
    }

    /**
    * @dev Unpauses the system after the tau cycles finnishes
    */
    function unpauseSystem() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Sets the system interest rate
     * @param _systemInterestRate The new system interest rate, in basis points
     */
    function setSystemInterestRate(SD59x18 _systemInterestRate) external onlyOwner {
        systemInterestRate = _systemInterestRate;
    }

    /**
    * @dev Grants the QLE role to the specified address.
    * @param _qle The address to grant the QLE role to.
    */
    function grantQLERole(address _qle) external onlyOwner {
        _grantRole(QLE_ROLE, _qle);
    }

    /**
    * @dev Creates a new debt contract and stores it in the `debtContracts` mapping.
    * @param borrower The address of the borrower.
    * @param principalTotal The total principal of the loan, as a SD59x18 number.
    * @param totalPaymentPeriods The total number of payment periods for the loan, as a SD59x18 number.
    * @param interestRateMultiplier The interest rate multiplier for the loan. Will be multiplied with 0.01. So 100% -> 100 (equal to systemInterestRate)
    * @return ID nonce of the new debt contract.
    */
    function createDebtContract(
        address borrower,
        int256 principalTotal,
        int256 totalPaymentPeriods,
        int256 interestRateMultiplier
    ) public returns (uint256) {
        // temp anyone can call it, but only QLEs should be able to call it
        nonce++;
        DebtContract storage newDebtContract = debtContracts[nonce];
        newDebtContract.activated = true;
        newDebtContract.borrower = borrower;
        newDebtContract.principalTotal = convert(principalTotal);
        newDebtContract.remainingDebt = convert(principalTotal);
        newDebtContract.totalPaymentPeriods = convert(totalPaymentPeriods);
        newDebtContract.remainingPaymentPeriods = convert(totalPaymentPeriods);
        newDebtContract.interestRateMultiplier = sd(interestRateMultiplier * 0.01e18);
        
        //consoleLogSD("irm", newDebtContract.interestRateMultiplier);
        //consoleLogSD("aaa", sd(1e18));
    
        // create SST token and transfer to borrower
        uint256 amountToMint = newDebtContract.principalTotal.intoUint256();

        //console.log("Amount to mint %d", amountToMint);
        SST.mint(borrower, amountToMint);

        // calculate and add the value to the PDC
        SD59x18 presentValue = calculateDebtContractValue(nonce);
        //consoleLogSD(presentValue);
        newDebtContract.lastPresentValue = presentValue;

        pooledDebtContractValue = pooledDebtContractValue.add(presentValue);
        consoleLogSD("PDCV", pooledDebtContractValue);

        // update system interest rate
        SSMS.updateSystemInterestRate();

        return nonce;
    }

    /**
    * @dev Processes a specified number of preliminary debt contracts and deletes them from the array
    * @param numContracts The number of contracts to process
    * @param startTau The starting tau to set for the activated contracts
    * @return The remaining length of the preliminaryDebtContracts array. 
    */
    /*
    function processPreliminaryDebtContracts(uint256 numContracts, uint256 startTau) external onlyOwner whenPaused returns (uint256) {
        require(preliminaryDebtContracts.length > 0, "there are no preliminary debt contracts to process");
        uint256 lastIndex = preliminaryDebtContracts.length - 1;
        (bool overflow, uint256 iterationStop) = lastIndex.trySub(numContracts);
        if (overflow) {
            iterationStop = 0;
        }
        for (uint256 i = lastIndex; i >= iterationStop; i--) {
            debtContracts[preliminaryDebtContracts[i]].activated = true;
            debtContracts[preliminaryDebtContracts[i]].startTau = startTau;
            preliminaryDebtContracts.pop();
        }
        return preliminaryDebtContracts.length;
    }
    */

    /**
     * @dev Calculates the next payment for a given debt contract, based on the current state and the interest rate
     * @param id The id of the debt contract to calculate the next payment for
     * @return (isLast, nextPaymentAmount) 
     */
    function calculateNextPayment(uint256 id) public view returns (SD59x18) {
        DebtContract storage dc = debtContracts[id];

        // according to the simplified formula in the paper
        //consoleLogSD("ssr", systemInterestRate);
        SD59x18 specificInterestRate = systemInterestRate.mul(dc.interestRateMultiplier).add(convert(1));
        //consoleLogSD("sir", specificInterestRate);
        //consoleLogSD("111", convert(1));
        //consoleLogSD("rpp", dc.remainingPaymentPeriods);
        //return (false, convert(1));
        // TODO ADD 1 in formula
        SD59x18 tmp = specificInterestRate.pow(dc.remainingPaymentPeriods.add(convert(1)));
        //consoleLogSD("tmp", tmp);
        SD59x18 nextPayment = dc.remainingDebt.mul(tmp).div(dc.remainingPaymentPeriods.add(convert(1)));
        //consoleLogSD("np", nextPayment);

        return nextPayment;
    }

    /**
    * @dev Calculates the current value of a debt contract
    * @param id The ID of the debt contract to calculate the value of
    * @return The current value of the debt contract
    */
    function calculateDebtContractValue(uint256 id) public view returns (SD59x18) {
        SD59x18 currentMonthlyPayment = calculateNextPayment(id);
        DebtContract storage dc = debtContracts[id];

        // if this is the last payment the value is the next payment
        //console.log("isLast", isLast);
        //consoleLogSD("cmp", currentMonthlyPayment);
        if (dc.remainingPaymentPeriods.lte(sd(0))) {
            return currentMonthlyPayment;
        }


        SD59x18 specificInterestRate = systemInterestRate.mul(dc.interestRateMultiplier).add(convert(1));

        SD59x18 presentValue = sd(0);
        for (uint i = 0; i < uint(convert(dc.remainingPaymentPeriods)); i++) {
            SD59x18 discountFactor = specificInterestRate.powu(i);
            //consoleLogSD("df", discountFactor);
            presentValue = presentValue.add(sd(1e18).div(discountFactor));
            //consoleLogSD("ipv", presentValue);
        }
        presentValue = presentValue.mul(currentMonthlyPayment);
        //consoleLogSD("pv", presentValue);
        
        return presentValue;
    }

    // MISSING: Include time. 
    /**
    * @dev Processes a payment for the specified debt contract and sets the present value of the PDC. 
    * @param id The ID of the debt contract to process the payment for.
    */
    function pay(uint256 id) public {
        DebtContract storage dc = debtContracts[id];
        
        // you dont actually need to supply an amount, because the next payment will be calculated for you
        
        SD59x18 nextPayment = calculateNextPayment(id);

        // add interest rate to remainingDebt
        SD59x18 specificInterestRate = systemInterestRate.mul(dc.interestRateMultiplier).add(convert(1));
        //consoleLogSD("sir", specificInterestRate);
        dc.remainingDebt = dc.remainingDebt.mul(specificInterestRate);

        //consoleLogSD("nextPayment: ", nextPayment);
        if (dc.remainingPaymentPeriods.lte(sd(0))) {
            require(nextPayment.eq(dc.remainingDebt), "catastrophic failure 1");
            //consoleLogSD("remaining Payment Periods", dc.remainingPaymentPeriods);
        }

        // decrease principal
        dc.remainingDebt = dc.remainingDebt.sub(nextPayment);
        //consoleLogSD("remaining Principal", dc.remainingDebt);

        // calculate interest on the remaining principal.

        // calculate present value
        SD59x18 pv = calculateDebtContractValue(id);
        //consoleLogSD("dcv", pv);

        // update PDC value
        pooledDebtContractValue = pooledDebtContractValue.add(pv).sub(dc.lastPresentValue);
        //consoleLogSD("new PDCV", pooledDebtContractValue);

        // set old 
        dc.lastPresentValue = pv;
        dc.lastMonthlyPaymentAmount = nextPayment;

        // decrease remaining duration
        if (dc.remainingPaymentPeriods.lte(sd(0))) {
            require(dc.remainingDebt.eq(sd(0)), "cf 5");
            require(dc.remainingPaymentPeriods.eq(sd(0)), "cf 6");
            require(pv.eq(sd(0)), "cf 7");
            dc.activated = false;
            //console.log("Last payment hurray!");
        } else {
            dc.remainingPaymentPeriods = dc.remainingPaymentPeriods.sub(convert(1));
        }

        //consoleLogSD("remaining payment periods", dc.remainingPaymentPeriods);
    
        //console.log("Burning this", nextPayment.intoUint256());
        // For now, instead of sending SST to PDT, just burn it. 
        SST.burnFrom(msg.sender, nextPayment.intoUint256());
        //console.log("Total supply", SST.totalSupply());
        //console.log("Balance", SST.balanceOf(msg.sender));

        // update system interest rate
        SSMS.updateSystemInterestRate();
    }

}