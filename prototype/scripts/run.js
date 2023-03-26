/* global BigInt */
var _SST = artifacts.require("SelfSovereignToken")
var _PDT = artifacts.require("PooledDebtToken")
var _SSMS = artifacts.require("SelfSovereignMoneySystem")
var _QLE = artifacts.require("QualifiedLegalEntites")
var _DC = artifacts.require("DebtContracts")



module.exports = async function() {
    const sleep = ms => new Promise(r => setTimeout(r, ms));

    var accounts;
    // in web front-end, use an onload listener and similar to this manual flow ... 
    await web3.eth.getAccounts(function(err,res) { accounts = res; });

    console.log(accounts)

    const SST = await _SST.deployed()
    const PDT = await _PDT.deployed()
    const QLE = await _QLE.deployed()
    const DC = await _DC.deployed()
    const SSMS = await _SSMS.deployed()

    let bal0 = await SST.balanceOf.call(accounts[0])
    let bal1 = await SST.balanceOf.call(accounts[1])

    await SST.increaseAllowance(DC.address, BigInt(10000000E18), {from: accounts[0]})


    console.log(bal0.toString(), bal1.toString())
    try {
        
        // get system interest rate
        stat = await SSMS.getStatus.call()
        console.log("1", stat)

        let newAmount = 250000
        let periods = 120
        let irm = 110
        let nonce = await DC.createDebtContract.call(accounts[0], newAmount, periods, irm)
        nonce = nonce.toNumber()
        console.log(nonce);
        await DC.createDebtContract(accounts[0], newAmount, periods, irm)
        console.log("after cdc")
        await SST.increaseAllowance(DC.address, BigInt(250000E18), {from: accounts[0]})

        stat = await SSMS.getStatus.call()
        console.log("2", stat)

        // check how much to pay

        let toPay = await DC.calculateNextPayment(nonce);
        let toPayStr = await DC.SDtoString(toPay)
        console.log("To pay", toPayStr)

        await DC.pay(nonce)

        stat = await SSMS.getStatus.call()
        console.log("3", stat)

           
    } catch (err) {
        console.log("Aaaaa")
        console.log(err)
    }

}
