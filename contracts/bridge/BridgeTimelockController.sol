// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/governance/TimelockController.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BridgeTimelockController is TimelockController {
    constructor(
        uint256 _minDelay,
        address[] memory _proposers,
        address[] memory _executors,
        address _admin
    ) TimelockController(_minDelay, _proposers, _executors, _admin) {
        grantRole(PROPOSER_ROLE, address(this));
        grantRole(EXECUTOR_ROLE, address(this));
        grantRole(CANCELLER_ROLE, address(this));
    }

    event SourceTransferInit(
        address indexed recipient,
        address targetToken,
        uint256 targetChainId,
        uint256 value,
        bytes32 indexed commitment,
        address indexed sender,
        address sourceToken
    );

    event DestinationTransferForwarded(
        address indexed recipient,
        address targetToken,
        uint256 value,
        bytes32 indexed commitment,
        address indexed sender,
        address sourceToken,
        uint256 sourceChainId,
        address relayer
    );

    event DestinationTransferFinalized(
        bytes32 indexed commitment,
        bytes32 preImageSalt,
        address indexed sender,
        address indexed sourceToken,
        uint256 value,
        uint256 sourceChainId
    );

    function initialzeTransferToOtherChain(
        address _recipient,
        IERC20 _sourceToken,
        address _targetToken,
        uint256 _value,
        bytes32 _commitment
    ) public {
        _sourceToken.transferFrom(msg.sender, address(this), _value);
        emit SourceTransferInit(
            _recipient,
            _targetToken,
            123,
            _value,
            _commitment,
            msg.sender,
            address(_sourceToken)
        );
        bytes memory refundFundsTransaction = abi.encodeWithSelector(
            IERC20.transferFrom.selector,
            address(this),
            msg.sender,
            _value
        );
        this.schedule(
            address(_sourceToken),
            0,
            refundFundsTransaction,
            bytes32(0),
            _commitment,
            240 //Change this
        );
    }

    function forwardTransferFromOtherChain(
        address _recipient,
        IERC20 _targetToken,
        uint256 _value,
        bytes32 _commitment,
        address _sender,
        address _sourceToken,
        uint256 _sourceChainId
    ) public {
        bytes memory cancelForwarding = abi.encodeWithSelector(
            IERC20.transferFrom.selector,
            address(this),
            msg.sender,
            _value
        );
        emit DestinationTransferForwarded(
            _recipient,
            address(_targetToken),
            _value,
            _commitment,
            _sender,
            _sourceToken,
            _sourceChainId,
            msg.sender
        );
        //requires allowance first
        _targetToken.transferFrom(msg.sender, address(this), _value);
        this.schedule(
            address(_targetToken),
            0,
            cancelForwarding,
            bytes32(0),
            _commitment,
            20 //Change this
        );
    }

    function finalizeTransferFromOtherChain(
        bytes32 _commitment,
        bytes32 _preImageSalt,
        address _sourceToken,
        IERC20 _targetToken,
        address _sender,
        address _relayer,
        uint256 _value,
        uint256 _sourceChainId
    ) public {
        require(
            preimageMatchesCommitment(
                _commitment,
                _preImageSalt,
                _sender,
                address(_sourceToken),
                _value
            ),
            "Preimage does not match commitment"
        );
        emit DestinationTransferFinalized(
            _commitment,
            _preImageSalt,
            _sender,
            _sourceToken,
            _value,
            _sourceChainId
        );
        _targetToken.transfer(msg.sender, _value);
        bytes memory cancelForwarding = abi.encodeWithSelector(
            IERC20.transferFrom.selector,
            address(this),
            _relayer,
            _value
        );
        bytes32 id = this.hashOperation(
            address(_targetToken),
            0,
            cancelForwarding,
            bytes32(0),
            _commitment
        );
        this.cancel(id);
    }

    function finalizeTransferToOtherChain(
        bytes32 _commitment,
        bytes32 _preImageSalt,
        address _sender,
        IERC20 _sourceToken,
        uint256 _value
    ) public {
        require(
            preimageMatchesCommitment(
                _commitment,
                _preImageSalt,
                _sender,
                address(_sourceToken),
                _value
            ),
            "Preimage does not match commitment"
        );
        bytes memory refundFundsTransaction = abi.encodeWithSelector(
            IERC20.transferFrom.selector,
            address(this),
            _sender,
            _value
        );
        bytes32 id = this.hashOperation(
            address(_sourceToken),
            0,
            refundFundsTransaction,
            bytes32(0),
            _commitment
        );
        this.cancel(id);
    }

    function cancelForwardingToOtherChain(
        address _relayer,
        uint256 _value,
        IERC20 _targetToken,
        bytes32 _commitment
    ) public {
        bytes memory cancelForwarding = abi.encodeWithSelector(
            IERC20.transferFrom.selector,
            address(this),
            _relayer,
            _value
        );
        this.execute(
            address(_targetToken),
            0,
            cancelForwarding,
            bytes32(0),
            _commitment
        );
    }

    function abortTransferToOtherChain(
        IERC20 _sourceToken,
        uint256 _value,
        bytes32 _commitment
    ) public {
        bytes memory refundFundsTransaction = abi.encodeWithSelector(
            IERC20.transferFrom.selector,
            address(this),
            msg.sender,
            _value
        );
        this.execute(
            address(_sourceToken),
            0,
            refundFundsTransaction,
            bytes32(0),
            _commitment
        );
    }

    function preimageMatchesCommitment(
        bytes32 _commitment,
        bytes32 _preimage,
        address _sender,
        address _token,
        uint256 _amount
    ) public pure returns (bool) {
        return
            _commitment ==
            keccak256(abi.encodePacked(_preimage, _sender, _token, _amount));
    }
}
