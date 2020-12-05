pragma solidity >=0.4.22 <0.7.3;

import '@openzeppelin/contracts-ethereum-package/contracts/presets/ERC20PresetMinterPauser.sol';
import "contracts/interfaces/apwine/IFuture.sol";


contract FutureYieldToken is ERC20PresetMinterPauserUpgradeSafe{

    address public future;

    function initialize(string memory _tokenName, string memory _tokenSymbol, address _futureAddress) initializer public {
        super.initialize(_tokenName,_tokenSymbol);
        _setupRole(DEFAULT_ADMIN_ROLE, _futureAddress);
        _setupRole(MINTER_ROLE, _futureAddress);
        _setupRole(PAUSER_ROLE, _futureAddress);
        future = _futureAddress;

    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        if(recipient!=future && recipient!=IFuture(future).getFutureWalletAddress()){
            _approve(sender, _msgSender(), allowance(sender,_msgSender()).sub(amount, "ERC20: transfer amount exceeds allowance"));
        }
        return true;
    }

}