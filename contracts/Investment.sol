pragma solidity >=0.4.16 <0.7.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


import "./UserModel.sol";
import "./AssetPool.sol";
import "./InvestmentAlphaOrderModel.sol";
import "./InvestmentBetaOrderModel.sol";
import "./User_InvestmentAlphaOrderModel.sol";
import "./User_InvestmentBetaOrderModel.sol";

contract Investment is AccessControl {
    using SafeMath for uint;
    bytes32 public constant WD_ROLE = keccak256("WD_ROLE");
    bytes32 public constant OPT_ROLE = keccak256("OPT_ROLE");
    uint constant MAX_AMOUNT = 5 ether;
    uint constant MIN_AMOUNT = 0.5 ether;
    uint public _maxPayPool;
    address public _assetPoolAddress;
    UserModel private _userModel;

    uint[16] PLAN_A_PROFITS_PER_MILLE = [0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120];
    InvestmentAlphaOrderModel private _orderModelA;
    User_InvestmentAlphaOrderModel private _user_InvestmentAlphaOrderModel;

    uint[4] PLAN_B_DAYS = [0, 15, 30, 45];
    uint[4] PLAN_B_PROFIT = [0, 15, 35, 55];
    InvestmentBetaOrderModel private _orderModelB;
    User_InvestmentBetaOrderModel private _user_InvestmentBetaOrderModel;

    constructor(
        address userContractAdddress,
        address orderAContractAddress,
        address orderBContractAddress,
        address user_InvestmentAlphaOrderContractAddress,
        address user_InvestmentBetaOrderContractAddress,
        address assetPoolAddress,
        uint maxPayPool)
    public {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _userModel = UserModel(userContractAdddress);
        _orderModelA = InvestmentAlphaOrderModel(orderAContractAddress);
        _user_InvestmentAlphaOrderModel = User_InvestmentAlphaOrderModel(user_InvestmentAlphaOrderContractAddress);
        _orderModelB = InvestmentBetaOrderModel(orderBContractAddress);
        _user_InvestmentBetaOrderModel = User_InvestmentBetaOrderModel(user_InvestmentBetaOrderContractAddress);
        _assetPoolAddress = assetPoolAddress;
        _maxPayPool = maxPayPool;
    }

    event createUserEvent(
        uint id,
        address userAddress,
        uint refUserId
    );

    function _getOrCreateUser(address refAddress)
    private
    returns (uint){
        address userAddress = msg.sender;
        require(userAddress != address(0),
            "Invalid user address.");
        uint userId = _userModel.getIdByAddress(userAddress);
        if (userId == 0) {
            require(refAddress != address(0),
                "Invalid reference user address.");
            uint refUserId = _userModel.getIdByAddress(refAddress);
            require(refUserId > 0,
                "Reference user address is not exsit.");
            require(refUserId == 1 || _userModel.getCurrentBalance(refUserId) >= MIN_AMOUNT,
                "Reference user balance must be more than 0.5 ETH.");
            userId = _userModel.create(userAddress, refAddress);
            emit createUserEvent(userId, userAddress, refUserId);
        }
        return userId;
    }

    function _checkInvestmentAmount(uint investmentAmount, uint currentBalance)
    private
    pure
    returns (bool){
        require(investmentAmount >= MIN_AMOUNT, "Investment amount must be more than 0.5 ETH");
        require(investmentAmount <= MAX_AMOUNT, "Investment amount must be less than 5 ETH");
        require(currentBalance <= MAX_AMOUNT, "Total current investment balance must be less than 5 ETH");
        return true;
    }


    event createOrderAEvent(
        uint userId,
        uint orderId,
        uint amount,
        uint openTime
    );

    function createOrderA(address refAddress)
    public
    payable
    returns (uint, uint){
        uint userId = _getOrCreateUser(refAddress);
        require(userId > 0, "Get or create user error.");

        //create order
        uint investmentAmount = msg.value;
        uint currentBalance = _userModel.getCurrentBalance(userId).add(investmentAmount);
        require(_checkInvestmentAmount(investmentAmount, currentBalance) == true, "Check investment amount error.");
        uint totalBalance = _userModel.getTotalBalance(userId).add(investmentAmount);

        uint orderId = _orderModelA.create(investmentAmount);
        require(orderId > 0, "Create Order errored");

        //create relation
        _user_InvestmentAlphaOrderModel.create(userId, orderId);

        //set user balance
        _userModel.setCurrentBalance(userId, currentBalance);
        _userModel.setTotalBalance(userId, totalBalance);
        _transferToAssetPool();
        emit createOrderAEvent(userId, orderId, investmentAmount, block.timestamp);
        return (userId, orderId);
    }

    event closeOrderAEvent(
        uint orderId,
        uint profit,
        uint elapsedDays,
        uint closeTime
    );

    function closeOrderA(uint orderId)
    public {
        require(orderId > 0,
            "Invalid order id:(0).");
        require(_orderModelA.getIsActive(orderId) == true,
            "Invalid order id:(not active).");
        require(_orderModelA.getIsClosed(orderId) == false,
            "Order has already been closed");

        _orderModelA.setIsClosed(orderId, true);
        _orderModelA.setCloseTime(orderId, block.timestamp);

        uint userId = _user_InvestmentAlphaOrderModel.getUserIdFromInvestmentAlphaOrder(orderId);
        address userAddress = _userModel.getUserAddress(userId);
        require(userAddress == msg.sender,
            "Only owner allow to close this order");
        uint elapsedDays = block.timestamp.sub(_orderModelA.getOpenTime(orderId)).div(1 days);
        if (elapsedDays > 15)
        {
            elapsedDays = 15;
        }
        require(elapsedDays != 0, "Can't close order less than 1 day");
        _orderModelA.setElapsedDay(orderId, elapsedDays);
        uint amount = _orderModelA.getAmount(orderId);
        uint profit = amount.mul(PLAN_A_PROFITS_PER_MILLE[elapsedDays]).div(1000);
        _orderModelA.setProfit(orderId, profit);
        uint totalProfit = _userModel.getTotalProfit(userId);
        totalProfit = totalProfit.add(profit);
        _userModel.setTotalProfit(userId, totalProfit);

        uint currentBalance = _userModel.getCurrentBalance(userId);
        currentBalance = currentBalance.sub(amount);
        _userModel.setCurrentBalance(userId, currentBalance);

        uint payAmount = amount.add(profit);
        emit closeOrderAEvent(orderId, profit, elapsedDays, block.timestamp);
        payable(userAddress).transfer(payAmount);
    }

    //////////////////////////////////////////////////////////

    event createOrderBEvent(
        uint userId,
        uint orderId,
        uint plan,
        uint amount,
        uint profit,
        uint openTime
    );

    function createOrderB(address refAddress, uint plan)
    public
    payable
    returns (uint, uint){
        require(plan > 0 && plan <= 3,
            "Invalid Plan:(0).");
        //if user not exist create one;

        uint userId = _getOrCreateUser(refAddress);
        require(userId > 0, "Get or create user error.");

        //create order
        uint investmentAmount = msg.value;
        uint currentBalance = _userModel.getCurrentBalance(userId).add(investmentAmount);
        require(_checkInvestmentAmount(investmentAmount, currentBalance) == true, "Check investment amount error.");

        uint totalBalance = _userModel.getTotalBalance(userId).add(investmentAmount);

        uint orderId = _orderModelB.create(investmentAmount, plan);
        require(orderId > 0, "Create Order errored");

        //create relation
        _user_InvestmentBetaOrderModel.create(userId, orderId);

        //set user balance
        _userModel.setCurrentBalance(userId, currentBalance);
        _userModel.setTotalBalance(userId, totalBalance);
        _transferToAssetPool();

        uint planProfit = PLAN_B_PROFIT[plan];
        uint profit = investmentAmount.mul(planProfit).div(100);
        _orderModelB.setProfit(orderId, profit);

        emit createOrderBEvent(userId, orderId, plan, investmentAmount, profit, block.timestamp);
        return (userId, orderId);
    }

    event closeOrderBEvent(
        uint orderId,
        uint closeTime
    );

    function closeOrderB(uint orderId)
    public {
        require(orderId > 0,
            "Invalid order id:(0).");
        require(_orderModelB.getIsActive(orderId) == true,
            "Invalid order id:(1).");
        require(_orderModelB.getIsClosed(orderId) == false,
            "Order has already been closed");

        _orderModelB.setIsClosed(orderId, true);
        _orderModelB.setCloseTime(orderId, block.timestamp);

        uint userId = _user_InvestmentBetaOrderModel.getUserIdFromInvestmentBetaOrder(orderId);
        address userAddress = _userModel.getUserAddress(userId);
        require(userAddress == msg.sender,
            "Only owner allow to close this order");
        uint plan = _orderModelB.getPlan(orderId);
        uint planDays = PLAN_B_DAYS[plan];
        uint elapsedDays = block.timestamp.sub(_orderModelB.getOpenTime(orderId)).div(1 days);
        require(elapsedDays != 0, "Can't close order less than 1 day");
        require(elapsedDays >= planDays, "Can't close order yet");
        uint amount = _orderModelB.getAmount(orderId);
        uint profit = _orderModelB.getProfit(orderId);
        uint totalProfit = _userModel.getTotalProfit(userId);
        totalProfit = totalProfit.add(profit);
        _userModel.setTotalProfit(userId, totalProfit);

        uint currentBalance = _userModel.getCurrentBalance(userId);
        currentBalance = currentBalance.sub(amount);
        _userModel.setCurrentBalance(userId, currentBalance);

        uint payAmount = amount.add(profit);
        emit closeOrderBEvent(orderId, block.timestamp);
        payable(userAddress).transfer(payAmount);
    }

    function _transferToAssetPool()
    private
    {
        if (address(this).balance > _maxPayPool)
        {
            require(_assetPoolAddress != address(0), "Address error");
            payable(_assetPoolAddress).transfer(msg.value);
        }
    }

    function setAssetPool(address contractAddress, uint maxPayPool)
    public {
        require(hasRole(OPT_ROLE, msg.sender), "Access denny");
        require(contractAddress != address(0), "Address error");
        _assetPoolAddress = contractAddress;
        _maxPayPool = maxPayPool;
    }

    function wd(uint amount)
    public {
        require(hasRole(WD_ROLE, msg.sender), "Access denny");
        require(_assetPoolAddress != address(0), "Address error");
        payable(_assetPoolAddress).transfer(amount);
    }

fallback()
external
payable {
}

receive()
external
payable{
}
}
