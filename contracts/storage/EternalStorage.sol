pragma solidity ^0.4.18;

/**
 * @title EternalStorage
 * @dev An ownable contract that can be used as a storage where the variables
 * are stored in a set of mappings indexed by hash names.
 */
contract EternalStorage{

  struct Storage {
    mapping(bytes32 => bool) _bool;
    mapping(bytes32 => int) _int;
    mapping(bytes32 => uint256) _uint;
    mapping(bytes32 => string) _string;
    mapping(bytes32 => address) _address;
    mapping(bytes32 => bytes) _bytes;
  }

  Storage internal s;

  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The constructor sets the original `owner` of the
   * contract to the sender account.
   */
  function EternalStorage() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a
   * newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  /**
   * @dev Allows the owner to set a value for a boolean variable.
   * @param h The keccak256 hash of the variable name
   * @param v The value to be stored
   */
  function setBoolean(bytes32 h, bool v) public onlyOwner {
    s._bool[h] = v;
  }

  /**
   * @dev Allows the owner to set a value for a int variable.
   * @param h The keccak256 hash of the variable name
   * @param v The value to be stored
   */
  function setInt(bytes32 h, int v) public onlyOwner {
    s._int[h] = v;
  }

  /**
   * @dev Allows the owner to set a value for a boolean variable.
   * @param h The keccak256 hash of the variable name
   * @param v The value to be stored
   */
  function setUint(bytes32 h, uint256 v) public onlyOwner {
    s._uint[h] = v;
  }

  /**
   * @dev Allows the owner to set a value for a address variable.
   * @param h The keccak256 hash of the variable name
   * @param v The value to be stored
   */
  function setAddress(bytes32 h, address v) public onlyOwner {
    s._address[h] = v;
  }

  /**
   * @dev Allows the owner to set a value for a string variable.
   * @param h The keccak256 hash of the variable name
   * @param v The value to be stored
   */
  function setString(bytes32 h, string v) public onlyOwner {
    s._string[h] = v;
  }

  /**
   * @dev Allows the owner to set a value for a bytes variable.
   * @param h The keccak256 hash of the variable name
   * @param v The value to be stored
   */
  function setBytes(bytes32 h, bytes v) public onlyOwner {
    s._bytes[h] = v;
  }

  /**
   * @dev Get the value stored of a boolean variable by the hash name
   * @param h The keccak256 hash of the variable name
   */
  function getBoolean(bytes32 h) public view returns (bool){
    return s._bool[h];
  }

  /**
   * @dev Get the value stored of a int variable by the hash name
   * @param h The keccak256 hash of the variable name
   */
  function getInt(bytes32 h) public view returns (int){
    return s._int[h];
  }

  /**
   * @dev Get the value stored of a uint variable by the hash name
   * @param h The keccak256 hash of the variable name
   */
  function getUint(bytes32 h) public view returns (uint256){
    return s._uint[h];
  }

  /**
   * @dev Get the value stored of a address variable by the hash name
   * @param h The keccak256 hash of the variable name
   */
  function getAddress(bytes32 h) public view returns (address){
    return s._address[h];
  }

  /**
   * @dev Get the value stored of a string variable by the hash name
   * @param h The keccak256 hash of the variable name
   */
  function getString(bytes32 h) public view returns (string){
    return s._string[h];
  }

  /**
   * @dev Get the value stored of a bytes variable by the hash name
   * @param h The keccak256 hash of the variable name
   */
  function getBytes(bytes32 h) public view returns (bytes){
    return s._bytes[h];
  }

}
