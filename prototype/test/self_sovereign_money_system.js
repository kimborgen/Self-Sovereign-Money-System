const SelfSovereignMoneySystem = artifacts.require("SelfSovereignMoneySystem");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("SelfSovereignMoneySystem", function (/* accounts */) {
  it("should assert true", async function () {
    await SelfSovereignMoneySystem.deployed();
    return assert.isTrue(true);
  });
  const sleep = ms => new Promise(r => setTimeout(r, ms));

  it("should calculateNewSystemInterest", async function() {
    var ssms = await SelfSovereignMoneySystem.deployed();
    await sleep(1000);
    await ssms.updateSystemInterestRate()
  })
});
