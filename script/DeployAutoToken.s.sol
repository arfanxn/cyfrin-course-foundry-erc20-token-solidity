// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {AutoToken} from "src/AutoToken.sol";

contract DeployAutoToken is Script {
    uint256 public constant INITIAL_SUPPLY = 1000 ether;

    function run() external returns (AutoToken) {
        vm.startBroadcast();
        AutoToken autoToken = new AutoToken(INITIAL_SUPPLY);
        vm.stopBroadcast();
        return autoToken;
    }
}
