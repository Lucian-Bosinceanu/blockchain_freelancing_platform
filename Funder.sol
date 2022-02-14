// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Marketplace.sol";
import "./Token.sol";

contract Funder {

    Marketplace marketplace;
    event StartingFunding();

    constructor(address _marketplace, address token) payable {
        marketplace = Marketplace(_marketplace);
        marketplace.add_funder(address(this));
        Token(token).approve(_marketplace, 100000);
    }

    function fund_task(uint task_id, uint256 sum) public payable {
        emit StartingFunding();
        marketplace.add_funder_contribution_to_task(task_id, address(this), sum);
    }
}
