《你不知道的JavaScript》第二部分`this`和对象原型第 1 篇。

本篇来看下js中的`this`关键字。

刚接触`this`关键字的时候，一脸懵逼，看字面意思很好理解，日常英语中的this指代“这个”，有指向的意思，难道这个关键字意思也是如此？作为纯自学起来的我，在踩了那么多坑后，已然条件反射般的感觉不对劲。果不其然，在新手阶段，我是看概念懵、抄demo懵、用起来更懵，完全不知什么鬼，这个this到底指向哪？关于这个`this`，硬啃了好久，经常一会懂一会懵的，工作中想用还不敢用了。后来勉强算熟手了，才算慢慢用起来，边用边理解，发现果然坑还是很多，但等到确实理解后，发现也没什么可怕的。人一胆大，就是一句话了：不要怂，就是干~~

好，先从最开始看这个`this`。

在全局作用域中，`this`指向全局变量；此外函数中的`this`关键字并不指向函数本身，以浏览器环境为例：
```javascript
var count = 0;
function fn(num){
    console.log("fn:" + num);
    console.log(this);      // window
    this.count++;
}
fn.count = 0;
for(var i=0; i<5; i++){
    fn(i);
}
console.log(fn.count);  // 0
console.log(count);     // 5
// for循环中fn函数执行5次
/*
fn:0
fn:1
fn:2
fn:3
fn:4
*/
```
从上例输出可以看到：
- 函数调用时，函数体内的this并不指向自身，因为函数fn中的this打印结果指向的是全局对象`window`，全局对象的属性`count`值最后打印为5；函数fn多次调用后函数属性`count`值依然是0，而非如预期的5。
- 函数体内的this不是指向函数本体，而是指向调用函数的对象。

那么针对上例，如果我想把函数中的`this`指向函数本身呢？可以使用js中的另一个神奇的武器：`call`或`apply`来修改this指向。
```javascript
function fn(num){
    console.log("fn: " + num);
    console.log(this);
    this.count ++;
}
fn.count = 0;
for(var i=0; i<5; i++){
    fn.call(fn, i);     //这里将fn函数内的this指向由指向全局对象window改为指向fn函数
}
console.log(fn.count);  // 5
console.log(count);     // ReferenceError: count is not defined
```
瞧，在fn函数调用时，通过`call`来修改fn函数内的this指向来达到递增fn函数属性count的目的。

上面两个小例子，只是`this`使用的起始，想用好this，先理解this的机制：

>`this`是在运行时进行绑定的，并不是在编写时绑定的，它的上下文取决于函数调用时的条件。`this`的绑定和函数声明的位置没有任何关系，只取决于函数的调用方式。一句话：**`this`其实是在函数被调用时发生的绑定，它指向什么完全取决于函数在哪里被调用。**

关于上下文，很多人一直不理解或者似懂非懂，我觉得下面这段话讲的很到位：

当一个函数被**调用**时，会创建一个**活动记录(也叫执行上下文)**。这个记录会包含函数在哪里被调用(调用栈)、函数的调用方法、传入的参数等信息。`this`就是其中一个属性，会在函数执行过程中用到。