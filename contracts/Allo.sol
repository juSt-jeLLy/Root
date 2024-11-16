// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IStrategy.sol";


contract Allo {
    struct Pool {
        address strategy;
        bool isActive;
    }

    struct Recipient {
        uint256 id;
        address addr;
        uint256 balance; // Balance to track Ether allocated to the recipient
    }

    mapping(uint256 => Pool) public pools;
    mapping(uint256 => Recipient) public recipients;

    uint256 public poolCount;
    uint256 public recipientCount;

    event PoolCreated(uint256 poolId, address strategy);
    event RecipientRegistered(uint256 recipientId, address recipient);
    event Allocation(uint256 recipientId, uint256 amount);
    event MilestonesSet(uint256 recipientId);
    event MilestoneSubmitted(uint256 recipientId, uint256 milestoneIndex);
    event MilestoneAttested(uint256 recipientId, uint256 milestoneIndex);
    event Distribution(uint256 recipientId, uint256 milestoneIndex);
    event PoolClosed(uint256 poolId);

    modifier onlyActivePool(uint256 poolId) {
        require(pools[poolId].isActive, "Pool is inactive");
        _;
    }

    // Create a pool with a specified strategy
    function createPool(address strategy) external returns (uint256) {
        poolCount++;
        pools[poolCount] = Pool({strategy: strategy, isActive: true});
        emit PoolCreated(poolCount, strategy);
        return poolCount;
    }

    // Register a recipient with a specific pool
    function registerRecipient(uint256 poolId) external onlyActivePool(poolId) returns (uint256) {
        address strategy = pools[poolId].strategy;
        uint256 recipientId = IStrategy(strategy).registerRecipient(msg.sender);

        recipientCount++;
        recipients[recipientCount] = Recipient({
            id: recipientId,
            addr: msg.sender,
            balance: 0 // Initially set recipient balance to 0
        });
        emit RecipientRegistered(recipientId, msg.sender);

        return recipientId;
    }

    // Allocate Ether to a recipient in a specific pool
    function allocate(uint256 poolId,   uint256 recipientId) external payable onlyActivePool(poolId) {
        require(msg.value > 0, "Must send Ether to allocate");
        
        address strategy = pools[poolId].strategy;
        IStrategy(strategy).allocate{value: msg.value}(recipients[recipientId].id);
    

        // Update recipient's Ether balance
        recipients[recipientId].balance += msg.value;

        emit Allocation(recipientId, msg.value);
    }

    // Set milestones for a recipient
    function setMilestones(uint256 poolId, uint256 recipientId, string[] calldata milestones) external onlyActivePool(poolId) {
        address strategy = pools[poolId].strategy;
        IStrategy(strategy).setMilestones(recipients[recipientId].id, milestones);
        emit MilestonesSet(recipientId);
    }

    // Submit an upcoming milestone for a recipient
    function submitUpcomingMilestone(uint256 poolId, uint256 recipientId, uint256 milestoneIndex) external onlyActivePool(poolId) {
        address strategy = pools[poolId].strategy;
        IStrategy(strategy).submitUpcomingMilestone(recipients[recipientId].id, milestoneIndex);
        emit MilestoneSubmitted(recipientId, milestoneIndex);
    }

    // Attest to a completed milestone for a recipient
    function attestMilestone(uint256 poolId, uint256 recipientId, uint256 milestoneIndex) external onlyActivePool(poolId) {
        address strategy = pools[poolId].strategy;
        IStrategy(strategy).attestMilestone(recipients[recipientId].id, milestoneIndex);
        emit MilestoneAttested(recipientId, milestoneIndex);
    }

    // Distribute Ether to a recipient for a completed milestone
    function distribute(uint256 poolId, uint256 recipientId, uint256 milestoneIndex) external onlyActivePool(poolId) {
        address strategy = pools[poolId].strategy;
        IStrategy(strategy).distribute(recipients[recipientId].id, milestoneIndex);
        
        uint256 amountToDistribute = recipients[recipientId].balance;
        require(amountToDistribute > 0, "No funds to distribute");

        // Transfer the allocated Ether to the recipient
        payable(recipients[recipientId].addr).transfer(amountToDistribute);

        // Reset the recipient's balance after distribution
        recipients[recipientId].balance = 0;

        emit Distribution(recipientId, milestoneIndex);
    }

    // Set the pool as active or inactive
    function setPoolActive(uint256 poolId, bool isActive) external {
        pools[poolId].isActive = isActive;
        if (!isActive) {
            emit PoolClosed(poolId);
        }
    }

    // Fallback function to accept Ether directly (for allocation and transfers)
    receive() external payable {}
}
