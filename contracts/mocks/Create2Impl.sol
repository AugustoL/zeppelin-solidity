pragma solidity ^0.5.0;

import "../utils/Create2.sol";

contract Create2Impl {
  function deploy(bytes32 salt, bytes memory code) public {
      Create2.deploy(salt, code);
  }
  function computeAddress(
      bytes32 salt, bytes memory code
  ) public view returns (address) {
      return Create2.computeAddress(salt, code);
  }
  function computeAddress(
      address deployer, bytes32 salt, bytes memory code
  ) public view returns (address) {
      return Create2.computeAddress(deployer, salt, code);
  }
}
