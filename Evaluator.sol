// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Marketplace.sol";

contract Evaluator {

    string name;
    string expertise_category;
    address marketplace;

    constructor(string memory _name, string memory _expertise_category, address _marketplace) {
        name = _name;
        expertise_category = _expertise_category;
        marketplace = _marketplace;

        Marketplace(marketplace).add_evaluator((address(this)));
    }

    function arbitrate_task(uint task_id, bool verdict) public {
        Marketplace(marketplace).arbitrate_task(task_id, address(this), verdict);
    }    

    function get_name() public view returns (string memory) {
        return name;
    }

    function get_expertise_category() public view returns (string memory) {
        return expertise_category;
    }
}