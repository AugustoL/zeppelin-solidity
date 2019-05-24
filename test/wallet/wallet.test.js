const { BN, shouldFail, time } = require('openzeppelin-test-helpers');

const { buildCreate2Address } = require('../helpers/create2');
const { toEthSignedMessageHash, signMessage } = require('../helpers/sign');

const Create2 = artifacts.require('Create2');
const WalletFactory = artifacts.require('WalletFactory');
const Wallet = artifacts.require('Wallet');
const ERC20Mock = artifacts.require('ERC20Mock');

contract('WalletFactory', function ([_, tokenOwner, walletOwner, deployer, otherAccount]) {
  const salt = 'salt message';
  const saltHex = web3.utils.soliditySha3(salt);
  const walletBytecode = Wallet.bytecode;

  beforeEach(async function () {
    const create2Lib = await Create2.new();
    await WalletFactory.link("Create2", create2Lib.address);
    this.factory = await WalletFactory.new(walletBytecode);
    this.token = await ERC20Mock.new(tokenOwner, 100);
  });

  it.only('should deploy a Wallet contract with correct owner and pay fee in tokens', async function () {
    const constructorData = web3.eth.abi.encodeParameters(['address'], [walletOwner]);
    const feePaymentData = web3.eth.abi.encodeFunctionCall({
      name: 'transfer',
      type: 'frunction',
      inputs: [{ type: 'address', name: 'to' },{ type: 'uint256', name: 'value' }]
    }, [deployer, 30]);
    const beforeTime = (await time.latest()) + 60;
    const walletAddress =
      buildCreate2Address(this.factory.address, saltHex, walletBytecode+constructorData.substring(2));
    const feePaymentDataSigned = await signMessage(walletOwner,
      web3.utils.soliditySha3(this.token.address, feePaymentData, beforeTime)
    );
    // Send Tokens to wallet by knowing the address before being created
    await this.token.transfer(walletAddress, 50, {from: tokenOwner});
    const tx = await this.factory.deploy(saltHex, this.token.address, 30, beforeTime, constructorData, feePaymentDataSigned, {from: deployer})
    const wallet = await Wallet.at(walletAddress);

    (await this.token.balanceOf(tokenOwner)).should.be.bignumber.equal(new BN(50));
    (await this.token.balanceOf(deployer)).should.be.bignumber.equal(new BN(30));
    (await this.token.balanceOf(walletOwner)).should.be.bignumber.equal(new BN(0));
    (await this.token.balanceOf(wallet.address)).should.be.bignumber.equal(new BN(20));
    (await wallet.owner()).should.be.equal(walletOwner);

  });

  it.only('should deploy a Wallet contract with correct owner and pay fee in eth', async function () {
    const constructorData = web3.eth.abi.encodeParameters(['address'], [walletOwner]);
    const feePaymentData = web3.eth.abi.encodeFunctionCall({
      name: 'transfer',
      type: 'frunction',
      inputs: [{ type: 'address', name: 'to' },{ type: 'uint256', name: 'value' }]
    }, [deployer, 80]);
    const beforeTime = (await time.latest()) + 60;
    const walletAddress =
      buildCreate2Address(this.factory.address, saltHex, walletBytecode+constructorData.substring(2));
    const feePaymentDataSig = await signMessage(walletOwner,
      web3.utils.soliditySha3(walletAddress, feePaymentData, beforeTime)
    );

    // Send ETH to wallet by knowing the address before being created
    await web3.eth.sendTransaction({from: tokenOwner, to : walletAddress, value: 100});
    const tx = await this.factory.deploy(saltHex, walletAddress, 80, beforeTime, constructorData, feePaymentDataSig, {from: deployer})
    const wallet = await Wallet.at(walletAddress);

    (await web3.eth.getBalance(wallet.address)).should.be.equal('20');
    (await wallet.owner()).should.be.equal(walletOwner);

  });

  it.only('should deploy a Wallet contract paying with tokens and then pay for another wallet tx', async function () {
    const constructorData = web3.eth.abi.encodeParameters(['address'], [walletOwner]);
    let feePaymentData = web3.eth.abi.encodeFunctionCall({
      name: 'transfer',
      type: 'frunction',
      inputs: [{ type: 'address', name: 'to' },{ type: 'uint256', name: 'value' }]
    }, [deployer, 30]);
    let beforeTime = (await time.latest()) + 60;
    const walletAddress =
      buildCreate2Address(this.factory.address, saltHex, walletBytecode+constructorData.substring(2));
    let feePaymentDataSig = await signMessage(walletOwner,
      web3.utils.soliditySha3(this.token.address, feePaymentData, beforeTime)
    );
    // Send Tokens to wallet by knowing the address before being created
    await this.token.transfer(walletAddress, 50, {from: tokenOwner});
    await this.factory.deploy(saltHex, this.token.address, 30, beforeTime, constructorData, feePaymentDataSig, {from: deployer})
    const wallet = await Wallet.at(walletAddress);

    let sendTokensData = web3.eth.abi.encodeFunctionCall({
      name: 'transfer',
      type: 'frunction',
      inputs: [{ type: 'address', name: 'to' },{ type: 'uint256', name: 'value' }]
    }, [otherAccount, 19]);
    beforeTime = (await time.latest()) + 60;
    const sendTokensDataSig = await signMessage(walletOwner,
      web3.utils.soliditySha3(this.token.address, sendTokensData, this.token.address, 1, beforeTime)
    );
    await wallet.call(this.token.address, sendTokensData, this.token.address, 1, beforeTime, sendTokensDataSig, {from: deployer});

    (await this.token.balanceOf(tokenOwner)).should.be.bignumber.equal(new BN(50));
    (await this.token.balanceOf(deployer)).should.be.bignumber.equal(new BN(31));
    (await this.token.balanceOf(walletOwner)).should.be.bignumber.equal(new BN(0));
    (await this.token.balanceOf(otherAccount)).should.be.bignumber.equal(new BN(19));
    (await this.token.balanceOf(wallet.address)).should.be.bignumber.equal(new BN(0));
    (await wallet.owner()).should.be.equal(walletOwner);

  });
});
