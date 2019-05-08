本篇复习下上篇用到的`Symbol.iterator`，它是ES6内置的十一个Symbol值之一。ES6中规定对象的`Symbol.iterator`属性指向该对象的默认迭代器方法，当对象进行`for...of..`遍历迭代时，会调用对象的`Symbol.iterator`方法，返回该对象的默认迭代器。

至于这个迭代器的形成原因，是因为到ES6，js已有Array、Object、Set和Map四种数据集合，用户还能自由组合它们来定义自己的数据结构，这样js就需要一种统一的接口机制来处理所有不同的数据结构。而迭代器(Iterator)就是这样一种机制。它是一种接口，为各种不同的数据结构提供统一的访问机制。任何数据结构只要部署Iterator接口，就可以完成遍历操作(依次处理该数据结构的所有成员)。

迭代器(Iterator)作用有三：
- 为各种数据结构提供统一简便的访问接口
- 使得数据结构的成员能够按照某种次序排列
- ES6创造了新遍历命令`for...of...`，迭代器(Iterator)主要供`for...of..`消费

迭代器(Iterator)的遍历过程是这样的：
- 创建一个指针对象，指向当前数据结构的起始位置。也就是说，遍历器对象本质上，就是一个指针对象
- 第一次调用指针对象的next方法，可以将指针指向数据结构的第一个成员
- 第二次调用指针对象的next方法，指针就指向数据结构的第二个成员
- 不断调用指针对象的next方法，直到它指向数据结构的结束位置

每一次调用next()方法，都会返回数据结构的当前成员的信息。具体来说，就是返回一个包含`value`和`done`两个属性的对象。其中`value`属性是当前成员的值，`done`属性是一个布尔值，表示遍历是否结束。

总的来说，迭代器(Iterator)接口的目的，就是为所有数据结构提供一种统一的访问机制，这个访问机制其实就是`for...of...`。当使用`for...of...`循环遍历某种数据结构时，该循环会自动寻找`Iterator`接口。

所以一种数据结构只要部署了`Iterator`接口，我们就称这种数据结构是可遍历(iterable)的。

ES6规定，默认的迭代器(Iterator)接口部署在数据结构的`Symbol.iterator`属性上，或者一个数据结构只要具有`Symbol.iterator`属性，就可以认为是可遍历(iterable)的。

`Symbol.iterator`属性本身是一个函数，就是当前数据结构默认的迭代器生成函数。执行这个函数，就去返回一个迭代器。至于属性名`Symbol.iterator`，它是一个表达式，返回`Symbol`对象的`iterator`属性，这是一个预定义好的、类型为 `Symbol` 的特殊值，所以要放在方括号内。

ES6中原生具有迭代器(Iterator)接口的数据结构有：`Array`、`Set`、`Map`、`String`、`TypedArray`、函数中的arguments、NodeList对象，它们都具有`Symbol.iterator`属性。注意对象`Object`没有`Symbol.iterator`属性，也就是说没有部署迭代器接口。

下面是数组的迭代器接口使用示例：
```javascript
var arr = [10, 2, 3, 4, 5];
var it = arr[Symbol.iterator]();    // 调用数组arr的迭代器接口方法，获取数组的迭代器对象
console.log(it.next().value);       // 10
console.log(it.next().value);       // 2
console.log(it.next().value);       // 3
console.log(it.next().value);       // 4
```
上面代码中，变量arr是一个数组，原生就具有遍历器接口，部署在arr的Symbol.iterator属性上面。所以，调用这个属性，就得到遍历器对象。

对于原生部署 Iterator 接口的数据结构，不用自己写遍历器生成函数，for...of循环会自动遍历它们。除此之外，其他数据结构（主要是对象）的 Iterator 接口，都需要自己在Symbol.iterator属性上面部署，这样才会被for...of循环遍历。

对象（Object）之所以没有默认部署 Iterator 接口，是因为对象的哪个属性先遍历，哪个属性后遍历是不确定的，需要开发者手动指定。本质上，遍历器是一种线性处理，对于任何非线性的数据结构，部署遍历器接口，就等于部署一种线性转换。

一个对象如果要具备可被for...of循环调用的 Iterator 接口，就必须在Symbol.iterator的属性上部署遍历器生成方法（原型链上的对象具有该方法也可）。

继续用前文示例中的something迭代器，已经忘记的可以翻下前文(这里是前文链接)。something对象之所以被称为迭代器，是因为其接口中含有一个next()方法，这类迭代器对象(Iterator)有一个术语叫做可迭代(iterable)。

从ES6开始，从一个iterable中提取迭代器的方法是：iterable必须支持一个函数，其名称是专门的ES6符号值`Symbol.iterator`。调用这个函数时，它会返回一个迭代器。通常每次调用会返回一个全新的迭代器。回顾下自定义的something迭代器：
```javascript
var something = (function(){
    var nextVal;
    return {
        [Symbol.iterator]: function(){ return this; },
        next: function(){
            // 执行next()时迭代的执行逻辑
            return {done: false, value: nextVal}
        }
    }
})()
```
上例中something对象中定义了一个方法`[Symbol.iterator]: function(){ return this; }`，这个`Symbol.iterator`方法将something对象也构建成一个iterable。现在它既是iterable，也是迭代器，当把something传递给`for..of`循环时，可以工作。

js原生的迭代器还记得有哪些么：Array、Set、Map、String等。以数组为例：
```javascript
var arr = [10, 2, 3 , 5, 6];
for(var v of arr){
    console.log(v);
}
// 10  2  3  5  6
```
上例中的arr是一个iterable。`for..of`循环会自动调用它的`Symbol.iterator`函数来构建一个迭代器。当然也可以手工调用这个`Symbol.iterator`函数，然后使用它返回的迭代器。

对于上例中arr数组的手工创建迭代器：
```javascript
var arr = [10, 2, 3 , 5, 6];
var it = arr[Symbol.iterator]();    // 注意，这里要调用(Symbol.iterator)函数才会创建出一个迭代器
console.log(it.next().value);       // 10
console.log(it.next().value);       // 2
console.log(it.next().value);       // 3
```