import { ethers } from 'hardhat'

async function main() {
  process.stdout.write('Getting accounts... ')
  const [deployer, firstMember, secondMember, thirdMember, fourthMember] =
    await ethers.getSigners()
  console.log('[DONE]')
  console.log(`Deploying with account: ${deployer.address}\n`)

  process.stdout.write('Deploying main contract... ')
  const Deal = await ethers.getContractFactory('TimeDispersions')
  const deal = await Deal.deploy()
  console.log('[DONE]')
  console.log(`Contract address: ${deal.address}\n`)

  const ethQuatityForContract = 5
  process.stdout.write(`Sending ${ethQuatityForContract} ETH to contract... `)
  await deployer.sendTransaction({
    to: deal.address,
    value: ethers.utils.parseEther(`${ethQuatityForContract}`),
  })
  console.log('[DONE]\n')

  // Register members to contract (address, percent), if percent is
  // equal to 0, the percentage will be calculated automatically based
  // on the existing ones. Percent sum must always be equal to 100.
  console.log('Registering members... ')
  const members = [
    {
      address: firstMember.address,
      percent: 10,
    },
    {
      address: secondMember.address,
      percent: 10,
    },
    {
      address: thirdMember.address,
      percent: 10,
    },
    {
      address: fourthMember.address,
      percent: 0, // Automatically set to 70
    },
  ]
  for (const member of members) {
    const { address, percent } = member
    process.stdout.write(`${address} (${percent}%)... `)
    await deal.registerMember(address, percent)
    console.log('[DONE]')
  }
  console.log()

  // Set duration of contract
  process.stdout.write('Setting duration for contract (4 months)... ')
  // await deal.setEnd(4, web3.utils.fromUtf8('month'))
  await deal.setEnd(
    4,
    '0x6d6f6e7468000000000000000000000000000000000000000000000000000000'
  )
  console.log('[DONE]\n')

  // Set time lapseds (percents, value, unit)
  //
  // First month to 10% of total of ethers
  // Second month to 10% of total of ethers
  // Third month to 10% of total of ethers
  // Fourth month to 70% of total of ethers
  process.stdout.write('Setting lapseds... ')
  await deal.setLapseds(
    [10, 10, 10, 70],
    1,
    /*web3.utils.fromUtf8('month')*/ '0x6d6f6e7468000000000000000000000000000000000000000000000000000000'
  )
  console.log('[DONE]\n')

  // Sign all members
  // After all members are signed, the contract automatically
  // executes `exec`.
  console.log('Signing members...')
  for (const member of members) {
    const { address } = member
    process.stdout.write(`${address}... `)
    await deal.sign(address)
    console.log('[DONE]')
  }
  console.log()

  console.log('Contract running!')
}

;(() => {
  try {
    main()
  } catch (exception) {
    console.log(exception)
    process.exitCode = 1
  }
})()
