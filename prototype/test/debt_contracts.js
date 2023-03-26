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

  it("should calculate specific interest rate", async function(){
    var dc = await DebtContracts.deployed()
    
    let a = await dc._calcSpecificInterestRate(BigInt(0), BigInt(0.4E18))
    let b = await dc.SDtoString(a)
    console.log(b)
  })

  it("should calcualte nextPAyment", async function() {
    var dc = await DebtContracts.deployed()
    
    let a = await dc._calculateNextPayment(BigInt(0), BigInt(2E18), BigInt(120E18), BigInt(2000E18))
    let b = await dc.SDtoString(a)
    console.log(b)
  })

  it("should create Debt Contract", async function() {
    var dc = await DebtContracts.deployed()
    
    await dc.createDebtContract(accounts[1], 100000, 120, 100)
    await dc.createDebtContract(accounts[1], 200000, 120, 40)
    await dc.createDebtContract(accounts[1], 5000000, 120, 200)
  })

  it("should be able to pay off a full loan", async function() {
    var dc = await DebtContracts.deployed()
    var sst = await SST.deployed()
    var nonce = await dc.createDebtContract.call(accounts[2], 100000, 2, 110)
    nonce = nonce.toNumber()
    await dc.createDebtContract(accounts[2], 100000, 2, 110)
    // approve that the contract can spend all the tokens it created
    await sst.increaseAllowance(dc.address, BigInt(1500000E18), {from: accounts[2]})
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
