// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {DeployAutoToken} from "script/DeployAutoToken.s.sol";
import {AutoToken} from "src/AutoToken.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract AutoTokenTest is Test {
    AutoToken public autoToken;
    DeployAutoToken public deployer;

    function setUp() public {
        deployer = new DeployAutoToken();
        autoToken = deployer.run();
    }

    modifier asMsgSender() {
        // Use this modifier to run the test as the msg.sender
        vm.prank(msg.sender);
        _;
    }

    function testInitialSupply() public view {
        assertEq(autoToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testSenderBalanceEqualsToInitialSupply() public view {
        assertEq(autoToken.balanceOf(msg.sender), deployer.INITIAL_SUPPLY());
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(autoToken)).mint(address(this), 1);
    }

    function testTransfer() public asMsgSender {
        address recipient = address(0x123);
        uint256 amount = 100;

        // Transfer tokens from deployer (msg.sender) to recipient
        autoToken.transfer(recipient, amount);

        // Check balances
        console.log("Recipient Balance:", autoToken.balanceOf(recipient));
        console.log("Sender Balance:", autoToken.balanceOf(msg.sender));
        assertEq(autoToken.balanceOf(recipient), amount);
        assertEq(
            autoToken.balanceOf(msg.sender),
            deployer.INITIAL_SUPPLY() - amount
        );
    }

    function testTransferFailsIfInsufficientBalance() public asMsgSender {
        address recipient = address(0x123);
        uint256 amount = deployer.INITIAL_SUPPLY() + 1; // More than initial supply

        vm.expectRevert();
        autoToken.transfer(recipient, amount);
    }

    function testApprove() public asMsgSender {
        address spender = address(0x456);
        uint256 amount = 50;

        // Approve spender to spend tokens
        autoToken.approve(spender, amount);

        // Check allowance
        console.log(
            "Allowance for spender:",
            autoToken.allowance(msg.sender, spender)
        );
        assertEq(autoToken.allowance(msg.sender, spender), amount);
    }

    function testTransferFrom() public asMsgSender {
        address spender = address(0x456);
        uint256 amount = 50;

        // Approve spender to spend tokens
        autoToken.approve(spender, amount);

        // Transfer from the owner to another address
        vm.prank(spender); // Set the caller to be the spender
        autoToken.transferFrom(msg.sender, address(0x789), amount);

        // Check balances
        console.log(
            "Balance of recipient after transfer:",
            autoToken.balanceOf(address(0x789))
        );
        console.log(
            "Balance of sender after transfer:",
            autoToken.balanceOf(msg.sender)
        );
        assertEq(autoToken.balanceOf(address(0x789)), amount);
        assertEq(
            autoToken.balanceOf(msg.sender),
            deployer.INITIAL_SUPPLY() - amount
        );
    }

    function testTransferFromFailsIfNotApproved() public asMsgSender {
        address spender = address(0x456);
        uint256 amount = 50;

        // Attempt to transfer from without approval
        vm.expectRevert();
        vm.prank(spender);
        autoToken.transferFrom(msg.sender, address(0x789), amount);
    }

    function testTransferFromFailsIfInsufficientAllowance() public asMsgSender {
        address spender = address(0x456);
        uint256 amount = 50;

        // Approve a smaller amount
        autoToken.approve(spender, amount - 1);

        // Attempt to transfer more than allowed
        vm.expectRevert();
        vm.prank(spender);
        autoToken.transferFrom(msg.sender, address(0x789), amount);
    }
}
