const SelfSovereignMoneySystem = artifacts.require("SelfSovereignMoneySystem");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Utils", function (/* accounts */) {
  it("tst", async function () {
    const SSMS = await SelfSovereignMoneySystem.deployed();

    let ir = await SSMS.testSDtoString.call()
    console.log(ir)

  });

});
