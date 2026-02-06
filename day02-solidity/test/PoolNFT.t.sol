// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "../lib/forge-std/src/Test.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {PoolNFT} from "../src/PoolNFT.sol";

contract PoolNFTTest is Test {
    PoolNFT private nft;
    address private owner;
    address private user;

    string private constant BASE_URI = "ipfs://QmTestCID/";

    function setUp() public {
        owner = address(this);
        user = address(0xBEEF);
        nft = new PoolNFT(BASE_URI);
    }

    function testInitialTotalSupply() public {
        assertEq(nft.totalSupply(), 0);
    }

    function testOwnerCanMintAndTokenURI() public {
        nft.mint(user);
        assertEq(nft.totalSupply(), 1);
        assertEq(nft.ownerOf(1), user);
        string memory expected = string.concat(BASE_URI, "1");
        assertEq(nft.tokenURI(1), expected);
    }

    function testOnlyOwnerCanMint() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user));
        nft.mint(user);
    }

    function testMintBatch() public {
        nft.mintBatch(user, 3);
        assertEq(nft.totalSupply(), 3);
        assertEq(nft.ownerOf(3), user);
        assertEq(nft.tokenURI(3), string.concat(BASE_URI, "3"));
    }
}
