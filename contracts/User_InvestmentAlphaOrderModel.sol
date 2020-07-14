pragma solidity >=0.4.16 <0.7.0;
import "@openzeppelin/contracts/access/AccessControl.sol";

contract User_InvestmentAlphaOrderModel is AccessControl{
    bytes32 public constant OPT_ROLE = keccak256("OPT_ROLE");

    struct InvestmentAlphaOrderStruct{
        uint userId;
        uint indexByUser;
    }

    struct UserStruct {
        uint[] investmentAlphaOrderIds;
    }

    mapping(uint => InvestmentAlphaOrderStruct) _investmentAlphaOrders;
    mapping(uint => UserStruct) _users;

    constructor()
    public {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function getUserIdFromInvestmentAlphaOrder(uint id)
    public
    view
    returns (uint){
        return _investmentAlphaOrders[id].userId;
    }

    function getIndexByUserFromInvestmentAlphaOrder(uint id)
    public
    view
    returns (uint){
        return _investmentAlphaOrders[id].indexByUser;
    }

    function getInvestmentAlphaOrdersLengthFromUser(uint id)
    public
    view
    returns (uint){
        return _users[id].investmentAlphaOrderIds.length;
    }

    function getInvestmentAlphaOrderIdFromUser(uint id, uint index)
    public
    view
    returns (uint){
        return _users[id].investmentAlphaOrderIds[index];
    }

    function create(uint userId, uint investmentAlphaOrderId)
    public
    returns (bool)
    {
        require(hasRole(OPT_ROLE, msg.sender), "Access denny");
        InvestmentAlphaOrderStruct memory investmentAlphaOrder;
        investmentAlphaOrder.userId = userId;
        investmentAlphaOrder.indexByUser = _users[userId].investmentAlphaOrderIds.length;
        _investmentAlphaOrders[investmentAlphaOrderId] = investmentAlphaOrder;
        _users[userId].investmentAlphaOrderIds.push(investmentAlphaOrderId);
        return true;
    }
}
