// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {SaveEther} from "../src/Save.sol";

contract SaveEtherTest is Test {
    SaveEther public saveEther;

    function setUp() public {
        saveEther = new SaveEther();
    }

}
