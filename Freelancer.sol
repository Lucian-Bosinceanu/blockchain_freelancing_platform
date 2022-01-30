// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Freelancer {

    string name;
    string expertise_category;
    uint reputation;

    function subscribe_to_task(address payable marketplace, uint task_id) public {
        // marketplace -> subscribe_freelancer_to_task
    }

    function notify_manager(address manager, uint task_id) public {
        // manager -> mark_task_as_ready_for_evaluation
    }

    function increase_reputation() public {
        // ignore if reputation = 10
    }

    function decrease_reputation() public {
        // ignore if reputation = 1
    }
}