职责链的定义：使多个对象都有机会处理请求，从而避免请求的发送者和接收者之间的耦合关系，将这些对象连成一条链，并沿着这条链传递该请求，直到有一个对象能处理它为止，传递链中的这些对象就叫节点。

需求背景： 一个电商网站，用户交500定金且定金已付时，可享受500优惠券且不受货物数量限制；用户交200定金且定金已付时，可享受500优惠券且不受货物数量限制；用户不交定金时受货物数量限制，有货时原价买，无货时则无法买。

原始版本， if else一路判断
```javascript
var buyOrder = function(orederType, pay, stock){
    if(orederType == 1){
        if(pay){
            console.log('500优惠券');
        }else {
            if(stock > 0){
                console.log('普通购物页面');
            }else {
                console.log('已无货');
            }
        }
    }else if(orederType == 2){
        if(pay){
            console.log('200优惠券');
        }else {
            if(stock > 0){
                console.log('普通购物页面');
            }else {
                console.log('已无货');
            }
        }
    }else if(orederType == 3){
        if(stock > 0){
            console.log('普通购物页面');
        }else {
            console.log('已无货');
        }
    }
}

buyOrder(1, true, 600)
```

改进版本
```javascript
var order500 = function(orderType, pay , stock){
    if(orderType == '1' && pay == true){
        console.log('500优惠券');
    }else {
        order200(orderType, pay , stock)
    }
}

var order200 = function(orderType, pay , stock){
    if(orderType == '2' && pay == true){
        console.log('200优惠券');
    }else {
        orderNormal(orderType, pay , stock)
    }
}

var orderNormal = function(orderType, pay , stock){
    if(stock > 0){
        console.log('普通购物页面');
    }else {
        console.log('已无货');
    }
}

order500(3, true, 0)
```

优化版本1：
同步的职责链
```javascript
//3个订单函数 ，它们都是节点函数
var order500 = function(orderType, pay , stock){
    if(orderType == '1' && pay == true){
        console.log('500优惠券');
    }else {
        return 'nextSuccessor';     //我不知道下个节点是谁，反正把请求往后传递
    }
}

var order200 = function(orderType, pay , stock){
    if(orderType == '2' && pay == true){
        console.log('200优惠券');
    }else {
        return 'nextSuccessor';     //我不知道下个节点是谁，反正把请求往后传递
    }
}

var orderNormal = function(orderType, pay , stock){
    if(stock > 0){
        console.log('普通购物页面');
    }else {
        console.log('已无货');
    }
}

//职责构造函数
var Chain = function(fn){
    this.fn = fn;
    this.successor = null;
}

Chain.prototype.setNextSuccessor = function(successor){     //设置职责顺序方法
    this.successor = successor
}

Chain.prototype.passRequest = function(){       //请求传递
    var ret = this.fn.apply(this, arguments)

    if(ret === 'nextSuccessor'){
        return this.successor && this.successor.passRequest.apply(this.successor, arguments)
    }

    return ret;
}

//把3个订单函数分别包装成职责链的节点
var chainOrder500 = new Chain(order500)
var chainOrder200 = new Chain(order200)
var chainOrderNormal = new Chain(orderNormal)

//然后指定节点在职责链中的顺序
chainOrder500.setNextSuccessor(chainOrder200)
chainOrder200.setNextSuccessor(chainOrderNormal)

//最后把请求传递给第一个节点，开启职责链模式传递
chainOrder500.passRequest(1, true, 500)     //500优惠券
chainOrder500.passRequest(3, true, 20)      //普通购物页面
chainOrder500.passRequest(3, true, 0)       //已无货

//此时如果中间有需求改动，只需如此做： 
var order300 = function(){
    if(orderType == '3' && pay == true){
        console.log('300优惠券');
    }else {
        return 'nextSuccessor';     //我不知道下个节点是谁，反正把请求往后传递
    }
}
var chainOrder300 = new Chain(order300)     //添加新职责节点
chainOrder500.setNextSuccessor(chainOrder300)
chainOrder300.setNextSuccessor(chainOrder300)   //修改职责链顺序
chainOrder200.setNextSuccessor(chainOrderNormal)

//这样，就可以完全不必去理会原来的订单函数代码，只需增加一个节点，然后重新设置职责链中的相关节点的顺序就行。
```

优化版本2：异步的职责链

在实际开发中，经常会遇到 一些异步的问题，比如要在节点函数中发起一个ajax请求，异步请求返回的结果才能决定是否继续在职责链中passRequest

可以给Chain类再增加一个原型方法：
```javascript
//职责构造函数
var Chain = function(fn){
    this.fn = fn;
    this.successor = null;
}

Chain.prototype.setNextSuccessor = function(successor){     //设置职责顺序方法
    this.successor = successor
}

Chain.prototype.passRequest = function(){       //请求传递
    var ret = this.fn.apply(this, arguments)

    if(ret === 'nextSuccessor'){    //传递给职责链中的下一个节点
        return this.successor && this.successor.passRequest.apply(this.successor, arguments)
    }

    return ret;
}

//新增，表示手动传递请求给职责链中的下一个节点
Chain.prototype.next = function(){
    return this.successor && this.successor.passRequest.apply(this.successor, arguments)
}


//异步职责链例子
var fn1 = new Chain(function(){
    console.log(1);
    return 'nextSuccessor'
})

var fn2 = new Chain(function(){
    console.log(2);
    var self = this;
    setTimeout(function(){
        self.next()
    }, 1000)
})

var fn3 = new Chain(function(){
    console.log(3);
})


//指定节点在职责链中的顺序
fn1.setNextSuccessor(fn2)
fn2.setNextSuccessor(fn3)

//把请求传递给第一个节点，开始节点传递
fn1.passRequest()

//输出 1 2 ...(1秒后)... 3

//这是一个异步职责链，请求在职责链节点中传递，但节点有权利决定什么时候 把请求交给下一个节点。这样可以创建一个异步ajax队列库。 
```

*tips:*

这里补充个知识点："短路求值"  `&&` 会返回第一个假值`（0, null, "", undefined, NaN）`，而 `||` 则会返回第一个真值。

`var x = a || b || c ` 等价于：
```javascript
var x;
if(a){
    x = a;
} else if(b){
    x = b;
} else {
    x = c;
}
```

`var x = a && b && c ` 等价于：
```javascript
var x = a;
if(a){
    x = b;
    if(b){
        x = c;
    }
}
```

所以 `&&` 有时候会用来代替 `if (expression) doSomething()`，转成 `&& `方式就是 `expression && doSomething()`。

而 `||` 比较用来在函数中设置默认值，比如：
```javascript
function doSomething(arg1, arg2, arg3) {
    arg1 = arg1 || 'arg1Value';
    arg2 = arg2 || 'arg2Value';
}
```

不过还需要看具体的使用场景，就比如如果要求 `doSomething()` 传入的 arg1 为一个数值，则上面的写法就会出现问题（在传入 0 的时候被认为是一个假值而使用默认值）。

现在个人比较常用的方法只判断是否与 `undefined` 相等，比如

```javascript
function doSomething(arg) {
    arg = arg !== void 0 ? arg : 0;
}
```

> 职责链模式的优势：解耦请求发送者和N个接收者之间的复杂关系，由于不知道链条中的哪个节点可以处理你发出的请求，所以只需把请求传递给第一个节点就行。

如果在实际开发中，当维护一个含有多个条件分支语句的巨大函数时时，可以使用职责链模式。链中的节点对象可以灵活拆分重组，增加删除节点，且无需改动其他节点函数内的代码。