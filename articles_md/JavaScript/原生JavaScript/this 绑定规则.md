《你不知道的JavaScript》第二部分`this`和对象原型第 2 篇。

关于`this`，之前说过，`this`的指向取决于函数调用位置而非函数定义位置。谁调用函数，则函数上下文中的`this`就指向谁。

概念很好理解，但实际使用时，坑实在是多，要注意看。

## 坑一：默认绑定。

在没有应用其他规则时，this绑定遵循默认绑定，但严格模式下与非严格模式下完全不同。
```javascript
//非严格模式
var a = 2;
function fn(){
    console.log(this.a);    // 2
}
fn();

//严格模式
function foo(){
    "use strict";
    console.log(this.a);    // TypeError: Cannot read property 'a' of undefined
}
foo(); 
```
看，非严格模式下，全局作用域中的函数调用时，函数词法作用域内的`this`指向全局对象`window`。而当严格模式时，函数调用时词法作用域内的`this`指向`undefined`，报 `TypeError`错误。

当然上例仅是举例，在实际开发中，不应混用严格与非严格模式。例外情况时引用到第三方库时可能会与原有代码有不同的严格模式，这个时候就有兼容性问题需要注意下。

## 坑二：隐式绑定。

当函数调用位置存在上下文对象时，可能会造成this指向出现意想不到的问题。用的时候需要注意。看下面例子：
```javascript
function fn(){
    console.log(this.a);   // 2
}
var obj = {
    a: 2,
    fn: fn
}
var a = 1;
obj.fn();
```
运行结果是 2 ，也就是取的obj对象属性a的值，而非取的全部对象属性a的值。原因是当函数fn被当作引用属性添加到obj中，调用位置会使用obj上下文来引用函数。即当fn()被调用时，该函数就引用了obj对象的上下文对象，此时隐式绑定规则就会把函数调用中的`this`绑定到这个上下文对象。所以`this.a`就和`obj.a`是一样的。

但这里就有坑了，看下面示例：
```javascript
function fn(){
    console.log(this.a);    // 1
}
var obj = {
    a: 2,
    fn: fn
}
var a = 1;
var foo = obj.fn;
foo();
```
咦，打印结果怎么变成 1 了？ 不应该是2么，fn()函数被当作引用属性添加到obj的上下文对象了呀？注意，这里坑就坑在`var foo = obj.fn`，这段代码又**把fn()函数的引用赋值给了全局变量属性foo**了。当调用foo()时，fn的上下文对象就变成全局作用域的了，好嘛，到obj对象里绕了一圈又出来，绝对坑你没商量的障眼法。

唔，上面这个还算好，仔细想想还容易从坑里爬出来，下面这个绝对就是个坑了：
```javascript
function fn(){
    console.log(this.a);
}
function bar(foo){
    foo();  //回调函数，高能预警 !!!
}
var obj = {
    a: 2,
    fn: fn
}
var a = 1;
bar( obj.fn );  // 1 
```
当将`obj.fn`作为回调函数传入 `bar()` 函数中时，通过传参变量赋值操作，将fn函数由obj.fn标识符引用改为指向foo标识符引用，由于bar函数中的this是指向window对象的，所以此时再执行foo()函数调用时，根据this的默认绑定规则自然会访问全局作用域中的变量a的值。

这个坑非常微妙，很容易栽跟头。

当然如果把上面的bar()函数换成js内置函数如setTimeout，其结果也是一样的：
```javascript
function fn(){
    console.log(this.a);
}
var obj = {
    a: 2,
    fn: fn
}
var a = 1;
setTimeout(obj.fn, 1000);   // 1

//js内置延迟函数实现类似于下面：
function setTimeout(fn, delay){
    // 延迟 delay 时间执行
    fn();   // 调用位置
}
```
所以在回调函数中，this丢失绑定的情况一个不注意就会发生。

## 坑三：显式绑定

针对上面的情况，肯定是有解决办法。那就是用显示绑定，用函数的`call`或`apply`方法来强制绑定`this`。当然，这两个家伙的坑也是能埋人的...

首先这两个方法也有兼容性敢信？js的宿主环境有时会提供一些非常特殊的函数，它们并没有这两个方法，尽管这样的函数非常罕见。js提供的绝大多数函数和用户自己创建的所有函数都可以使用`call`和`apply`方法。

其次需要明白这两个方法的工作机制：它们的第一个参数是个对象，它们会把这个对象绑定到this，接着在函数调用时指定这个this。如此由于是人为指定this的绑定对象，所以也称为显示绑定。看下面例子：
```javascript
function fn(){
    console.log(this.a);
}
var obj = {
    a: 20
}
fn.call(obj);       // 20
```
通过`fn.call()`，可以在函数fn调用时强制把它内部的this绑定到obj对象上面。如果传入的第一个参数是一个原始值(字符串类型、数字类型或布尔类型)来当作this的绑定对象，这个原始值就会被转换成它的对象形式(也就是 `new String(...)`、`new Number(...)`或者`new Boolean(...)`)。唔，这种操作叫做“装箱”，听起来好牛逼...

注意：从this绑定的角度来说，`call()`和`apply()`方法作用是完全一样的，它们的区别只是在于其他参数上，具体可以参考官方资料。

用`call()`和`apply()`方法绑定this 有两种实现方式：硬绑定和API绑定。

硬绑定：
```javascript
function fn(){
    console.log(this.a);
}
function bar(){
    fn.call(obj)
}
var obj = {
    a: 2
}
bar();      // 2
setTimeout(bar, 1000);  // 2

//即使重新绑定也无法修改
bar.call(window);   // 2
```
上述绑定的工作原理是：通过调用函数fn的call方法来将函数内部的this绑定到obj对象上，如此当fn函数调用时，函数内部this就指向了obj对象，`this.a`就和`obj.a`一样。这就是硬绑定。并且这种硬绑定完成后this的指向就是不可修改的。

这种硬绑定的应用场景非常广泛，多用于创建包裹函数，多种常用设计模式也会用到这种硬绑定:
```javascript
function fn(something){
    console.log(this.a, something);     // 2 4
    return this.a + something;
}
function bar(){
    return fn.apply(obj, arguments);
}
var obj = {
    a: 2
}
var res = bar(4);    
console.log(res);   // 6
```
还可以用来写成复用的方法，比如：
```javascript
// 可复用的辅助绑定函数
function bind(fn, obj){
    return function(){
        return fn.apply(obj, arguments);
    }
}

function fn(something){
    console.log(this.a, something);     // 2 5
    return this.a + something;
}
var obj = {a: 2};
var bar = bind(fn, obj);
var res = bar(5);
console.log(res);   // 7
```
当然上例中的辅助绑定函数其实在ES5中已有实现，就是`Function.prototype.bind`。一看这段代码就知，ES5中提供的`bind()`方法是挂载到Function的原型上，也就是说这个bind方法是个货真价实的实例方法，所有函数实例都可以用，来看看它怎么用：
```javascript
function fn(something){
    console.log(this.a, something);     // 2 6
    return this.a + something;
}
var obj = {a: 2};
var bar = fn.bind(obj);
var res = bar(6);
console.log(res);       // 8
```
不要去看mdn上面的解释，写的云山雾罩的，直接跟着这几个示例下来，就大致明白原生js中的bind()方法怎么回事了。bind()会返回一个对内部this硬绑定过的新函数，它会把参数obj设置为原函数this中的上下文并调用原函数。

## 坑四：new绑定
什么叫new绑定呢？看如下代码：
```javascript
function Fn(a){
    this.a = a;
}
var bar = new Fn(10);
console.log(bar.a);
```
这段代码很熟悉吧。它就是常见的构造函数new一个对象。

熟悉面向对象语言的同学肯定更熟悉，这不就是从类里new出来一个对象么？比如`Student s = new Student();`从`Student`类里通过无参构造方法`Student()`来`new`一个对象`s`出来。那这个构造方法是不是就这js中构造函数呢？看起来好像啊。

其实在js中这样理解是错的。

js中本质上是没有类这样概念的，js是基于原型的。`Fn`虽然被称为构造函数，但其实不是真正的构造函数，它本质还是一个普通的函数，只是当它被用来new一个新对象时，才称其为构造函数，正确的理解应该是对函数的“构造调用”。

当使用 new 关键字来发生构造函数调用时，会自动执行如下过程：
- 创建(或是构造)一个全新的对象。
- 这个新对象会被执行原型连接。
- 这个新对象会被绑定到函数调用的this。
- 如果函数没有返回其他对象，那么 new 表达式中的函数调用会自动返回这个新对象。

怎么理解上面这几句话呢？

当执行到 **new 函数调用** 时，如果函数中没有return出对象或者return的不是对象类型，则new表达式就会返回一个全新对象，否则返回的是函数内部return的对象。当new表达式函数调用返回创建出一个全新对象时，这个对象的原型是函数的prototype属性(`bar.__proto__ === Fn.prototype`)，并且**函数内部的this被绑定到这个全新对象上**。

上例代码就是这样理解的，Fn函数中的this被绑定到bar对象上。