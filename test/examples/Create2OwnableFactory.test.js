const { BN, shouldFail } = require('openzeppelin-test-helpers');

const { buildCreate2Address } = require('../helpers/create2');

const Create2 = artifacts.require('Create2');
const Create2OwnableFactory = artifacts.require('Create2OwnableFactory');
const Ownable = artifacts.require('OwnableMock');

contract('Create2OwnableFactory', function ([_, creator]) {
  const salt = 'salt message';
  const saltHex = web3.utils.soliditySha3(salt);
  const constructorByteCode = Ownable.bytecode;

  beforeEach(async function () {
    const create2Lib = await Create2.new();
    await Create2OwnableFactory.link("Create2", create2Lib.address);
    this.factory = await Create2OwnableFactory.new();
  });

  it('should deploy a Ownable with correct owner', async function () {
    const offChainComputed =
      buildCreate2Address(this.factory.address, saltHex, constructorByteCode);
    const deployTx = await this.factory
      .deploy(saltHex, constructorByteCode, { from: creator });
    const newOwnable = await Ownable.at(offChainComputed);
    (await newOwnable.owner()).should.be.equal(creator);
  });
});
