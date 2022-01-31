// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Marketplace.sol";

contract Evaluator {

    string name;
    string expertise_category;

    constructor(string memory _name, string memory _expertise_category) {
        name = _name;
        expertise_category = _expertise_category;
    }

    function arbitrate_task(address _marketplace, uint task_id, bool verdict) public {
        Marketplace marketplace = Marketplace(_marketplace);
        marketplace.arbitrate_task(task_id, address(this), verdict);
    }    
}