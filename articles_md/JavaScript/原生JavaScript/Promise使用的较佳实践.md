本章讨论下Promise使用时的较佳实践。

## 顺序错误处理
Promise的设计局限性有一个让人掉坑的地方，即Promise链中错误容易被无意中默默忽略掉。

由于一个Promise链仅仅是连接到一起的成员Promise，没有把整个链标识为一个个体的实体，这意味着没有外部方法可以用于观察可能发生的错误。

如果构建了一个没有错误处理函数的Promise链，链中任何地方的错误都会在链中一直传播下去，直到被查看(通过在某个步骤注册拒绝处理函数)。可以是在某个步骤的then()中注册拒绝处理函数，也可以是有一个在指向链中最后一个promise的引用处注册拒绝处理函数，这个拒绝处理函数可以得到所有传播过来的错误的通知：
```javascript
// foo() step2()、step3()都是支持promise的工具
var p = foo(42)
        .then(step2())
        .then(step3())

p.catch(handleErrors);
```
p指向的是最后一个promise，即来自调用then(step3())的那个。在上例前半段的promise链中任何一个步骤都没显式处理自身错误，此时可以在p上注册一个拒绝错误处理函数，这样对于链中任何位置出现的任何错误，这个处理函数都会得到通知。

## 传递多个值
根据定义，在Promise中只能有一个完成值或一个拒绝理由，简单情况下这就够了，但在复杂情况下可能就会受限。

方法一：通常的建议是构造一个值封装(比如对象或数组)来保持这样的多个信息。虽然这个方案有效，但如果要在链条每一步都进行这样封装和解封，就显得不那么优雅。

值封装的情况：
```javascript
function get(res) {
    return new Promise(function (resolve, reject) {
                setTimeout(function () {
                    resolve( (3*res) - 1 );
                }, 1000)
            })
}

function foo(x, y) {
    var res = x * y;

    return  get(res)
            .then(function (val) {
                return [res, val];
            })
}

foo(10, 20)
.then(function (val) {
    var a = val[0];
    var b = val[1];

    console.log(a, b);      // 200  599
})
```

方法二：分裂值。

出现如下情况时，可以考虑把问题分解成两个或者更多的Promise来试试：

分裂成两个promise来试试：
```javascript
function get(res) {
    return new Promise(function (resolve, reject) {
                setTimeout(function () {
                    resolve( (3*res) - 1 );
                }, 1000)
            })
}

function foo(x, y) {
    var res = x * y;

    return  [
        Promise.resolve(res),
        get(res)
    ]
}

Promise.all( foo(10, 20) )
.then(function (val) {
    var a = val[0];
    var b = val[1];

    console.log(a, b);      // 200  599
})
```
尽管这种写法从语法角度看相比第一种写法没什么改进，但代码更整洁灵活。

## 单决议
Promise最本质的特征是：Promise只能被决议一次(完成或拒绝)。

在许多异步情况中，只会获取一个值一次，所以这可以工作良好。

但还有很多异步的情况适合另一种模式，即一种类似于事件或数据流的模式。

设想这样的一个场景：要启动一系列异步步骤以响应某种可能多次发生的情况，例如点击事件。看下面的伪代码：
```javascript
// 假设有一个ajax工具 ajax(url, callback)
// request()是一个支持promise的ajax封装
function request(url){
    return new Promise(function(resolve, reject){
        // ajax回调应该是这里promise的resolve()函数
        ajax(url, resolve);
    })
}

// 由于promise只能决议一次，而点击按钮可能会点击多次，所以可以在事件点击处理函数中定义整个Promise链
var btnA = document.getElementById("btnA");
btnA.onclick = function (event) {
    var btnId = event.target.id;

    request("http://some.url.1/?id=" + btnId)
    .then(function(data){
        console.log(data);
    })
}
```
尽管这样将Promise链放在事件处理函数中会显得丑陋，但由于Promise只能决议一次的特性，目前只能先这样放。

总的来说，Promise并没有抛弃回调，只是把回调的安排转交给一个位于我们和其他工具之间的可信任的中介机制。Promise链提供了以顺序的方式表达异步流的一个更好的方法，这有助于大脑更好的组织和维护js代码。