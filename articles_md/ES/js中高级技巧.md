## 1.判断对象的数据类型

使用 `Object.prototype.toString()`与闭包，通过传入不同的判断类型来返回不同的判断函数。传入的判断类型type的格式必须为首字母大写。

不推荐将这个函数用来检测可能会产生包装类型的基本数据类型上,因为 call 会将第一个参数进行装箱操作

```javascript
const isType = function( type ){
    return function( target ){
        return `[object ${type}]` === Object.prototype.toString.call( target );
    }
}

const isArray = isType( "Array" );

console.log( isArray( [] ) );   // true
console.log( Object.prototype.toString.call( [] ) );    // [object Array]
console.log( Object.prototype.toString.call( {} ) );    // [object Object]
console.log( Object.prototype.toString.call( function(){} ) );  // [object Function]
console.log( Object.prototype.toString.call( null ) );  // [object Null]
console.log( Object.prototype.toString.call( undefined ) );  // [object Undefined]
```

## 2.用ES5实现ES6的class语法

ES6中的class内部实现基于寄生组合式继承。

通过`Object.create()`方法创建一个继承自`Object.create()`方法内两个参数的新对象，这个新对象的原型对象指向父类superType的原型，并且新对象被指定了constructor属性并且定义成不可枚举的内部属性(enumerable:false)，然后再将子类subType的原型对象指向这个新对象。

由于 ES6 的 class 允许子类继承父类的静态方法和静态属性，而普通的寄生组合式继承只能做到实例与实例之间的继承，对于类与类之间的继承需要额外定义方法，这里使用 Object.setPrototypeOf(作用是设置一个指定的对象的原型到另一个对象)将 superType 设置为 subType 的原型，从而能够从父类中继承静态方法和静态属性。

```javascript
function inherit( subType, superType ){
    subType.prototype = Object.create( superType.prototype, {
        constructor: {
            enumerable: false,
            configurable: true,
            writable: true,
            value: subType.constructor
        }
    } )

    // 将superType设置为subType的原型，目的是子类能够继承到父类的静态方法和静态属性
    Object.setPrototypeOf( subType, superType );
}
```

## 3.自执行函数的几种常用写法

```javascript
// 方法一：用圆括号将匿名函数包裹后，解析器会把这个函数当成一个函数表达式，此时可以通过再加一个圆括号来执行这个函数表达式
(function(a){
    console.log(a);     // 1
})(1)

// 方法二：前端页面脚本压缩可减少脚本数量和脚本大小，为了避免压缩时前一个脚本没有写最后一个分号而导致压缩后脚本不能使用，所以更好的写法是在开始圆括号前加一个分号
;(function(b){
    console.log(b);     // 2
})(2)

// 方法三：由方法一得知，任何能将函数变成一个函数表达式的作法，都可以使解析器正确的调用定义函数。而符号 ! + - || 等都可以。
!function(c){
    console.log(c);     // 3
}(3)
```

## 4.数组的插入删除

数组的头尾插入方法分别是`unshift()`和`push()`，头尾删除方法分别`shift()`和`pop()`，并且这两个删除方法会返回被删除的项。

数组的非头尾位置插入或删除项时，可以采用`splice()`拼接方法，它是用来替换数组中指定位置项。
