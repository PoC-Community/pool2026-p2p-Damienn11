// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../src/Vault.sol";

contract MockERC20 is ERC20 {
    address public owner;

    constructor() ERC20("Mock Token", "MOCK") {
        owner = msg.sender;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == owner, "Only owner");
        _mint(to, amount);
    }
}

contract VaultTest is Test {
    MockERC20 private token;
    Vault private vault;

    address private alice = address(0xA11CE);
    address private bob = address(0xB0B);

    function setUp() public {
        token = new MockERC20();
        vault = new Vault(IERC20(address(token)));

        token.mint(alice, 1_000 ether);
        token.mint(bob, 1_000 ether);
        token.mint(address(this), 1_000 ether);
    }

    function testDepositAndPreview() public {
        uint256 depositAmount = 100 ether;

        vm.startPrank(alice);
        token.approve(address(vault), depositAmount);

        uint256 expectedShares = vault.previewDeposit(depositAmount);
        uint256 shares = vault.deposit(depositAmount);

        assertEq(shares, expectedShares);
        assertEq(vault.sharesOf(alice), shares);
        assertEq(token.balanceOf(address(vault)), depositAmount);
        vm.stopPrank();
    }

    function testYieldIncreaseShareValue() public {
        uint256 depositAmount = 100 ether;

        vm.startPrank(alice);
        token.approve(address(vault), depositAmount);
        uint256 shares = vault.deposit(depositAmount);
        vm.stopPrank();

        // Simulate yield by minting tokens directly to vault
        token.mint(address(vault), 50 ether);

        // Preview shows alice gets more assets now
        uint256 assetsPreview = vault.previewWithdraw(shares);
        assertGt(assetsPreview, depositAmount);
    }

    function testWithdrawBasic() public {
        uint256 depositAmount = 100 ether;

        vm.startPrank(alice);
        token.approve(address(vault), depositAmount);
        uint256 shares = vault.deposit(depositAmount);
        vm.stopPrank();

        vm.startPrank(alice);
        uint256 assetsOut = vault.withdraw(shares);
        vm.stopPrank();

        assertEq(assetsOut, depositAmount);
        assertEq(vault.sharesOf(alice), 0);
        assertEq(token.balanceOf(alice), 1_000 ether);
    }

    function testWithdrawAll() public {
        uint256 depositAmount = 100 ether;

        vm.startPrank(alice);
        token.approve(address(vault), depositAmount);
        vault.deposit(depositAmount);
        vm.stopPrank();

        vm.startPrank(alice);
        uint256 assetsOut = vault.withdrawAll();
        vm.stopPrank();

        assertEq(assetsOut, depositAmount);
        assertEq(vault.sharesOf(alice), 0);
        assertEq(token.balanceOf(alice), 1_000 ether);
    }

    function testCannotWithdrawMoreThanOwned() public {
        uint256 depositAmount = 100 ether;

        vm.startPrank(alice);
        token.approve(address(vault), depositAmount);
        vault.deposit(depositAmount);
        vm.stopPrank();

        vm.startPrank(bob);
        vm.expectRevert(Vault.InsufficientShares.selector);
        vault.withdraw(1 ether);
        vm.stopPrank();
    }

    function testCannotDepositZero() public {
        vm.startPrank(alice);
        vm.expectRevert(Vault.ZeroAmount.selector);
        vault.deposit(0);
        vm.stopPrank();
    }
}