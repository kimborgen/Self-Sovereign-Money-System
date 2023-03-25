/* global BigInt */
const DebtContracts = artifacts.require("DebtContracts");
const SST = artifacts.require("SelfSovereignToken");
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
    await dc.createDebtContract(accounts[1], 2000, 120, 40)
    await dc.createDebtContract(accounts[1], 500, 120, 200)
  })

  it("should be able to pay off a full loan", async function() {
    var dc = await DebtContracts.deployed()
    var sst = await SST.deployed()
    await sst.mint(accounts[2], BigInt(500E18)) // to pay interest
    var nonce = await dc.createDebtContract.call(accounts[2], 1000, 2, 110)
    nonce = nonce.toNumber()
    await dc.createDebtContract(accounts[2], 1000, 2, 110)
    // approve that the contract can spend all the tokens it created
    await sst.increaseAllowance(dc.address, BigInt(1500E18), {from: accounts[2]})
    var bal = await sst.balanceOf.call(accounts[2])
    console.log("Balance: ", bal.toString())
    console.log("Nonce ", nonce)
    await dc.pay(nonce, {from: accounts[2]})
    bal = await sst.balanceOf.call(accounts[2])
    console.log("Balance: ", bal.toString())
    await dc.pay(nonce, {from: accounts[2]})
    await dc.pay(nonce, {from: accounts[2]})
    

  })

});
