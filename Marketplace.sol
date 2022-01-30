// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */

import "./Manager.sol";
import "./Evaluator.sol";
import "./Freelancer.sol";
import "./Funder.sol";

contract Marketplace {

    enum TaskState {Funding, Open, Executing, Evaluation, Arbitration, Success, Fail, Cancel}

    struct FunderContribution{
        uint256 sum;
        Funder funder;
    }

    struct Task {
        uint task_id;
        TaskState state;
        string description;
        uint256 freelancer_reward;
        uint256 evaluator_reward;
        string domain;
        address payable manager;

        // maybe use mapping here
        FunderContribution[] funders;

        Evaluator evaluator;
        Freelancer executor_freelancer;
        Freelancer[] subscribed_freelancers;
    }

    mapping(uint => Task) tasks;
    mapping(address => Freelancer) freelancers;
    mapping(address => Manager) managers;
    mapping(address => Evaluator) evaluators;
    mapping(address => Funder) funders;

    function create_task(
        address payable manager, 
        string description, 
        string domain,
        uint256 freelancer_reward,
        uint256 evaluator_reward) public {}

    function list_tasks() public {}

    function add_freelancer(address payable freelancer) public {
        // add to freelancers mapping
    }

    function add_manager(address payable manager) public {
        // add to managers mapping
    }

    function add_evaluator(address payable evaluator) public {
        // add to evaluators mapping
    }

    function add_funder(address payable funder) public {
        // add to funders mapping
    }

    function add_funder_contribution_to_task(
        uint task_id,
        address payable funder,
        uint256 sum
    ) public {
        // require task.state in Funding
        // require funder in funders
        // require funder has sum

        // add funder to task funders
    }

    function assign_evaluator(
        uint task_id,
        address payable manager,
        address payable evaluator
    ) public {
        // require task.state in Open
        // require manager in managers
        // require task.manager = request manager
        // require evaluator in evaluators
        // require evaluator.expertise_category = task.domain
    }

    function subscribe_freelancer_to_task(
        uint task_id,
        address payable freelancer) public {
            // require task.state in Open
            // require freelancer in freelancers
            // require freelancer.expertise_category = task.domain

            // add freelancer in task.freelancers
            // get freelancer guarantee = evaluator_reward
        }
    )

    function assign_freelancer(
        uint task_id,
        address payable manager,
        address payable freelancer
    ) public {
        // require task.state in Open
        // require task.manager = manager
        // require freelancer in task.subscribed_freelancers

        // change task.State to Executing
        // set task executor_freelancer as the freelancer from the request
        // return guarantees of other freelancers
    }

    function mark_task_as_ready_for_evaluation(
        uint task_id.
        address payable manager
    ) public {
        // require task.state in Executing
        // require task.manager = manager

        // set task.state to Evaluation
    }

    function evaluate_task(
        uint task_id,
        address payable manager,
        bool verdict
    ) public {
        // require task.state in Evaluation
        // require task.manager = manager

        //if verdict == true -> handle_task_evaluation_success(task_id)
        //else set task.state = Arbitration
    }

    function handle_task_evaluation_success(uint task_id) private {
        // mark task.state as Success
        // pay freelancer_reward + evaluator_reward + freelancer_guarantee to the freelancer
        // increase freelancer reputation
    }

    function arbitrate_task(
        uint task_id,
        address payable evaluator,
        bool verdict
    ) public {
        // require task.state in Arbitration
        // require task.evaluator = evaluator

        // if verdict == true -> handle_task_arbitration_success(task_id)
        // else handle_task_arbitration_fail(task_id)
    }

    function handle_task_arbitration_success(task_id) private {
        // send freelancer_reward + guarantee to freelancer
        // increase freelancer reputation
        // send evaluator_reward to evaluator
        // mark task.state as Success

    }

    function handle_task_arbitration_fail private {
        // return freelancer_reward + evaluator_reward to funders
        // decrease freelancer reputation
        // send freelancer guarantee to evaluator
        // mark task.state as Fail
    }

    function cancel_task(
        uint task_id,
        address payable manager
    ) public {
        // require task.state in Funding
        // require task.manager = manager
        
        // return contributions back to funders
        // mark task as Canceled
    }
}