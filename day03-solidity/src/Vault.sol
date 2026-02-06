// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../day02-solidity/lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Vault {
    IERC20 public immutable asset;

    // Total shares issued by the vault
    uint256 public totalShares;

    // User share balances
    mapping(address => uint256) public sharesOf;

    constructor(IERC20 _asset) {
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
}
