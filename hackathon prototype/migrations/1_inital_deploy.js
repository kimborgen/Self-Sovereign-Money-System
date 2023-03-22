var SST = artifacts.require("SelfSovereignToken")
var PDT = artifacts.require("PooledDebtToken")
var SSMS = artifacts.require("SelfSovereignMoneySystem")

module.exports = async function(_deployer) {
  // Use deployer to state migration tasks.
  
  // Deploy all contracts in the system
  await _deployer.deploy(SST)
  await _deployer.deploy(PDT)
  const _SST = await SST.deployed()
  const _PDT = await PDT.deployed()
  await _deployer.deploy(SSMS, _SST.address, _PDT.address)
  const _SSMS = await SSMS.deployed()
  
  // Transfer owner from account that deployed to the SSMS smart contract
  await _SST.transferOwnership(_SSMS.address)
  await _PDT.transferOwnership(_SSMS.address)
};
