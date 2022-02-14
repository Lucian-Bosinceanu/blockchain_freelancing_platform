// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Marketplace.sol";
import "./Manager.sol";
import "./Token.sol";

contract Freelancer {
    string name;
    string expertise_category;
    uint reputation;
    Marketplace marketplace;

    constructor(string memory _name,
        string memory _expertise_category,
        address _marketplace,
        address token
    ) {
        name = _name;
        expertise_category = _expertise_category;
        reputation = 5;
        marketplace = Marketplace(_marketplace);
        marketplace.add_freelancer(address(this));
        Token(token).approve(_marketplace, 100000);
    }
    
    function subscribe_to_task(uint task_id) public {
        marketplace.subscribe_freelancer_to_task(task_id, (address(this)));
    }

    function notify_manager(address _marketplace, uint task_id, address _manager) public {
        Manager manager = Manager(_manager);
        manager.mark_task_as_ready_for_evaluation(_marketplace, task_id, address(this));
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