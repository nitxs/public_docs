在JS开发中，异步函数是一个绕不过去的坎，要想写出优雅适用的js代码，把异步函数的使用技巧掌握透是必须的。

在es5版本中，异步函数的使用受原生API支持较少影响，好用的方法不多，笨办法可以写出个回调嵌套，在回调嵌套1 2层还好，多了就变成回调地狱了，那种代码的恶心程度，真是不忍直视，比如：
```javascript
//Nodejs 代码
connection.query(sql, (err, result) => {
    if(err) {
        console.err(err)
    } else {
        connection.query(sql, (err, result) => {
            if(err) {
                console.err(err)
            } else {
                ...
            }
        })
    }
})
```
这种代码既难看，又难维护，过段时间如果业务逻辑稍有变动，改动起来就是真恶心了。并且它对异常的捕获也无法支持，找个bug实在令人烦躁。

怎么办？在没有提供原生支持的情况下，只能借助设计模式在尽量写出优雅的js代码，常用的比如发布订阅模式。这就是我非常喜欢用的一种设计模式。

下面给出我常用的发布订阅模式的对象封装：

```javascript
/**
 * 发布订阅对象
 * @param {*} obj   //需要装载发布订阅功能的初始对象
 */
var observer = function(obj){

    //定义发布订阅对象
    var ObserverEvent = (function(){
        var cacheList = {},     //缓存列表，存放订阅者的回调函数
            listen,             //添加订阅方法
            trigger,            //发布消息
            remove;             //取消订阅方法

        listen = function(key, fn){
            if(!cacheList[key]){        //如果还没有订阅过此类消息，给该类消息创建一个缓存列表
                cacheList[key] = []
            }

            cacheList[key].push(fn)     //订阅的消息添加进消息缓存列表
        }

        trigger = function(){
            var key = Array.prototype.shift.call(arguments),     //取出消息类型
                fns = cacheList[key];       //取出该消息对应的回调函数集合

            if(!fns || fns.length==0){      //如果没有订阅该消息，则返回
                return false;
            }

            for(var i=0; i<fns.length; i++){
                fns[i].apply(this, arguments)
            }
        }

        remove = function(key, fn){
            var fns = cacheList[key]
            
            if(!fns || fns.length==0){      //如果key对应的消息没有被订阅，则直接返回
                return false;
            }

            if(!fn){
                fns.length=0
            }else {
                for(var l=fns.length-1; l>=0; l--){
                    var _fn = fns[l]
                    if(_fn == fn){
                        fns.splice(l, 1)
                    }
                }
            }
        }

        return {
            cacheList: cacheList,
            listen: listen,
            trigger: trigger,
            remove: remove
        }
    })()
    
    //定义发布对象安装函数，这个函数可以给所有的对象动态安装发布-订阅功能
    var installEvent = function(obj){
        for(var i in ObserverEvent){
            obj[i] = ObserverEvent[i]
        }
    }

    return installEvent(obj);   //为该对象装载发布订阅功能
}

```
直接向`observer`函数中传递一个空白对象`obj`即可(obj对象自定义自行命名)，`obj`对象通过`for in`方法继承了发布订阅对象`ObserverEvent`的属性与方法，这样在项目中的一个页面上都可以以这个`obj`对象作为页面数据对象，进行事件的订阅与触发。尤其是如果页面`ajax`使用较多且数据互相依赖时，使用发布订阅模式进行数据获取与DOM操作，非常舒服。

除了善用设计模式提高代码优雅程度外，es6原生提供的Promise对象也为异步函数回调提供的比较优雅的解决方案。它把原来的嵌套回调变成了级联调用，很好的解决回调地狱的问题。

以下关于Promise对象的解释内容引用自《ES6标准入门》，感谢大神阮一峰的布道。

>ES6 规定，`Promise`对象是一个构造函数，用来生成`Promise`实例。

```javascript
const promise = new Promise(function(resolve, reject) {
  // ... some code

  if (/* 异步操作成功 */){
    resolve(value);
  } else {
    reject(error);
  }
});
```
>`Promise`构造函数接受一个函数作为参数，该函数的两个参数分别是`resolve`和`reject`。它们是两个函数，由 JavaScript 引擎提供，不用自己部署。

>`resolve`函数的作用是，将`Promise`对象的状态从“未完成”变为“成功”（即从 pending 变为 resolved），在异步操作成功时调用，并将异步操作的结果，作为参数传递出去；`reject`函数的作用是，将`Promise`对象的状态从“未完成”变为“失败”（即从 pending 变为 rejected），在异步操作失败时调用，并将异步操作报出的错误，作为参数传递出去。

>`Promise`实例生成以后，可以用`then`方法分别指定resolved状态和rejected状态的回调函数。
```javascript
promise.then(function(value) {
    //resolved状态回调函数
  // success
}, function(error) {
    //rejected状态的回调函数
  // failure
});
```

`Promise`新建后会立即执行，所以首先输出的是Promise，然后是同步任务执行的结果，然后才是异步回调函数的结果。
```javascript
var timeout = function(ms){
    return new Promise(function(resolve, reject){
        console.log(2355);
        setTimeout(resolve, ms, 'done')
    })
}

timeout(2000).then(function(data){
    console.log(data);
})

console.log('Hi)

//立即打印
2355
'Hi'
//2秒后打印
'done'
```
这里想到个知识点补充下，在浏览器中js同步和异步的执行顺序问题，在浏览器执行栈中，优先执行同步任务，当同步任务全部执行完毕时，才会读取由异步任务组成的队列中的异步任务。这些异步任务还分成宏任务和微任务。

其中同步任务是指`console.log()`打印一条日志、声明一个变量或执行一次加减法操作、调用一个普通函数等等。异步任务的常见操作有`Ajax`、`DOM的事件操作`、`setTimeout`、`Promise`的then方法、Node的文件读取IO操作等。

理解同步异步执行顺序的最好方法还是看图：

前面说过，异步任务分为宏任务和微任务。

宏任务主要有：
> `script`全局任务、`setTimeout`、`setInterval`、`setImmediate`、`I/O`、`UI rendering`

微任务主要有：
>`process.nextTick`、`Promise.then()`、`Object.observe`

在微任务中 process.nextTick 优先级高于Promise。

当一个异步任务入栈时，主线程判断该任务为异步任务，并把该任务交给异步处理模块处理，当异步处理模块处理完打到触发条件时，根据任务的类型，将回调函数压入任务队列。

- 如果是宏任务，则新增一个宏任务队列，任务队列中的宏任务可以有多个来源。
- 如果是微任务，则直接压入微任务队列。

所以上图的任务队列可以继续细化一下：


下面来理下事件执行机制：

- 从全局任务 script开始，任务依次进入栈中，被主线程执行，执行完后出栈。
- 遇到异步任务，交给异步处理模块处理，对应的异步处理线程处理异步任务需要的操作，例如定时器的计数和异步请求监听状态的变更。
- 当异步任务达到可执行状态时，事件触发线程将回调函数加入任务队列，等待栈为空时，依次进入栈中执行。

当异步任务进入栈执行时：

- 由于执行代码入口都是全局任务 script，而全局任务属于宏任务，所以当栈为空，同步任务任务执行完毕时，会先执行微任务队列里的任务。
- 微任务队列里的任务全部执行完毕后，会读取宏任务队列中拍最前的任务。
- 执行宏任务的过程中，遇到微任务，依次加入微任务队列。
- 栈空后，再次读取微任务队列里的任务，依次类推。

```javascript
setTimeout(function(){
    console.log(1);
    Promise.resolve().then(function(){
        console.log(2);
    })
}, 0)
setTimeout(function(){
    console.log(3);
}, 3)
Promise.resolve().then(function(){
    console.log(4);
})
console.log(5);

// 5 4 1 2 3
```
上述行文与代码的结论简单表述是，在js加载时，在加载js脚本`script`文件后，先执行同步任务，当同步任务都执行完毕后，再执行异步任务中的微任务，当微任务都执行完毕后，再执行异步任务中的宏任务。如遇异步任务中包含同步任务或异步任务时，也要记住同步=>异步微任务=>异步宏任务的执行优先级。


下面来看个Promise封装的ajax请求示例
```javascript
var getJson = function(url){
var promise = new Promise(function(resolve, reject){
    var handle = function(){
        if(this.readyState !== 4){
            return ;
        }
        if(this.status === 200){
            resolve(this.resoponse)
        }else {
            reject(new Error(this.statusText));
        }
    };
    var client = new XMLHttpRequest();
    client.open('get', url);
    client.onreadystatechange = handle;
    client.responseType = 'json';
    client.setRequestHeader('Accept', 'application/json');
    client.send();
})

return promise;
}
getJson(orderUrlBase + '/rollBaseOrder/oustStockInfo?wareIds' + wareIds).then(function(data){
console.log(data);
}, function(){
console.log(error);
})
```

上面代码中，getJSON是对 XMLHttpRequest 对象的封装，用于发出一个针对 JSON 数据的 HTTP 请求，并且返回一个Promise对象。需要注意的是，在getJSON内部，resolve函数和reject函数调用时，都带有参数。

如果调用resolve函数和reject函数时带有参数，那么它们的参数会被传递给回调函数。reject函数的参数通常是Error对象的实例，表示抛出的错误；resolve函数的参数除了正常的值以外，还可能是另一个 Promise 实例。


下面代码中，调用resolve(10)以后，后面的console.log(2)还是会执行，并且会首先打印出来。这是因为立即 resolved 的 Promise 是在本轮事件循环的末尾执行，总是晚于本轮循环的同步任务。
```javascript
new Promise(function(resolve, reject){
    resolve(10)
    console.log(2);
})
.then(function(data){
    console.log(data);
}, function(err){
    console.log(err);
})

//2
//10
```
一般来说，调用resolve或reject以后，Promise 的使命就完成了，后继操作应该放到then方法里面，而不应该直接写在resolve或reject的后面。所以，最好在它们前面加上return语句，这样就不会有意外。
```javascript
new Promise(function(resolve, reject){
    return resolve(10)
    console.log(2);
})
.then(function(data){
    console.log(data);
}, function(err){
    console.log(err);
})
//10
```

#### then方法
Promise实例具有then()方法，也就是说then()方法是定义在原型对象`Promise.prototype`上的，`then`方法的第一个参数是`resolved`状态的回调函数，第二个参数(可选)是`rejected`状态的回调函数。

另外需要注意的是，`then`方法返回的是一个新的Promise实例，所以可以使用链式写法，即在`then`方法后面再调另一个`then`方法。
```javascript
getJSON("/post/1.json").then(function(post) {
  return getJSON(post.commentURL);
}).then(function funcA(comments) {
  console.log("resolved: ", comments);
}, function funcB(err){
  console.log("rejected: ", err);
});
```
这里请注意，上段代码中的第一个`then`方法指定的回调函数，返回的是一个Promise对象。第二个`then`方法指定的回调函数，就会等待这个新的Promise对象状态发生变化。如果变为resolvee，就调用funcA，如果状态变为rejected，就调用funcB。


#### catch方法
Promise.prototype.catch()方法是then(null, rejection)的别名，用于指定发生错误时的回调函数。
```javascript
getJSON('/posts.json').then(function(posts) {
  // ...
}).catch(function(error) {
  // 处理 getJSON 和 前一个回调函数运行时发生的错误
  console.log('发生错误！', error);
});
```
上面代码中，getJSON方法返回一个 Promise 对象，如果该对象状态变为resolved，则会调用then方法指定的回调函数；如果异步操作抛出错误，状态就会变为rejected，就会调用catch方法指定的回调函数，处理这个错误。另外，then方法指定的回调函数，如果运行中抛出错误，也会被catch方法捕获。
```javascript
var promise = new Promise(function(resolve, reject){
    // throw new Error('error')
    // resolve(10)
    reject(new Error('can not do it.'))
})
promise.then(function(data){
    console.log(data);
}, function(err){
    console.log(err);
})
.catch(function(err){
    console.log(err);
})

//Error: test
```
这里需要注意下，如果promise状态已经变成resolved，再抛出错误就是没用的。

上面代码中，Promise 在resolve语句后面，再抛出错误，不会被捕获，等于没有抛出。因为 Promise 的状态一旦改变，就永久保持该状态，不会再变了。

Promise 对象的错误具有“冒泡”性质，会一直向后传递，直到被捕获为止。也就是说，错误总是会被下一个catch语句捕获。
```javascript
getJSON('/post/1.json').then(function(post) {
  return getJSON(post.commentURL);
}).then(function(comments) {
  // some code
}).catch(function(error) {
  // 处理前面三个Promise产生的错误
});
```
上面代码中，一共有三个 Promise 对象：一个由getJSON产生，两个由then产生。它们之中任何一个抛出的错误，都会被最后一个catch捕获。

对于promise对象的错误捕获，通常最佳实践是不在then()方法里设置reject状态的回调函数(即then方法的第二个参数，其可选)，而是使用catch方法捕获。
```javascript
// bad
promise
  .then(function(data) {
    // success
  }, function(err) {
    // error
  });

// good
promise
  .then(function(data) { //cb
    // success
  })
  .catch(function(err) {
    // error
  });
```
至于这么写的理由，其实就是第二种写法可以捕获前面then方法中的错误，而如果没有使用catch方法，Promise对象抛出的错误不会传递到外层代码中，即对错误异常不会有任何反应，这会导致无法debug调试。

所以一般总是建议，Promise 对象后面要跟catch方法，这样可以处理 Promise 内部发生的错误。catch方法返回的还是一个 Promise 对象，因此后面还可以接着调用then方法。




