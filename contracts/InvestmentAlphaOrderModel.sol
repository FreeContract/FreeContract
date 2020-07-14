pragma solidity >=0.4.16 <0.7.0;
import "@openzeppelin/contracts/access/AccessControl.sol";
pragma experimental ABIEncoderV2;

contract InvestmentAlphaOrderModel is AccessControl{
    bytes32 public constant OPT_ROLE = keccak256("OPT_ROLE");
    InvestmentAlphaOrderStruct[] public _investmentAlphaOrderArray;
    struct InvestmentAlphaOrderStruct {
        //uint id;
        bool isActive;
        uint amount;
        uint openTime;
        bool isClosed;
        uint profit;
        uint elapsedDay;
        uint closeTime;
    }

    constructor()
    public {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        InvestmentAlphaOrderStruct memory zeroInvestmentAlphaOrder;
        _investmentAlphaOrderArray.push(zeroInvestmentAlphaOrder);
    }

    function getInvestmentAlphaOrder(uint id) view public returns (InvestmentAlphaOrderStruct memory) {
        require(id > 0 ,'Invalid order id');
        return _investmentAlphaOrderArray[id];
    }

    function getCount() view public returns (uint) {
        return _investmentAlphaOrderArray.length-1;
    }


    function create(uint amount)
    public
    returns (uint){
        require(hasRole(OPT_ROLE, msg.sender), "Access denny");
        InvestmentAlphaOrderStruct memory investmentAlphaOrder;
        uint id = _investmentAlphaOrderArray.length;
        //investmentAlphaOrder.id = id;
        investmentAlphaOrder.isActive = true;
        investmentAlphaOrder.amount = amount;
        investmentAlphaOrder.openTime = block.timestamp;
        _investmentAlphaOrderArray.push(investmentAlphaOrder);
        return id;
    }

    function getIsActive(uint id)
    public
    view
    returns (bool){
        return _investmentAlphaOrderArray[id].isActive;
    }

    function getAmount(uint id)
    public
    view
    returns (uint){
        return _investmentAlphaOrderArray[id].amount;
    }

    function getOpenTime(uint id)
    public
    view
    returns (uint){
        return _investmentAlphaOrderArray[id].openTime;
    }

    function getIsClosed(uint id)
    public
    view
    returns (bool){
        return _investmentAlphaOrderArray[id].isClosed;
    }

    function getProfit(uint id)
    public
    view
    returns (uint){
        return _investmentAlphaOrderArray[id].profit;
    }

    function getElapsedDay(uint id)
    public
    view
    returns (uint){
        return _investmentAlphaOrderArray[id].elapsedDay;
    }

    function getCloseTime(uint id)
    public
    view
    returns (uint){
        return _investmentAlphaOrderArray[id].closeTime;
    }

    function setAmount(uint id,uint value)
    public{
        require(hasRole(OPT_ROLE, msg.sender), "Access denny");
        _investmentAlphaOrderArray[id].amount = value;
    }

    function setOpenTime(uint id,uint value)
    public{
        require(hasRole(OPT_ROLE, msg.sender), "Access denny");
        _investmentAlphaOrderArray[id].openTime = value;
    }

    function setIsClosed(uint id, bool value)
    public{
        require(hasRole(OPT_ROLE, msg.sender), "Access denny");
        _investmentAlphaOrderArray[id].isClosed = value;
    }

    function setProfit(uint id, uint value)
    public{
        require(hasRole(OPT_ROLE, msg.sender), "Access denny");
        _investmentAlphaOrderArray[id].profit = value;
    }

    function setElapsedDay(uint id, uint value)
    public{
        require(hasRole(OPT_ROLE, msg.sender), "Access denny");
        _investmentAlphaOrderArray[id].elapsedDay = value;
    }

    function setCloseTime(uint id, uint value)
    public {
        require(hasRole(OPT_ROLE, msg.sender), "Access denny");
        _investmentAlphaOrderArray[id].closeTime = value;
    }
}
