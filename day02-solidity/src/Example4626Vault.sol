// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Example4626Vault is ERC20 {
    IERC20 public immutable asset;

    constructor(IERC20 _asset, string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        asset = _asset;
    }

    // Total underlying assets held by the vault
    function totalAssets() public view returns (uint256) {
        return asset.balanceOf(address(this));
    }

    // Simple conversion: if no shares exist, 1:1, otherwise proportional
    function convertToShares(uint256 assets) public view returns (uint256) {
        uint256 _totalSupply = totalSupply();
        uint256 _totalAssets = totalAssets();
        if (_totalSupply == 0 || _totalAssets == 0) {
            return assets;
        }
        return (assets * _totalSupply) / _totalAssets;
    }

    function convertToAssets(uint256 shares) public view returns (uint256) {
        uint256 _totalSupply = totalSupply();
        if (_totalSupply == 0) return shares;
        return (shares * totalAssets()) / _totalSupply;
    }

    function previewDeposit(uint256 assets) external view returns (uint256) {
        return convertToShares(assets);
    }

    function previewWithdraw(uint256 assets) external view returns (uint256) {
        uint256 _totalAssets = totalAssets();
        uint256 _totalSupply = totalSupply();
        if (_totalAssets == 0 || _totalSupply == 0) return 0;
        return (assets * _totalSupply) / _totalAssets;
    }

    // deposit assets and mint shares to receiver
    function deposit(uint256 assets, address receiver) external returns (uint256 shares) {
        require(asset.transferFrom(msg.sender, address(this), assets), "transfer failed");
        shares = convertToShares(assets);
        _mint(receiver, shares);
    }

    // withdraw assets by burning shares from owner; supports allowance semantics
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares) {
        uint256 _totalAssets = totalAssets();
        uint256 _totalSupply = totalSupply();
        require(_totalAssets > 0 && _totalSupply > 0, "no assets or shares");
        shares = (assets * _totalSupply) / _totalAssets;
        if (msg.sender != owner) {
            uint256 allowed = allowance(owner, msg.sender);
            require(allowed >= shares, "ERC4626: insufficient allowance");
            _approve(owner, msg.sender, allowed - shares);
        }
        _burn(owner, shares);
        require(asset.transfer(receiver, assets), "transfer failed");
    }
}
