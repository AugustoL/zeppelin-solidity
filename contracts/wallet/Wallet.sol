pragma solidity ^0.5.0;

import "../cryptography/ECDSA.sol";
import "../ownership/Ownable.sol";

contract Wallet is Ownable {

  using ECDSA for bytes32;

  constructor(address owner) public {
    _transferOwnership(owner);
  }

  // Used to prevent execution of already executed txs during a timeframe
  mapping(bytes32 => uint256) pastTxs;

  /**
   * @dev Call a external contract and pay a fee for the call
   * @param to The address of the contract to call
   * @param data ABI-encoded contract call to call `_to` address.
   * @param sig The hash of the data signed by the wallet owner
   * @param feeToken The token used for the fee, use wallet address for ETH
   * @param feeAmount The amount to be payed as fee
   * @param beforeTime timetstamp of the time where this tx cant be executed
   * once it passed
   */
  function call(
    address to, bytes memory data, address feeToken, uint256 feeAmount, bytes memory sig, uint256 beforeTime
  ) public payable {
    require(beforeTime < block.timestamp);
    bytes32 txHash = keccak256(abi.encodePacked(
      to, data, sig, feeToken, feeAmount
    ));
    require(pastTxs[txHash] < block.timestamp);

    address _signer = keccak256(abi.encodePacked(to, data, feeToken, feeAmount, beforeTime)).recover(sig);
    require(owner() == _signer, "Signer is not wallet owner");

    bytes memory feePaymentData = abi.encodeWithSelector(
      bytes4(keccak256("transfer(address,uint256)")), msg.sender, feeAmount
    );

    _call(to, data);
    _call(feeToken, feePaymentData);
    pastTxs[txHash] = beforeTime;
  }

  /**
   * @dev Call a external contract
   * @param to The address of the contract to call
   * @param data ABI-encoded contract call to call `_to` address.
   * @param sig The hash of the data signed by the wallet owner
   * @param beforeTime timetstamp of the time where this tx cant be executed
   * once it passed
   */
  function call(address to, bytes memory data, bytes memory sig, uint256 beforeTime) public payable {
    require(beforeTime < block.timestamp);
    bytes32 txHash = keccak256(abi.encodePacked(
      to, data, sig
    ));
    require(pastTxs[txHash] < block.timestamp);

    address _signer = keccak256(abi.encodePacked(to, data, beforeTime)).recover(sig);
    require(owner() == _signer, "Signer is not wallet owner");

    _call(to, data);
    pastTxs[txHash] = beforeTime;
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
