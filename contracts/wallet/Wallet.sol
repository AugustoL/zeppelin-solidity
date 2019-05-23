pragma solidity ^0.5.0;

import "../cryptography/ECDSA.sol";
import "../ownership/Ownable.sol";

contract Wallet is Ownable {

  using ECDSA for bytes32;

  /**
   * @dev Call a external contract
   * @param to The address of the contract to call
   * @param data ABI-encoded contract call to call `_to` address.
   * @param sig The hash of the data signed by the wallet owner
   */
  function call(address to, bytes memory data, bytes memory sig) public payable {
    bytes32 dataHash = keccak256(data);
    require(owner() == address(dataHash.recover(sig)), "Signer is not wallet owner");
    _call(to, data);
  }

  /**
   * @dev Transfer eth
   * @param _to The address to transfer the eth
   * @param _amount The amount of eth in wei to be transfered
   */
  function transfer(address payable _to, uint256 _amount) internal {
    _to.transfer(_amount);
  }

  /**
   * @dev Call a external contract
   * @param _to The address of the contract to call
   * @param _data ABI-encoded contract call to call `_to` address.
   */
  function _call(address _to, bytes memory _data) internal {
    // solium-disable-next-line security/no-call-value, no-unused-vars
    (bool success, bytes memory data) = _to.call.value(msg.value)(_data);
    require(success, "Call to external contract failed");
  }
}
