// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Escrow} from "../src/Escrow.sol";
import {RealEstate} from "../src/RealEstate.sol";
import {Deploy} from "../../script/Deploy.s.sol";

contract EscrowTest is Test {
    RealEstate realEstate;
    Escrow escrow;
    address BUYER = makeAddr("buyer");
    address SELLER = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address INSPECTOR = makeAddr("inspector");
    address LENDER = makeAddr("lender");

    uint256 constant STARTING_BALANCE = 100 ether;

    function setUp() external {
        // escrow = new Escrow();
        Deploy deploy = new Deploy();
        (realEstate, escrow) = deploy.run();
        vm.deal(BUYER, STARTING_BALANCE);
        vm.deal(LENDER, STARTING_BALANCE);
    }

    function makeSales() private {
        vm.startPrank(BUYER);
        escrow.depositEarnest{value: 10 ether}(1);
        vm.stopPrank();

        vm.startPrank(INSPECTOR);
        escrow.updateInspectionStatus(1, true);
        vm.stopPrank();

        vm.startPrank(BUYER);
        escrow.approveSale(1);
        vm.stopPrank();

        vm.startPrank(SELLER);
        escrow.approveSale(1);
        vm.stopPrank();

        vm.startPrank(LENDER);
        escrow.approveSale(1);
        escrow.transfer{value: 20 ether}(payable(address(escrow)));
        vm.stopPrank();

        vm.startPrank(SELLER);
        escrow.finalizeSale(1);
        vm.stopPrank();
    }

    function testListing_UpdatesAsListed() public view {
        assertEq(escrow.isListed(1), true);
    }

    function testListing_ReturnsBuyer() public view {
        assertEq(escrow.buyer(1), BUYER);
    }

    function testListing_ReturnsPurchasePrice() public view {
        assertEq(escrow.purchasePrice(1), 20 ether);
    }

    function testListing_ReturnsEscrowAmount() public view {
        assertEq(escrow.escrowAmount(1), 10 ether);
    }

    function testListing_UpdatesOwnership() public view {
        assertEq(realEstate.ownerOf(1), address(escrow));
    }

    // --

    function testDeposits_UpdatesContractBalance() public {
        vm.startPrank(BUYER);
        escrow.depositEarnest{value: 10 ether}(1);
        vm.stopPrank();

        assertEq(escrow.getBalance(), 10 ether);
    }

    function testInspection_UpdatesInspectionStatus() public {
        vm.startPrank(INSPECTOR);
        escrow.updateInspectionStatus(1, true);
        vm.stopPrank();

        assertEq(escrow.inspectionPassed(1), true);
    }

    function testApproval_UpdatesApprovalStatus() public {
        vm.startPrank(BUYER);
        escrow.approveSale(1);
        vm.stopPrank();

        vm.startPrank(SELLER);
        escrow.approveSale(1);
        vm.stopPrank();

        vm.startPrank(LENDER);
        escrow.approveSale(1);
        vm.stopPrank();

        assertEq(escrow.approval(1, BUYER), true);
        assertEq(escrow.approval(1, SELLER), true);
        assertEq(escrow.approval(1, LENDER), true);
    }

    function testSale_UpdatesBalance() public {
        makeSales();
        assertEq(escrow.getBalance(), 0);
    }

    function testSale_UpdatesOwnership() public {
        makeSales();
        assertEq(realEstate.ownerOf(1), BUYER);
    }
}
