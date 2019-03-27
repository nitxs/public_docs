这两天，在对现有项目进行框架优化，由于项目使用gulp+jQuery构建的，不支持ES6规范，不能很好满足越来越复杂的需求场景，尤其是需要多异步任务的情况下，js又要异步又要操作各种DOM状态，状态与状态间也是各种紧耦合，单纯使用es5和jQuery，已经开始影响开发效率了。

虽然通过相关设计模式的使用，一定程度上减轻了js逻辑处理的复杂度，但看着有更佳实践的ES6语法不能用而只能白流口水，实在是不能忍，尤其是口水已久的ES6中的`Promise`对象，简直异步最爱，也是我这次优化最想拿下的目标。趁有点空闲，果断优化编译流程，打算添加支持编译ES6功能，主要是要支持`Promise`。

为不对现有项目造成影响，我本地新建个小demo，打算最后能编译通过再移植到现有项目中。

新建项目`es`：

图1

其中`src`目录是js源代码目录，本次测试js放在`src/js/test1.js`文件中，测试涉及ES6语法：`let`、`Promise`、`Object.assgin()`、字符串扩展。
```javascript
// Promise 对象
function test(x){
    return new Promise((resolve, reject)=>{
        if(x > 10){
            resolve(x)
        }else {
            reject('x小于10');
        }
    })
}
let result = test(13);
result
    .then((x)=>{
        console.log(x);
    })
    .catch((err)=>{
        console.log(err);
    })

//Object.assign() 方法
const object1 = {
    a: 1,
    b: 2,
    c: 3
};
const object2 = Object.assign({c: 4, d: 5}, object1);  
console.log(object2.c, object2.d);

// ES6 字符串语法
let str1 = '12345';
let str = `口令aa${str1}`;
console.log(str);
```

在es项目根目录创建`package.json`并安装依赖：
- `npm install gulp babel-core gulp-babel babel-preset-env babel-plugin-transform-runtime --save-dev`
- `npm install babel-polyfill --save` 
由于项目打包后还需要对`babel-polyfill`进行依赖，所以安装在`dependencies`中。

图2

`gulp`不用说，是构建工具。

下面是重点：

js作为宿主语言，非常依赖执行环境(浏览器、node等)。不同环境对js语法的支持也不同，甚至不同浏览器可能也会对js语法的支持存在差异。目前对于ES5语法的支持基本都没有问题，但是对于ES6乃至ES7甚至更高版本的JS语法，支持还远没有完善。

在WEB开发中，如果想使用高版本的JS语法用到那些更好的语法实践，就需要先将高版本的JS语法编译成低版本的ES5语法，来尽量兼容各浏览器。`babel`就是用来做这个编译工作。

在`babel5`时，`babel`是全家桶形的，装个`babel`其他就不需要管了，因为所以相关工具插件全装好，但`babel`升级到版本6后，移除全家桶，将各工具拆分成单独模块，比如`babel-core`、`babel-cli`、`babel-node`、`babel-polyfill`等；并且新增了`.babelrc`配置文件，所有babel转译都会先读其中的配置再进行后续操作；新增 `plugin` 配置，所有的东西都插件化，什么代码要转译都能在插件中自由配置；新增 `preset` 配置，`babel5`会默认转译ES6和jsx语法，`babel6`转译的语法都要在perset中配置，preset简单说就是一系列plugin包的使用

其中`babel-core`是核心模块，`babel`的核心api都在这个模块里。比如`transform`：`babel.transform`用于字符串转码得到AST...

`gulp-babel`是专供gulp用的。

**`babel-polyfill`注意，这家伙是有大作用的。** 因为`babel`默认只转译新的JavaScript句法，而不会转译新的API，比如`Iterator`、`Generator`、`Set`、`Maps`、`Proxy`、`Reflect`、`Symbol`、`Promise`等全局对象，以及一些定义在全局对象上的方法（比如Object.assign）都不会转码，所以`babel-polyfill`必加，不然如果项目的js文件中有`Promise`等全局对象,那么就算用  `babel-preset-env` 转化过后,代码中还是存在 `Promise`对象,对于兼容性并没有什么用。(这里我踩了三个小时的坑才爬出来，明明编译通过却没有转译`Promise`，并且还没有任何报错，为找原因差点把头发都拔光，无知害死人啊啊啊...)

上面是`babel`的模块，前面说了，还有个配置文件`.babelrc`需要配置。`babel`所有的操作基本都会来读取这个配置文件，除了一些在回调函数中设置`options`参数的，如果没有这个配置文件，会从`package.json`文件的`babel`属性中读取配置。配置的对象属性为`presets`(预设)、`plugins`插件。

目前官方推荐使用`babel-preset-env`来进行`presets`配置，详情配置如下：
```javascript
// npm install babel-preset-env --save-dev
{
    "presets": [
        ["env", {
            "targets": { //指定要转译到哪个环境
                //浏览器环境
                "browsers": ["last 2 versions", "safari >= 7"],
                //node环境
                "node": "6.10", //"current"  使用当前版本的node
                
            },
             //是否将ES6的模块化语法转译成其他类型
             //参数："amd" | "umd" | "systemjs" | "commonjs" | false，默认为'commonjs'
            "modules": 'commonjs',
            //是否进行debug操作，会在控制台打印出所有插件中的log，已经插件的版本
            "debug": false,
            //强制开启某些模块，默认为[]
            "include": ["transform-es2015-arrow-functions"],
            //禁用某些模块，默认为[]
            "exclude": ["transform-es2015-for-of"],
            //是否自动引入polyfill，开启此选项必须保证已经安装了babel-polyfill
            //参数：Boolean，默认为false.
            "useBuiltIns": false
        }]
    ]
}
```
注意上例中的`mudules`属性，其作用是将es6模块化语法转译成其他类型，这里请根据你生产代码的实现部署场景选择相应的模块规范，选`false`则会转译成ES模块规范，这里也被坑过，比如我开始没选，转译默认选择的`commonjs`的模块规范，结果浏览器打印报`require not defined`错误，也是坑了好久才找到这么个犄角旮旯的知识点，这里要吐槽`babel`的文档不是很全呐。

另外当转译成ES6模块规范后，还有个需要注意的，在html页面script引用编译后js时，由于已经是使用模块化了，所以在script属性中要加上`type="module"`，这块可以看下ES6的 **Module 的加载实现**部分。

关于最后一个参数`useBuiltIns`，有两点必须要注意：
- 如果`useBuiltIns`为`true`，项目中必须引入`babel-polyfill`。
- `babel-polyfill`只能被引入一次，如果多次引入会造成全局作用域的冲突。

下面给出我的`.babelrc`配置
```javascript
{
    "presets": [ [ "env", { 
                    "modules": false } 
                ] ], 
    "plugins": ["transform-runtime"]   // babel-plugin-transform-runtime 在这里使用，可以编译Iterator、Generator、Set、Maps、Proxy、Reflect、Symbol、Promise等全局对象等新的API
}
```
再来看看`plugins`配置。`babel`中的插件，通过配置不同的插件才能告诉`babel`，我们的代码中有哪些是需要转译的，比如转译箭头函数、class语法、for-of等等，可以对单一转译需求进行个性化定制，从而减少最后打包时文件体积。当然，我是不喜欢这样做的，一般WEB开发也不会需要用到这么极端，推荐`babel`+`babel-polyfill`一口气把所有能转译的ES6全支持。一般的建议是开发一些框架或者库的时候使用不会污染全局作用域的babel-runtime，而开发web应用的时候可以全局引入babel-polyfill避免一些不必要的错误，而且大型web应用中全局引入babel-polyfill可能还会减少你打包后的文件体积（相比起各个模块引入重复的polyfill来说）。

唔，写到这里，看下最后的转译JS代码：
```javascript
//es6模块规范
import _Object$assign from 'babel-runtime/core-js/object/assign';
import _Promise from 'babel-runtime/core-js/promise';
// Promise 对象
function test(x) {
    return new _Promise(function (resolve, reject) {
        if (x > 10) {
            resolve(x);
        } else {
            reject('x小于10');
        }
    });
}
var result = test(13);
result.then(function (x) {
    console.log(x);
}).catch(function (err) {
    console.log(err);
});

//Object.assign() 方法
var object1 = {
    a: 1,
    b: 2,
    c: 3
};
var object2 = _Object$assign({ c: 4, d: 5 }, object1);
console.log(object2.c, object2.d);

// ES6 字符串语法
var str1 = '12345';
var str = '\u53E3\u4EE4aa' + str1;
console.log(str);
```
开启服务器模式后，打开浏览器页面，结果报这个错：
图3

这个问题暂时没有解决，因为考虑到其实在打包后需要把相关模块也打包到dist文件里去，再考虑到报错中的路径引用问题，使用gulp暂时无法解决，和webpack相比，确实gulp属于上一代的打包工具明显功能欠缺。或者有更好的解决方案，但时间关系就不去找了。

不过在项目中使用上`Promise`对象的初衷还是要实现的，就换使用流行的`Promise`库吧，也就是`q.js`，毕竟先有的这个库，再有的ES6中的`Promise`语法，而且两者的代码实践居然一模一样，让我有点怀疑两者之间的关系。但不管怎么样，`Promise`对象可用的目标是实现了。

下面给出`q.js`实现的`promise`方案：
```javascript
var imgsrc = "http://jspang.com/static/upload/20181111/G-wj-ZQuocWlYOHM6MT2Hbh5.jpg";
function loadImg(src){
    return new Q.promise(function(resolve, reject){
        var img = document.createElement('img');
        img.onload = function(){
            resolve(img)
        }
        img.onerror = function(){
            reject("图片加载失败")
        }
        img.src = src;
    })
}
var promise = loadImg(imgsrc);
promise
    .then(function(img){
        document.body.appendChild(img);
    })
    .then(function(){
        console.log("图片加载成功");
    })
    .catch(function(err){
        console.log(err);
    })
```
套路和ES6的`Promise`是一样一样的，并且这个库兼容到IE9及以上，也是很不错的。就酱，我把它加入到现有项目JS模块体系中去。

这次对于`babel`进行系统化的研究，基本上里外也都摸了个遍，倒是对我在`webpack`构建中的`babel`理解帮助很大，也算是小有收获吧。