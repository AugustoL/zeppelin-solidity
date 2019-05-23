pragma solidity ^0.5.0;

import "../utils/Create2.sol";
import "../ownership/Ownable.sol";

contract Create2OwnableFactory {
  function deploy(bytes32 salt, bytes memory code) public {
      address deployedContract = Create2.computeAddress(salt, code);
      Create2.deploy(salt, code);
      Ownable(deployedContract).transferOwnership(msg.sender);
  }
  function computeAddress(
      bytes32 salt, bytes memory code
  ) public view returns (address) {
      return Create2.computeAddress(salt, code);
  }
}
