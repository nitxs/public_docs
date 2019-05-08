本篇继续看下对象的内置属性`[[Prototype]]`。

在js中`[[Prototype]]`属性最常出现的地方构造函数添加“原型方法”上面了。
```javascript
function Foo(name){
    this.name = name;
}
Foo.prototype.showName = function(){
    return this.name;
}
var obj = new Foo("nitx");
obj.showName();     // nitx
```
瞧，上面是js中最常见的类构造函数创建新实例对象，然后实例对象调用类的成员方法的过程。

唔，习惯了java之类的面向对象思维的同学一看，没毛病，就是这么个道理，对Foo类的有参构造方法进行new一下，创建出一个复制了Foo成员属性和成员方法的新对象obj。

但是！

js中是不存在类的！

js是基于原型的，面向原型的。

上面这段代码的正确描述应是：普通函数Foo拥有一个所有函数都有的公有且不可枚举的属性`[[Prototype]]`，这个属性的作用就是指向另一个对象，这个对象通常被称为Foo的原型，因为通常是通过名为`Foo.prototype`的属性引用来访问它。对象a是在调用 `new Foo()`时创建的，最后会被关联到"Foo点prototype"对象上，也就是对象a会被**关联**到`Foo.prototype`。注意，是关联哦，不是像类创建对象那样复制出一个新对象那样。用js的方式理解就是，对象a的原型就指向了`Foo.prototype`对象了，来验证下：
```javascript
function Foo(){}
var obj = new Foo();
Object.getPrototypeOf(obj) === Foo.prototype;    // true
```
证明`new Foo()`创建出来的新对象obj的原型的确指向了Foo.prototype这个对象了。

看到这里，需要仔细思考下上面说的对象obj关联到Foo.prototype对象的意义所在了。正是这个“关联”用词把js的原型和类彻底区分开来。java等面向对象语言中，类实例化是一个复制过程，可以复制多次创建多个新对象，这个复制的过程就是“把类的行为复制到物理对象中”，对于每个实例对象来说都会重复这一过程。

但在js中，却没有这样的重复机制，不能创建一个类的多个实例，只能创建多个对象，它们的内置属性`[[Prototype]]`指向(关联)的的是同一个对象。但是在默认情况下不会复制，因此这些对象不会完全失去联系，它们是关联的。

即**new Foo()会创建一个新对象obj，这个新对象obj的内置属性[[Prototype]]关联的是Foo.prototype对象。最后我们就得到两个对象，它们之间相互关联，整个过程就是这样。**我们没有初始化一个类，实际上我们都没有从“类”中复制任何行为到一个对象中，只是让两个对象相互关联。

理解了上面的代码的原理，再来回头看下所谓的“构造函数Foo”。它其实不是一个真正意义上的构造函数，因为js中都没有类，就更别提哪来的构造函数了。Foo其实就是一个js最普通的函数罢了，只有当使用 new 关键字来调用函数Foo时，Foo才被称为构造函数，同时为了与普通函数区分，学习了真正的构造函数那样写作首字母大写，以示把它当作构造函数。注意，只是当作，实际这个函数Foo依然是js世界中最普通的一个函数，本质没有改变，只是称呼改变罢了。

除了令人迷惑的“构造函数”之称，还有个容易被搞混的东西`constructor`，看下面代码：
```javascript
function Foo(){};
Foo.prototype.constructor === Foo;      //true
var obj = new Foo();
obj.constructor === Foo;    //true
```
看上面代码，可以暂时这样理解：Foo.prototype默认有一个公有并且不可枚举的属性`constructor`，这个属性引用的是对象关联的函数，上例关联的是Foo函数。另外通过”构造函数“调用`new Foo()`创建的对象obj也有一个属性`constructor`，指向是是创建这个对象的函数。

但这里注意了，实际上new调用创建的新对象obj默认是没有`constructor`这个属性的，虽然`obj.constructor`确实指向了Foo函数，但是它其实是通过原型链委托给了Foo.prototype对象，`obj.constructor`行为访问的其实是obj对象的原型对象`Foo.prototype`对象上的属性`constructor`的值。
```javascript
function Foo(){};
var obj = new Foo();
console.log(Object.getPrototypeOf(obj) === Foo.prototype);  // true
console.log(obj.constructor);                        // Foo
console.log(obj.hasOwnProperty("constructor"));     // fakse
console.log(Foo.prototype.constructor);             // Foo
console.log(Foo.prototype.hasOwnProperty("constructor"));       // true
```
所以上例代码可以看到，obj对象本身确实是没有内置属性`constructor`，而对`obj.constructor`的访问其实全是委托给obj对象的原型链上层对象`Foo.prototype`对象的。

此时可以思考一个问题，看如下代码：
```javascript
function Foo(){};
Foo.prototype = {a:10};
var obj = new Foo();
obj.constructor === Foo;    // 此时还是 true么??????
```
答案是`false`！因为`Foo.prototype = {a:10};`这段代码已经把Foo.prototype指向对象`{a:2}`了，这是一个字面量方法创建的对象，它的原型是Object.prototype。所以此时`obj.constructor`值为Object：
```javascript
obj.constructor === Object;     // true
```
此时如果想要将`obj.constructor`的指向重新修改到预期的Foo身上，就需要重新定义Foo.prototype的属性`constructor`的特性了，用什么方法呢？
```javascript
function Foo(){};
Foo.prototype = {a: 10};
var obj = new Foo();
obj.constructor === Object;     // true
Object.defineProperty(Foo.prototype, "constructor", {
    value: Foo,
    writable: true,
    enumerable: false,
    configurable: true
})
obj.constructor === Foo;       // true
```
好，这样就完成`constructor`指向的修改。

下面来总结下本篇所学：
- js中没有类
- `new Foo()`中Foo本质不是传统面向对象语言中类中的构造函数，而是js普通函数
- 构造函数创建的新对象没有constructor属性，访问它只能通过原型委托进一步访问Foo.prototype对象本身的`constructor`属性值
- `Foo.prototype`对象本身的`constructor`指向可以修改，所以不推荐在实际开发中通过 `obj.constructor`来引用Foo函数