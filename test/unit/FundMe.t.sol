// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/FundMe.s.sol";

contract FundMeTest is Test {
    address USER = makeAddr("USER");
    FundMe fund;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fund = deployFundMe.run();
        vm.deal(USER, 10e24);
    }

    function testDemo() public {
        assertEq(fund.getMinUSD(), 7e18);
    }

    function testOwner() public {
        console.log(fund.getOwner());
        console.log(msg.sender);
        assertEq(fund.getOwner(), msg.sender);
    }

    function testVersion() public {
        assertEq(fund.getVersion(), 4);
    }

    function testFundMinUSD() public {
        vm.expectRevert();
        fund.fund();
    }

    modifier FUND() {
        vm.prank(USER);
        fund.fund{value: 10e18}();
        _;
    }

    function testUpdatedMapping() public FUND {
        uint256 amount = fund.getAddressToAmmount(USER);
        assertEq(amount, 10e18);
    }

    function testUpdatedArray() public FUND {
        address funder = fund.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerWithdraw() public FUND {
        vm.prank(USER);
        vm.expectRevert();
        fund.withdraw();
    }

    function testWithdrawSingleFunder() public FUND {
        uint256 startingFundMeBalance = address(fund).balance;
        uint256 startingOwnerBalance = fund.getOwner().balance;
        vm.prank(fund.getOwner());
        fund.withdraw();
        uint256 endingFundMeBalance = address(fund).balance;
        uint256 endingOwnerBalance = fund.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingFundMeBalance + startingOwnerBalance);
    }

    function testWithdrawMultipleFunders() public {
        for (uint160 i = 1; i <= 10; i++) {
            hoax(address(i), 10e18);
            fund.fund{value: 10e18}();
        }

        uint256 startingFundMeAmount = address(fund).balance;
        uint256 startingOwnerAmount = fund.getOwner().balance;

        vm.prank(fund.getOwner());
        fund.withdraw();

        uint256 endingFundMeAmount = address(fund).balance;
        uint256 endingOwnerAmount = fund.getOwner().balance;

        assertEq(endingFundMeAmount, 0);
        assertEq(endingOwnerAmount, startingFundMeAmount + startingOwnerAmount);
    }

    function testWithdrawMultipleFundersCheaper() public {
        for (uint160 i = 1; i <= 10; i++) {
            hoax(address(i), 10e18);
            fund.fund{value: 10e18}();
        }

        uint256 startingFundMeAmount = address(fund).balance;
        uint256 startingOwnerAmount = fund.getOwner().balance;

        vm.prank(fund.getOwner());
        fund.cheaperWithraw();

        uint256 endingFundMeAmount = address(fund).balance;
        uint256 endingOwnerAmount = fund.getOwner().balance;

        assertEq(endingFundMeAmount, 0);
        assertEq(endingOwnerAmount, startingFundMeAmount + startingOwnerAmount);
    }
}
