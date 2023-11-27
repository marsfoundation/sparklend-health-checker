// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import { IERC20 } from "lib/erc20-helpers/src/interfaces/IERC20.sol";

import { IAToken }           from "lib/aave-v3-core/contracts/interfaces/IAToken.sol";
import { IPoolDataProvider } from "lib/aave-v3-core/contracts/interfaces/IPoolDataProvider.sol";
import { IPool }             from "lib/aave-v3-core/contracts/interfaces/IPool.sol";

contract SparkLendHealthChecker {

    address constant DATA_PROVIDER = 0xFc21d6d146E6086B8359705C8b28512a983db0cb;
    address constant POOL          = 0xC13e21B648A5Ee794902342038FF3aDAB66BE987;

    // address constant DATA_PROVIDER = 0x7B4EB56E7CD4b454BA8ff71E4518426369a138a3;
    // address constant POOL          = 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2;

    IPool             pool         = IPool(POOL);
    IPoolDataProvider dataProvider = IPoolDataProvider(DATA_PROVIDER);

    function runChecks() public view returns (bool) {
        return true;
    }

    function check1() external view returns (bool) {
        IPoolDataProvider.TokenData[] memory tokenData = dataProvider.getAllReservesTokens();

        console2.log("tokenData.length: %s", tokenData.length);

        for (uint256 i = 0; i < tokenData.length; i++) {
            console2.log("i", i);
            console2.log("----------------------------------------");
            console2.log("token:                     %s", tokenData[i].symbol);
            checkReserveInvariants(tokenData[i].tokenAddress);
        }
    }

    function checkReserveInvariants(address asset) public view returns (uint256 diff) {
        ( , uint256 accruedToTreasuryScaled,,,,,,,,,, )
            = dataProvider.getReserveData(asset);

        ( address aToken,, ) = dataProvider.getReserveTokensAddresses(asset);

        uint256 totalDebt         = dataProvider.getTotalDebt(asset);
        uint256 totalLiquidity    = IERC20(asset).balanceOf(aToken);
        uint256 scaledLiabilities = IAToken(aToken).scaledTotalSupply() + accruedToTreasuryScaled;

        uint256 assets      = totalLiquidity + totalDebt;
        uint256 liabilities = scaledLiabilities * pool.getReserveNormalizedIncome(asset) / 1e27;

        console2.log("assets:                    %s", assets);
        console2.log("liabilities:               %s", liabilities);
        console2.log("assets - liabilities:      %s", assets - liabilities);

        diff = (assets - liabilities) * 1e18 / 10 ** IERC20(asset).decimals();

        console2.log("diff:                      %s", diff * 10000 / 1e18);

        console2.log("----------------------------------------");
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

    function _toWad(address asset, uint256 amount) internal view returns (uint256) {
        return amount * 1e18 / 10 ** IERC20(asset).decimals();
    }

    function _bpsToWad(uint256 bps) internal pure returns (uint256) {
        return bps * 1e14;
    }

}
