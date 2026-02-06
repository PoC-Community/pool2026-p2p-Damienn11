// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/PoolToken.sol";
import "../src/Example4626Vault.sol";

contract Example4626Test is Test {
    PoolToken token;
    Example4626Vault vault;

    function setUp() public {
        token = new PoolToken(1_000_000 ether);
        vault = new Example4626Vault(IERC20(address(token)), "Vault Share", "vSHARE");

        // send some tokens to user (address(1))
        token.transfer(address(1), 1_000 ether);
    }

    function testDepositAndPreview() public {
        uint256 depositAmount = 100 ether;

        // approve vault from user
        vm.prank(address(1));
        token.approve(address(vault), depositAmount);

        // preview
        uint256 expectedShares = vault.previewDeposit(depositAmount);

        // deposit
        vm.prank(address(1));
        vault.deposit(depositAmount, address(1));

        // check shares minted
        assertEq(vault.balanceOf(address(1)), expectedShares);
        assertEq(vault.totalAssets(), depositAmount);
    }

    function testYieldAndWithdraw() public {
        uint256 depositAmount = 100 ether;

        vm.prank(address(1));
        token.approve(address(vault), depositAmount);

        vm.prank(address(1));
        vault.deposit(depositAmount, address(1));

        // simulate yield: mint tokens to vault (test contract is owner of PoolToken)
        token.mint(address(vault), 10 ether);

        // now each share is worth more
        uint256 shares = vault.balanceOf(address(1));
        uint256 assetsBefore = vault.convertToAssets(shares);
        assertGt(assetsBefore, depositAmount);

        // withdraw the assets
        vm.prank(address(1));
        // owner is address(1), so call withdraw directly
        vault.withdraw(depositAmount, address(1), address(1));

        // after withdraw, vault assets decreased
        assertEq(vault.totalAssets(), 10 ether);
    }
}
