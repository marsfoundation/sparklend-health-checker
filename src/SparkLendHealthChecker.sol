// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import { IERC20 } from "lib/erc20-helpers/src/interfaces/IERC20.sol";

import { IPoolDataProvider } from "lib/aave-v3-core/contracts/interfaces/IPoolDataProvider.sol";
import { IPool }             from "lib/aave-v3-core/contracts/interfaces/IPool.sol";

contract SparkLendHealthChecker {

    address constant DATA_PROVIDER = 0xFc21d6d146E6086B8359705C8b28512a983db0cb;
    address constant POOL          = 0xC13e21B648A5Ee794902342038FF3aDAB66BE987;

    IPool             pool         = IPool(POOL);
    IPoolDataProvider dataProvider = IPoolDataProvider(DATA_PROVIDER);

    function runChecks() public view returns (bool) {
        return true;
    }

    function check1() external view returns (bool) {
        IPoolDataProvider.TokenData[] memory tokenData = dataProvider.getAllReservesTokens();

        for (uint256 i = 0; i < tokenData.length; i++) {
            console.log("----------------------------------------");
            console.log("tokenData[%s].symbol:       %s", i, tokenData[i].symbol);
            console.log("tokenData[%s].tokenAddress: %s", i, tokenData[i].tokenAddress);

            (
                uint256 unbacked,
                uint256 accruedToTreasuryScaled,
                uint256 totalAToken,
                uint256 totalStableDebt,
                uint256 totalVariableDebt,
                uint256 liquidityRate,
                uint256 variableBorrowRate,
                uint256 stableBorrowRate,
                uint256 averageStableBorrowRate,
                uint256 liquidityIndex,
                uint256 variableBorrowIndex,
                uint40 lastUpdateTimestamp
              ) = dataProvider.getReserveData(tokenData[i].tokenAddress);

            console.log("unbacked:                  %s", unbacked);
            console.log("accruedToTreasuryScaled:   %s", accruedToTreasuryScaled);
            console.log("totalAToken:               %s", totalAToken);
            console.log("totalStableDebt:           %s", totalStableDebt);
            console.log("totalVariableDebt:         %s", totalVariableDebt);
            console.log("liquidityRate:             %s", liquidityRate);
            console.log("variableBorrowRate:        %s", variableBorrowRate);
            console.log("stableBorrowRate:          %s", stableBorrowRate);
            console.log("averageStableBorrowRate:   %s", averageStableBorrowRate);
            console.log("liquidityIndex:            %s", liquidityIndex);
            console.log("variableBorrowIndex:       %s", variableBorrowIndex);
            console.log("lastUpdateTimestamp:       %s", lastUpdateTimestamp);
            console.log("----------------------------------------");

            uint256 totalDebt = totalStableDebt + totalVariableDebt;

            console.log("totalDebt:                 %s", totalDebt);

            ( address aToken,, )
                = dataProvider.getReserveTokensAddresses(tokenData[i].tokenAddress);

            console.log("aTokenBal", IERC20(tokenData[i].tokenAddress).balanceOf(aToken));
        }
    }


    // TODO: Investigate if oracles should be a concern here since they are being used to calculate
    //       the base values.
    function checkUserHealth(address user)
        public view returns (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor,
            bool belowLtv,
            bool belowLiquidationThreshold
        )
    {
        (
            totalCollateralBase,
            totalDebtBase,
            availableBorrowsBase,
            currentLiquidationThreshold,
            ltv,
            healthFactor
        ) = pool.getUserAccountData(user);

        belowLtv = healthFactor < _bpsToWad(ltv);

        belowLiquidationThreshold = healthFactor < _bpsToWad(currentLiquidationThreshold);
    }

    function _bpsToWad(uint256 bps) internal pure returns (uint256) {
        return bps * 1e14;
    }

}
