// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IStrategy.sol";

contract RFPSimpleStrategy is IStrategy {
    struct Recipient {
        address addr;
        string[] milestones;
        uint256 milestoneIndex;
        uint256 balance;  // Balance of Ether allocated to the recipient
        bool active;
    }

    mapping(uint256 => Recipient) public recipients;
    uint256 public recipientCount;

    event Allocation(uint256 recipientId, uint256 amount);
    event Distribution(uint256 recipientId, uint256 amount);
    event MilestonesSet(uint256 recipientId, string[] milestones);

    /**
     * @notice Registers a recipient in the strategy.
     * @param recipient The address of the recipient to register.
     * @return recipientId The unique identifier for the registered recipient.
     */
    function registerRecipient(address recipient) external override returns (uint256) {
        recipientCount++;
        recipients[recipientCount] = Recipient({
            addr: recipient,
            milestones: new string[](0),
            milestoneIndex: 0,
            balance: 0,
            active: true
        });
        return recipientCount;
    }

    /**
     * @notice Allocates Ether to a specific recipient.
     * @param recipientId The ID of the recipient to allocate funds to.
     */
    function allocate(uint256 recipientId) external override payable {
        require(recipients[recipientId].active, "Recipient is not active");
        require(msg.value > 0, "Must send Ether to allocate");

        // Add the Ether sent to the recipient's balance
        recipients[recipientId].balance += msg.value;

        emit Allocation(recipientId, msg.value);
    }

    /**
     * @notice Sets milestones for a recipient.
     * @param recipientId The ID of the recipient to set milestones for.
     * @param milestones An array of milestone descriptions.
     */
    function setMilestones(uint256 recipientId, string[] calldata milestones) external override {
        require(recipients[recipientId].active, "Recipient is not active");
        
        // Clear existing milestones
        delete recipients[recipientId].milestones;
        
        // Copy milestones one by one
        for (uint256 i = 0; i < milestones.length; i++) {
            recipients[recipientId].milestones.push(milestones[i]);
        }
        
        emit MilestonesSet(recipientId, milestones);
    }

    /**
     * @notice Submits an upcoming milestone for review.
     * @param recipientId The ID of the recipient submitting the milestone.
     * @param milestoneIndex The index of the milestone being submitted.
     */
    function submitUpcomingMilestone(uint256 recipientId, uint256 milestoneIndex) external override view {
        require(recipients[recipientId].active, "Recipient is not active");
        require(milestoneIndex < recipients[recipientId].milestones.length, "Invalid milestone index");
        require(milestoneIndex == recipients[recipientId].milestoneIndex, "Milestone not in order");

        // Logic to submit the milestone (e.g., for review)
    }

    /**
     * @notice Attests to the completion of a milestone.
     * @param recipientId The ID of the recipient whose milestone is being attested.
     * @param milestoneIndex The index of the milestone being attested.
     */
    function attestMilestone(uint256 recipientId, uint256 milestoneIndex) external override {
        require(recipients[recipientId].active, "Recipient is not active");
        require(milestoneIndex == recipients[recipientId].milestoneIndex, "Milestone not in order");

        // Attestation logic: mark the milestone as completed
        recipients[recipientId].milestoneIndex++;
    }

    /**
     * @notice Distributes Ether to a recipient for a completed milestone.
     * @param recipientId The ID of the recipient to distribute funds to.
     * @param milestoneIndex The index of the milestone being distributed.
     */
    function distribute(uint256 recipientId, uint256 milestoneIndex) external override {
        require(recipients[recipientId].active, "Recipient is not active");
        require(milestoneIndex < recipients[recipientId].milestoneIndex, "Milestone not yet completed");

        uint256 amountToDistribute = recipients[recipientId].balance;
        require(amountToDistribute > 0, "No funds to distribute");

        // Transfer the allocated Ether to the recipient
        payable(recipients[recipientId].addr).transfer(amountToDistribute);

        // Reset recipient balance after distribution
        recipients[recipientId].balance = 0;

        emit Distribution(recipientId, amountToDistribute);
    }

    // Optional: Withdraw contract's balance (if needed for contract maintenance)
    function withdraw(uint256 amount) external {
        payable(msg.sender).transfer(amount);
    }

    // Fallback function to accept Ether directly (e.g., for donations or manual deposits)
    receive() external payable {}
}