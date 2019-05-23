pragma solidity ^0.5.0;

import "../utils/Create2.sol";
import "./Wallet.sol";
import "../token/ERC20/ERC20.sol";
import "../cryptography/ECDSA.sol";

contract WalletFactory {

  bytes public code;

  constructor(bytes memory _code) public {
    code = _code;
  }

  function deploy(
    bytes32 salt, address owner, address feeToken, uint256 fee, bytes memory feeSig
  ) public {

      Create2.deploy(salt, code);
      Wallet wallet = Wallet(Create2.computeAddress(salt, code));

      wallet.transferOwnership(owner);
      bytes memory feePaymentData = abi.encodeWithSelector(
        bytes4(keccak256("transfer(address,uint256)")), msg.sender, fee
      );
      
      wallet.call(feeToken, feePaymentData, feeSig);
  }
}
