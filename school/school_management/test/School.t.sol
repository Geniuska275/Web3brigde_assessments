// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {SchoolManagement} from "../src/school.sol";

contract SchoolManagementTest is Test {
    SchoolManagement public school;

    function setUp() public {
        school = new SchoolManagement(address(0)); // Initialize with a dummy token address
        
    }

    
}
