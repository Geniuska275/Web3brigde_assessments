// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Todo} from "../src/Todo.sol";

contract TodoTest is Test {
    Todo public todo;

    function setUp() public {
        todo = new Todo();
    }

    function test_Increment() public {
        todo.createTask("Test Task");
        assertEq(todo.getAllTasks().length, 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        todo.createTask("Test Task");
        assertEq(todo.getAllTasks().length, 1);
    }
}
