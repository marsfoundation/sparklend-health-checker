// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.13;

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
