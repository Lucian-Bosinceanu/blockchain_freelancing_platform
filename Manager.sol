// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Marketplace.sol";

contract Manager {

    address marketplace;

    constructor(address _marketplace) {
        marketplace = _marketplace;
        Marketplace(marketplace).add_manager((address(this)));
    }

    function create_task(
        string memory description,
        string memory domain,
        uint256 freelancer_reward,
        uint256 evaluator_reward) public {
             Marketplace(marketplace).create_task(address(this), description, domain, freelancer_reward, evaluator_reward);
        }

    function assign_evaluator(
        uint task_id, 
        address evaluator
        ) public {
             Marketplace(marketplace).assign_evaluator(task_id, address(this), evaluator);
        }

    function assign_freelancer(
        uint task_id, 
        address freelancer
        ) public {
             Marketplace(marketplace).assign_freelancer(task_id, address(this), freelancer);
        }

    function evaluate_task(
        uint task_id, 
        bool decision
        ) public {
             Marketplace(marketplace).evaluate_task(task_id, address(this), decision);
        }

    function mark_task_as_ready_for_evaluation(
        uint task_id,
        address freelancer) public {
             Marketplace(marketplace).mark_task_as_ready_for_evaluation(task_id, address(this), freelancer);
        }
}