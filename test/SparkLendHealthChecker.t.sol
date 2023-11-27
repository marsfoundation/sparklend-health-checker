// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import { SparkLendHealthChecker } from "../src/SparkLendHealthChecker.sol";

contract SparkLendHealthCheckerTest is Test {

    SparkLendHealthChecker public healthChecker;

    address constant WHALE = 0xf8dE75c7B95edB6f1E639751318f117663021Cf0;

    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    function setUp() public {
        vm.createSelectFork(getChain('mainnet').rpcUrl, 18613327);
        healthChecker = new SparkLendHealthChecker();
    }

    function test_checkUserHealth() public {
        (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor,
            bool belowLtv,
            bool belowLiquidationThreshold
        ) = healthChecker.checkUserHealth(WHALE);

        // console.log all of them like this console.log("key: %s, value: %s", key, value)
        console.log("totalCollateralBase:         %s", totalCollateralBase);
        console.log("totalDebtBase:               %s", totalDebtBase);
        console.log("availableBorrowsBase:        %s", availableBorrowsBase);
        console.log("currentLiquidationThreshold: %s", currentLiquidationThreshold);
        console.log("ltv:                         %s", ltv);
        console.log("healthFactor:                %s", healthFactor);
        console.log("belowLtv:                    %s", belowLtv);
        console.log("belowLiquidationThreshold:   %s", belowLiquidationThreshold);
    }

    function test_outputToFile() public {
        vm.writeLine("output2.csv", "blockNumber,diff");
        for (uint256 blockNumber = 18_150_000; blockNumber < 18_160_000; blockNumber += 500) {
            vm.createSelectFork(getChain('mainnet').rpcUrl, blockNumber);
            healthChecker = new SparkLendHealthChecker();
            console2.log("---- blockNumber: %s ----", blockNumber);
            uint256 diff = healthChecker.checkReserveInvariants(DAI);
            vm.writeLine(
                "output2.csv",
                string.concat(vm.toString(blockNumber), ",", vm.toString(diff / 1e18))
            );
        }
    }

    function test_check1() public {
        healthChecker.check1();
    }

}
