在使用`Promise`时，一个很重要的细节是如何确定值是不是真正的Promise，或者说它是不是一个行为方式类似于Promise的值？

一种检测方法是基于认为既然Promise是通过`new Promise(...)`创建的，那就可以通过`p instanceof Promise`来检查，但事实上这不足以作为检测方法。

原因很多，最主要的是Promise值可能是从其他浏览器窗口(iframe等)接收到的。这个浏览器窗口自己的Promise可能和当前窗口/frame的不同，所以这样的检查是无法识别Promise实例的。另外，有些库或者框架也有可能会选择实现自己的Promise，而不是使用原生的ES6 Promise来实现。

识别Promise(或者行为类似于Promise的东西)就是定义某种被称为thenable的东西，将其定义为任何具有then()方法的对象和函数，我们认为，任何这样的值就是Promise一致的thenable。

比较好的识别方法是通过鸭子类型检查来判断是否为Promise值。即根据一个值的形态(具有哪些属性)对这个值的类型做出一些假定。所谓的鸭子类型，就是“如果它看起来像只鸭子，叫起来像只鸭子，那它一定就是鸭子。”所以对thenable值的鸭子类型检查就大致类似于这样实现：
```javascript
// promise对象的鸭子类型判断
function promiseDuckCheck(p) {
    if( p!=null && ( typeof p === "object" || typeof p === "function" ) && typeof p.then === "function" ){
        return true
    }else {
        return false;
    }
}

var p = new Promise(function (resolve, reject) {});
console.log(typeof p);              // object
console.log(promiseDuckCheck(p));   // true     鸭子类型检测为Promise值

var o = {
    a: 1
    then: function () {  }
}
//让c对象的[[Prototype]]链到o对象
var c = Object.create(o);
console.log(promiseDuckCheck(o));   // true     虽然为true，但对象o不是Promise值，只是对象拥有then()方法
console.log(promiseDuckCheck(c));   // true     虽然为true，但对象c也不是Promise值，只是原型对象c拥有then()方法
```
这种通过鸭子类型来检测Promise值的方法比较粗糙，也不是很靠谱，比如如果一个对象本身有then()方法或者它的原型对象上有then()方法时，就比较尴尬了，示例如上的对象o和对象C。

promise的强大在于，promise为链式调用，如果不显式返回一个值，就会隐式返回undefined，并且这个promise仍然会以同样方式链接在一起。每个Promise的决议就成了继续下一个步骤的信号：
```javascript
function delay(timer){
    return new Promise(function(resolve, reject){
        setTimeout( resolve, timer );
    })
}

delay(100)
.then(function setp2(val) {
    console.log("setp2 after 100ms");
    return delay(200);
})
.then(function setp3() {
    console.log("setp3 after another 200ms");
})
.then(function setp4() {
    console.log("setp4 next job");
    delay(50);
})
.then(function setp5() {
    console.log("setp5 after another 50ms");
})

//打印结果：
/*
setp2 after 100ms
test3.html:81 setp3 after another 200ms
test3.html:84 setp4 next job
test3.html:88 setp5 after another 50ms
*/
```
当不用定时器，而用更常见的ajax请求时，可以这样：
```javascript
//假设存在工具 ajax(url, callback)
//定义一个工具request(..)，用来构造一个表示ajax()调用完成的promise
function request(url){
    return new Promise(function(resolve, reject){
        // ajax回调应该是这里promise的resolve()函数
        ajax(url, resolve);
    })
}
request("http://some.url.1")
.then(function(response1){
    return request( "http://some.url.2/?v=" + response1 )
})
.then(function(response2){
    return request( "http://some.url.3/?v=" + response2 )
})
.then(function(response3){
    console.log(response3);
})
.catch(function(err){
    console.log(err)
})
```
利用返回Promise的`request()`，通过使用第一个url调用它来创建链接中第一步，并且把返回的promise与第一个then()连接起来。

response1一返回，就可以使用这个值构造第二个url，并发出第二个request()调用。第二个request()的promise返回，以便异步流控制中的第三步等待这个ajax调用完成。第三步重复此行为。直到第四步response3返回并打印该值。

如果在链式调用中，有地方报错就执行reject()抛出错误，并由最后的catch()统一捕获。

在实际开发中，可以像这样通过promise构造ajax链式进行异步流调用。这样好维护也避免写出回调嵌套那样难看又难维护的代码。