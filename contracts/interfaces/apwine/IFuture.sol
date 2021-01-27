pragma solidity ^0.7.6;

interface IFuture {
    struct Registration {
        uint256 startIndex;
        uint256 scaledBalance;
    }

    /**
     * @notice Getter for the PAUSE future parameter
     * @return true if new periods are not paused, false otherwise
     */
    function PAUSED() external view returns (bool);

    /**
     * @notice Getter for the PERIOD future parameter
     * @return returns the period length of the future
     */
    function PERIOD_DURATION() external view returns (uint256);

    /**
     * @notice Getter for the PLATFORM_NAME future parameter
     * @return returns the platform of the future
     */
    function PLATFORM_NAME() external view returns (uint256);

    /**
     * @notice Intializer
     * @param _controller the address of the controller
     * @param _ibt the address of the corresponding ibt
     * @param _periodDuration the length of the period (in days)
     * @param _platformName the name of the platform and tools
     * @param _deployerAddress the future deployer address
     * @param _admin the address of the ACR admin
     */
    function initialize(
        address _controller,
        address _ibt,
        uint256 _periodDuration,
        string memory _platformName,
        address _deployerAddress,
        address _admin
    ) external;

    /**
     * @notice Set future wallet address
     * @param _futureVault the address of the new future wallet
     * @dev needs corresponding permissions for sender
     */
    function setFutureVault(address _futureVault) external;

    /**
     * @notice Set futureWallet address
     * @param _futureWallet the address of the new futureWallet
     * @dev needs corresponding permissions for sender
     */
    function setFutureWallet(address _futureWallet) external;

    /**
     * @notice Set liquidity gauge address
     * @param _liquidityGauge the address of the new liquidity gauge
     * @dev needs corresponding permissions for sender
     */
    function setLiquidityGauge(address _liquidityGauge) external;

    /**
     * @notice Sender registers an amount of ibt for the next period
     * @param _user address to register to the future
     * @param _amount amount of ibt to be registered
     * @dev called by the controller only
     */
    function register(address _user, uint256 _amount) external;

    /**
     * @notice Sender unregisters an amount of ibt for the next period
     * @param _user user addresss
     * @param _amount amount of ibt to be unregistered
     */
    function unregister(address _user, uint256 _amount) external;

    /**
     * @notice Sender unlock the locked funds corresponding to its apwibt holding
     * @param _user user adress
     * @param _amount amount of funds to unlocked
     * @dev will require transfer of fyt of the oingoing period corresponding to the funds unlocked
     */
    function withdrawLockFunds(address _user, uint256 _amount) external;

    /**
     * @notice Send the user its owed fyt (and apwibt if there are some claimable)
     * @param _user address of the user to send the fyt to
     */
    function claimFYT(address _user) external;

    /**
     * @notice Start a new period
     * @dev needs corresponding permissions for sender
     */
    function startNewPeriod() external;

    /**
     * @notice Check if a user has fyt not claimed
     * @param _user the user to check
     * @return true if the user can claim some fyt, false otherwise
     */
    function hasClaimableFYT(address _user) external view returns (bool);

    /**
     * @notice Check if a user has ibt not claimed
     * @param _user the user to check
     * @return true if the user can claim some ibt, false otherwise
     */
    function hasClaimableAPWIBT(address _user) external view returns (bool);

    /**
     * @notice Getter for user registered amount
     * @param _user user to return the registered funds of
     * @return the registered amount, 0 if no registrations
     * @dev the registration can be older than for the next period
     */
    function getRegisteredAmount(address _user) external view returns (uint256);

    /**
     * @notice Getter for user ibt amount that is unlockable
     * @param _user user to unlock the ibt from
     * @return the amount of ibt the user can unlock
     */
    function getUnlockableFunds(address _user) external view returns (uint256);

    /**
     * @notice Getter for yield that is generated by the user funds during the current period
     * @param _user user to check the unrealised yield of
     * @return the yield (amout of ibt) currently generated by the locked funds of the user
     */
    function getUnrealisedYield(address _user) external view returns (uint256);

    /**
     * @notice Getter for the amount of apwibt that the user can claim
     * @param _user user to check the check the claimable apwibt of
     * @return the amount of apwibt claimable by the user
     */
    function getClaimableAPWIBT(address _user) external view returns (uint256);

    /**
     * @notice Getter for the amount of fyt that the user can claim for a certain period
     * @param _user user to check the check the claimable fyt of
     * @param _periodID period ID to check the claimable fyt of
     * @return the amount of fyt claimable by the user for this period ID
     */
    function getClaimableFYTForPeriod(address _user, uint256 _periodID) external view returns (uint256);

    /**
     * @notice Getter for next period index
     * @return next period index
     * @dev index starts at 1
     */
    function getNextPeriodIndex() external view returns (uint256);

    /**
     * @notice Getter for controller  address
     * @return the controller  address
     */
    function getControllerAddress() external view returns (address);

    /**
     * @notice Getter for future wallet address
     * @return future wallet address
     */
    function getFutureVaultAddress() external view returns (address);

    /**
     * @notice Getter for futureWallet address
     * @return futureWallet address
     */
    function getFutureWalletAddress() external view returns (address);

    /**
     * @notice Getter for liquidityGauge address
     * @return liquidity gauge address
     */
    function getLiquidityGaugeAddress() external view returns (address);

    /**
     * @notice Getter for the ibt address
     * @return ibt address
     */
    function getIBTAddress() external view returns (address);

    /**
     * @notice Getter for future apwibt address
     * @return apwibt address
     */
    function getAPWIBTAddress() external view returns (address);

    /**
     * @notice Getter for fyt address of a particular period
     * @param _periodIndex period index
     * @return fyt address
     */
    function getFYTofPeriod(uint256 _periodIndex) external view returns (address);

    /* Admin functions*/

    /**
     * @notice Pause registrations and the creation of new periods
     */
    function pausePeriods() external;

    /**
     * @notice Resume registrations and the creation of new periods
     */
    function resumePeriods() external;
}
