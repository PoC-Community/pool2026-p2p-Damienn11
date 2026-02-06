// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "../lib/forge-std/src/Test.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {PoolToken} from "../src/PoolToken.sol";

contract PoolTokenTest is Test {
    PoolToken private token;
    address private owner;
    address private user;

    uint256 private constant INITIAL_SUPPLY = 1_000 ether;

    function setUp() public {
        owner = address(this);
        user = address(0xBEEF);
        token = new PoolToken(INITIAL_SUPPLY);
    }

    function testInitialSupply() public view {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
    }

    function testOnlyOwnerCanMint() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user));
        token.mint(user, 1_000 ether);
    }
}