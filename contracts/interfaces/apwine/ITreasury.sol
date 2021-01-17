pragma solidity >=0.7.0 <0.8.0;

interface ITreasury {
    function initialize(address _adminAddress) external;

    /**
     * @notice send erc20 tokens to an address
     * @param _erc20 the address of the erc20 token
     * @param _recipient the address of the recipient
     * @param _amount the amount of token to send
     */
    function sendToken(
        address _erc20,
        address _recipient,
        uint256 _amount
    ) external;

    /**
     * @notice send ether to an address
     * @param _recipient the address of the recipient
     * @param _amount the amount of ether to send
     */
    function sendEther(address payable _recipient, uint256 _amount) external payable;
}
