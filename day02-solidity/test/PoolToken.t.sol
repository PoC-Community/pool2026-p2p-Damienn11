// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "../lib/forge-std/src/Test.sol";
import {PoolToken} from "../src/PoolToken.sol";

contract PoolTokenTest is Test {
    PoolToken public token;
    address public owner;
    address public user;
    uint256 public constant INITIAL_SUPPLY = 1000000 * 10**18; // 1 million tokens

    function setUp() public {
        owner = address(this);
        user = address(0x123);
        token = new PoolToken(INITIAL_SUPPLY);
    }

    function testInitialSupply() public {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
    }

    function testOnlyOwnerCanMint() public {
        vm.prank(user);
        vm.expectRevert();
        token.mint(user, 1000 ether);
    }

    function testMint() public {
        uint256 mintAmount = 1000 ether;
        token.mint(user, mintAmount);
        assertEq(token.balanceOf(user), mintAmount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + mintAmount);
    }

    function testBurn() public {
        uint256 burnAmount = 100 ether;
        token.burn(burnAmount);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - burnAmount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY - burnAmount);
    }
}