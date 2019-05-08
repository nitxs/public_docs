《你不知道的JavaScript》第二部分`this`和对象原型第 4 篇。

前篇说了this绑定的例外情况，比如当以为是应用的其他绑定规则时，其实应用的可能是默认绑定。

## 例外情况1：this忽略

当把null或者undefined作为this的绑定对象传入call、apply或bind时，这些值在调用时会被忽略，此时实际应用的是默认绑定规则。
```javascript
function fn(){
    console.log(this.a);
}
var a = 10;
fn.call(null);      // 10
```
上例这种传入null的情况是非常常见的。

比如用apply将某个数组展开以便传入某个不关心this的函数:
```javascript
function fn(a, b){
    console.log( a*2 + b*3 );
}
//把数组展开成参数传入函数fn中
fn.apply(null, [10, 4]);    //32
```
或者使用bind()来对参数进行柯里化(预先设置一些参数):
```javascript
function fn(a, b){
    console.log( a*2 + b*3 );
}
//通过bind()，返回一个新函数，该函数类似于fn的拷贝，并且传入 5 预设为a值
var bar = fn.bind(null, 5);
bar(7);     //31
```
上面两个示例方法都需要传入一个参数作为this的绑定对象，如果函数不关心this要绑定到何处，但又需要传入一个占位值，这里较好的选择是传入null。

这里有个小知识点，针对上面展开数组的操作，在ES6中可以通过`...`来代替apply()，即`fn(...[10, 4])`和`fn(10, 4)`是一样的，这样能够避免非必要的this绑定。但是ES6中没有相应的函数柯里化语法，所以仍然需要通过bind()来进行函数的柯里化。

唔，通常情况下，如果函数内不关心this指向，使用null来作为this的绑定对象是没有问题，但偶尔也会有些问题，比如函数用到第三库的方法时，可能this会有特定的绑定对象，此时如对函数的this进行上述绑定操作，容易产生一些难以觉查的bug，所以在不是完全确定的情况下，可以采用一种更佳实践(《你不知道的javascript》书中推荐)，将this绑定到一个完全为空的对象上：
```javascript
function fn(a, b){
    console.log( a*2 + b*3 );
}
//创建一个完全空对象，Object.create(null)和 {} 很像，但并不会创建Object.prototype这个委托，其比 {} 更空
var Ø = Object.create(null);

fn.apply( Ø, [10, 4] );      // 32

// 使用bind()进行函数柯里化
var bar = fn.bind( Ø,5 )
bar(7);     // 31
```

## 例外情况2： 函数的间接引用
这种情况在之前的示例中有出现过，函数的间接引用会出现在有意无意的函数赋值操作时发生：
```javascript
function fn(){
    console.log(this.a);
}
var a = 10;
var obj = {a:3, fn:fn};
var p = {a:4};

obj.fn();       // 3
(p.fn = obj.fn)();      //10
console.log( p.fn = obj.fn );   
/* 上行代码打印结果：
ƒ fn(){
    console.log(this.a);
}
*/
```
在上例中`p.fn = obj.fn`的返回值是目标函数fn的引用，因此调用位置是fn()而不是p.fn()。那么此时就是应用默认绑定。

这里有个小知识点要注意，对于默认绑定来说，决定this绑定对象的不是函数调用位置是否处于严格模式，而是函数定义位置的函数体是否处于严格模式。如果函数体处于严格模式，则this会被绑定到undefined上，否则就会绑定到全局对象上。

## 例外情况3： 软绑定
现在我们知道函数的绑定规则中有个叫显式绑定，其中又有一种比较特殊的绑定形式叫硬绑定，使用`Function.prototype.bind()`来实现，则ES5提供实现。这个硬绑定可以把this强制绑定到指定对象，从而防止函数调用应用默认绑定规则。

但这个硬绑定有个不足之处，即一旦对函数实施硬绑定，那除非使用new绑定外，其他绑定规则都不通再修改函数体的this绑定。显然会在一定程度上限制程序的灵活性。

那么是否有办法来实现既可以防止函数调用应用默认绑定规则，又可以方便灵活的再次修改this绑定呢？

办法是有的，和硬绑定通过Function.prototype来添加实例方法bind类似，具体实现过程如下：
```javascript
if(!Function.prototype.softBind){
    Function.prototype.softBind = function(obj){
        var fn = this;
        //捕获所有 curried 参数
        var curried = [].slice.call( arguments, 1 );    // 将softBind()的参数从索引1处开始全部转变成数组
        var bound = function(){
            return fn.apply(
                (!this || this === (window || global)) ? obj : this,
                curried.concat.apply( curried, arguments )  //合并softBind传入的参数和 fn.apply()传入的参数为新数组
            )
        }
        bound.prototype = Object.create( fn.prototype );
        return bound;
    }
}
```
解释： softBind()方法首先会检查调用时的this，如果this绑定到全局对象或者undefined，那就把指定的默认对象obj绑定到this，否则不会修改this。

下面来看看这个软绑定是否起作用：
```javascript
function fn(){
    console.log(this.a);
}
var obj1 = {a:1},
    obj2 = {a:2},
    obj3 = {a:3};

var bar = fn.softBind(obj1);
bar();      // 1

obj2.fn = fn.softBind(obj1);
obj2.fn();      // 2

bar.call( obj3 );       // 3

setTimeout(obj2.fn, 1000)   // 1
```
可以看到，在将fn中this绑定到对象obj1后，再将函数引用赋值给obj2，即修改函数fn的调用位置上下文对象为obj2时，可以实现修改this绑定，使用call()修改this绑定对象也能工作。但如果应用默认规则时，则会将this绑定到obj。

唔，尽管这样起作用，但是我个人是不推荐直接修改 `Function.prototype`的，直接修改`Function`的原型，还是有隐患的，特别是在常规项目中，如非没有其他办法，一般不推荐这样修改污染原型对象。可以采用其他折中办法。

## 例外情况4： 箭头函数
在ES6中，箭头函数对this的对象绑定作用机制完全不一样。箭头函数并不是使用function关键字定义的。而是根据 `=>` 操作符定义的。

箭头函数不使用常规函数this的四种标准绑定规则，而是**根据外层(函数或全局)作用域来决定this绑定，并且一旦绑定就不可修改，即使是new绑定也不行**。
```javascript
function fn(){
    //返回一个箭头函数
    return a => {
        // this继承自fn()
        console.log(this.a);
    }
}

var obj1 = {a: 2},
    obj2 = {a: 3};

var bar = fn.call(obj1);
bar.call(obj2);     // 2 而不是3!
```
可以看到，fn函数返回一个箭头函数，根据箭头函数this的绑定规则，这个箭头函数中的this继承自外层函数fn中的this绑定的对象，也即是this绑定对象为obj1。

箭头函数常用的场景是回调函数中，比如事件处理器或者定时器：
```javascript
function fn(){
    setTimeout(()=>{
        //这里的this继承自外层函数fn
        console.log(this.a)
    }, 1000)
}

var obj = {a: 2};
fn.call(obj);   // 2
```
所以用箭头函数时，this绑定规则就很简单，直接继承自外层函数或全局作用域即可，不需要再去记常规函数的调用位置+4个绑定规则了。

箭头函数this试图用更常见的词法作用域来替代让人困扰的this机制(类似动态作用域)。

当然在ES5中也可以使用词法作用域来规避麻烦的this机制：
```javascript
function fn(){
    var self = this;
    setTimeout(function(){
        console.log(self.a);
    })
}
var obj = {a: 4};
fn.call(obj);   // 4
```
唔，这是一种取巧的办法。

所以通常来说，绑定函数的this对象，可以使用常规的this机制，也可以使用`self=this`或箭头函数来否定this机制，具体选哪个，看你更习惯哪种代码风格，没有谁优谁劣的，只要代码写出来注意优雅可维护就好。

最后，来为4篇this做个技术总结吧：
1. 有function关键字的函数内部关心this绑定的情况下，判定this绑定对象需要注意函数的调用位置和比较四种绑定规则
    - new绑定，优先级最高。this绑定到new 构造调用函数后创建出来的新对象上。
    - 显式绑定，优先级次之。由 call/apply或者bind 调用函数时指定的对象上
    - 隐式绑定，优先级再次之。由函数调用时上下文对象作为函数内部this绑定的对象。
    - 默认绑定，优先级最低。严格模式下this绑定到undefined，非严格模式下this绑定到全局对象。
2. 注意有些调用可能会无意中应用默认绑定规则，此时可以使用 `apply(null)`来忽略this绑定，更安全的做法是使用一个完全空集对象，例如`var Ø = Object.create(null); fn.apply(Ø);`，以保护全局对象
3. ES6中的箭头函数不遵循前述四种绑定规则，而是根据词法作用域来决定this绑定。即箭头函数会继承外层函数**调用**时的this绑定，并且不会管这个this绑定到底是什么。这点其实在ES5中已有实现，为`var self = this;`机制。