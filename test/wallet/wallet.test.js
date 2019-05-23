const { BN, shouldFail } = require('openzeppelin-test-helpers');

const { buildCreate2Address } = require('../helpers/create2');

const Create2 = artifacts.require('Create2');
const WalletFactory = artifacts.require('WalletFactory');
const Wallet = artifacts.require('Wallet');

contract('WalletFactory', function ([_, creator]) {
  const salt = 'salt message';
  const saltHex = web3.utils.soliditySha3(salt);
  const constructorByteCode = Wallet.bytecode;

  beforeEach(async function () {
    const create2Lib = await Create2.new();
    await WalletFactory.link("Create2", create2Lib.address);
    this.factory = await WalletFactory.new(constructorByteCode);
  });

  it.only('should deploy a Wallet contract with correct owner and pay fee', async function () {

  });
});
