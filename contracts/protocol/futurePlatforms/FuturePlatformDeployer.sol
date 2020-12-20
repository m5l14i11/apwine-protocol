pragma solidity >=0.7.0 <0.8.0;
pragma abicoder v2;

import '@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol';
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/EnumerableMapUpgradeable.sol";
import "contracts/protocol/futures/Future.sol";
import "contracts/interfaces/apwine/IFutureVault.sol";
import "contracts/interfaces/apwine/IFutureWallet.sol";
import "contracts/interfaces/IProxyFactory.sol";
import "contracts/protocol/Registry.sol";
import "contracts/protocol/Controller.sol";
import "contracts/protocol/GaugeController.sol";

abstract contract FuturePlatformDeployer is Initializable, AccessControlUpgradeable {
    using SafeMathUpgradeable for uint256;

    /* ACR */
    bytes32 public constant FUTURE_DEPLOYER = keccak256("FUTURE_DEPLOYER");
    bytes32 public constant CONTROLLER_ROLE = keccak256("CONTROLLER_ROLE");

    Controller private controller;

    function initialize(address _controller, address _admin) initializer public {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(CONTROLLER_ROLE, _controller);
        controller = Controller(_controller);
    }

    function deployFutureWithIBT(string memory _futurePlatformName,address _ibt, uint256 _periodDuration) public returns(address){
        require(hasRole(FUTURE_DEPLOYER, msg.sender), "Caller is not an future admin");
        Registry registery = Registry(controller.getRegistery());
        require(registery.isRegisteredFuturePlatform(_futurePlatformName),"invalid future platform name");

        address[3] memory futurePlatformContracts = registery.getFuturePlatform(_futurePlatformName);


        IProxyFactory proxyFactory = IProxyFactory(registery.getProxyFactoryAddress());
        address controller_default_admin = controller.getRoleMember(DEFAULT_ADMIN_ROLE,0);

        /* Deploy the new contracts */
        bytes memory payload = abi.encodeWithSignature("initialize(address,address,uint256,string,address)",address(this),_ibt,_periodDuration,_futurePlatformName,controller_default_admin);
        Future newFuture = Future(proxyFactory.deployMinimal(futurePlatformContracts[0], payload));

        payload = abi.encodeWithSignature("initialize(address,address)",address(newFuture),controller_default_admin);
        address newFutureVault = proxyFactory.deployMinimal(futurePlatformContracts[1], payload);

        payload = abi.encodeWithSignature("initialize(address,address,uint256)",address(newFuture),controller_default_admin);
        address newFutureWallet = proxyFactory.deployMinimal(futurePlatformContracts[2], payload);

        /* Liquidity Gauge registration */
        address newLiquidityGauge = GaugeController(registery.getGaugeControllerAddress()).registerNewGauge(address(newFuture));

        /* Configure the new future */
        newFuture.setFutureVault(newFutureVault);
        newFuture.setFutureWallet(newFutureWallet);
        newFuture.setLiquidityGauge(newLiquidityGauge);

        /* Register the newly deployed future */
        controller.registerNewFuture(address(newFuture));
        return address(newFuture);
    }


    /* TODO SETTER FOR VARIABLES */

}