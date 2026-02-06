// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/PoolNFT.sol";

contract DeployPoolNFT is Script {
    function run() external {
        string memory baseURI = vm.envString("BASE_URI");
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);
        PoolNFT nft = new PoolNFT(baseURI);
        vm.stopBroadcast();

        console.log("PoolNFT deployed at:", address(nft));
    }
}
