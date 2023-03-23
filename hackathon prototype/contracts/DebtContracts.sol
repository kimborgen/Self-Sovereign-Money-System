// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import { SD59x18, sd } from "@prb/math/src/SD59x18.sol";
import { UD60x18, ud } from "@prb/math/src/UD60x18.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

// This contract is an MVP, a proper contract would be way more complex
contract DebtContracts is AccessControl, Ownable, Pausable {
    using SafeMath for uint256;
    /*
        Encapsulate all personal variables, such as credit history, income, employement, savings, debt-to-income ratio, personal liquid assets, personal illiquid assets, etc.. into a single metric (1) for simplicity and MVPiniess, (2) for privacy. Can these variables be zkified? This variable can be called creditwhortiness. Increase the decentralization of these variables, so that they cannot be manipulated, ex: get employement from employer, degree from university, value of liquid assets from wallet, etc etc.

        Assume montly payments happens exactly when they should, no early payback, exact repayments, etc
    */
    bytes32 public constant QLE_ROLE = keccak256("QLE_ROLE");

    // MVP: 256 variables because I like to pay for gas
    struct DebtContract {
        bool activated;
        address borrower; // const
        address qualifiedLegalEntity; // const
        uint256 creditworthiness;
        uint256 loanCategory;
        uint256 collateralCategory; 
        uint256 collateralValue;
        // address collateral;
        uint256 principalTotal; // The principal at the start of the loan, how much money was borrowed?
        uint256 remainingDebt; // the remaining debt
        uint256 durationLength; // in tau
        uint256 startTau; 
        uint256 paymentPeriodicity; // in tau
        SD59x18 interestRateMultiplier;
    }

    uint256 private nonce;
    mapping(uint256 => DebtContract) debtContracts;
    uint[] public preliminaryDebtContracts;
    SD59x18 public systemInterestRate;
    
    constructor() {
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
    * @dev Creates a new debt contract and stores it in the `debtContracts` mapping
    * @param borrower The address of the borrower
    * @param qualifiedLegalEntity The address of the qualified legal entity
    * @param creditworthiness The creditworthiness of the borrower
    * @param loanCategory The category of the loan
    * @param collateralCategory The category of the collateral
    * @param collateralValue The value of the collateral
    * @param principalTotal The total principal of the loan
    * @param durationLength The length of the loan in tau
    * @param paymentPeriodicity The payment periodicity of the loan in tau
    * @param interestRateMultiplier The interest rate multiplier for the loan
    * @return ID nonce of the new debt contract
    */
    function createDebtContract(
        address borrower,
        address qualifiedLegalEntity,
        uint256 creditworthiness,
        uint256 loanCategory,
        uint256 collateralCategory,
        uint256 collateralValue,
        uint256 principalTotal,
        uint256 durationLength,
        uint256 paymentPeriodicity,
        SD59x18 interestRateMultiplier
    ) external onlyRole(QLE_ROLE) whenNotPaused  returns (uint256) {
        nonce++;
        DebtContract memory newDebtContract = DebtContract({
            activated: true,
            borrower: borrower,
            qualifiedLegalEntity: qualifiedLegalEntity,
            creditworthiness: creditworthiness,
            loanCategory: loanCategory,
            collateralCategory: collateralCategory,
            collateralValue: collateralValue,
            principalTotal: principalTotal,
            remainingDebt: principalTotal,
            durationLength: durationLength,
            startTau: 0,
            paymentPeriodicity: paymentPeriodicity,
            interestRateMultiplier: interestRateMultiplier
        });
        debtContracts[nonce] = newDebtContract;
        preliminaryDebtContracts.push(nonce);
        return nonce;
    }

    /**
    * @dev Processes a specified number of preliminary debt contracts and deletes them from the array
    * @param numContracts The number of contracts to process
    * @param startTau The starting tau to set for the activated contracts
    * @return The remaining length of the preliminaryDebtContracts array. 
    */
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

    // calculate value

    // calculate how much that needs to be paid

    // process a payment from borrower

}