# vscode配置 Java 环境

先安装 Java 语言相关的插件 4 枚
1. Language Support for Java(TM) by Red Hat     运行java代码
2. Debugger for Java        调试用，不调试可以不装
3. Java Test Runner         运行单元测试，不测试可以不装
4. Maven for Java           maven 是在Java环境下构建应用程序的软件（本地先安装）

这时候还需要在settings.json中配置一下 java.home
`"java.home": "D:\\Java\\jdk1.8.0_111"`

由于我使用的jdk8，但vscode扩展 Language Support for Java 更新到0.65.0后不再支持jdk8。

办法是
1. 更新jdk到11
2. 可以在settings.json中配置java.configuration.runtimes，这个配置仍然支持Java1.5到14，不过依旧需要安装JDK11，用来启动Java语言服务器，具体的编译版本则可以自行选择
```
"java.home": "/path/to/jdk-11",
"java.configuration.runtimes": [
 {
 "name": "JavaSE-1.8",
 "path": "/path/to/jdk-8",
 "default": true
 },
 {
 "name": "JavaSE-11",
 "path": "/path/to/jdk-11",
 },
]
```
3. 照常使用以前版本，直接选中该拓展的设置–>安装另一个版本–>选择安装的版本：0.64.1,然后关闭拓展更新：在设置中关闭Extensions: Auto Update。（我选方案3）


如果要在vscode中配置maven项目，可以看这篇文章：[点这](https://www.cnblogs.com/zhaoshizi/p/9524421.html)

# eclipse写java

在eclipse中创建maven项目  `File -> New -> Other -> Maven-Maven Project`

maven打包java项目， `项目右键Run As -> Goals中添加打包命令（我选择是clean package，意思是 mvn clean package，即先清理所有生成的class和jar再执行package生命周期打包）`

# TomCat 

tomcat中配置端口号 `tomcat根目录/conf/Server.xml中修改port值`

# eclipse maven打包项目

