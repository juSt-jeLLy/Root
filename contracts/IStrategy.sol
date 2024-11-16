// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IStrategy
 * @notice Interface for strategies used in the AllocationPool contract with Ether allocation support.
 */
interface IStrategy {
    /**
     * @notice Registers a recipient in the strategy.
     * @param recipient The address of the recipient to register.
     * @return recipientId The unique identifier for the registered recipient.
     */
    function registerRecipient(address recipient) external returns (uint256);

    /**
     * @notice Allocates Ether to a specific recipient.
     * @param recipientId The ID of the recipient to allocate funds to.
    
     */
    function allocate(uint256 recipientId) external payable;

    /**
     * @notice Sets milestones for a recipient.
     * @param recipientId The ID of the recipient to set milestones for.
     * @param milestones An array of milestone descriptions.
     */
    function setMilestones(uint256 recipientId, string[] calldata milestones) external;

    /**
     * @notice Submits an upcoming milestone for review.
     * @param recipientId The ID of the recipient submitting the milestone.
     * @param milestoneIndex The index of the milestone being submitted.
     */
    function submitUpcomingMilestone(uint256 recipientId, uint256 milestoneIndex) external;

    /**
     * @notice Attests to the completion of a milestone.
     * @param recipientId The ID of the recipient whose milestone is being attested.
     * @param milestoneIndex The index of the milestone being attested.
     */
    function attestMilestone(uint256 recipientId, uint256 milestoneIndex) external;

    /**
     * @notice Distributes Ether to a recipient for a completed milestone.
     * @param recipientId The ID of the recipient to distribute funds to.
     * @param milestoneIndex The index of the milestone being distributed.
     */
    function distribute(uint256 recipientId, uint256 milestoneIndex) external;
}
