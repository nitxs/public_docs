本篇来看下js中的原生函数，也叫内置函数。主要包括如下：
- String()
- Number()
- Boolean()
- Array()
- Object()
- Function()
- RegExp()
- Date()
- Error()
- Symbol()

原生函数可以被当作构造函数来用，但其构造出来的对象与设想的有区别，以String()为例：
```javascript
var s = new String("abc");
console.log(s);         // String {"abc"}
console.log(typeof s);  // object
console.log(Object.prototype.toString.call(s));     // [object String]
```
可以看到，变量s的打印结果不是设想的`abc`，而是`String {"abc"}`(这里不同浏览器不同版本可能显示有区别，我用的是chrome浏览器)，typeof的结果显示这是一个对象`object`，而不是字符串。

**通过构造函数(如 `new String("abc")`)创建出来的是封装了基本类型值(如"abc")的封装对象。**

上例中有个打印结果是"[object String]"，它是对象的一个分类。

所有typeof返回值为`object`的对象(比如数组、函数)都包含一个内部属性`[[class]]`(可以将其看作一个内部的分类，而非传统的面向对象意义上的类)。这个属性无法直接访问，一般通过`Object.prototype.toString.call()`来查看：
```javascript
Object.prototype.toString.call([1, 2, 3]);      // [object Array]
Object.prototype.toString.call(/[0-9]{1,2}/);   // [object RegExp]
```
上例中数组的内部`[[class]]`属性值是"Array"，正则表达示的值是"RegExp"。

多数情况下，对象的内部`[[class]]`属性和创建该对象的内建原生构造函数相对应。

其他基本类型值(比如字符串、数值和布尔)的情况则有所不同，通常被称为"包装"：
```javascript
Object.prototype.toString.call(42);         // [object Number]
Object.prototype.toString.call("abc");      // [object String]
Object.prototype.toString.call(true);       // [object Boolean]
```
上例中基本类型值被各自的封装对象自动包装，所以它们的内部`[[class]]`属性值分别为"String"、"Number"和"Boolean"。

对基本类型值进行手动对象封装是没有必要的，浏览器已对常见情况做了系统优化，直接使用封装对象来"提前优化"代码反而会降低执行效率，所以通常我们无需直接使用封装对象，最好的办法是让引擎自己决定什么时候应该用封装对象，开发者应优先使用基本类型值，而不是`new String()`这样手动创建封装对象。

既然有封装，那就有拆封。想要得到封装对象中的基本类型值，可以使用`valueOf()`函数：
```javascript
var a = new String("abc");
var b = new Number(42);
var c = new Boolean(true);

console.log(a.valueOf());       // abc
console.log(b.valueOf());       // 42
console.log(c.valueOf());       // true
```
在需要用到封装对象中的基本类型值的地方会发生隐式拆封，具体过程就是强制类型转换的过程，这个在下篇中再细看。

除了基本类型值的对象封装，引用类型值也会进行对象封装，即通过相应的构造函数创建封装对象。但通常应尽量少用构造函数来创建它们，比如数组、对象和函数，直接以常量的形式创建即可。
```javascript
var a = new Array(1, 2, 3);     // 构造函数创建数组
console.log(a);     // [1, 2, 3]

var b = [4, 5, 6];              // 常量形式创建数组
console.log(b);     // [4, 5, 6]
```

但相较于其他原生构造函数，`Date()`和`Error()`则不一样，因为没有对应的常量形式来作为它们的替代。

创建日期对象必须使用`new Date()`。`Date()`可以带参数，用来指定日期和时间，而不带参数的话则使用当前的日期和时间。`Date()`主要用来获得当前的Unix时间戳(从1970年1月1日开始计算，以秒为单位)。该值可以通过日期对象中的getTime()来获得。

创建错误对象主要是为了获取当前运行栈的上下文，栈上下文信息包含函数调用栈信息和产生错误的代码行号，以便于debug调试。错误对象通常与throw一起使用。
```javascript
function foo(x){
    if(!x){
        throw new Error("x is not defined.");
    }
}
foo();      // Uncaught Error: x is not defined.
```

ES6中新增加了一个基本数据类型：`Symbol`(符号)。符号是具有唯一性的特殊值，用它来命名对象属性不容易导致重名。这个东西我没用过，也没什么觉得用的必要？没什么感受，就不举例了，有兴趣的可以自行去看。可能等我以后确实碰到用了，才会觉得这玩意很重要？到时再看吧。

除了上面的这些原生构造函数对象本身外，它们也都有各自的`.prototype`对象，即它们的原型对象，例如`String.prototype`、`Array.prototype`等，这些原型对象包含了其对应子类型所特有的行为特性。借助原型代理，所有的这些构造函数的"实例"对象都具有对应原型对象上的方法。

最后总结下，js为所有基本类型值提供了封装对象，它们也被称为原生函数(String、Number、Boolean等)。注意这些对象的首字母是大写的，与那些全小写的作用类型值名称以示区分。当要访问基本类型值的一些方法或属性时，如`length`或者`String.prototype`，js引擎会自动对该值进行封装（即用相应类型的封装对象来包装它）来实现对这些属性和方法的访问。
