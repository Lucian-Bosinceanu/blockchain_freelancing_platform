// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */

import "./Manager.sol";
import "./Evaluator.sol";
import "./Freelancer.sol";
import "./Funder.sol";
import "./Token.sol";
import "./utils.sol";


enum TaskState {Funding, Open, Executing, Evaluation, Arbitration, Success, Fail, Canceled}

struct FunderContribution{
    uint256 sum;
    Funder funder;
}

struct Task {
    uint task_id;
    bool isPresent;
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
    mapping(address => Freelancer) subscribed_freelancers;
    address[] freelancer_addresses;
}

contract Marketplace {
    mapping(uint => Task) tasks;
    mapping(address => Freelancer) freelancers;
    address[] freelancers_addresses;
    mapping(address => Manager) managers;
    mapping(address => Evaluator) evaluators;
    mapping(address => Funder) funders;

    Token token;

    uint last_task_id;

    constructor(address _token) {
        last_task_id = 1;
        token = Token(_token);
    }

    function create_task(
        address manager, 
        string calldata description, 
        string calldata domain,
        uint256 freelancer_reward,
        uint256 evaluator_reward) public {

        last_task_id += 1;
        Task storage task = tasks[last_task_id];
        task.task_id = last_task_id;
        task.state = TaskState.Open;
        task.description = description;
        task.domain = domain;
        task.manager = Manager(manager);
        task.freelancer_reward = freelancer_reward;
        task.evaluator_reward = evaluator_reward;
    }

    // function list_tasks() public returns (Task[] memory) {
    //     Task[] memory task_values;
    //     for (uint i = 0; i < tasks_ids.length; i++){
    //         Task memory current_task = tasks[tasks_ids[i]];
    //         task_values.push(Task({
    //             task_id: current_task.task_id,
    //             state: current_task.state,
    //             description: current_task.description,
    //             domain: current_task.domain,
    //             manager: current_task.manager,
    //             freelancer_reward: current_task.freelancer_reward,
    //             evaluator_reward: current_task.evaluator_reward,
    //             funders: current_task.funders,
    //             evaluator: current_task.evaluator,
    //             executor_freelancer: current_task.executor_freelancer,
    //             subscribed_freelancers: current_task.subscribed_freelancers
    //         }));
    //     }
    //     return task_values;
    // }

    function add_freelancer(address freelancer) public {
        require(freelancers[freelancer] == Freelancer(address(0x0)), "Freelancer already registered.");
        freelancers[freelancer] = Freelancer(freelancer);
        freelancers_addresses.push(freelancer);
    }

    function list_freelancers() public view returns (Freelancer[] memory) {
        Freelancer[] memory freelancers_to_return = new Freelancer[](freelancers_addresses.length);
        Freelancer current_freelancer;
        for (uint i = 0; i < freelancers_addresses.length; i++){
            current_freelancer = freelancers[freelancers_addresses[i]];
            freelancers_to_return[i] = current_freelancer;
        }
        return freelancers_to_return;
    }

    function add_manager(address manager) public {
        managers[manager] = Manager(manager);
    }

    function add_evaluator(address evaluator) public {
        evaluators[evaluator] = Evaluator(evaluator);
    }

    function add_funder(address funder) public {
        funders[funder] = Funder(funder);
    }

    function add_funder_contribution_to_task(
        uint task_id,
        address funder,
        uint256 sum
    ) public {
        Task storage task = tasks[task_id];
        require(tasks[task_id].state == TaskState.Open, "The task is not open anymore.");
        require(address(funders[funder]) != address(0x0), "The funder is not registered in the marketplace.");

        uint payover = 0;
        uint totalContributions = 0;
        for (uint i=0; i < task.funders.length; i++) {
            totalContributions += task.funders[i].sum;
        }

        if (totalContributions >= (task.freelancer_reward + task.evaluator_reward)) {
            revert("The contribution sum was already reached.");
            // already done
        }

        if (sum > (task.freelancer_reward + task.evaluator_reward)) {
            // need to send some tokens back to the funder
            payover = sum - (task.freelancer_reward + task.evaluator_reward);
        }

        FunderContribution memory contribution = FunderContribution({sum: sum - payover, funder: funders[funder]});
        task.funders.push(contribution);
        token.transferFrom(funder, address(tasks[task_id].executor_freelancer), task.freelancer_reward);
    }

    function assign_evaluator(
        uint task_id,
        address manager,
        address evaluator
    ) public {
        require(tasks[task_id].state == TaskState.Open, "Task is not in OPEN state.");
        require(abi.encodePacked(managers[manager]).length > 0, "Manager is not registered.");
        require(tasks[task_id].manager == managers[manager], "Caller manager is not the same as the task manager.");
        require(abi.encodePacked(evaluators[evaluator]).length > 0, "Evaluator does not exist.");
        require(keccak256(abi.encodePacked(evaluators[evaluator].get_expertise_category())) == keccak256(abi.encodePacked(tasks[task_id].domain)), "Evaluator expertise and task domain are different.");

        tasks[task_id].evaluator = Evaluator(evaluator);
    }

    function subscribe_freelancer_to_task(
        uint task_id,
        address freelancer) public {
            require(tasks[task_id].isPresent, "Subscribe freelancer method called on invalid task id.");
            require(tasks[task_id].state == TaskState.Open, "Task is not in OPEN state.");
            require(abi.encodePacked(freelancers[freelancer]).length > 0, "Freelancer is not registered.");
            require(token.balanceOf(freelancer) > tasks[task_id].evaluator_reward, "The freelancer does not have enough tokens for the guarantee");
            require(keccak256(abi.encodePacked(freelancers[freelancer].get_expertise_category())) == keccak256(abi.encodePacked(tasks[task_id].domain)), "Freelancer expertise and task domain are different.");

            tasks[task_id].subscribed_freelancers[freelancer] = freelancers[freelancer];
            tasks[task_id].freelancer_addresses.push(freelancer);
            token.transferFrom(freelancer, address(this), tasks[task_id].evaluator_reward);
        }

    function assign_freelancer(
        uint task_id,
        address _manager,
        address _freelancer
    ) public {
        require(tasks[task_id].isPresent, "Assign freelancer method called on invalid task id.");
        require(tasks[task_id].state == TaskState.Open, "Task is not in OPEN state.");
        require(abi.encodePacked(freelancers[_freelancer]).length > 0, "Freelancer is not registered.");
        require(abi.encodePacked(managers[_manager]).length > 0, "Manager is not registered.");
        require(tasks[task_id].manager == managers[_manager], "Caller manager is not the same as the task manager.");
        require(tasks[task_id].subscribed_freelancers[_freelancer] == freelancers[_freelancer], "Chosen freelancer is not subscribed to task.");

        tasks[task_id].state = TaskState.Executing;
        tasks[task_id].executor_freelancer = freelancers[_freelancer];
        

        for (uint i=0; i<tasks[task_id].freelancer_addresses.length; i++) {
            address freelancer_address = tasks[task_id].freelancer_addresses[i];
            if (freelancer_address != _freelancer) {
                token.transferFrom(address(this), freelancer_address, tasks[task_id].freelancer_reward);
            }
        }
    }

    function mark_task_as_ready_for_evaluation(
        uint task_id,
        address _manager,
        address _freelancer
    ) public {
        require(tasks[task_id].state == TaskState.Executing, "This task is not in the right state to be marked in Evaluation!");
        require(address(tasks[task_id].manager) == _manager, "The task cannot be marked in evaluation by this manager!");
        require(address(tasks[task_id].executor_freelancer) == _freelancer, "The task was not executed by this freelancer!");

        tasks[task_id].state = TaskState.Evaluation;
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