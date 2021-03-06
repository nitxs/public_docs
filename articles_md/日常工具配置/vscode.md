# 配置我的vscode

## 字体/主题/文件图标主题

1. 字体选择等宽字体，确保电脑上有`Source Code`这个字体，在`C:\Windows\Fonts`中可以查看电脑上已安装字体（这个字体电脑默认是没有的），在`github`上下载字体，搜索`Source Code Pro`，选择第一个，点击`latest realse`，选择`ttf`文件下载。打开`vscode`的设置界面，`文件->首选项->设置`，搜索`settings.json`，添加配置`'Source Code Pro'`，还可以再设置合适的字体大小和行高。其他推荐的字体有`Fira Code`、`Menlo`、`Consolas`、`Monaco`、`Courier New`。
2. 主题配置我选的是 `one Dark`系列，我喜好其中的`One Dark Pro Bold`主题，这会将变量/方法对应的显示字体稍微加粗些，看起来更醒目舒服。白色背景主题可以选择vscode默认就有的`Light +`
3. 文件图标主题我就选的默认的`Seti`
4. 我的`settings.json`配置如下：

```json
{
    "git.ignoreMissingGitWarning": true,
    "editor.fontFamily": "Source Code Pro, Fira Code",
    "editor.renderLineHighlight": "none",
    "editor.lineHeight": 24,
    "editor.roundedSelection": false,
    "extensions.autoUpdate": true,
    "editor.fontSize": 14,
    "editor.tabSize": 4,
    "workbench.colorTheme": "One Dark Pro Bold",
}
```

## markDown

1. 安装插件`markdownlint`，作用是检查书写的markdown语法
2. 安装插件`Markdown All in One`，作用是各种快捷键、创建表格、预览等

## 其他配置

1. 路径自动查找：插件`Path Intellisense`
2. 自动重命名html标签：插件`Auto Rename Tag`
3. 自动添加html闭合标签：插件`Auto Close Tag`
4. vscode汉化：插件`Chinese (Simplified) Language Pack for Visual Studio Code`
5. FTL语法：插件`FreeMarker`
6. 颜色高亮指示：插件`Color Highlight`
7. html文件支持：插件`HTML CSS Support`、插件`HTML Snippets`
8. ES6语法快捷输入支持：插件`JavaScript (ES6) code snippets`
9. 浏览器打开页面：插件`open in browser`
10. vue支持：插件`Vetur`


## 配置 Java 环境

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