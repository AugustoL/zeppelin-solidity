pragma solidity ^0.4.18;


import '../storage/EternalStorage.sol';
import '../math/SafeMath.sol';


/**
 * @title Eternal Storage token
 * @dev version of Basic Token using Eternal Storage
 */
contract ESToken {
  using SafeMath for uint256;

  EternalStorage public s;

  function ESToken() {
    s = new EternalStorage();
    s.setAddress(keccak256('owner'), msg.sender);
  }

  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    uint256 senderBalance = s.getUint(keccak256('balance', msg.sender));
    require(_value <= senderBalance);

    uint256 receiverBalance = s.getUint(keccak256('balance', _to));
    s.setUint(keccak256('balance', msg.sender), senderBalance.sub(_value));
    s.setUint(keccak256('balance', _to), receiverBalance.add(_value));
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev mint tokens, only calleed by the owner
  * @param _to The address to receive the tokens.
  * @param _value The amount to be minted.
  */
  function mint(address _to, uint256 _value) {
    address _owner = s.getAddress(keccak256('owner'));
    require(_owner == msg.sender);

    s.setUint(keccak256('balance', _to), _value);
    s.setUint(keccak256('totalSupply'), _value);
  }

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return s.getUint(keccak256('totalSupply'));
  }

  /**
  * @dev owner address
  */
  function owner() public view returns (address) {
    return s.getAddress(keccak256('owner'));
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return s.getUint(keccak256('balance', _owner));
  }

}
