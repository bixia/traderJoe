pragma solidity >=0.8.0;

import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/stdlib.sol";

import "@uniswap/UniswapV2Factory.sol";
import "@uniswap/UniswapV2Router02.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UniswapTest is DSTest, stdCheats {
    Vm public vm = Vm(HEVM_ADDRESS);

    UniswapV2Router02 public router;
    ERC20 public tokenA;
    ERC20 public tokenB;
    ERC20 public weth;

    UniswapV2Factory public factory;
    address alice = address(0xdeadbeef);
    function setUp() public {
        vm.startPrank(alice);
        factory = new UniswapV2Factory(alice);
        tokenA = new ERC20("Token","token");
        tokenB = new ERC20("Token","token");
        weth = new ERC20("WETH","weth");
        router = new UniswapV2Router02(address(factory),address(weth));

        tip(address(tokenA), alice, 1000 ether);
        tip(address(tokenB), alice, 1000 ether);

        tokenA.approve(address(router), 1000 ether);
        tokenB.approve(address(router), 1000 ether);
        
        vm.stopPrank();
    }
    function testGetPairHash() public {
        factory.getPairHash();
    }
    function testAddLiquidity() public {
        vm.startPrank(alice);
        router.addLiquidity(
            address(tokenA),
            address(tokenB),
            1000 ether,
            1000 ether,
            0,
            0,
            alice,
            type(uint256).max

        );
        vm.stopPrank();
    }
}