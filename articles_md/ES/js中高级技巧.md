## js内置函数使用

### 1.Array.prototype.map
map() (映射)方法最后生成一个新数组，不改变原始数组的值。其结果是该数组中的每个元素都调用一个提供的函数后返回的结果。

传递给 map 的回调函数（callback）接受三个参数，分别是 currentValue——正在遍历的元素、index（可选）——元素索引、array（可选）——原数组本身，除了 callback 之外还可以接受 this 值（可选），用于执行 callback 函数时使用的this 值。

callback需要有return值，否则会出现所有项映射为undefind；

```javascript
[].map(function(currentValue, index, array) {
    // ...
}, [ thisObject]);

// 有一个数组[1, 2, 3, 4]，我们想要生成一个新数组，其每个元素皆是之前数组的两倍
// 不使用高阶函数
const arr1 = [1, 2, 3, 4];
const arr2 = [];
for (let i = 0; i < arr1.length; i++) {
  arr2.push( arr1[i] * 2);
}

console.log( arr2 );
// [2, 4, 6, 8]
console.log( arr1 );
// [1, 2, 3, 4]

// 使用高阶函数
const arr1 = [1, 2, 3, 4];
const arr2 = arr1.map(item => item * 2);

console.log( arr2 );
// [2, 4, 6, 8]
console.log( arr1 );
// [1, 2, 3, 4]
```

### 2.Array.prototype.reduce
reduce() 方法对数组中的每个元素执行一个提供的 reducer 函数(升序执行)，将其结果汇总为单个返回值。传递给 reduce 的回调函数（callback）接受四个参数，分别是累加器 accumulator、currentValue——正在操作的元素、currentIndex（可选）——元素索引，但是它的开始会有特殊说明、array（可选）——原始数组本身，除了 callback 之外还可以接受初始值 initialValue 值（可选）。

- 如果没有提供 initialValue，那么第一次调用 callback 函数时，accumulator 使用原数组中的第一个元素，currentValue 即是数组中的第二个元素。在没有初始值的空数组上调用 reduce 将报错。
- 如果提供了 initialValue，那么将作为第一次调用 callback 函数时的第一个参数的值，即 accumulator，currentValue 使用原数组中的第一个元素。

```javascript
// 有一个数组  [0, 1, 2, 3, 4]，需要计算数组元素的和
// 不使用高阶函数reduce
const arr = [0, 1, 2, 3, 4];
let sum = 0;
for (let i = 0; i < arr.length; i++) {
  sum += arr[i];
}
console.log( sum );
// 10
console.log( arr );
// [0, 1, 2, 3, 4]

// 使用高阶函数reduce， 无 initialValue 值
const arr = [0, 1, 2, 3, 4];
let sum = arr.reduce((accumulator, currentValue, currentIndex, array) => {
  return accumulator + currentValue;
});
console.log( sum );
// 10
console.log( arr );
// [0, 1, 2, 3, 4]

// // 使用高阶函数reduce， 有 initialValue 值
const arr = [0, 1, 2, 3, 4];
let sum = arr.reduce((accumulator, currentValue, currentIndex, array) => {
  return accumulator + currentValue;
}, 10);
console.log( sum );
// 20
console.log( arr );
// [0, 1, 2, 3, 4]
```

### 3.Array.prototype.filter
filter(过滤，筛选) 方法创建一个新数组,原始数组不发生改变。

其包含通过提供函数实现的测试的所有元素。接收的参数和 map 是一样的，filter的callback函数需要返回布尔值true或false. 如果为true则表示通过啦！如果为false则失败，其返回值是一个新数组，由通过测试为true的所有元素组成，如果没有任何数组元素通过测试，则返回空数组。

```javascript
//对一个数组去重
// 这里去重的原理是利用 indexOf方法会返回在数组中可以找到一个给定元素的第一个索引
// 不使用高阶函数 filter
let arr1 = [ 2, 3, "a", false, false, "a", 3, 8, 9, 8, 0, 2 ];
let arr2 = [];
for( var i=0; i<arr1.length; i++ ){
    if( arr1.indexOf( arr1[i] ) === i ){
        arr2.push( arr1[i] );
    }
}
console.log( arr2 );    // [2, 3, "a", false, 8, 9, 0]

// 使用高阶函数filter
let arr1 = [ 2, 3, "a", false, false, "a", 3, 8, 9, 8, 0, 2 ];
let arr2 = arr1.filter( function( el, index, self ){
    return self.indexOf( el ) === index;
} )
console.log( arr2 );    // [2, 3, "a", false, 8, 9, 0]
```

## js非内置函数使用

### 1.判断对象的数据类型

使用 `Object.prototype.toString()`与闭包，通过传入不同的判断类型来返回不同的判断函数。传入的判断类型type的格式必须为首字母大写。

```javascript
function typeConstructor(){
    var type = {},
        typeArr = [ "String", "Object", "Array", "RegExp", "Number", "Boolean" ]
    for( var i=0; i<typeArr.length; i++ ){
        (function(i){
            type[ "is" + typeArr[i] ] = function( param ){
                return Object.prototype.toString.call( param ) === "[object "+ typeArr[i] +"]";
            }
        })(i)
    }
    return type;
}

var Type = typeConstructor();
console.log( Type );

console.log( Type.isString( "str" ) );
console.log( Type.isArray( [2, 4] ) );
console.log( Type.isRegExp( /^12$/g ) );
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

## 5.函数的柯里化
函数的柯里化又称部分求值，一个柯里化函数会接收一些参数，在接收这些参数后，柯里化函数不会立即求值，而是返回另外一个函数，之前传入的参数在函数形成的闭包中被保存起来。等到函数被真正需要求值时，之前传入的参数都会被一次性用于求值。

示例：
```javascript
function currying( fn ){
    let args = [];
    return function(){
        if( arguments.length === 0 ){
            return fn.apply( null, args );
        }else {
            Array.prototype.push.apply( args, arguments );
        }
    }
}

let calc = (function (){
    let money = 0;
    return function(){
        for( var i=0; i<arguments.length; i++ ){
            money += arguments[i];
        }
        return money;
    }
})()

let cost = currying( calc );
// 未求值，只是通过闭包保存这些值
cost( 30 )  
cost( 60 )
cost( 90 )

// 真正求值了，此时会一次性将之前所有传入的参数进行求值。
console.log( cost() );  // 180
```

## 6.通过闭包为函数添加缓存机制

```javascript
let calc = (function(){
    let cache = {}; // 缓存对象

    function calcFn(){
        let x = 1;
        for( let i=0; i<arguments.length; i++ ){
            x = x*arguments[i];
        }
        return x;
    }

    return function(){
        let res = Array.prototype.join.call( arguments, "," );
        if( res in cache ){
            return cache[res]
        }
        return cache[res] = calcFn.apply( null, arguments );
    }
})()
```

## 7.函数节流的实现
函数节流的原理是将即将被执行的函数用setTimeout延迟一段时间执行。如果该次延迟执行还没有完成，则忽略接下来调用该函数的请求。

throttle函数接收两个参数，第一个参数是需被延迟执行的函数，第二个参数是延迟执行的时间。

```javascript
let throttle = function( fn, interval ){
    let timer = null,
        firstTime = true;

    return function(){
        let _me = this;

        // 如果是第一次，不需要调用延迟器
        if( firstTime ){    
            fn.apply( _me, arguments );
            return firstTime = false;
        }

        // 如果定时器还在，则前一次延迟还未完成，则忽略该函数的下一次请求
        if( timer ){
            return false;
        }

        // 延迟一段时间执行
        timer = setTimeout( function(){
            clearTimeout( timer );
            timer = null;
            fn.apply( _me, arguments )
        }, interval || 500 )
    }
}

let callback = function(){
    console.log( 124 );
}

window.onresize = throttle( callback, 2000 );
```

## 8.分时函数

上一个函数节流是一种限制函数被频繁调用的解决方案，函数分时则是用来解决当用户主动调用时因为一些客观原因会严重影响页面性能的场景，如一个页面加载时要加载成百上千的节点时，短时间往页面中大量添加节点可能造成页面停顿甚至卡死，此时就需要使用到分时函数来人为控制节点的一次性加载个数，以让浏览器有足够的响应能力：

```javascript
// 分时函数，第一个参数是创建节点时需要用到的数据，第二个参数是封装了创建节点逻辑的函数，第三个参数表示每一批创建节点的数量
var timeChunk = function( ary, fn, count ){
    let obj = null,
        t = null;

    var start = function(){
        for( var i=0; i<Math.min( count||1, ary.length ); i++ ){
            obj = ary.shift();
            fn( obj );
        }
    }

    return function(){
        t = setInterval( function(){
            if( ary.length === 0 ){
                return clearInterval( t );
            }
            start();
        }, 200 )
    }   
}

var ary = [];
for( var i=0; i<1000; i++ ){
    ary.push( i );
}
var renderList = timeChunk( ary, function( obj ){
    var div = document.createElement( "div" );
    div.innerHTML = obj;
    document.body.appendChild( div );
}, 8 )

renderList();
```

## 8.单例模式
单例模式：保证一个类仅有一个实例，并提供一个访问它的全局访问点。

```javascript
let CreateDiv = function( html ){
    this.html = html;
}

let proxySign = (function(){
    let instance = null;

    return function( html ){
        if( !instance ){
            instance = new CreateDiv( html )
        }
        return instance;
    }
})()

let a = proxySign(10)
let b = proxySign(12)

console.log( a === b );     // true
```

不过在js中，由于不存在类，所以可以不用像上面那样麻烦，传统的单例模式在js中可能不是很适用。

单例模式的核心是确保只有一个实例就行，并且提供可访问。

除了普通单例，还有惰性单例，这才是单例的重点。单例实例只有在调用时才创建，而不是一开始就创建好：
```javascript
// 惰性单例方法
let getSignInstance = function( fn ){
    let instance = null;
    return function(){
        return instance || (instance = fn.apply( this, arguments ))
    }
}

// 实际业务逻辑
let createDiv = function(){
    let div = document.createElement( "div" );
    div.innerHTML = 123;
    div.style.display = "none";
    document.body.appendChild( div );
    return div;
}

// 创建一个经惰性单例方法包装后的业务逻辑方法，有返回值
let getSignDiv = getSignInstance( createDiv );

// 当执行具体操作时再创建单例对象，而不是一开始就创建好
document.getElementById( "btn" ) .onclick = function(){
    let div = getSignDiv();
    div.style.display = "block";
}
document.getElementById( "btn2" ).onclick = function(){
    let div = getSignDiv();
    div.style.display = "none";
}
```