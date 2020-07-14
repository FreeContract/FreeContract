pragma solidity >=0.4.16 <0.7.0;
import "@openzeppelin/contracts/access/AccessControl.sol";

contract AssetPool is AccessControl{
    bytes32 public constant WD_ROLE = keccak256("WD_ROLE");
    bytes32 public constant OPT_ROLE = keccak256("OPT_ROLE");
    address public _investmentContract;

    constructor()
    public{
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setInvestmentContract(address contractAddress)
    public{
        require(hasRole(OPT_ROLE, msg.sender), "Access denny");
        require(contractAddress != address(0), "Address error");
        _investmentContract = contractAddress;
    }

    function transferToInvestmentContract(uint amount)
    public
    {
        require(hasRole(WD_ROLE, msg.sender), "Access denny");
        require(_investmentContract != address(0), "Address error");
        payable(_investmentContract).transfer(amount);
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
