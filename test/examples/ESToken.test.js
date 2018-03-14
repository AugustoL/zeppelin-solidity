import assertRevert from '../helpers/assertRevert';

var ESToken = artifacts.require('ESToken');

contract('ESToken', function (accounts) {
  let token;

  beforeEach(async function () {
    token = await ESToken.new();
    await token.mint(accounts[0], 100);
  });

  it('should return the correct totalSupply after construction', async function () {
    let totalSupply = await token.totalSupply();
    assert.equal(totalSupply, 100);
  });

  it('should return correct balances after transfer', async function () {
    await token.transfer(accounts[1], 100);
    assert.equal(await token.balanceOf(accounts[0]), 0);
    assert.equal(await token.balanceOf(accounts[1]), 100);
  });

  it('should throw an error when trying to transfer more than balance', async function () {
    await assertRevert(token.transfer(accounts[1], 101));
  });

  it('should throw an error when trying to transfer to 0x0', async function () {
    await assertRevert(token.transfer(0x0, 100));
  });
});
