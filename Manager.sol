// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Marketplace.sol";

contract Manager {
    function create_task(
        address payable marketplace, 
        string memory description,
        string memory domain,
        uint256 freelancer_reward,
        uint256 evaluator_reward) public {}

    function assign_evaluator(
        address payable marketplace, 
        uint task_id, 
        address payable evaluator
        ) public {
            // calls marketplace -> assign_evaluator
        }

    function assign_freelancer(
        address payable marketplace, 
        uint task_id, 
        address payable freelancer
        ) public {
            // calls marketplace -> assign_freelancer
        }

    function evaluate_task(
        address _marketplace, 
        uint task_id, 
        bool decision
        ) public {
            Marketplace marketplace = Marketplace(_marketplace);
            marketplace.evaluate_task(task_id, address(this), decision);
        }

    function mark_task_as_ready_for_evaluation(
        address payable marketplace, 
        uint task_id,
        address payable freelancer) public {
            // calls marketplace -> mark_task_as_ready_for_evaluation
        }
}