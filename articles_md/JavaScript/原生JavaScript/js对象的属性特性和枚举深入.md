《你不知道的JavaScript》第二部分 对象 第 2 篇。

自ES5开始，js中的对象属性具有属性描述符。可以直接检测与定义属性特性。

检测属性特性：
```javascript
var obj = {
    a: 2
}
console.log(Object.getOwnPropertyDescriptor(obj, 'a'));
//打印
/**
configurable: true
enumerable: true
value: 2
writable: true
/
```
可以看到，检测属性的结果打印为4个属性数据描述符：value(属性值)、writable(可写)、enumerable(可枚举)、configurable(可配置)。
- `value`是属性的值。
- 后三者的默认值均为`true`；
- `writable`特性就是控制属性是否可改写；
- `enumerable`特性是控制属性是否会出现在对象的属性枚举中，所谓的可枚举，就相当于 “可以出现在对象属性的遍历中”，比如`for...in`循环；
- `configurable`特性就是控制属性是否可配置，即是否能通过`defineProperty()`方法来修改属性特性，当该特性值为false时，属性就不可配置。

在用对象字符量方式创建对象时，对象的属性特性均会使用默认值。

如果想自定义属性特性，可以通过`Object.defineProperty()`来添加一个新属性或者修改一个已有属性，当然想自定义的前提是configurable属性要为true。
```javascript
var newObj = {};
Object.defineProperty(newObj, 'a', {
    value: 10,
    writable: true,
    enumerable: true,
    configurable: true
})
console.log(newObj.a);      // 10
```
上例就是通过`Object.defineProperty()`来为对象`newObj`添加一个属性`a`，并为这个属性配置了相关的属性特性。当然这种只是示例，在实际开发中不推荐这样定义一个对象，除非是要修改属性特性。

通过`Object.defineProperty()`来控制对象属性的特性，比较好玩的一个实现就是生成一个真正的常量属性(不可修改、重定义或者删除)：
```javascript
var obj = {};
Object.defineProperty(obj, 'a', {
    writable: false,
    configurable: false
})
```
当然还有其他好玩的实现，请多研究吧。

ES5对象属性除了有四个数据描述符，还有两个访问描述符getter和setter。当对属性定义访问描述符时，js会忽略它们的 `value`和`writable`特性，而改为关心 `set`和`get`以及`configurable`和`enumerable`特性。
```javascript
var obj = {
    //给a定义一个getter
    get a(){
        return 3;
    }
}

Object.defineProperty(obj, 'b', {
    //给b设置一个getter
    get: function(){return this.a*2;},
    //确保b会出现对象的属性列表中
    enmuerable: true
})

console.log( obj.a );   // 3
console.log( obj.b );   // 6
```
不管是在对象字面量中的 `get a(){...}`还是在`defineProperty()`中的显式定义，二者都会在对象中创建一个不包含值的属性。

对于这个值的访问会自动调用一个隐藏函数，它的返回值会被当作属性访问的返回值：
```javascript
var obj = {
    get a(){
        return 2;
    }
}

obj.a = 10;
console.log(obj.a);     // 2
```
你看，即使再次对属性a进行set操作，返回值依然是是get隐藏函数的返回值，从而让set操作没有意义，也再次验证使用访问描述符时，js会忽略它们的value和writable特性。

所以为了让属性更合理，可以获取也可以修改值，还应当定义setter。通常getter和setter是成对出现的：
```javascript
var obj = {
    get a(){
        return this.res;
    },
    set a(val){
        this.res = val;
    }
}
obj.a = 10;
console.log( obj.a );   // 10

obj.a = 5;
console.log( obj.a );   // 5
```

最后再来看下对象中属性的存在性检测：
- `in`操作符会检查属性是否在对象及其原型链中
- `hasOwnProperty()`只会检查属性是否在对象中，不会检查到原型链中

所有普通对象都可以通过对`Object.protptype`的委托来访问`hasOwnProperty()`方法
```javascript
var obj = {a:2};
console.log(obj.hasOwnProperty('a'));   // true
```

但有的对象可能是由于没有连接到`Object.prototype`而不能访问`hasOwnProperty()`方法，此时可以通过 call/apply 来借用：
```javascript
var emptyObj = Object.create(null);
emptyObj.a = 11;
console.log('hasOwnProperty' in emptyObj);      // false emptyObj对象无法访问hasOwnProperty方法

console.log(Object.prototype.hasOwnProperty.call(emptyObj, 'a'));   // true 

```
前几篇this的绑定规则还记得不，四个绑定规则里有一个是显式绑定，上例就是通过显式绑定来把`Object.prototype.hasOwnProperty`方法里的this绑定到`emptyObj`对象上，以达到借用`hasOwnProperty`方法的目的。

补充个对象的枚举知识，有几点需要注意：
- `in`操作符可以用来判断属性是否在对象及其原型链中，
- `for...in...`操作符只可以用来判断属性是否可枚举，即属性特性`enumerable`为true时可枚举
- `propertyIsEnumerable()`会检查给定的属性名是否直接存在于对象中(而不是存在于原型链中)，并且还需满足`enumerable: true`。
- `Object.keys()`会返回一个数组，包含所有可枚举属性
- `Object.getOwnPropertyNames()`会返回一个数组，包含所有属性，无论它们是否可枚举
- `in`和`hasOwnProperty()`的区别在于是否查找原型链，然而`Object.keys()`和`Object.getOwnPropertyNames()`都只会查找对象直接包含的属性
- 目前并没有内置的方法可以获取`in`操作符使用的属性列表(对象本身的属性及原型链上的属性)。不过可以递归遍历某个对象的整条原型链并保存每层中使用`Object.keys()`得到的属性列表，这里只包含可枚举属性。