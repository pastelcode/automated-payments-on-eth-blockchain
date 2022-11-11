import { ethers } from 'hardhat'

async function main() {
  const [deployer, firstMember, secondMember, thirdMember, fourthMember] =
    await ethers.getSigners()
  console.log(`Deploying with account: ${deployer.address}`)

  const Deal = await ethers.getContractFactory('TimeDispersions')
  const deal = await Deal.deploy()

  await deployer.sendTransaction({
    to: deal.address,
    value: ethers.utils.parseEther('5'),
  })

  // Register members to contract (address, percent), if percent is
  // equal to 0, the percentage will be calculated automatically based
  // on the existing ones. Percent sum must always be equal to 100.
  await deal.registerMember('0x70997970C51812dc3A010C7d01b50e0d17dc79C8', 10)
  await deal.registerMember('0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC', 10)
  await deal.registerMember('0x90F79bf6EB2c4f870365E785982E1f101E93b906', 10)
  await deal.registerMember('0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65', 0) // Automatically set to 70

  // Set duration of contract
  // await deal.setEnd(4, web3.utils.fromUtf8('month'))
  await deal.setEnd(
    4,
    '0x6d6f6e7468000000000000000000000000000000000000000000000000000000'
  )

  // Set time lapseds (percents, value, unit)
  //
  // First month to 10% of total of ethers
  // Second month to 10% of total of ethers
  // Third month to 10% of total of ethers
  // Fourth month to 70% of total of ethers
  await deal.setLapseds(
    [10, 10, 10, 70],
    1,
    /*web3.utils.fromUtf8('month')*/ '0x6d6f6e7468000000000000000000000000000000000000000000000000000000'
  )

  // Sign all members
  // After all members are signed, the contract automatically
  // executes `exec`.
  await deal.sign(firstMember.address)
  await deal.sign(secondMember.address)
  await deal.sign(thirdMember.address)
  await deal.sign(fourthMember.address)
}

;(() => {
  try {
    main()
  } catch (exception) {
    console.log(exception)
    process.exitCode = 1
  }
})()
