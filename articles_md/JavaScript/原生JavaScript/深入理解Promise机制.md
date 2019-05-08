promise篇章1

本篇开始回顾下ES6中的`Promise`。注意是回顾，如果想从基础看promise的话，推荐看阮一峰大神的ES6入门中的promise章节。

在这个API面世之前，js开发者写异步代码主要用的是“回调函数”。但回调地狱什么的，想必有过经历都懂，难写难看难维护，真是不想看第二眼。所以`Promise`出来后备受欢迎。

当我下决心并把`Promise`真正弄懂之后，恨不得抱着`Promise`亲两口，把垃圾的回调一脚踢到天涯海角去，唔，那种心情想必有过经历的也懂，哈哈~~~

在开始看`Promise`代码之前，先拿一个实际生活案例来对`Promise`运行机制有个初步印象：

>和妹子去餐厅吃牛排，找到位子坐下来后第一件事就是拿菜单点单，唔，这个这个那个一顿乱戳，选好菜品呼叫服务生确认菜单，服务生确认后去开单然后把菜品账单拿回来给你，告知20分钟内所有菜品将上齐，请耐心等待。点菜就是一个请求的过程，菜品账单就是一个承诺，保证最终会得到那些菜。所以得保存好菜品账单，这代表未来的菜品，所以此时无需担心。在等菜的过程中你可以和妹子在位子上讲话增进感情了。你对那些菜已经抱有想象，味道咋样？妹子喜不喜欢吃？价钱划不划算？菜虽然还上来但你已有这些想法，依据是大脑已经把菜品账单当作菜品的占位符，从本质上讲，这个占位符使得值不再依赖时间，这是一个未来值。终于服务生上菜了，上完菜就是一个承诺值完成的过程。当然也有可能会出现另一种情况，服务生抱歉的告诉你某样菜没有了，此时除了失望、愤怒，但还应看到未来值的另一个重要特性：它可能成功，也可能失败。

基于上例理解，`Promise`就是一个未来值承诺会执行的过程，不管这个未来值是成功还是失败。

下面给出Primise的一个使用实例。

```javascript
function add(xPromise, yPromise) {
    // Promise.call([..])接收一个promise数组并返回一个新的promise
    // 这个返回的新promise等待数组中的所有promise完成
    return Promise.all([xPromise, yPromise])
}

var xPromise = function () {
    return new Promise(function (resolve, reject) {
                var str = "hello";
                setTimeout(function () {
                    if(str){
                        resolve(str);
                    }else {
                        reject("str is undefined.");
                    }
                }, 1000)
            })
            .then(function (res) {
                return res;
            })
            .catch(function (err) {
                console.log(err);
            })
}

var yPromise = function () {
    return new Promise(function (resolve, reject) {
                var str = "world";
                setTimeout(function () {
                    if(str){
                        resolve(str);
                    }else {
                        reject("str is undefined.");
                    }
                }, 2000)
            })
            .then(function (res) {
                return res;
            })
            .catch(function (err) {
                console.log(err);
            })
}

// xPromise()和yPromise()返回相应值的promise，可能已经就绪，也可能以后就绪
add( xPromise(), yPromise() )
// add函数返回的promise决议后，取得收到的x值和y值加在一起
.then(function (valArr) {
    console.log(valArr);
    return valArr[0] + " " + valArr[1];
})
// 得到一个两个数组的和的promise，继续链式调用then()来等待返回新的promise
.then(function (sum) {
    console.log(sum);
})
```
xPromise()和yPromise()是直接调用的，它们的返回值(是promise)被传给add()，第二层是add()，通过`Promise.all([..])`创建并返回的promise，通过调用then()来等待这个promise。

就像上面的点菜案例一样，Promise决议的结果可能是完成也可能是拒绝。拒绝值和完成的Promise不一样：完成值总是编程给出，而拒绝值，也叫拒绝原因(reject reason)则可能是程序逻辑直接设置的，也可能是从运行异常隐式得出的值。

通过Promise，调用then()实际上可以接收两个函数参数，第一个是用于完成情况，第二个是用于拒绝情况：
```javascript
add( xPromise(), yPromise() )
.then(
    //完成处理函数
    function (sum) {
        console.log(sum);
    },
    //拒绝处理函数
    function (err) {
        console.log(err);
    },
)
```
但通常的写法是把拒绝原因写在最后统一的catch中，而不写在then()里面。

关于promise有一个设计中最基础也是最重要的因素，promise决议后就是外部不可变的值，可以安全的把这个值传递给第三方，并确信它不会被有意无意的修改。

promise是一种封装和组合未来值的易于复用的机制。