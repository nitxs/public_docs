从本篇开始读《你不知道的JavaScript》中篇。

本篇看下js中的类型和值的知识点。

先来看下js中的七种内置类型：
- 空值 `null`
- 未定义 `undefined`
- 布尔值 `boolean`
- 数值 `number`
- 字符串 `string`
- 对象 `object`
- 符号 `symbol`(ES6中新增)

除对象外，其他统称为基本类型。

可以使用typeof来查看值的类型，它返回的是类型的字符串值。但有一种类型和它的字符串值并不一一对应：
```javascript
typeof undefined === "undefined";   // true
typeof 42 === "number";             // true
typeof "abc42" === "string";        // true
typeof true === "boolean";          // true
typeof {name: "nitx"} === "object"; // true
typeof Symbol() === "symbol";       // teue

//注意，null和它的字符串值并不对应
typeof null === "object";           // true
```
关于的null，正确的返回结果应是"null"，这是语言bug，但由于这个错误自语言面世延续至今，所以为系统安全，这个bug大概率不会去修正了。

需要使用复合类型来检测null值的类型：
```javascript
var a = null;
( !a && typeof a === "object" );    // true
```
另外还有几种：
```javascript
typeof function a(){} === "function";    // true
typeof [1, 2, 3] === "object";          // true
```
函数和数组都可以理解成是`object`的一个“子类型”。

在js中变量是没有类型的，只有值才有。变量可以随时持有任何类型的值。

变量在未持有值时为`undefined`，此时typeof返回"undefined"。
```javascript
var a;
typeof a;   // undefined
```