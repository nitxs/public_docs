本篇开始学习webpack打包的构建配置，所用版本为`webpack 4.16.1`和`webpack-cli 3.2.3`。

由于主要开发电商项目，所以对webpack配置生成多页面html更感兴趣。

配置生成html的插件采用`html-webpack-plugin`，主要作用是：根据模板生成页面/无模板生成页面、自动引入js等外部资源、设置title/meta等标签内容。

还是从最简单的单入口配置开始，安装相应包的过程略，直接给出webpack.config.js配置：
```javascript
const path = require( "path" );
const HtmlWebpackPlugin = require( "html-webpack-plugin" );
const CleanWebackPlugin = require( "clean-webpack-plugin" );

module.exports = {
    entry: {
        app: __dirname + "/src/index.js"
    },
    output: {
        filename: "[name].[chunkhash].bundle.js",
        path: path.resolve( __dirname, "dist" )
    },
    devtool: "inline-source-map",
    mode: "development",
    module: {
        rules:[

        ]
    },
    plugins: [
        new HtmlWebpackPlugin( {
            title: "开发测试页面"
        } ),
        new CleanWebackPlugin( ["dist"] )
    ],
}
```

接下来是多入口页面配置。

多页面演示模型如下：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190228_0.png?raw=true)

webpack.config.js配置如下：
```javascript
const path = require( "path" );
const webpack = require( 'webpack' );
const HtmlWebpackPlugin = require( "html-webpack-plugin" );
const CleanWebpackPlugin = require( "clean-webpack-plugin" );

module.exports = {
    entry: {
        main: __dirname + "/src/js/main.js",
        about: __dirname + "/src/js/about.js",
        list: __dirname + "/src/js/list.js"
    },
    output: {
        filename: "js/[name].[chunkhash].bundle.js",
        path: path.resolve( __dirname, "dist" )
    },
    devtool: "inline-source-map",
    module: {
        rules: [

        ]
    },
    plugins: [
        new HtmlWebpackPlugin( {
            // html文件 title标签的内容
            title: "main",      
            // 输出的文件名，可配置路径
            filename: "views/main.html",   
            // 采用的模板文件名，可配置路径  
            template: "src/views/main.html",   
            // 生成的html文件中引入的js文件名，与entry入口和slpitChunks分离等配置的js文件名相同
            chunks: [ "main", "manifest", "vendors", "common" ]     
        } ),
        new HtmlWebpackPlugin( {
            title: "about",
            filename: "views/about.html",
            template: "src/views/about.html",
            chunks: [ "about", "manifest", "vendors", "common" ]
        } ),
        new HtmlWebpackPlugin( {
            title: "list",
            filename: "views/list.html",
            template: "src/views/list.html",
            chunks: [ "list", "manifest", "vendors", "common" ]
        } ),
        new webpack.ProvidePlugin( {
            // npm i jquery -S 安装jquery，然后利用ProvidePlugin这个webpack内置API将jquery设置为全局引入，从而无需单个页面import引入
            $: "jquery"
        } ),
        new CleanWebpackPlugin( ["dist"] )
    ],
    // 提取公共模块，包括第三方库和自定义工具库等
    optimization: {
        // 找到chunk中共享的模块,取出来生成单独的chunk
        splitChunks: {
            chunks: "all",  // async表示抽取异步模块，all表示对所有模块生效，initial表示对同步模块生效
            cacheGroups: {
                vendors: {  // 抽离第三方插件
                    test: /[\\/]node_modules[\\/]/,     // 指定是node_modules下的第三方包
                    name: "vendors",
                    priority: -10                       // 抽取优先级
                },
                utilCommon: {   // 抽离自定义工具库
                    name: "common",
                    minSize: 0,     // 将引用模块分离成新代码文件的最小体积
                    minChunks: 2,   // 表示将引用模块如不同文件引用了多少次，才能分离生成新chunk
                    priority: -20
                }
            }
        },
        // 为 webpack 运行时代码创建单独的chunk
        runtimeChunk:{
            name:'manifest'
        }
    }
}
```
多页面多入口场景中，使用以上配置可以正常打包。

上例加上JQuery这个第三方库，为方便各页面引用，利用webpack内置API中的ProvidePlugin对象将jquery设置成全局对象以供使用，无需在各页面import了。

另外也多处引用有一个util.js的自定义工具库。

上例通过`optimization.splitChunks`配置将第三方库分离打包到vendors.js文件中，将自定义工具库util.js分离打包到common.js文件中。

如下是多入口项目完整目录截图，dist目录为打包后目录：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190228_1.png?raw=true)

本篇实现单入口/多入口打包功能。采用插件为`html-webpack-plugin`。分离共用模板插件为`SplitChunksPlugin`。
