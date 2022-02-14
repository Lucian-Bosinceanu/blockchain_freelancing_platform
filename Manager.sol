// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Marketplace.sol";

contract Manager {
    function create_task(
        address marketplace, 
        string calldata description,
        string calldata domain,
        uint256 freelancer_reward,
        uint256 evaluator_reward) public {
        Marketplace(marketplace).create_task(address(this), description, domain, freelancer_reward, evaluator_reward);
    }

    function assign_evaluator(
        address payable marketplace, 
        uint task_id, 
        address payable evaluator
        ) public {
            Marketplace(marketplace).assign_evaluator(task_id, address(this), evaluator);
        }

    function assign_freelancer(
        address payable marketplace, 
        uint task_id, 
        address payable freelancer
        ) public {
            Marketplace(marketplace).assign_freelancer(task_id, address(this), freelancer);
        }

    function evaluate_task(
        address payable marketplace, 
        uint task_id, 
        bool decision
        ) public {
            Marketplace(marketplace).evaluate_task(task_id, address(this), decision);
        }

    function mark_task_as_ready_for_evaluation(
        address marketplace, 
        uint task_id,
        address freelancer) public {
            Marketplace(marketplace).mark_task_as_ready_for_evaluation(task_id, address(this), freelancer);
        }
}