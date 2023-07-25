// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/NFT.sol";

contract NFTTest is Test {
    NFT public nft;
    address vani = address(0x1);

    function setUp() public {
        nft = new NFT();
    }

    function testBatchMint() public {
        nft.batchMint(10,vani);
        uint256 balance = nft.balanceOf((vani));
        assertEq(balance,10);

        vm.prank(vani);
        vm.expectRevert();
        nft.batchMint(10,vani);
    }
}

