//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/stdlib.sol";


import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router02.sol";
import "./IWETH.sol";
contract Deploy is DSTest, stdCheats {
    string public constant RouterCodePath = "src/test/utils/router.json";
    string public constant FacotryCodePath = "src/test/utils/factory.json";
    string public constant WethCodePath = "src/test/utils/weth.json";
    IUniswapV2Factory public factory;
    IUniswapV2Router02 public router;
    IWETH public weth;
    Vm public vm = Vm(HEVM_ADDRESS);
    function setUp() public {
        //deploy weth
        address wethAddr = deployCode(WethCodePath);
        weth = IWETH(payable(wethAddr));
        //deploy factory
        address factoryAddr = deployCode(FacotryCodePath);
        factory = IUniswapV2Factory(payable(factoryAddr));
        //deploy router
        bytes memory params = abi.encode(factoryAddr, wethAddr);
        address routerAddr = deployCode(RouterCodePath, params);
        router = IUniswapV2Router02(payable(routerAddr));

        vm.label(routerAddr, "router");
        vm.label(factoryAddr, "factory");
        vm.label(wethAddr, "weth");

        emit log_named_address("factory", address(factory));
        emit log_named_address("weth", address(weth));
        emit log_named_address("router", address(router));
    }
    function testDeploy() public {
        require(router.factory() == address(factory));
        require(router.WETH() == address(weth));
        emit log_named_address("factory", router.factory());
        emit log_named_address("weth", router.WETH());
        emit log_named_address("router", address(router));
    }
}