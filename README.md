# Automated payments on ETH Blockchain

This project is a recreation of https://medium.com/@mundorap2010/solidity-in-automated-payments-on-eth-blockchain-55d893e5dd1d

The application deals with the following: A dapp that allows to distribute payments by percentages according to certain rules previously established through a period of time, that is, to be able to pay an number of people n amount each month / day or week the amount of ETH established in the contract.

## Try it out!

1. `yarn` (to install all dependencies)
2. Open a new terminal window/tab
3. `npx hardhat node` to start a HTTP and WebSocket JSON-RPC server
4. Go back to the first terminal
5. `npx hardhat run --network localhost scripts/deploy.ts`
