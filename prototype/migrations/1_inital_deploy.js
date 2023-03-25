var SST = artifacts.require("SelfSovereignToken")
var PDT = artifacts.require("PooledDebtToken")
var SSMS = artifacts.require("SelfSovereignMoneySystem")
var QLE = artifacts.require("QualifiedLegalEntites")
var DC = artifacts.require("DebtContracts")

module.exports = async function(_deployer) {
  // Use deployer to state migration tasks.
  
  // Deploy all contracts in the system
  await _deployer.deploy(SST)
  await _deployer.deploy(PDT)
  await _deployer.deploy(QLE)
  const _SST = await SST.deployed()
  await _deployer.deploy(DC, _SST.address)
  const _PDT = await PDT.deployed()
  const _QLE = await QLE.deployed()
  const _DC = await DC.deployed()
  await _deployer.deploy(SSMS, _SST.address, _PDT.address, _QLE.address, _DC.address)
  const _SSMS = await SSMS.deployed()
  await _DC.secondInit(_SSMS.address)
  // Transfer roles
  await _SST.grantMintRole(_DC.address)
  await _SST.grantMintRole(_SSMS.address)
  
  // Transfer owner from account that deployed to the SSMS smart contract
  await _SST.transferOwnership(_SSMS.address)
  await _PDT.transferOwnership(_SSMS.address)
  await _QLE.transferOwnership(_SSMS.address)
  await _DC.transferOwnership(_SSMS.address)

  await _SSMS.secondInit()
  
};
