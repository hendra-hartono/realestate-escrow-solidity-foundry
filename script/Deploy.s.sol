// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {RealEstate} from "../src/RealEstate.sol";
import {Escrow} from "../src/Escrow.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Deploy is Script {
    address BUYER = makeAddr("buyer");
    address SELLER = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address INSPECTOR = makeAddr("inspector");
    address LENDER = makeAddr("lender");

    function run() external returns (RealEstate, Escrow) {
        vm.startBroadcast(SELLER);

        // Deploy Real Estate
        RealEstate realEstate = new RealEstate();
        console.log("RealEstate contract deployed to:", address(realEstate));

        // Mint Properties
        console.log("Minting 3 properties...\n");
        for (uint256 i = 0; i < 3; i++) {
            realEstate.mint(
                string.concat(
                    "https://ipfs.io/ipfs/QmQVcpsjrA6cr1iJjZAodYwmPekYgbnXGo4DFubJiLc2EB/",
                    Strings.toString(i + 1),
                    ".json"
                )
            );
        }

        // Deploy Escrow
        Escrow escrow = new Escrow(
            address(realEstate),
            payable(SELLER),
            INSPECTOR,
            LENDER
        );
        console.log("Deployed Escrow Contract at:", address(escrow));

        // Approve Properties
        console.log("Approving 3 properties...\n");
        for (uint256 i = 0; i < 3; i++) {
            realEstate.approve(address(escrow), i + 1);
        }

        // List Properties
        console.log("Listing 3 properties...\n");
        escrow.list(1, BUYER, 20 ether, 10 ether);
        escrow.list(2, BUYER, 15 ether, 5 ether);
        escrow.list(3, BUYER, 10 ether, 5 ether);

        vm.stopBroadcast();
        console.log("Finished.");

        return (realEstate, escrow);
    }
}
