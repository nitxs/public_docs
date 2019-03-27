在js中，对于对象的理解很重要。

js的数据类型主要分为基本类型和引用类型。基本类型包括`String`、`Number`、`Boolean`、`undefined`、`null`。引用类型包括`Object`。

通常判断一个数据类型是基本类型可以使用`typeof`，判断一个数据类型是引用类型的可以使用`instanceof`。

本文要讲的其实就是基于引用类型对象来说的。所谓的对象其实可以理解为**若干属性的集合**。狭义的对象`object`是对象，`Function`也是对象，`Array`同样也是对象。

`object`对象可以自由添加属性和方法是众所周知的，那么`Function`和`Array`可以使用同样的方法添加属性和方法么？

```javascript
var fn = function(){
    console.log(100);
}
fn.a = 20;      //函数fn添加属性a
fn.b = function(){      //函数fn添加方法b
    console.log('aaa');
}
fn.c = {        //函数fn添加属性c, c的值是个对象
    a: 29
}
console.log(fn);
console.log(fn.a);
console.log(fn.b());
console.log(fn.c);

//打印
/*
ƒ (){
    console.log(100);
}
b1.html:25 20
b1.html:19 aaa
b1.html:26 undefined
b1.html:27 {a: 29}
*/
```
上例就是函数添加属性和方法。至于向数组添加属性和方法，在实际工作中数组的方法使用的应该不少了吧，比如`concat`、`slice`之类的，所以结论是只要是对象，js中都可以自由添加属性和方法。

现在我们明确知道，**函数就是对象的一种**。但函数和对象其实有种鸡生蛋蛋生鸡的感觉。因为对象的创建`var obj = {a:1}`的本质行为是:
```javascript
var obj = new Object();
obj.a = 1;

var arr = new Array();
arr[0] = 10

console.log(typeof Object); //function
console.log(typeof Array); //function
```
可以很明确的看到，狭义对象或数组本质上都是通过函数来创建出来的。此时我又要祭出我珍藏已久的JS万物图了，相信筒子们可以图中理解Function和Object之间的互相关系了。

其实函数本身就是有属性的，无需通过上文举例来证明函数可以添加属性，这个函数的已有属性就是`prototype`。

```javascript
var Fn = function(){};  //定义构造函数Fn
Fn.prototype.getStatus = function(){};   //在构造函数Fn的原型上添加getStatus方法
var fn = new Fn();  //通过构造函数Fn进行new出来一个实例对象fn，

//fn的原型链指向Fn的原型
//即：fn.__proto__ === Fn.prototype
```
每个函数`function`都有一个原型属性，即`prototype`。每个对象都有一个隐式原型链，即`__proto__`，对象的`__proto__`指向该对象构造器的`prototype`原型。
```javascript
var obj = new Object();
console.log(obj.__proto__ === Object.prototype);    //true
```
上例可以用一个图来表示：
图2

这里有一个问题，js中所有对象其实最终都指向`Object.prototype`，那么这个`Object.prototype`又指向哪里呢？指向`null`看图：
图3

所以结合上面几个图，可以形成这样一个结论：

>在JS世界中，`null`为开始，由`null`开始衍生出`Object.prototype`。`Object.prototype`的隐式原型链指向`null`。正向来说`Object.prototype`是构造函数`Function Object()`的原型`prototype`，反过来说`Object.prototype`的构造器`constructor`也是构造函数`Function Object()`。这里`Object.prototype`和`Function Object()`的关系比较容易混淆，但请认真记住。

下面给出完事原型图：
图4

从上图可以看出一个关系，那就是js中的各对象间都是通过原型链来互相连接起来的，这个原型链将所有对象链接在了一起，这就是为什么说JS是基于原型的面向对象编程语言，即使现在有es6 7有了class类，它本质上也是基于原型链形成的语法糖而已。

js中实现的继承就是通过这条原型链来工作的：在访问一个对象的某个属性时，先该对象的现有属性中查找，如果没有，再沿着`__proto__`这种链向上找，这就是原型链。















