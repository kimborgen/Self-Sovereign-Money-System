 This repo/folder is a prototype implementation of the companion "[draft working paper] Towards a (Self) Sovereign Money System with equivalent economic growth to Fractional Reserve Banking" paper 

 This prototype is made for the ethglobal hackathon https://ethglobal.com/events/scaling2023

 ## Rough architecture
Architecture philosophy: Optimize the system for efficiency, for example, it makes no sense to have separate smart contracts for each Debt Contract, the gas cost of this would be too large and it is much more efficient to have a single contract handle all Debt Contracts. But keep the ownership as simple and standardized as possible. For example, the SST and PDT should both be as simple ERC20 tokens as is possible, for example, to make cross-chain interoperability easier. It may be prudent to tokenize through ERC20, ERC721 or equivalent standards each step of ownership into fungible or non-fungible tokens, however for the sake of time in the hackathon, these are marked with optional and probably won't be implemented in this hackathon. 

An overview of the relevant smart contracts
- Self-Sovereign Money System (SSMS): the main smart contract and owner of all other smart contracts in the system. Creates and destroys SST, executes the process in PLC, manages QLE, and implements the functionality that buys any PDT sent to it by creating new SST. 
- Self-Sovereign Token (SST): a simple ERC20 token where the owner (SSMS) can create and destroy tokens. This token must implement cross-chain functionality so it can be used on any chain.
- Pooled Liquidity Contract (PLC): A contract that acts as a savings account, where savers can deposit SST, periodically the SSMS may create SST to fill the PLC to meet the demand for all new approved loans (preliminary Debt Contracts), all SSTs in the PLC is then converted into PDT and distributed accordingly to the savers, including the SSMS. Savers can withdraw their SST into this contract at any time until the above process starts. 
- QLE Qualified Legal Entities - A contract that manages all processes with QLEs that create DCs (out of scope for this hackathon). 
- (optional, out of scope) Real World Asset Token (RWAT): A token that represents a real world asset, may be non-fungible or fungible. To be wrapped in the DC.
- Debt Contract (DC): A contract that creates and manages debt contracts and stores/updates every related variable
- (optional) Debt Contract Token (DCT): A simple ERC-721 Non-Fungible Token to represent ownership of individual DCs, to be owned by PDC. 
- Pooled Debt Contract (PDC): A contract that pools together all DC into one contract with related functions to calculate the value, etc. 
- Pooled Debt Token (PDT): a simple ERC20 token used to represent ownership of Pooled Debt Contracts (PDC). New tokens can be created by the system (SSMS). 

## Out Of scopes
- Upgradability
- Governance/managers/real-life owners
- New standardization, example ERC20Permit (EIP-2612), make a true MVP.

## Plan
- Only QLEs can make DCs. Make a dirt simple contract that only creates DCs
- DC, including a very simplified value calculation
- PLC, activate DCs, defer PDT creation
- PDC, connect PDT
- PLC PDT creation
- Iterate on value calculation

