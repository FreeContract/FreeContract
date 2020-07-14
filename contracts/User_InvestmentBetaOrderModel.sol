pragma solidity >=0.4.16 <0.7.0;
import "@openzeppelin/contracts/access/AccessControl.sol";

contract User_InvestmentBetaOrderModel is AccessControl{
    bytes32 public constant OPT_ROLE = keccak256("OPT_ROLE");

    struct InvestmentBetaOrderStruct{
        uint userId;
        uint indexByUser;
    }

    struct UserStruct {
        uint[] investmentBetaOrderIds;
    }

    mapping(uint => InvestmentBetaOrderStruct) _investmentBetaOrders;
    mapping(uint => UserStruct) _users;

    constructor()
    public {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function getUserIdFromInvestmentBetaOrder(uint id)
    public
    view
    returns (uint){
        return _investmentBetaOrders[id].userId;
    }

    function getIndexByUserFromInvestmentBetaOrder(uint id)
    public
    view
    returns (uint){
        return _investmentBetaOrders[id].indexByUser;
    }

    function getInvestmentBetaOrdersLengthFromUser(uint id)
    public
    view
    returns (uint){
        return _users[id].investmentBetaOrderIds.length;
    }

    function getInvestmentBetaOrderIdFromUser(uint id, uint index)
    public
    view
    returns (uint){
        return _users[id].investmentBetaOrderIds[index];
    }

    function create(uint userId, uint investmentBetaOrderId)
    public
    returns (bool)
    {
        require(hasRole(OPT_ROLE, msg.sender), "Access denny");
        InvestmentBetaOrderStruct memory investmentBetaOrder;
        investmentBetaOrder.userId = userId;
        investmentBetaOrder.indexByUser = _users[userId].investmentBetaOrderIds.length;
        _investmentBetaOrders[investmentBetaOrderId] = investmentBetaOrder;
        _users[userId].investmentBetaOrderIds.push(investmentBetaOrderId);
        return true;
    }
}
