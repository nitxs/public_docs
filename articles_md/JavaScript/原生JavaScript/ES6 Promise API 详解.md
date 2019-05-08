本篇系统总结ES6 Promise API。

## new Promise(...) 

先看下 new Promise(...) 构造器。

new Promise(...) 构造器的参数必须提供一个函数回调。这个回调是同步的或者立即调用的。这个函数又接受两个函数回调参数，用以支持promise的决议。通常把这两个函数回调参数称为 `resolve()`和`reject()`：
```javascript
var p = new Promise( function(resolve, reject){
    // resolve() 用于决议/完成这个promise
    // reject() 用于拒绝这个 promise
} )
```
reject()就是拒绝这个promise。但是resolve()既可能完成promise，也可能拒绝，要根据传入参数而定。如果传给resolve()的是一个非Promise、非thenable的立即值，这个promise就会用这个值完成。
但是如果传给resolve()的是一个真正的Promise或thenable值，这个值就会被递归展开，并且(要构造的)promise将取用其最终决议值或状态。
```javascript
var p1 = function(num){
    return new Promise(function (resolve, reject) {
        if(num > 10){
            resolve(num);
        }else {
            reject("num 小于等于10");
        }
    })
}

function res() {
    return new Promise(function (resolve, reject) {
        //传入的是Promise值，此时resolve()递归传递出去的值要依据传入的promise值而定，是完成还是拒绝状态，并且(要构造的)promise将取用其最终决议值或状态
        resolve(p1(12));        // 完成状态
        // resolve(p1(6));      // 拒绝状态
    })
}
res()
.then(function (val) {
    console.log(val);
})
.catch(function (err) {
    console.log(err);
})
```

## resolve()和reject()

下面看下resolve()和reject()。

创建一个已被拒绝的Promise的快捷方式是使用Promise.reject()，所以以下两个promise是等价的：
```javascript
var p1 = new Promise(function(resolve, reject){
    reject("Oops!")
})

var p2 = Promise.reject("Oops!")
```
Promise.resolve() 常用于创建一个已完成的Promise，使用方式与Promise.reject()类似。但是Promise.resolve()也会展开thenable值。在这种情况下，返回的Promise采用传入的这个thenable的最终决议值，可能是完成，也可能是拒绝。
```javascript
var fulfilledTh = {
    then: function(cb){ cb(42) }
}
var rejectedTh = {
    then: function(cb, errCb){
        errCb("Oops")
    }
}
var p1 = Promise.resolve(fulfilledTh);
var p2 = Promise.resolve(rejectedTh);

// p1是完成的promise
// p2是拒绝的promise
```
此外，如果传入的是真正的Promise，Promise.resolve()什么都不会做，只会直接把这个值返回。所以对不了解属性的值调用Promise.resolve()，如果它恰好是一个真正的Promise，是不会有额外开销的。
```javascript
// p1(..)的返回值是一个真正的Promise
var p1 = function(num){
    return new Promise(function (resolve, reject) {
        if(num > 10){
            resolve(num)
        }else {
            reject("num 小于等于10")
        }
    })
}
var res = Promise.resolve(p1(12));
res
.then(function(val){
    console.log(val);
})
.catch(function (err) {
    console.log(err);
})
```

## then()和catch()
每个Promise**实例**都有then()和catch()方法，通过这两个方法可以为这个Promise注册完成和拒绝处理函数。当Promise决议之后，会**立即调用**这两个处理函数**之一**，但不会两个都调用，而且总是**异步调用**。

`then()`接受一个**或**两个参数：第一个用于**完成回调**，第二个用于**拒绝回调**。如果两者中的任何一个被省略或者作为非函数值传入的话，就会替换为相应的默认回调。默认完成回调只是把消息传递下去，而默认拒绝回调则只是重新抛出(传播)其接收到的出错原因。

`catch()`只接受一个拒绝回调作为参数，并自动替换默认完成回调。也就是说，其等价于`then(null, rejected)`:
```javascript
p.then(fulfilled);
p.then(fulfilled, rejected);
p.cathc(rejected);      // 或者 p.then(null, rejected);
```
`then()`和`catch()`也会创建并返回一个新的promise，这个promise可以用于实现Promise链式流程控制。如果完成或拒绝回调中抛出异常，返回的promise是被拒绝的。如果任意一个回调返回非Promise、非thenable的立即值，这个值就会被用作返回promise的完成值。如果完成处理函数返回一个promise或者thenable，那么这个值就会被展开，并作用返回promise的决议值。

## Promise.all([...]) 和 Promise.race([...])
ES6 Promise API有两个**静态**辅助函数：`Promise.all([...])`和`Promise.race([...])`。它们都会创建一个Promise作为它们的返回值。这个promise的决议完全由传入的promise数组控制。

对`Promise.all([...])`来说，只有传入的所有promise都完成，返回promise才能完成。如果有任何promise被拒绝，返回的主promise就会立即被拒绝(并且会抛弃任何其他promise的结果)。如果完成的话，就会得到一个数组，其中包含传入的所有promise的完成值。对于拒绝的情况，你只会得到第一个拒绝promise的拒绝理由值。这种模式传统上被称为门，即所有人都到齐了才开门。

对于`Promise.race([...])`来说，只有第一个决议的promise(完成或拒绝)取胜，并且其决议结果成为返回promise的决议。这种模式传统上称为门闩，即第一个到达者打开门闩通过。

```javascript
var p1 = Promise.resolve(42);
var p2 = Promise.resolve("Hello World");
var p3 = Promise.reject("Oops");

//如果有任何promise被拒绝，返回的主promise就会立即被拒绝(并且会抛弃任何其他promise的结果)，你只会得到第一个拒绝promise的拒绝理由值
Promise.all([p1, p2, p3])
.then(function(val){
    console.log(val);
})
.catch(function(err){
    console.log(err);   // Oops
})

// 第一个决议的promise(完成或拒绝)取胜，并且其决议结果成为返回promise的决议
Promise.race([p1, p2, p3])
.then(function(val){
    console.log(val);   // 42
})
.catch(function(err){
    console.log(err);   
})

// 如果完成的话，就会得到一个数组，其中包含传入的所有promise的完成值
Promise.all([p1, p2])
.then(function(val){
    console.log(val);   // [42, Hello World]
})
.catch(function(err){
    console.log(err);   
})
```
注意，如果向`Promise.all([...])`中传入空数组，它会立即完成，但`Promise.race([...])`会挂住，且永远不会决议。
```javascript
// 向`Promise.all([...])`中传入空数组，它会立即完成
Promise.all([])
.then(function(val){
    console.log(val);   // []
})
.catch(function(err){
    console.log(err);
})

// 向`Promise.race([...])`中传入空数组，它会挂住，且永远不会决议
Promise.race([])
.then(function(val){
    console.log(val);   // 不进决议
})
.catch(function(err){
    console.log(err);   // 不进拒绝
})
```

以上就是ES6 Promise API，它们非常直观也很用，对于异步的支持很友好，可以用来重构回调地狱代码，使代码更易于追踪和维护。