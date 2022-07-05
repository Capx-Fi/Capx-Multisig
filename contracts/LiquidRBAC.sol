// SPDX-License-Identifier: GNU GPLv3

pragma solidity 0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

interface LiquidERC20Factory {
    function setLender(address _lender) external;
    function transferOwnership(address newOwner) external;
}

interface LiquidMaster {
    function setLiquidController(address _controller) external;
    function setLiquidFactory(address _factory) external;
    function setVestingController(address _controller) external;
    function commitTransferFactory(address _newFactory) external;
    function applyTransferFactory() external;
    function revertFactoryTransfer() external;
    function commitTransferProposal(address _newProposal) external;
    function applyTransferProposal() external;
    function revertProposalTransfer() external;
    function transferOwnership(address newOwner) external;
    function upgradeTo(address newImplementation) external;
}

interface LiquidController {
    function kill() external;
    function revive() external;
    function transferOwnership(address newOwner) external;
    function upgradeTo(address newImplementation) external;
}

interface LiquidVesting {
    function setMaster(address _master) external;
    function commitTransferMaster(address _newMaster) external;
    function applyTransferMaster() external;
    function revertMasterTransfer() external;
    function transferOwnership(address newOwner) external;
    function upgradeTo(address newImplementation) external;
}

contract LiquidRBAC is Initializable, UUPSUpgradeable, OwnableUpgradeable, AccessControlUpgradeable {
    address public liquidFactory;
    address public liquidMaster;
    address public liquidController;
    address public liquidVesting;

    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
    bytes32 public constant DEPLOYER_ROLE = keccak256("DEPLOYER_ROLE");
    bytes32 public constant DESTROYER_ROLE = keccak256("DESTROYER_ROLE");

    function initialize(address factory, address master, address controller, address vesting, address _default) public initializer {
        __Ownable_init();
        liquidFactory = factory;
        liquidMaster = master;
        liquidController = controller;
        liquidVesting = vesting;
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

    // Factory Functions
    function transferOwnershipFactory(address newOwner) external onlyRole(DEFAULT_ADMIN_ROLE) {
        LiquidERC20Factory(liquidFactory).transferOwnership(newOwner);
    }

    function setLenderFactory(address _lender) external onlyRole(EXECUTOR_ROLE) {
        LiquidERC20Factory(liquidFactory).setLender(_lender);
    }

    function rawCallFactory(bytes memory data) external onlyRole(DEFAULT_ADMIN_ROLE) {
        (bool success,) = address(liquidFactory).call(data);
        require(success, "Raw call Failed.");
    }

    // Master Functions
    function transferOwnershipMaster(address newOwner) external onlyOwner {
        LiquidMaster(liquidMaster).transferOwnership(newOwner);
    }

    function setLiquidControllerMaster(address _controller) external onlyRole(EXECUTOR_ROLE) {
        LiquidMaster(liquidMaster).setLiquidController(_controller);
    }

    function setLiquidFactoryMaster(address _factory) external onlyRole(EXECUTOR_ROLE) {
        LiquidMaster(liquidMaster).setLiquidFactory(_factory);
    }

    function setVestingControllerMaster(address _controller) external onlyRole(EXECUTOR_ROLE) {
        LiquidMaster(liquidMaster).setVestingController(_controller);
    }

    function commitTransferFactoryMaster(address _newFactory) external onlyRole(PROPOSER_ROLE) {
        LiquidMaster(liquidMaster).commitTransferFactory(_newFactory);
    }

    function applyTransferFactoryMaster() external onlyRole(EXECUTOR_ROLE) {
        LiquidMaster(liquidMaster).applyTransferFactory();
    }

    function revertFactoryTransferMaster() external onlyRole(DEFAULT_ADMIN_ROLE) {
        LiquidMaster(liquidMaster).revertFactoryTransfer();
    }

    function commitTransferProposalMaster(address _newProposal) external onlyRole(PROPOSER_ROLE) {
        LiquidMaster(liquidMaster).commitTransferProposal(_newProposal);
    }

    function applyTransferProposalMaster() external onlyRole(EXECUTOR_ROLE) {
        LiquidMaster(liquidMaster).applyTransferProposal();
    }

    function revertProposalTransferMaster() external onlyRole(DEFAULT_ADMIN_ROLE) {
        LiquidMaster(liquidMaster).revertProposalTransfer();
    }

    function upgradeToMaster(address newImplementation) external onlyRole(DEPLOYER_ROLE) {
        LiquidMaster(liquidMaster).upgradeTo(newImplementation);
    }

    function rawCallMaster(bytes memory data) external onlyRole(DEFAULT_ADMIN_ROLE) {
        (bool success,) = address(liquidMaster).call(data);
        require(success, "Raw call Failed.");
    }

    // Controller Functions
    function transferOwnershipController(address newOwner) external onlyRole(DEFAULT_ADMIN_ROLE) {
        LiquidController(liquidController).transferOwnership(newOwner);
    }

    function killController() external onlyRole(DESTROYER_ROLE) {
        LiquidController(liquidController).kill();
    }

    function reviveController() external onlyRole(DESTROYER_ROLE) {
        LiquidController(liquidController).revive();
    }

    function upgradeToController(address newImplementation) external onlyRole(DEPLOYER_ROLE) {
        LiquidController(liquidController).upgradeTo(newImplementation);
    }

    function rawCallController(bytes memory data) external onlyRole(DEFAULT_ADMIN_ROLE) {
        (bool success,) = address(liquidController).call(data);
        require(success, "Raw call Failed.");
    }

    // Vesting Functions
    function transferOwnershipVesting(address newOwner) external onlyRole(DEFAULT_ADMIN_ROLE) {
        LiquidVesting(liquidVesting).transferOwnership(newOwner);
    }

    function setMasterVesting(address _master) external onlyRole(DEFAULT_ADMIN_ROLE) {
        LiquidVesting(liquidVesting).setMaster(_master);
    }

    function commitTransferMasterVesting(address _newMaster) external onlyRole(PROPOSER_ROLE) {
        LiquidVesting(liquidVesting).commitTransferMaster(_newMaster);
    }

    function applyTransferMasterVesting() external onlyRole(EXECUTOR_ROLE) {
        LiquidVesting(liquidVesting).applyTransferMaster();
    }

    function revertMasterTransfer() external onlyRole(DEFAULT_ADMIN_ROLE) {
        LiquidVesting(liquidVesting).revertMasterTransfer();
    }

    function upgradeToVesting(address newImplementation) external onlyRole(DEPLOYER_ROLE) {
        LiquidVesting(liquidVesting).upgradeTo(newImplementation);
    }

    function rawCallVesting(bytes memory data) external onlyRole(DEFAULT_ADMIN_ROLE) {
        (bool success,) = address(liquidVesting).call(data);
        require(success, "Raw call Failed.");
    }

}