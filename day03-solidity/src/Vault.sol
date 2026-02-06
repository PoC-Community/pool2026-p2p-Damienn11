// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Vault is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable asset;

    // Total shares issued by the vault
    uint256 public totalShares;

    // User share balances
    mapping(address => uint256) public sharesOf;

    // Events
    event Deposit(address indexed user, uint256 assets, uint256 shares);
    event Withdraw(address indexed user, uint256 assets, uint256 shares);

    // Errors
    error ZeroAmount();
    error InsufficientShares();
    error ZeroShares();

    constructor(IERC20 _asset) Ownable(msg.sender) {
        asset = _asset;
    }

    // Convert assets -> shares. First depositor (totalShares == 0) receives 1:1 shares
    function _convertToShares(uint256 assets) internal view returns (uint256) {
        uint256 _totalShares = totalShares;
        uint256 _totalAssets = asset.balanceOf(address(this));
        if (_totalShares == 0 || _totalAssets == 0) {
            return assets;
        }
        return (assets * _totalShares) / _totalAssets;
    }

    // Convert shares -> assets. If no shares exist, return 0.
    function _convertToAssets(uint256 shares) internal view returns (uint256) {
        uint256 _totalShares = totalShares;
        if (_totalShares == 0) return 0;
        return (shares * asset.balanceOf(address(this))) / _totalShares;
    }

    // Preview how many shares would be minted for a deposit
    function previewDeposit(uint256 assets) external view returns (uint256) {
        return _convertToShares(assets);
    }

    // Preview how many assets would be returned for given shares
    function previewWithdraw(uint256 shares) external view returns (uint256) {
        return _convertToAssets(shares);
    }

    // Deposit assets and mint shares to sender
    function deposit(uint256 assets) external nonReentrant returns (uint256 shares) {
        if (assets == 0) revert ZeroAmount();

        // Calculate shares before changing balances / transferring tokens
        shares = _convertToShares(assets);
        if (shares == 0) revert ZeroShares();

        // Effects
        sharesOf[msg.sender] += shares;
        totalShares += shares;

        // Interaction: transfer tokens from user to vault
        asset.safeTransferFrom(msg.sender, address(this), assets);

        emit Deposit(msg.sender, assets, shares);
    }

    // Withdraw assets by burning shares from sender
    function withdraw(uint256 shares) public nonReentrant returns (uint256 assets) {
        if (shares == 0) revert ZeroAmount();
        if (sharesOf[msg.sender] < shares) revert InsufficientShares();

        // Calculate assets corresponding to shares (based on current vault state)
        assets = _convertToAssets(shares);

        // Effects: update accounting before external transfer
        sharesOf[msg.sender] -= shares;
        totalShares -= shares;

        // Interaction: transfer assets to the user
        asset.safeTransfer(msg.sender, assets);

        emit Withdraw(msg.sender, assets, shares);
    }

    // Convenience: withdraw all shares
    function withdrawAll() external returns (uint256 assets) {
        uint256 shares = sharesOf[msg.sender];
        if (shares == 0) revert ZeroAmount();
        assets = withdraw(shares);
    }
}
