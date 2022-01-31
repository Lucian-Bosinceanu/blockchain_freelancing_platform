// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Freelancer {

    string name;
    string expertise_category;
    uint reputation;

    constructor(string memory _name, string memory _expertise_category) {
        name = _name;
        expertise_category = _expertise_category;
        reputation = 5;
    }

    function subscribe_to_task(address payable marketplace, uint task_id) public {
        // marketplace -> subscribe_freelancer_to_task
    }

    function notify_manager(address manager, uint task_id) public {
        // manager -> mark_task_as_ready_for_evaluation
    }

    function increase_reputation() public {
        if (reputation == 10) {
            return;
        }

        reputation = reputation + 1;
    }

    function decrease_reputation() public {
        if (reputation == 1) {
            return;
        }

        reputation = reputation - 1;
    }

    function get_name() public view returns (string memory) {
        return name;
    }

    function get_expertise_category() public view returns (string memory) {
        return expertise_category;
    }

    function get_reputation() public view returns (uint) {
        return reputation;
    }
}