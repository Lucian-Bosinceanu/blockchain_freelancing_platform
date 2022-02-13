// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Marketplace.sol";

contract Funder {

    address marketplace;

    constructor(address _marketplace) {
        marketplace = _marketplace;
        Marketplace(marketplace).add_funder((address(this)));
    }

    function fund_task(uint task_id, uint256 sum) public {
        Marketplace(marketplace).add_funder_contribution_to_task(task_id, address(this), sum);
    }

}