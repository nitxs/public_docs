前面讲完了词法作用域和this机制。接下来要看下js中重头：对象。

在js中，数据类型主要有：`string`、`number`、`boolean`、`undefined`、`null`、`symbol`和`object`。其中前6种是基本数据类型，最后种引用数据类型。注意喽，这里的英文表示全是小写。

这里注意个小细节，`null`也是基本类型，尽管`typeof null`时会返回字符串`"object"`，但null本身还真就是基本类型。这是js语言本身的一个小bug，因为在底层对象表示为二进制形式，在js中二进制前三位都是0的话会被判定为对象object类型，而null的二进制表示全部都是0，自然前三位也就是0，所以执行typeof时会返回"object"。

在js中对象object类型还有许多特殊的对象子类型，它们也叫内置对象：`String`、`Number`、`Boolean`、`Object`、`Function`、`Array`、`Date`、`RegExp`、`Error`。它们都是大写。

这些内置对象从表现形式来看很像其他语言的类，比如java中的String类。但在js中，它们都只是一些内置函数。这些内置函数可以当作构造函数(被new构造调用)，从而创建一些对应子类型的新对象。
```javascript
var strPrimitive = "I am a string.";    // 文字形式创建字符串
console.log(typeof strPrimitive);    // string
console.log(strPrimitive instanceof String);     // false

var strObject = new String("I am a string.");   //构造形式创建字符串
console.log(typeof strObject);      // Object
console.log(strObject instanceof String);       // true
console.log(Object.prototype.toString.call(strObject));  // [object String]
```
如上例所示，创建一个字符串可以使用文字形式创建，也可以使用构造形式创建。

前者创建的字符串是原始值，并不是对象而只是一个字面量，并且是一个不可变的值。但如果要对这个字符串执行操作如获取长度、访问其中某个字符等，需要将其转换为String对象。这里无需我们显式创建对象，引擎会在必要时自动把字符串字面量转换成String对象。并且这也是一种公认的创建字符串的最佳实践，不需要通过构造方法来创建字符串对象。

同样的事，也会发生在数值字面量和布尔字面量上。null和undefined没有对应的构造形式，它们只有文字形式。而Date则只有构造形式，没有文字形式。

对于Object、Array、Function和RegExp来说，无论使用文字形式还是构造形式，它们都是对象，不是字面量。

Error对象很少在代码中显式创建，一般是在抛出异常时被自动创建，也可以使用 new Error(...) 这种构造形式创建。

对象的概念讲完，下面来看下对象中的内容。

所谓对象中的内容，是由若干组键值对组成，其中键为属性名，值为任意类型的属性值。

注意，表述内容的位置可称之为对象中，但实际情况引擎内这些值的存储方式多种多样，一般不会存储在对象容器内部。存储在对象容器内部的这些属性的名称，它们就像指针一样，指向这些值真正的存储位置。
```javascript
var obj = {
    a: 2
}
console.log(obj.a);         // 2
console.log(obj['a']);      // 2
```
访问对象中a位置上的值，可以使用 `.`操作符和`[...]`操作符。前者称为属性访问，后者称为键访问。通常两种访问形式可以互换，常用的是属性访问。但如果属性名不满足标识符的命名规范，如`super-fn`这样的，就只能通过键访问来获取相应位置上的值，即`obj["super-fn"]`。

在对象中，属性名永远是字符串，即使使用字符串以外的其他值作为属性名，它也会首先被转换成字符串形式。即使是数字也不例外，当然这里要区分下数组的下标，两者用法是不同的。

数组有一套更加结构化的值存储机制，并且也不限制值的类型。数组中值存储位置(也叫索引)是整数。

时间关系，先看到这，下篇再细看对象内容的其他方面。