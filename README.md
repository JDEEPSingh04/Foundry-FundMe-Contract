This is a smart contract written in foundry which allows users users to fund to the contract owner given that they are funding more than the minimum value set by the owner. Further the owner can withdraw all the funds all transfer them to his/her account.
I have used the interface AggregatorV3Interface.sol to get the priceFeeds of the different currencies to convert them to the equivalent value in USD.
Further I have used DevOpsTools library to get the latest deployed contract address.

The scripts and tests for interacting and deploying the contracts and for testing the contracts are also present in the Script and Test folder.

Refer to Makefile for further assistance.
