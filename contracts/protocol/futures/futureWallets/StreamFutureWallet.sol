pragma solidity >=0.7.0 <0.8.0;

import "./FutureWallet.sol";

abstract contract StreamFutureWallet is FutureWallet{
    using SafeMathUpgradeable for uint256;

    uint256 private scaledTotal;
    uint256[] private scaledFutureWallets;


    function initialize(address _futureAddress, address _adminAddress) public initializer override{
        super.initialize(_futureAddress,_adminAddress);
    }

    function registerExpiredFuture(uint256 _amount) public override{
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not allowed to register a harvest");

        uint256 currentTotal = ibt.balanceOf(address(this));

        if(scaledFutureWallets.length>1){
            uint256 scaledInput = APWineMaths.getScaledInput(_amount,scaledTotal,currentTotal);
            scaledFutureWallets.push(scaledInput);
            scaledTotal = scaledTotal.add(scaledInput);
        }else{
            scaledFutureWallets.push(_amount);
            scaledTotal = scaledTotal.add(_amount);
        }
    }

    function getRedeemableYield(uint256 _periodIndex, address _tokenHolder) public view override returns(uint256){
        IFutureYieldToken fyt = IFutureYieldToken(future.getFYTofPeriod(_periodIndex));
        uint256 senderTokenBalance = fyt.balanceOf(_tokenHolder);
        uint256 scaledOutput = (senderTokenBalance.mul(scaledFutureWallets[_periodIndex]));
       return APWineMaths.getActualOutput(scaledOutput,scaledTotal,ibt.balanceOf(address(this))).div(fyt.totalSupply());
    }

    function _updateYieldBalances(uint256 _periodIndex, uint256 _userFYT, uint256 _totalFYT) internal override returns(uint256){
        uint256 scaledOutput = (_userFYT.mul(scaledFutureWallets[_periodIndex])).div(_totalFYT);
        uint256 claimableYield =  APWineMaths.getActualOutput(scaledOutput,scaledTotal,ibt.balanceOf(address(this)));
        scaledFutureWallets[_periodIndex] = scaledFutureWallets[_periodIndex].sub(scaledOutput);
        scaledTotal = scaledTotal.sub(scaledOutput);
        return claimableYield;
    }


}