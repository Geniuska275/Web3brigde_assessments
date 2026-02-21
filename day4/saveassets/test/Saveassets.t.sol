// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {SaveAsset} from "../src/Saveassets.sol";

contract SaveAssetTest is Test {
    SaveAsset public saveAsset;

    function setUp() public {
        saveAsset = new SaveAsset(address(0));
    }


}
