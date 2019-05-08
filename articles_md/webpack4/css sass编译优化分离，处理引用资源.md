在上篇中，解决了webpack4关于多页面及分离第三方库js和共用自定义库js的配置，本篇将以此为基础继续配置css引入、分离等功能。

本篇实现功能：css转换，sass编译转换，css代码优化压缩合并和提取，css图片资源定位路径的转换，处理浏览器css兼容，css中对静态资源(如图片)的引用打包，引用优化(base64)。

首先需要明确关于css打包的概念：**webpack构建工程中，html页面里不需要引入css文件，通过js间接的获取样式（import引入css文件，和js模块引入一样），这样整个html只需要引入一个js文件即可。**js中如要使用样式，直接引用相应样式类名即可(和js模块方法一样引用使用)。

先说下webpack4中对于css模块的处理需要用到的插件及功能：
- `style-loader`：将处理结束的css代码存储在js中，运行时嵌入`<style>`后挂载到html页面上
- `css-loader`：加载器，使webpack可以识别css文件
- `postcss-loader`：加载器，承载autoprefixer功能。是对css的扩展，编译后转换成正常的css且会自动加上前缀，配合 autoprefixer 使用。
- `sass-loader`：加载器，使webpack可以识别`sass/scss`文件，默认使用`node-sass`进行编译，
- `mini-css-extract-plugin`：插件，webpack4启用的插件，可以将处理后的css代码提取为单独的css文件
- `optimize-css-assets-webpack-plugin`：插件，实现css代码压缩
- `autoprefixer`：自动化添加跨浏览器兼容前缀

在webpack中为了从javascript模块中import一个css文件，需要在module配置中安装并添加style-loader和css-loader。

下面给出单入口单纯使用css样式文件时的带注释配置方案：
```javascript
const path = require( "path" );
const webpack = require( "webpack" );
const fs = require( "fs" );
const HtmlWebpackPlugin = require( "html-webpack-plugin" );         // 用于生成html文件的插件
const CleanWebpackPlugin = require( "clean-webpack-plugin" );       // 每次运行打包时清理过期文件
const MinCssExtractPlugin = require( "mini-css-extract-plugin" );   // 将css代码提取为独立文件的插件
const OptimizeCssAssetsWebpackPlugin = require( "optimize-css-assets-webpack-plugin" );     // css模块资源优化插件
const env = process.env.NODE_ENV　!== "production";  // 判断node运行环境   

module.exports = {
    entry: "./src/index.js",
    output: {
        filename: "[name].bundle.js",
        path: path.resolve( __dirname, "dist" )
    },
    devtool: "inline-source-map",
    module: {
        // 多个loader是有顺序要求的，从右往左(从下往上)，因为转换的时候是从右往左(从下往上)转换的
        rules: [
            {
                test: /\.css$/,
                include: [path.resolve(__dirname, 'src')],   // 限制打包范围，提高打包速度
                exclude: /node_modules/,                     // 排除node_modules文件夹
                use: [
                    // {    // 当配置MinCssExtractPlugin.loader后，此项就无需配置，原因看各自作用
                    //     loader: "style-loader"  // 将处理结束的css代码存储在js中，运行时嵌入`<style>`后挂载到html页面上
                    // },
                    {
                        loader: MinCssExtractPlugin.loader  // 将处理后的CSS代码提取为独立的CSS文件，可以只在生产环境中配置，但我喜欢保持开发环境与生产环境尽量一致
                    },
                    {
                        loader: "css-loader"    // CSS加载器，使webpack可以识别css文件
                    }
                ]
            }
        ]
    },
    plugins: [
        new HtmlWebpackPlugin( {
            filename: "index.html",
            template: "src/index.html",
            chunks: [ "main" ]
        } ),
        new MinCssExtractPlugin( {
            //为抽取出的独立的CSS文件设置配置参数
            filename: "[name].css"
        } ),
        new CleanWebpackPlugin( ["dist"] )
    ],
    optimization: {
        //对生成的CSS文件进行代码压缩 mode='production'时生效
        minimizer: [
            new OptimizeCssAssetsWebpackPlugin()
        ]
    }
}
```

接下来就是多入口单纯使用css样式文件时的带注释配置方案，添加了postcss-loader，用于添加css前缀；另添加scss编译打包配置，sass-loader依赖node-sass。

需要注意的是，module.rules.use数组中，loader 的位置。根据 webpack 规则：放在最后的 loader 首先被执行。所以，首先应该利用sass-loader将 scss 编译为 css，剩下的配置和处理 css 文件相同。

此外，还配置引用静态资源，使用file-loader、url-loader。具体内容可以看注释：
```javascript
const path = require( "path" );
const webpack = require( 'webpack' );
const fs = require( "fs" );
const HtmlWebpackPlugin = require( "html-webpack-plugin" );         // 用于生成html文件的插件
const CleanWebpackPlugin = require( "clean-webpack-plugin" );       // 清理过期文件
const MinCssExtractPlugin = require( "mini-css-extract-plugin" );   // 将css代码提取为独立文件的插件
const OptimizeCssAssetsWebpackPlugin = require( "optimize-css-assets-webpack-plugin" );     // css模块资源优化插件
// 设置nodejs的开发/生产环境，步骤依次为：npm i cross-env -D  /  package.json中script 启动命令中设置
const env = process.env.NODE_ENV !== "production";  // 判断运行环境

// 配置入口对象与html-webpack-plugin实例集合，约定对应html的js与html同名以便自动化生成入口对象
const entries = {};     // 保存文件入口
const pages = [];       // 存放html-webpack-plugin实例
(function () {
    let pagePath = path.join( __dirname, "src/views" );     // 定义存放html页面的文件夹路径，此处值为 F:\modules\webapck4\w4-2\src\views
    let paths = fs.readdirSync(pagePath);                   // 获取pagePath路径下的所有文件，此处值为 [ 'about.html', 'index.html', 'list.html', 'main.html' ]
    paths.forEach( page=>{
        page = page.split( "." )[0];        // 获取文件名（不带后缀），例： [ 'about', 'html' ]，当前page值就为字符串about
        pages.push( new HtmlWebpackPlugin( {
            filename: `views/${page}.html`,     // 生成的html文件的路径（基于出口配置里的path）
            template: path.resolve( __dirname, `src/views/${page}.html` ),      // 参考的html模板文件
            chunks: [ page, "common", "vendors", "manifest" ],       // 配置生成的html引入的公共代码块 引入顺序从右至左
            // favicon: path.resolve(__dirname, 'src/img/favicon.ico'),            // 配置每个html页面的favicon
        } ) );
        entries[page] = path.resolve( __dirname, `src/js/${page}.js` );     // 入口js文件对象
    } )
})();

const config = {
    entry: entries,
    output: {
        filename: "js/[name].[chunkhash].bundle.js",
        path: path.resolve( __dirname, "dist" )
    },
    devtool: "inline-source-map",
    mode: 'development',
    module: {
        // 多个loader是有顺序要求的，从右往左(从下往上)，因为转换的时候是从右往左(从下往上)转换的
        rules: [
            {
                test: /\.(jpg|png|svg|gif)/,
                use: [
                    // {
                    //     // webpack通过file-loader处理资源文件，它会将rules规则命中的资源文件按照配置的信息（路径，名称等）输出到指定目录，并返回其资源定位地址（输出路径，用于生产环境的publicPath路径），默认的输出名是以原文件内容计算的MD5 Hash命名的
                    //     loader: "file-loader",
                    //     options: {
                    //         outputPath: "images/"
                    //     }
                    // },
                    {
                        // 构建工具通过url-loader来优化项目中对于资源的引用路径，并设定大小限制，当资源的体积小于limit时将其直接进行Base64转换后嵌入引用文件，体积大于limit时可通过fallback参数指定的loader进行处理。
                        // 打包后可以看到小于8k的资源被直接内嵌进了CSS文件而没有生成独立的资源文件
                        loader:'url-loader',
                        options:{
                          limit:8129,//小于limit限制的图片将转为base64嵌入引用位置
                          fallback:'file-loader',//大于limit限制的将转交给指定的loader处理，开启这里后就无需再单独配置file-loader
                          outputPath:'images/'//options会直接传给fallback指定的loader
                        }
                    }
                ]
            },
            {
                test: /\.css$/,
                include: [path.resolve(__dirname, 'src')],   // 限制打包范围，提高打包速度
                exclude: /node_modules/,                     // 排除node_modules文件夹
                use: [
                    // {    // 当配置MinCssExtractPlugin.loader后，此项就无需配置，原因看各自作用
                    //     loader: "style-loader"  // 将处理结束的css代码存储在js中，运行时嵌入`<style>`后挂载到html页面上
                    // },
                    {
                        loader: MinCssExtractPlugin.loader,  // 将处理后的CSS代码提取为独立的CSS文件，可以只在生产环境中配置，但我喜欢保持开发环境与生产环境尽量一致
                    },
                    {
                        loader: "css-loader"    // CSS加载器，使webpack可以识别css文件
                    },
                    {   
                        loader: "postcss-loader"    //承载autoprefixer功能，为css添加前缀
                    },
                ]
            },
            {
                test: /\.scss$/,
                include: [path.resolve(__dirname, 'src')],   // 限制打包范围，提高打包速度
                exclude: /node_modules/,                     // 排除node_modules文件夹
                use: [
                    // {    // 当配置MinCssExtractPlugin.loader后，此项就无需配置，原因看各自作用
                    //     loader: "style-loader"  // 将处理结束的css代码存储在js中，运行时嵌入`<style>`后挂载到html页面上
                    // },
                    {
                        loader: MinCssExtractPlugin.loader,  // 将处理后的CSS代码提取为独立的CSS文件，可以只在生产环境中配置，但我喜欢保持开发环境与生产环境尽量一致
                    },
                    {
                        loader: "css-loader"    // CSS加载器，使webpack可以识别css文件
                    },
                    {   
                        loader: "postcss-loader"    //承载autoprefixer功能，为css添加前缀
                    },
                    {
                        loader: "sass-loader",       // 编译sass，webpack默认使用node-sass进行编译，所以需要同时安装 sass-loader 和 node-sass
                        options: {      // loader 的额外参数，配置视具体 loader 而定
                            sourceMap: true, // 要安装resolve-url-loader，当此配置项启用 sourceMap 才能正确加载 Sass 里的相对路径资源，类似background: url(../image/test.png)
                        }
                    }
                ]
            },
        ]
    },
    plugins: [
        ...pages,
        // 引入jquery
        new webpack.ProvidePlugin( {
            $: "jquery",
            jQuery: 'jquery',
            'window.$': 'jquery',
            'window.jQuery': 'jquery'
        } ),
        new MinCssExtractPlugin( {
            filename: "[name].css"
        } ),
        new CleanWebpackPlugin( ["dist"] )
    ],
    // 提取公共模块，包括第三方库和自定义工具库等
    optimization: {
        // 找到chunk中共享的模块,取出来生成单独的chunk
        splitChunks: {
            chunks: "all",      // async表示抽取异步模块，all表示对所有模块生效，initial表示对同步模块生效
            cacheGroups: {
                vendors: {  // 抽离第三方插件
                    test: /[\\/]node_modules[\\/]/,     // 指定是node_modules下的第三方包
                    name: "vendors",
                    priority: -10       // 抽取优先级
                },
                commons: {      // 抽离自定义工具库
                    name: "common",
                    priority: -20,      // 将引用模块分离成新代码文件的最小体积
                    minChunks: 2,       // 表示将引用模块如不同文件引用了多少次，才能分离生成新chunk
                    minSize: 0
                }
            }
        },
        // 为 webpack 运行时代码创建单独的chunk
        runtimeChunk: {
            name: "manifest"
        },
        // 对生成的CSS文件进行代码压缩 mode='production'时生效
        minimizer: [
            new OptimizeCssAssetsWebpackPlugin()
        ]
    },
    // 配置webpack执行相关
    performance: {
        maxEntrypointSize: 1000000, // 最大入口文件大小1M
        maxAssetSize: 1000000       // 最大资源文件大小1M
    }
}

module.exports = config;
```

此时看下贴出的package.json文件：
截图1
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190304_0.png?raw=true)

看下整个项目目录：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190304_1.png?raw=true)
