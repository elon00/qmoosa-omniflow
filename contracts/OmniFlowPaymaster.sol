// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title OmniFlowPaymaster
 * @dev ERC-4337 Account Abstraction Paymaster for ETHGlobal Mumbai
 * @notice Provides gas sponsorship and intent-based cross-L2 payment routing.
 */
contract OmniFlowPaymaster {
    address public owner;
    mapping(address => uint256) public sponsorBalances;
    mapping(bytes32 => bool) public executedIntents;

    event GasSponsored(address indexed user, uint256 actualGasCost);
    event IntentSettled(bytes32 indexed intentHash, address indexed recipient, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function depositSponsorship() external payable {
        sponsorBalances[msg.sender] += msg.value;
    }

    function executePaymentIntent(
        bytes32 intentHash,
        address recipient,
        uint256 amount,
        bytes calldata signature
    ) external {
        require(!executedIntents[intentHash], "Intent already fulfilled");
        require(signature.length >= 64, "Invalid signature length");

        executedIntents[intentHash] = true;
        payable(recipient).transfer(amount);

        emit IntentSettled(intentHash, recipient, amount);
    }
}
