pragma solidity >=0.4.16 <0.7.0;
import "@openzeppelin/contracts/access/AccessControl.sol";
pragma experimental ABIEncoderV2;

contract UserModel is AccessControl{
    bytes32 public constant OPT_ROLE = keccak256("OPT_ROLE");
    UserStruct[] public _userArray;

    struct UserStruct {
        //uint id;
        bool isActive;
        bool isRoot;
        address userAddress;
        address refAddress;
        uint totalBalance;
        uint currentBalance;
        uint totalProfit;
        uint[] inviteUsers;
    }
    mapping(address => uint) public _addressMap;


    constructor(address rootUserAddress)
    public {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        UserStruct memory zeroUser;
        _userArray.push(zeroUser);
        UserStruct memory rootUser;
        //rootUser.id = 1;
        rootUser.isActive = true;
        rootUser.isRoot = true;
        rootUser.userAddress = rootUserAddress;
        rootUser.refAddress = address(0);
        _userArray.push(rootUser);
        _addressMap[rootUserAddress] = 1;
    }

    function create(address userAddress, address refAddress)
    public
    returns(uint)
    {
        require(hasRole(OPT_ROLE, msg.sender), "Access denny");
        UserStruct memory user;
        uint id = _userArray.length;
        //user.id = id;
        user.isActive = true;
        user.userAddress = userAddress;
        user.refAddress = refAddress;
        uint refUserId = _addressMap[refAddress];
        _userArray[refUserId].inviteUsers.push(id);
        _userArray.push(user);
        _addressMap[userAddress] = id;//index
        return id;
    }

    function getUser(uint id) view public returns (UserStruct memory) {
        require(id > 0 ,'Invalid order id');
        return _userArray[id];
    }

    function getCount() view public returns (uint) {
        return _userArray.length-1;
    }

    function getIdByAddress(address userAddress)
    view
    public
    returns (uint){
        return _addressMap[userAddress];
    }

    function getIsActive(uint id) public view returns (bool){
        return _userArray[id].isActive;
    }

    function getIsRoot(uint id) public view returns (bool){
        return _userArray[id].isRoot;
    }


    function getUserAddress(uint id) public view returns (address){
        return _userArray[id].userAddress;
    }

    function getRefAddress(uint id) public view returns (address){
        return _userArray[id].refAddress;
    }

    function getTotalBalance(uint id) public view returns (uint){
        return _userArray[id].totalBalance;
    }

    function getCurrentBalance(uint id) public view returns (uint){
        return _userArray[id].currentBalance;
    }

    function getTotalProfit(uint id) public view returns (uint){
        return _userArray[id].totalProfit;
    }

    function getInviteUsersLength(uint id) public view returns (uint){
        return _userArray[id].inviteUsers.length;
    }

    function getInviteUsersId(uint id,uint index) public view returns (uint){
        return _userArray[id].inviteUsers[index];
    }
    function setTotalBalance(uint id, uint value) public{
        require(hasRole(OPT_ROLE, msg.sender), "Access denny");
        _userArray[id].totalBalance = value;
    }
    function setCurrentBalance(uint id, uint value) public{
        require(hasRole(OPT_ROLE, msg.sender), "Access denny");
        _userArray[id].currentBalance = value;
    }
    function setTotalProfit(uint id, uint value) public{
        require(hasRole(OPT_ROLE, msg.sender), "Access denny");
        _userArray[id].totalProfit = value;
    }
}
