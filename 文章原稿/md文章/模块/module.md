今天开始研究`jquery`源码。

从jq官网down下最新的未压缩版代码并打开后，首先看下整体，这就是一个大型的自执行的匿名函数：

```javascript
( function( global, factory ) {

    "use strict";

    if ( typeof module === "object" && typeof module.exports === "object" ) {

        // For CommonJS and CommonJS-like environments where a proper `window`
        // is present, execute the factory and get jQuery.
        // For environments that do not have a `window` with a `document`
        // (such as Node.js), expose a factory as module.exports.
        // This accentuates the need for the creation of a real `window`.
        // e.g. var jQuery = require("jquery")(window);
        // See ticket #14549 for more info.
        module.exports = global.document ?
            factory( global, true ) :
            function( w ) {
                if ( !w.document ) {
                    throw new Error( "jQuery requires a window with a document" );
                }
                return factory( w );
            };
    } else {
        factory( global );
    }

// Pass this if window is not defined yet
} )( typeof window !== "undefined" ? window : this, function( window, noGlobal ) {

    //这里编写jquery主体代码...

    // AMD
    if ( typeof define === "function" && define.amd ) {
        define( "jquery", [], function() {
            return jQuery;
        } );
    }

    var
        // Map over jQuery in case of overwrite
        _jQuery = window.jQuery,

        // Map over the $ in case of overwrite
        _$ = window.$;

    jQuery.noConflict = function( deep ) {
        if ( window.$ === jQuery ) {
            window.$ = _$;
        }

        if ( deep && window.jQuery === jQuery ) {
            window.jQuery = _jQuery;
        }

        return jQuery;
    };

    if ( !noGlobal ) {
        window.jQuery = window.$ = jQuery;
    }

    return jQuery;
} );
```
这个自执行匿名函数需要传入`global`和`factory`两个形参，分别指全局变量和一个工厂函数。

在这个匿名函数的函数体中对当前所处环境进行判断：
- 如果所处为支持`CommonJS`的环境中时，如有`window`属性和`document`属性存在，则通过`module.exports`暴露出工厂函数并可取得`jQuery`对象以供使用；否则仅暴露出给定抛出错误的工厂函数，比如`Nodejs`环境
- 非第一种情况时，则执行匿名函数体中的`factory( global )`，并在工厂函数中进行AMD的判断、命名冲突检测和全局暴露等操作。

想到这里，需要先停下，我需要重新回顾下`CommonJS`、`AMD`和`CMD`模块规范，扎实下知识点，另外再借此机会复习ES6中新增的模块规范部分。

## 一、CommonJS

`CommonJS`的诞生是由于早先原生js没有模块系统而出现的，它可以在任何地方运行，不只是浏览器，还可以在服务端，其最有名的应用实现就是`NodeJS`。

`CommonJS`的模块规范：**一个文件就是一个模块，每个模块都拥有单独的作用域。普通方式定义的变量、函数、对象都属于该模块内。**
- 通过`exports`和`module.exports`来暴露模块中的内容。
- 通过`require`来加载模块。

使用 exports 暴露模块接口：
```javascript
//studygd.js
var hello = function () {
    console.log('hello studygd.com.');
}
exports.hello = hello;

//main.js
const studygd = require('./studygd');
studygd.hello();

//打印：
//hello studygd.com.
```

使用 modul.exports 暴露模块对象:
```javascript
//studygd2.js
//模块内的私有变量，没有被暴露
let text = 10;
//公开方法
function Study(){
    let name;
}
Study.prototype.setName = function (myName) {
    this.name = myName;
}
Study.prototype.hello = function () {
    console.log(`Hello `+ this.name);
}

module.exports = Study;

//main2.js
let Study = require('./studygd2');
let study = new Study();
study.setName('nitx');
study.hello();

//打印：
//Hello nitx
```
那么`exports`和`module.exports`有什么区别么？
- `module.exports` 初始值为一个空对象 `{}`
- `exports` 是指向的 `module.exports` 的引用
- `require()` 返回的是 `module.exports` 而不是 `exports`

## 二、AMD
`AMD`全称是`Asynchromous Module Definition`，即异步模块定义。它的最有名的实现是`RequireJS`，它是一个浏览器端模块开发的规范。`AMD` 模式可以用于浏览器环境并且允许非同步加载模块，也可以按需动态加载模块。

`AMD`模块规范：
- 通过异步加载模块，模块加载不是影响后面语句的运行，所有依赖某些模块的语句块放置在回调函数中。
- `AMD` 规范只定义了一个函数 `define`，通过 `define` 方法定义模块。
- `AMD` 规范允许输出模块兼容 `CommonJS` 规范。

在实际使用中，页面需首先加载`require.js`即：`<script type="text/javascript" src="require.js"></script>`，才可使用，具体示例可以看文档。

## 三、CMD
`CMD` 全称为 Common Module Definition，它的最著名实践是`SeaJS`。

`CMD`和`AMD`相近，区别如下：
- 对于依赖的模块 `CMD` 是延迟执行，而 `AMD` 是提前执行（不过 `RequireJS` 从 2.0 开始，也改成可以延迟执行。 ）
- `CMD` 推崇依赖就近，`AMD` 推崇依赖前置
- `AMD` 的 `api` 默认是一个当多个用，`CMD` 严格的区分推崇职责单一，其每个 `API` 都简单纯粹

## 四、ES6的模块规范
`ES6`的模块规范如下：
- 一个模块就是一个独立的文件。该文件内部的所有变量，外部无法获取，如果如果你希望外部能够读取模块内部的某个变量，就必须使用`export`关键字输出该变量
- `export` 命令用于规定模块的对外接口，通常情况下，export输出的变量就是本来的名字，但是可以使用as关键字重命名
- `import` 命令用于输入其他模块提供的功能
- `ES6` 模块的设计思想是尽量的静态化，使得编译时就能确定模块的依赖关系，以及输入和输出的变量

模块功能主要有两个命令构成：`export`和`import`。`export`命令用于规定模块的对外接口。`import`命令用于输入其他模块提供的功能。

```javascript
//export.js
let firstName = 'Ni';
let lastName = 'tx';
let year = 30;
function fn(){
    console.log(2234);
}
export {
        firstName, 
        lastName, 
        year,
        fn as clgFn
    };

//import.js
import {firstName} from '../exportPack/e1';
console.log(firstName);

//打印：
//Ni
```
这里有个注意点，现在浏览器和nodejs对于es6模块的支持依然不完全，所以在实际使用中最好通过`babel`兼容下。

不过未来是ES6模块规范的，这里引述阮一峰的ES6一书一段话：
>在 ES6 之前，社区制定了一些模块加载方案，最主要的有 CommonJS 和 AMD 两种。前者用于服务器，后者用于浏览器。ES6 在语言标准的层面上，实现了模块功能，而且实现得相当简单，完全可以取代 CommonJS 和 AMD 规范，成为浏览器和服务器通用的模块解决方案。ES6 模块的设计思想是尽量的静态化，使得编译时就能确定模块的依赖关系，以及输入和输出的变量。CommonJS 和 AMD 模块，都只能在运行时确定这些东西。比如，CommonJS 模块就是对象，输入时必须查找对象属性。由于 ES6 模块是编译时加载，使得静态分析成为可能。有了它，就能进一步拓宽 JavaScript 的语法，比如引入宏（macro）和类型检验（type system）这些只能靠静态分析实现的功能。除了静态加载带来的各种好处，ES6 模块还有以下好处：不再需要UMD模块格式了，将来服务器和浏览器都会支持 ES6 模块格式。目前，通过各种工具库，其实已经做到了这一点；将来浏览器的新 API 就能用模块格式提供，不再必须做成全局变量或者`navigator`对象的属性；不再需要对象作为命名空间（比如Math对象），未来这些功能可以通过模块提供。

除了指定加载某个输出值，还可以使用整体加载，即用星号（*）指定一个对象，所有输出值都加载在这个对象上面。

好，以上就是现有的JS模块加载回顾，总结就是ES6模块是现在和未来，在`Vue`、`React`等框架配合`webpack`进行项目构建时，可成熟使用，但在jquery等较老库中时，尚未可用，以后也基本不会多支持。而`CommonJS`、`AMD`等模块规范倒是向下兼容的更好，`jQuery`中兼容好用，其中`CommonJS`多用于服务端，而`AMD`则用于浏览器端，其中代表性实现是`RequireJS`。

所以现在在技术选型选择模块规范时，如用到`jQuery`，则搭配`RequireJS`使用；如用到`Vue`+`Webpack`，则使用ES6模块。

好，以上就是今天的`jQuery`源码研究开篇，仅仅只是看了个头，就引出模块规范这个大知识点，脑子里知道和真正写出来的差别还是挺大的，在以后的源码研究中，涉及到的知识点，我都会延伸，熟悉的就回顾，不熟的学习。
