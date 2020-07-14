pragma solidity >=0.4.16 <0.7.0;
import "@openzeppelin/contracts/access/AccessControl.sol";
pragma experimental ABIEncoderV2;

contract InvestmentBetaOrderModel is AccessControl{
    bytes32 public constant OPT_ROLE = keccak256("OPT_ROLE");

    InvestmentBetaOrderStruct[] public _InvestmentBetaOrderArray;
    struct InvestmentBetaOrderStruct {
        //uint id;
        bool isActive;
        uint amount;
        uint plan;
        uint openTime;
        bool isClosed;
        uint profit;
        uint closeTime;
    }

    constructor()
    public {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        InvestmentBetaOrderStruct memory zeroInvestmentBetaOrder;
        _InvestmentBetaOrderArray.push(zeroInvestmentBetaOrder);
    }

    function getInvestmentBetaOrder(uint id) view public returns (InvestmentBetaOrderStruct memory) {
        require(id > 0 ,'Invalid order id');
        return _InvestmentBetaOrderArray[id];
    }

    function getCount() view public returns (uint) {
        return _InvestmentBetaOrderArray.length-1;
    }

    function create(uint amount,uint plan)
    public
    returns (uint){
        require(hasRole(OPT_ROLE, msg.sender), "Access denny");
        InvestmentBetaOrderStruct memory InvestmentBetaOrder;
        uint id = _InvestmentBetaOrderArray.length;
        //InvestmentBetaOrder.id = id;
        InvestmentBetaOrder.isActive = true;
        InvestmentBetaOrder.amount = amount;
        InvestmentBetaOrder.plan = plan;
        InvestmentBetaOrder.openTime = block.timestamp;
        _InvestmentBetaOrderArray.push(InvestmentBetaOrder);
        return id;
    }

    function getIsActive(uint id)
    public
    view
    returns (bool){
        return _InvestmentBetaOrderArray[id].isActive;
    }

    function getAmount(uint id)
    public
    view
    returns (uint){
        return _InvestmentBetaOrderArray[id].amount;
    }

    function getPlan(uint id)
    public
    view
    returns (uint){
        return _InvestmentBetaOrderArray[id].plan;
    }

    function getOpenTime(uint id)
    public
    view
    returns (uint){
        return _InvestmentBetaOrderArray[id].openTime;
    }

    function getIsClosed(uint id)
    public
    view
    returns (bool){
        return _InvestmentBetaOrderArray[id].isClosed;
    }

    function getProfit(uint id)
    public
    view
    returns (uint){
        return _InvestmentBetaOrderArray[id].profit;
    }

    function getCloseTime(uint id)
    public
    view
    returns (uint){
        return _InvestmentBetaOrderArray[id].closeTime;
    }

    function setAmount(uint id,uint value)
    public{
        require(hasRole(OPT_ROLE, msg.sender), "Access denny");
        _InvestmentBetaOrderArray[id].amount = value;
    }
    function setPlan(uint id,uint value)
    public{
        require(hasRole(OPT_ROLE, msg.sender), "Access denny");
        _InvestmentBetaOrderArray[id].plan = value;
    }
    function setOpenTime(uint id,uint value)
    public{
        require(hasRole(OPT_ROLE, msg.sender), "Access denny");
        _InvestmentBetaOrderArray[id].openTime = value;
    }

    function setIsClosed(uint id, bool value)
    public{
        require(hasRole(OPT_ROLE, msg.sender), "Access denny");
        _InvestmentBetaOrderArray[id].isClosed = value;
    }

    function setProfit(uint id, uint value)
    public{
        require(hasRole(OPT_ROLE, msg.sender), "Access denny");
        _InvestmentBetaOrderArray[id].profit = value;
    }

    function setCloseTime(uint id, uint value)
    public {
        require(hasRole(OPT_ROLE, msg.sender), "Access denny");
        _InvestmentBetaOrderArray[id].closeTime = value;
    }
}
