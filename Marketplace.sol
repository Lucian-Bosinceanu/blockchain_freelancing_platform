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
import "./Token.sol";

contract Marketplace {

    enum TaskState {Funding, Open, Executing, Evaluation, Arbitration, Success, Fail, Canceled}

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

        // maybe use mapping here
        FunderContribution[] funders;

        Manager manager;
        Evaluator evaluator;
        Freelancer executor_freelancer;
        Freelancer[] subscribed_freelancers;
    }

    mapping(uint => Task) tasks;
    mapping(address => Freelancer) freelancers;
    mapping(address => Manager) managers;
    mapping(address => Evaluator) evaluators;
    mapping(address => Funder) funders;

    Token token;

    function create_task(
        address payable manager, 
        string memory description, 
        string memory domain,
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
        uint task_id,
        address payable manager
    ) public {
        // require task.state in Executing
        // require task.manager = manager

        // set task.state to Evaluation
    }

    function evaluate_task(
        uint task_id,
        address _manager,
        bool verdict
    ) public {
        require(tasks[task_id].task_id == task_id, "There is no task with this id!");
        require(tasks[task_id].state == TaskState.Evaluation, "This task is not in the right state to be evaluated!");
        require(address(tasks[task_id].manager) == _manager, "The task cannot be evaluated by this manager!");

        if (verdict == true) {
            handle_task_arbitration_success(task_id);
        } 
        else {
            tasks[task_id].state = TaskState.Arbitration;
        }
    }

    function handle_task_evaluation_success(uint task_id) private {        
        // mark task.state as Success
        // pay freelancer_reward + evaluator_reward + freelancer_guarantee to the freelancer
        // increase freelancer reputation

        tasks[task_id].state = TaskState.Success;

        uint256 reward = tasks[task_id].freelancer_reward + 2 * tasks[task_id].evaluator_reward;

        token.transferFrom(address(this), address(tasks[task_id].executor_freelancer), reward);
        tasks[task_id].executor_freelancer.increase_reputation();
    }

    function arbitrate_task(
        uint task_id,
        address _evaluator,
        bool verdict
    ) public {
        require(tasks[task_id].task_id == task_id, "There is no task with this id!");
        require(tasks[task_id].state == TaskState.Arbitration, "This task is not in the right state to be arbitrated!");
        require(address(tasks[task_id].evaluator) == _evaluator, "The task cannot be evaluated by this evaluator!");

        if (verdict == true) {
            handle_task_arbitration_success(task_id);
        } 

        handle_task_arbitration_fail(task_id);
    }

    function handle_task_arbitration_success(uint task_id) private {
        // send freelancer_reward + guarantee to freelancer
        // increase freelancer reputation
        // send evaluator_reward to evaluator
        // mark task.state as Success

        tasks[task_id].state = TaskState.Success;

        uint256 freelancer_reward = tasks[task_id].freelancer_reward + tasks[task_id].evaluator_reward;
        uint256 evaluator_reward = tasks[task_id].evaluator_reward;

        token.transferFrom(address(this), address(tasks[task_id].executor_freelancer), freelancer_reward);
        token.transferFrom(address(this), address(tasks[task_id].evaluator), evaluator_reward);
        tasks[task_id].executor_freelancer.increase_reputation();
    }

    function handle_task_arbitration_fail(uint task_id) private {
        // return freelancer_reward + evaluator_reward to funders
        // decrease freelancer reputation
        // send freelancer guarantee to evaluator
        // mark task.state as Fail

        tasks[task_id].state = TaskState.Fail;
        tasks[task_id].executor_freelancer.decrease_reputation();

        uint256 evaluator_reward = tasks[task_id].evaluator_reward;
        token.transferFrom(address(this), address(tasks[task_id].evaluator), evaluator_reward);

        uint fundersLength = tasks[task_id].funders.length;

        for (uint i=0; i < fundersLength; i++) {
            token.transferFrom(
                address(this), 
                address(tasks[task_id].funders[i].funder), 
                tasks[task_id].funders[i].sum
                );
        }
    }

    function cancel_task(
        uint task_id,
        address _manager
    ) public {
        require(tasks[task_id].task_id == task_id, "There is no task with this id!");
        require(tasks[task_id].state == TaskState.Funding, "This task is not in the right state to be canceled!");
        require(address(tasks[task_id].manager) == _manager, "The task cannot be canceled by this manager!");
        
        // return contributions back to funders
        // mark task as Canceled

        uint fundersLength = tasks[task_id].funders.length;

        for (uint i=0; i < fundersLength; i++) {
            token.transferFrom(
                address(this), 
                address(tasks[task_id].funders[i].funder), 
                tasks[task_id].funders[i].sum
                );
        }

        tasks[task_id].state = TaskState.Canceled;
    }
}