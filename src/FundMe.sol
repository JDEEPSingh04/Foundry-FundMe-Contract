// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from
    "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__notOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) private AcountToAmount;
    address[] private funders;

    address private immutable i_owner;
    uint256 private constant minUSD = 7 * 1e18;
    AggregatorV3Interface private priceFeed;

    constructor(address price_feed) {
        i_owner = msg.sender;
        priceFeed = AggregatorV3Interface(price_feed);
    }

    function fund() public payable {
        require(msg.value.getConversionRate(priceFeed) > minUSD, "You are sending amount less than minimum amount");
        AcountToAmount[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__notOwner();
        _;
    }

    function cheaperWithraw() public onlyOwner {
        uint256 length = funders.length;
        for (uint256 i = 0; i < length; i++) {
            address funder = funders[i];
            AcountToAmount[funder] = 0;
        }
        funders = new address[](0);

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Not called successfully");
    }

    function withdraw() public onlyOwner {
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            AcountToAmount[funder] = 0;
        }
        funders = new address[](0);

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Not called successfully");
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    function getAddressToAmmount(address funder) public view returns (uint256) {
        return AcountToAmount[funder];
    }

    function getFunder(uint256 index) public view returns (address) {
        return funders[index];
    }

    function getMinUSD() public pure returns (uint256) {
        return minUSD;
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }
}
