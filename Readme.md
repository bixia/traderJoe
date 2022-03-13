TraderJoe LaunchPad 学习：

学习资料：
[traderJoe](https://code4rena.com/reports/2022-01-trader-joe/)

本文是针对tradeJoe在code4rena上的一篇学习文章，主要学习内容有：

1. 类似于traderJoe的launchpad应该怎么设计
2. 好的文档，以及怎么去画一个好的图
3. 针对找到的issue，为啥我当初看的时候没有找出来，具体的issue分析

初步打算：

1. 用forge在本地搭建一个测试环境出来，然后针对找出的issue（critical issue）进行一个简单的POC
2. 自己的语言描述一下这个lanuchPad的工作流程
3. 重新熟悉一下clone，以及为啥不用常规的Transparent Proxy模式，而是一个clone

踩坑之旅：

1. 在traderJoe里面需要用到UniswapV2，但是traderJoe的solidity代码基本上在^0.8.0, 而uniswapV2的代码基本上都在0.6.12。出现了版本不兼容的问题：
   解决方案有两个：
   其一是：把UniswapV2直接port到0.8.0的版本，所幸的是有人已经做了。但是他只做了core部分，router部分没有做。所以需要把router部分port到0.8.0的版本上。具体可以参见：[uniswap0.8](https://github.com/bixia/uniswapv2-solc0.8) 我自己把router部分重新port了一遍, 欢迎PR；
   其二是：可以用fundry里面的魔法函数：getCode,deployCode。具体做法是：在etherscan上找到uniswapV2Factory,WETH,uniswapV2Router02的合约地址，然后分别把对应的init code和对应的interface拷贝存储到本地。然后在deploy合约里写一个deployCode脚本，生成新的合约地址，再把interface对应上去就变成了一个新的合约了。具体可以参见[deploy](./src/test/utils/Deploy.t.sol)合约



