const hre = require("hardhat");

async function main() {
  const RFPSimpleStrategy = await hre.ethers.getContractFactory(
    "RFPSimpleStrategy"
  );
  const rfpSimpleStrategy = await RFPSimpleStrategy.deploy();
  await rfpSimpleStrategy.deployed();

  console.log("RFPSimpleStrategy deployed to:", rfpSimpleStrategy.address);

  const Allo = await hre.ethers.getContractFactory("Allo");
  const allo = await Allo.deploy();
  await allo.deployed();
  console.log("Allo deployed to:", allo.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
