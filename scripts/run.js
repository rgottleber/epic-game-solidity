
const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
  const gameContract = await gameContractFactory.deploy(
  ['Acid Burn', 'Zero Cool', 'Crash Override'],
  ['https://www.daopunks.io/static/media/1.12a20d45.jpg', 'https://www.daopunks.io/static/media/2.3f403f82.jpg', 'https://www.daopunks.io/static/media/3.ced9f136.jpg'],
  [100, 200, 300],
  [100, 50, 25]
  );
  await gameContract.deployed();
  console.log("Contract deployed to: ", gameContract.address);
  let txn;
  txn = await gameContract.mintCharacterNFT(2);
  await txn.wait();
  let returnedTokenUri = await gameContract.tokenURI(1);
  console.log("Token URI: ", returnedTokenUri);
}

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};

runMain();