// SPDX-License-Identifier: GNU GPLv3

pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

interface ExchangeAuxi {
    function kill() external;
    function revive() external;
    function setTradingFeeArray(uint256[] memory _tradeFeeArray) external;
    function setExchangeContract(address _exchangeContract) external;
    function setStableCoinsStatus(address[] memory _stableCoins, bool[] memory _status) external;
    function setCapxToken(address _capx) external;
    function withdrawFees(address _stableCoin, uint256 _amount) external;
    function transferOwnership(address newOwner) external;
    function upgradeTo(address newImplementation) external;
}

interface Exchange {
    function kill() external;
    function revive() external;
    function transferOwnership(address newOwner) external;
    function upgradeTo(address newImplementation) external;
}

contract LiquidRBAC is Initializable, UUPSUpgradeable, OwnableUpgradeable, AccessControlUpgradeable {
    
    address public exchangeAuxi;
    address public exchange;
    
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
    bytes32 public constant DEPLOYER_ROLE = keccak256("DEPLOYER_ROLE");
    bytes32 public constant DESTROYER_ROLE = keccak256("DESTROYER_ROLE");

    function initialize(address _auxi, address _exchange,address _default) public initializer {
        __Ownable_init();
        exchangeAuxi = _auxi;
        exchange = _exchange;
        // Owner of this contract would be the Default Admin Multisig.
        _setupRole(DEFAULT_ADMIN_ROLE, address(_default));
        _setupRole(PROPOSER_ROLE,address(_default));
        _setupRole(EXECUTOR_ROLE,address(_default));
        _setupRole(DEPLOYER_ROLE,address(_default));
        _setupRole(DESTROYER_ROLE,address(_default));
    }

    function _authorizeUpgrade(address _newImplementation)
        internal
        override
        onlyOwner
    {}

    // Exchange Auxi Functions
    function killAuxi() external onlyRole(DESTROYER_ROLE) {
        ExchangeAuxi(exchangeAuxi).kill();
    }

    function reviveAuxi() external onlyRole(DEFAULT_ADMIN_ROLE) {
        ExchangeAuxi(exchangeAuxi).revive();
    }

    function setTradingFeeArrayAuxi(uint256[] memory _tradeFeeArray) external onlyRole(EXECUTOR_ROLE) {
        ExchangeAuxi(exchangeAuxi).setTradingFeeArray(_tradeFeeArray);
    }

    function setStableCoinStatusAuxi(address[] memory _stableCoins, bool[] memory _status) external onlyRole(EXECUTOR_ROLE) {
        ExchangeAuxi(exchangeAuxi).setStableCoinsStatus(_stableCoins, _status);
    }

    function setExchangeContractAuxi(address _exchangeContract) external onlyRole(EXECUTOR_ROLE) {
        ExchangeAuxi(exchangeAuxi).setExchangeContract(_exchangeContract);
    }

    function setCapxTokenAuxi(address _capx) external onlyRole(EXECUTOR_ROLE) {
        ExchangeAuxi(exchangeAuxi).setCapxToken(_capx);
    } 

    function withdrawFeesAuxi(address _stableCoin, uint256 _amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        ExchangeAuxi(exchangeAuxi).withdrawFees(_stableCoin, _amount);
    }

    function transferOwnershipAuxi(address newOwner) external onlyRole(DEFAULT_ADMIN_ROLE) {
        ExchangeAuxi(exchangeAuxi).transferOwnership(newOwner);
    }

    function upgradeToAuxi(address newImplementation) external onlyRole(DEPLOYER_ROLE) {
        ExchangeAuxi(exchangeAuxi).upgradeTo(newImplementation);
    }

    function rawCallAuxi(bytes memory data) external onlyRole(DEFAULT_ADMIN_ROLE) {
        (bool success,) = address(exchangeAuxi).call(data);
        require(success, "Raw call Failed.");
    }

    // Exchange Functions
    function killExchange() external onlyRole(DESTROYER_ROLE) {
        Exchange(exchange).kill();
    }

    function reviveExchange() external onlyRole(DEFAULT_ADMIN_ROLE) {
        Exchange(exchange).revive();
    }

    function transferOwnershipExchange(address newOwner) external onlyRole(DEFAULT_ADMIN_ROLE) {
        Exchange(exchange).transferOwnership(newOwner);
    }

    function upgradeToExchange(address newImplementation) external onlyRole(DEPLOYER_ROLE) {
        Exchange(exchange).upgradeTo(newImplementation);
    }

    function rawCallExchange(bytes memory data) external onlyRole(DEFAULT_ADMIN_ROLE) {
        (bool success,) = address(exchange).call(data);
        require(success, "Raw call Failed.");
    }
}