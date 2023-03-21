 This repo/folder is a prototype implementation of the companion "Towards equivalent economic growth in a (Self) Sovereign Money System with Collateralized Asset Tokens (CAT) compared to our current Fractional Reserve Banking system [Working Paper]" paper 

 This prototype is made for the ethglobal hackathon https://ethglobal.com/events/scaling2023

 ## Rough architecture
An overview of the relevant smart contracts
- SST Self Sovereign Token, a simple ERC20 token where the owner/manager (the system smart contract) can create and destroy tokens. This token must implement cross-chain functionality so it can be used on any chain. 
- CAT Collaterlized Asset Token, an ERC20 token used to represent ownership of Pooled Debt Contracts (PDC). New tokens can be created by the owner/manager (the system contract). Can potentially calculate its own value in SST. This token must implement cross-chain functionality so it can be used on any chain. 
- S System - The brains
- DC Debt Contract - A contract that creates and manages a debt contract and every related attribute.
- PDC Pooled Debt Contracts - MAYBE, a contract that owns all activated DCs.Can calculate its own value in SST. DC and PDC may be combined...
- QLE Qualified Legal Entities - A contract that manages all processes with QLEs that create DCs (out of scope for this hackathon).
