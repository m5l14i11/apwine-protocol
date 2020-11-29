
pragma solidity >=0.4.22 <0.7.3;


import '@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol';
import "@openzeppelin/contracts-ethereum-package/contracts/Initializable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/access/AccessControl.sol";

import "../../interfaces/ERC20.sol";
import "../../interfaces/apwine/IFutureYieldToken.sol";
import "../../interfaces/apwine/IAPWineVineyard.sol";

import "../../libraries/APWineMaths.sol";


abstract contract APWineCellar is Initializable, AccessControlUpgradeSafe{

    using SafeMath for uint256;


    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant CAVIST_ROLE = keccak256("CAVIST_ROLE");

    IAPWineVineyard public vineyard;
    ERC20 public ibt;

    /**
    * @notice Intializer
    * @param _vineyardAddress the address of the corresponding future
    * @param _adminAddress the address of the ACR admin
    */  
    function initialize(address _vineyardAddress, address _adminAddress) public initializer virtual{
        vineyard = IAPWineVineyard(_vineyardAddress);   
        ibt =  ERC20(vineyard.getIBTAddress());     
        _setupRole(DEFAULT_ADMIN_ROLE, _adminAddress);
        _setupRole(ADMIN_ROLE, _adminAddress);
        _setupRole(CAVIST_ROLE, _vineyardAddress);
        
    }

    /**
    * @notice register the yield of an expired period
    * @param _amount the amount of yield to be registered
    */  
    function registerExpiredFuture(uint256 _amount) public virtual;

    /**
    * @notice redeem the yield of the underlying yield of the FYT held by the sender
    * @param _periodIndex the index of the period to redeem the yield from
    */  
    function redeemYield(uint256 _periodIndex) public virtual{
        require(_periodIndex<vineyard.getNextPeriodIndex()-1,"Invalid period index");
        IFutureYieldToken fyt = IFutureYieldToken(vineyard.getFYTofPeriod(_periodIndex));
        uint256 senderTokenBalance = fyt.balanceOf(msg.sender);
        require(senderTokenBalance > 0,"FYT sender balance should not be null");
        require(fyt.transferFrom(msg.sender, address(this), senderTokenBalance),"Failed transfer");

        uint256 claimableYield = _updateYieldBalances(_periodIndex, senderTokenBalance, fyt.totalSupply());

        ibt.transfer(msg.sender, claimableYield);
        fyt.burn(senderTokenBalance);
    }   

    /**
    * @notice return the yield that could be redeemed by an address for a particular period
    * @param _periodIndex the index of the corresponding period
    * @param _tokenHolder the fyt holder
    * @return the yield that could be redeemed by the token holder for this period
    */  
    function getRedeemableYield(uint256 _periodIndex, address _tokenHolder) public view virtual returns(uint256);

    function _updateYieldBalances(uint256 _periodIndex, uint256 _cavistFYT, uint256 _totalFYT) internal virtual returns(uint256);

}