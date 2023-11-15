// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import { SparkLendHealthChecker } from "../src/SparkLendHealthChecker.sol";

contract SparkLendHealthCheckerTest is Test {

    SparkLendHealthChecker public healthChecker;

    function setUp() public {
        healthChecker = new SparkLendHealthChecker();
    }

    function test_runChecks() public {
        assertEq(healthChecker.runChecks(), true);
    }

}
