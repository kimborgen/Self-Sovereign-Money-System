const DebtContracts = artifacts.require("DebtContracts");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("DebtContracts", function (accounts) {
  it("should assert true", async function () {
    await DebtContracts.deployed();
    return assert.isTrue(true);
  });

  it("should create Debt Contract", async function() {
    var dc = await DebtContracts.deployed()
    
    await dc.createDebtContract(accounts[1], 1000, 120, 100)
    await dc.createDebtContract(accounts[1], 2000, 120, 110)
    await dc.createDebtContract(accounts[1], 500, 120, 200)
    await dc.createDebtContract(accounts[1], 1000, 120, 80)
    await dc.createDebtContract(accounts[1], 1000, 120, 100)


  })

});
