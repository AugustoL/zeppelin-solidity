const { BN, shouldFail } = require('openzeppelin-test-helpers');

const { buildCreate2Address } = require('../helpers/create2');

const CREATE2Factory = artifacts.require('CREATE2Factory');
const ERC20Mock = artifacts.require('ERC20Mock');

contract('CREATE2Factory', function ([_, creator, notCreator]) {
  const salt = 'salt message';
  const saltHex = web3.utils.soliditySha3(salt);
  const constructorByteCode = `${ERC20Mock.bytecode}${web3.eth.abi
    .encodeParameters(['address', 'uint256'], [creator, 100]).slice(2)
  }`;

  beforeEach(async function () {
    this.factory = await CREATE2Factory.new();
  });

  it('should compute the correct contract address', async function () {
    const onChainComputed = await this.factory
      .computeAddress(creator, saltHex, constructorByteCode);
    const offChainComputed =
      buildCreate2Address(creator, saltHex, constructorByteCode);
    onChainComputed.should.equal(offChainComputed);
  });

  it('should deploy a ERC20Mock with correct balances', async function () {
    const offChainComputed =
      buildCreate2Address(this.factory.address, saltHex, constructorByteCode);
    const deployTx = await this.factory
      .deploy(saltHex, constructorByteCode, { from: creator });
    deployTx.logs[0].args.addr.should.equal(offChainComputed);
    const erc20 = await ERC20Mock.at(offChainComputed);
    (await erc20.balanceOf(creator)).should.be.bignumber.equal(new BN(100));
  });

  it('should failed deploying a contract in an existent address', async function () {
    await this.factory.deploy(saltHex, constructorByteCode, { from: creator });
    await shouldFail.reverting(
      this.factory.deploy(saltHex, constructorByteCode, { from: creator })
    );
  });
});
