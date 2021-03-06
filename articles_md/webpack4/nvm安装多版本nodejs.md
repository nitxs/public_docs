在熟悉了原生JavaScript和nodejs之后，要开始进入到前端项目构建工具的范畴了，这是后期便于使用vue等的必经之路，毕竟磨刀不误砍柴功嘛，熟悉了生产力工具的使用才能少了羁绊。

本来我是从安装webpack4+开始来弄webpack构建的，但由于我电脑里的nodejs和npm版本较低，分别是8.11和5.6，导致npm安装webpack4+失败，报如下截图错误。
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190226_0.png?raw=true)

但我又不想完全使用最新稳定版的nodejs，因为本地很多项目依赖的npm版本较低，担心贸然升级造成未知错误，不想去拆那个腾，浪费时间又没意义。所以最好的办法是电脑安装多版本的nodejs，来根据需要切换。

windows环境下可以通过安装nvm来实现。本文就记录下nvm安装及切换nodejs的过程。算是一个备忘笔记吧，毕竟这种过程频率很低，时间一长就忘记其中注意点，到时还得到处翻教程，麻烦！直接记录下过程以后翻自己的就行了。

1、在安装nvm之前，首先需要清除本地已安装的nodejs，可以通过控制面板-卸载程序直接卸载，然后再清除剩余文件，可以在cmd下使用`where node`查看文件路径

2、下载nvm，下载地址：[github下载链接，地址：https://github.com/coreybutler/nvm-windows/releases](https://github.com/coreybutler/nvm-windows/releases)，选择安装文件，我下的时候nvm是1.1.7版本。截图如下：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190226_1.png?raw=true)

安装包下载好后解压一路next，这个不多说，注意看安装界面文字提示就是，根据自己需求来。

3、检测nvm安装成功的方法是cmd中 nvm -v 看版本号：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190226_2.png?raw=true)

4、补充点：nvm会自动加上环境变量，可以自行去windows环境变量处查看。

5、nvm常用命令：
```javascript
nvm install latest            // 安装最新版的nodejs，会同时一起安装对应的npm

nvm install 8.11.3            // 安装指定版本号的nodejs，会同时一起安装对应的npm

nvm ls                        // 查看当前已安装的所有nodejs版本

nvm use 8.11.3                // nodejs版本切换
```
接下来安装更高版本的nodejs后就可以安装webpack4+了，由于最新的4.29.5版本即使用最新的nodejs11.10.0也还是会报如上错误，难道上官方过没及时更新支持？挨个试了下，找了个顺眼的4.16.1版本的webpack终于可以用11.10.0版本的nodejs安装成功了。

今天比较水，就这么多，下篇开始就是webpack4构建配置的内容了。
