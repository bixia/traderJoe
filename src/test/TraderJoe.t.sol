//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./utils/Deploy.t.sol";

import {RocketJoeFactory} from "@traderJoe/RocketJoeFactory.sol";
import {RocketJoeToken} from "@traderJoe/RocketJoeToken.sol";
import {RocketJoeStaking, IERC20Upgradeable} from "@traderJoe/RocketJoeStaking.sol";
import {LaunchEvent} from "@traderJoe/LaunchEvent.sol";
import {ERC20Token} from "@traderJoe/mocks/ERC20Token.sol";

contract TraderJoeTest is Deploy {
    ERC20Token public joe;
    ERC20Token public reward;
    RocketJoeFactory public rFactory;
    RocketJoeToken public rJoe;
    RocketJoeStaking public staking;
    LaunchEvent public launchEvent;
    LaunchEvent public proxy;

    address alice = address(0xdeadbeef);
    address user = address(0xbeefdead);
    function setUp() public  override {
        super.setUp();

        vm.startPrank(alice);
        reward = new ERC20Token();
        joe = new ERC20Token();
        rJoe = new RocketJoeToken();
        staking = new RocketJoeStaking();
        launchEvent = new LaunchEvent();
        rFactory = new RocketJoeFactory(
            address(launchEvent),
            address(rJoe),
            address(weth),
            address(alice),
            address(router),
            address(factory)    
        );
    
        staking.initialize(
            IERC20Upgradeable(address(joe)),
            rJoe,
            100 ether,
            block.timestamp + 1 days //starttime
        );
        reward.mint(address(alice), 100000 ether);
        joe.mint(address(user), 100000 ether);

        reward.approve(address(rFactory), 100000 ether);
        address proxyAddr = rFactory.createRJLaunchEvent(
            address(alice),
            block.timestamp + 1 days, //starttime
            address(reward),
            1000 ether,
            100 ether,
            1 ether,
            5e17,
            2e17,
            100 ether,
            7 days,
            14 days
        );
        proxy = LaunchEvent(proxy);
        vm.stopPrank();

        vm.label(address(joe),"joe");
        vm.label(address(rJoe),"rJoe");
        vm.label(address(staking),"staking");
        vm.label(address(launchEvent),"launchEvent");
        vm.label(address(rFactory),"rFactory");
        vm.label(address(reward),"reward");
        vm.label(address(proxy),"proxy");

        vm.warp(2 days);
    }
    function testDeploy() override public {
        super.testDeploy();
        require(address(staking.joe()) == address(joe));
        require(address(staking.rJoe()) == address(rJoe));

    }
}