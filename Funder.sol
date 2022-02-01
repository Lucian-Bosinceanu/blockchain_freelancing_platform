// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Marketplace.sol";

contract Funder {

    constructor(address _marketplace) {
        Marketplace marketplace = Marketplace(_marketplace);
        marketplace.add_funder((address(this)));
    }

    function fund_task(address _marketplace, uint task_id, uint256 sum) public {
        Marketplace marketplace = Marketplace(_marketplace);
        marketplace.add_funder_contribution_to_task(task_id, address(this), sum);
    }

}