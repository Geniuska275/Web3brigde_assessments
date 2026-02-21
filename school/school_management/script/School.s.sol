// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {SchoolManagement} from "../src/school.sol";

contract SchoolManagementScript is Script {
    SchoolManagement public school;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        school = new SchoolManagement(address(0)); // Initialize with a dummy token address

        vm.stopBroadcast();
    }
}
