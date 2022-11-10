import { ethers } from 'hardhat'

async function main() {
  const Stages = await ethers.getContractFactory('Stage')
  const stages = await Stages.deploy()

  await stages.deployed()
}

;(() => {
  try {
    main()
  } catch (exception) {
    console.log(exception)
    process.exitCode = 1
  }
})()
