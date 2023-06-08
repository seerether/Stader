pragma solidity 0.8.16;

import './library/UtilLib.sol';
// Import other contract dependencies...

contract StaderOracle {
    mapping(address => uint256) public reputation;
    uint256 public constant PENALTY_THRESHOLD = 10; // Reputation threshold for penalties

    // Existing contract code...

    function submitSDPrice(SDPriceData calldata _sdPriceData) external override trustedNodeOnly checkMinTrustedNodes {
        // Existing code...

        // Check reputation of the submitting node
        if (reputation[msg.sender] < PENALTY_THRESHOLD) {
            // Apply penalty for low reputation
            applyPenalty(msg.sender);
        }

        // Existing code...
    }

    function applyPenalty(address _nodeAddress) internal {
        // Apply penalty logic here
        // For example, you can reduce the reputation or impose a temporary ban

        // Reduce the reputation of the node
        reputation[_nodeAddress]--;

        // Emit penalty event
        emit PenaltyApplied(_nodeAddress);
    }

    function rewardNode(address _nodeAddress) internal {
        // Reward logic here
        // For example, you can increase the reputation or provide incentives

        // Increase the reputation of the node
        reputation[_nodeAddress]++;

        // Emit reward event
        emit RewardGiven(_nodeAddress);
    }
}
