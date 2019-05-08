Generator函数也叫生成器函数，它是协程在ES6的实现，最大特点就是可以交出函数的执行权(即暂停执行)。整个 Generator 函数就可以封装一个异步任务，异步操作需要暂停的地方，用yield语句注明。

当调用生成器函数时，会返回一个迭代器(内部指针)，这点是生成器函数区别于普通函数的一个地方，即执行生成器函数不会返回结果。调用返回的迭代器的next()方法，会移动内部指针(即执行异步的第一阶段)，指向第一个遇到的 yield 语句。

所以其实 next 方法的作用就是分阶段执行生成器函数。每次调用 next 方法都会返回一个对象`{value:***, done: ***}`，表示当前阶段的信息，其中 value 属性是 yield 语句后面表达式的值，表示当前阶段的值；done 属性是一个布尔值，表示生成器函数是否执行完毕，即是否还有下一阶段。
```javascript
function *foo( x ) {
    var z = 3;
    var y = yield x + z;
    return y;
}

var it = foo( 10 );

console.log( it.next() );
console.log( it.next() );

// 打印结果：
/*
{ value: 13, done: false }
{ value: undefined, done: true }
*/
```
生成器函数可以暂停执行和恢复执行，以此可以封装异步任务。此外生成器函数还可以实现与函数外部的数据交换和错误处理。

next 方法返回的对象中的value属性就是生成器函数向外输出的数据；next 方法还可以传入参数，这个参数就是向生成器函数内部输入的数据，它会替换生成器内部上个阶段异步任务的返回结果，实现李代桃僵。
```javascript
function *foo( x ) {
    var z = 3;
    var y = yield x + z;
    return y;
}

var it = foo( 10 );

console.log( it.next() );
console.log( it.next( 7 ) );

// 打印结果：
/*
{ value: 13, done: false }
{ value: 7, done: true }    
*/
```
上个暂停阶段返回的value值y被next(7)中传入的参数7代替。

生成器函数内部还能部署错误代码，捕获函数体外抛出的错误。
```javascript
function *foo( x ) {
    try{
        var y = yield x + 2;
    }catch( err ){
        console.log(err);
    }
    return y;
}

var it = foo( 9 );
console.log( it.next() );
it.throw( "出错了" );

// 打印结果：
/*
{ value: 11, done: false }
出错了
*/
```

下面使用生成器函数执行真实异步任务，示例中的ajax方法 `getJSON()` 采用上一篇**《深入浅出Node.js》：Node异步编程解决方案 之 ES6 Promise**中封装的原生ajax，执行结果看截图：
```javascript
function *foo() {
    var url = "https://api.github.com/users/Bournen";
    var result = yield getJSON( url );
    console.log( result.url );
}

var it = foo();
var result = it.next();

result.value
.then( function ( data ) {
    return data;
} )
.then( function ( data ) {
    console.log( data );
    it.next( data );
} )
.catch( function ( err ) {
    console.log( err );
} )
```
![](https://github.com/Bournen/private_collection/blob/master/imageHosting/19/190131.png?raw=true)

配合Promise，生成器函数将异步操作执行的好似同步操作。