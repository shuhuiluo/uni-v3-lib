// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ISqrtPriceMath} from "src/test/interfaces/ISqrtPriceMath.sol";
import {FullMath} from "src/FullMath.sol";
import {SqrtPriceMath} from "src/SqrtPriceMath.sol";
import "./Base.t.sol";

contract SqrtPriceMathWrapper is ISqrtPriceMath {
    function getNextSqrtPriceFromAmount0RoundingUp(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amount,
        bool add
    ) external pure returns (uint160) {
        return SqrtPriceMath.getNextSqrtPriceFromAmount0RoundingUp(sqrtPX96, liquidity, amount, add);
    }

    function getNextSqrtPriceFromAmount1RoundingDown(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amount,
        bool add
    ) external pure returns (uint160) {
        return SqrtPriceMath.getNextSqrtPriceFromAmount1RoundingDown(sqrtPX96, liquidity, amount, add);
    }

    function getNextSqrtPriceFromInput(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amountIn,
        bool zeroForOne
    ) external pure returns (uint160) {
        return SqrtPriceMath.getNextSqrtPriceFromInput(sqrtPX96, liquidity, amountIn, zeroForOne);
    }

    function getNextSqrtPriceFromOutput(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amountOut,
        bool zeroForOne
    ) external pure returns (uint160) {
        return SqrtPriceMath.getNextSqrtPriceFromOutput(sqrtPX96, liquidity, amountOut, zeroForOne);
    }

    function getAmount0Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity,
        bool roundUp
    ) external pure returns (uint256) {
        return SqrtPriceMath.getAmount0Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity, roundUp);
    }

    function getAmount1Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity,
        bool roundUp
    ) external pure returns (uint256) {
        return SqrtPriceMath.getAmount1Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity, roundUp);
    }

    function getAmount0Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        int128 liquidity
    ) external pure returns (int256) {
        return SqrtPriceMath.getAmount0Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity);
    }

    function getAmount1Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        int128 liquidity
    ) external pure returns (int256) {
        return SqrtPriceMath.getAmount1Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity);
    }
}

/// @title Test contract for SqrtPriceMath
contract SqrtPriceMathTest is BaseTest {
    // Wrapper that exposes the original SqrtPriceMath library.
    ISqrtPriceMath internal ogWrapper;
    SqrtPriceMathWrapper internal wrapper;

    function setUp() public override {
        ogWrapper = ISqrtPriceMath(deployCode("out/SqrtPriceMathTest.sol/SqrtPriceMathTest.json"));
        wrapper = new SqrtPriceMathWrapper();
    }

    function testFuzz_GetNextSqrtPriceFromAmount0RoundingUp(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amount,
        bool add
    ) external {
        sqrtPX96 = boundUint160(sqrtPX96);
        try ogWrapper.getNextSqrtPriceFromAmount0RoundingUp(sqrtPX96, liquidity, amount, add) returns (
            uint160 expected
        ) {
            assertEq(wrapper.getNextSqrtPriceFromAmount0RoundingUp(sqrtPX96, liquidity, amount, add), expected);
        } catch (bytes memory) {
            vm.expectRevert();
            wrapper.getNextSqrtPriceFromAmount0RoundingUp(sqrtPX96, liquidity, amount, add);
        }
    }

    function testFuzz_GetNextSqrtPriceFromAmount1RoundingDown(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amount,
        bool add
    ) external {
        liquidity = uint128(bound(liquidity, 1, type(uint128).max));
        sqrtPX96 = boundUint160(sqrtPX96);
        amount = bound(amount, 0, FullMath.mulDivQ96(type(uint160).max, liquidity));
        try ogWrapper.getNextSqrtPriceFromAmount1RoundingDown(sqrtPX96, liquidity, amount, add) returns (
            uint160 expected
        ) {
            assertEq(wrapper.getNextSqrtPriceFromAmount1RoundingDown(sqrtPX96, liquidity, amount, add), expected);
        } catch (bytes memory) {
            vm.expectRevert();
            wrapper.getNextSqrtPriceFromAmount1RoundingDown(sqrtPX96, liquidity, amount, add);
        }
    }

    function testFuzz_GetNextSqrtPriceFromInput(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amountIn,
        bool zeroForOne
    ) external {
        try ogWrapper.getNextSqrtPriceFromInput(sqrtPX96, liquidity, amountIn, zeroForOne) returns (uint160 expected) {
            assertEq(wrapper.getNextSqrtPriceFromInput(sqrtPX96, liquidity, amountIn, zeroForOne), expected);
        } catch (bytes memory) {
            vm.expectRevert();
            wrapper.getNextSqrtPriceFromInput(sqrtPX96, liquidity, amountIn, zeroForOne);
        }
    }

    function testGas_GetNextSqrtPriceFromInput() external view {
        for (uint256 i; i < 100; ++i) {
            try
                wrapper.getNextSqrtPriceFromInput(
                    pseudoRandomUint160(i),
                    pseudoRandomUint128(i ** 2),
                    pseudoRandom(i ** 3),
                    i % 2 == 0
                )
            {} catch {}
        }
    }

    function testGas_GetNextSqrtPriceFromInput_Og() external view {
        for (uint256 i; i < 100; ++i) {
            try
                ogWrapper.getNextSqrtPriceFromInput(
                    pseudoRandomUint160(i),
                    pseudoRandomUint128(i ** 2),
                    pseudoRandom(i ** 3),
                    i % 2 == 0
                )
            {} catch {}
        }
    }

    function testFuzz_GetNextSqrtPriceFromOutput(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amountOut,
        bool zeroForOne
    ) external {
        try ogWrapper.getNextSqrtPriceFromOutput(sqrtPX96, liquidity, amountOut, zeroForOne) returns (
            uint160 expected
        ) {
            assertEq(wrapper.getNextSqrtPriceFromOutput(sqrtPX96, liquidity, amountOut, zeroForOne), expected);
        } catch (bytes memory) {
            vm.expectRevert();
            wrapper.getNextSqrtPriceFromOutput(sqrtPX96, liquidity, amountOut, zeroForOne);
        }
    }

    function testGas_GetNextSqrtPriceFromOutput() external view {
        for (uint256 i; i < 100; ++i) {
            try
                wrapper.getNextSqrtPriceFromOutput(
                    pseudoRandomUint160(i),
                    pseudoRandomUint128(i ** 2),
                    pseudoRandom(i ** 3),
                    i % 2 == 0
                )
            {} catch {}
        }
    }

    function testGas_GetNextSqrtPriceFromOutput_Og() external view {
        for (uint256 i; i < 100; ++i) {
            try
                ogWrapper.getNextSqrtPriceFromOutput(
                    pseudoRandomUint160(i),
                    pseudoRandomUint128(i ** 2),
                    pseudoRandom(i ** 3),
                    i % 2 == 0
                )
            {} catch {}
        }
    }

    function testFuzz_GetAmount0Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity,
        bool roundUp
    ) external {
        try ogWrapper.getAmount0Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity, roundUp) returns (uint256 expected) {
            assertEq(wrapper.getAmount0Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity, roundUp), expected);
        } catch (bytes memory) {
            vm.expectRevert();
            wrapper.getAmount0Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity, roundUp);
        }
    }

    function testFuzz_GetAmount1Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity,
        bool roundUp
    ) external {
        try ogWrapper.getAmount1Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity, roundUp) returns (uint256 expected) {
            assertEq(wrapper.getAmount1Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity, roundUp), expected);
        } catch (bytes memory) {
            vm.expectRevert();
            wrapper.getAmount1Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity, roundUp);
        }
    }

    function testFuzz_GetAmount0Delta(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, int128 liquidity) external {
        try ogWrapper.getAmount0Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity) returns (int256 expected) {
            assertEq(wrapper.getAmount0Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity), expected);
        } catch (bytes memory) {
            vm.expectRevert();
            wrapper.getAmount0Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity);
        }
    }

    function testGas_GetAmount0Delta() external view {
        for (uint256 i; i < 100; ++i) {
            try
                wrapper.getAmount0Delta(pseudoRandomUint160(i), pseudoRandomUint160(i ** 2), pseudoRandomInt128(i ** 3))
            {} catch {}
        }
    }

    function testGas_GetAmount0Delta_Og() external view {
        for (uint256 i; i < 100; ++i) {
            try
                ogWrapper.getAmount0Delta(
                    pseudoRandomUint160(i),
                    pseudoRandomUint160(i ** 2),
                    pseudoRandomInt128(i ** 3)
                )
            {} catch {}
        }
    }

    function testFuzz_GetAmount1Delta(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, int128 liquidity) external {
        try ogWrapper.getAmount1Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity) returns (int256 expected) {
            assertEq(wrapper.getAmount1Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity), expected);
        } catch (bytes memory) {
            vm.expectRevert();
            wrapper.getAmount1Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity);
        }
    }

    function testGas_GetAmount1Delta() external view {
        for (uint256 i; i < 100; ++i) {
            try
                wrapper.getAmount1Delta(pseudoRandomUint160(i), pseudoRandomUint160(i ** 2), pseudoRandomInt128(i ** 3))
            {} catch {}
        }
    }

    function testGas_GetAmount1Delta_Og() external view {
        for (uint256 i; i < 100; ++i) {
            try
                ogWrapper.getAmount1Delta(
                    pseudoRandomUint160(i),
                    pseudoRandomUint160(i ** 2),
                    pseudoRandomInt128(i ** 3)
                )
            {} catch {}
        }
    }
}
