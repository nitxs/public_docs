nodejs中，模块的概念很重要。所有功能都是基于模块划分的。每个模块都是JavaScript脚本，核心模块中主要是由js写成，部分是由C/C++编写，内建模块多是由C/C++编写。

这些模块的调用遵循CommonJS规范。

使用`require()`加载模块文件，参数值是字符串，如非nodejs自有模块，需要指定模块文件的完整路径及文件名。可以使用相对路径`./`或绝对路径`/`。
```javascript
// count.js  count模块文件
function count( a, b ) {
    return a*2 + b;
}
module.exports = {
    count
}

// app.js 业务代码文件
const countModule = require( "./count" );
let res = countModule.count( 10, 2 );
console.log( res );     // 22
```
如果count模块文件不存在，require()函数会将抛出一个异常。

通常在模块内部定义的本地就是、函数或对象只能在该模块内部访问，但当需要从模块外部引用这些变量、函数或对象时，需要用到**代表当前模块文件的module对象的exports属性**，这个module.exports属性就是模块的对象接口。换句话说，**加载某个模块，其实就是加载该模块的module.exports属性**。弄明白这个，就可以将需要被在模块外引用的变量、函数和对象放在module.exports属性的值中。
```javascript
// some.js 模块文件
module.exports = {
    someValName: someVal,
    someFnName : someFn,
    someObjName: someObj
}

// app.js  调用some模块的文件，假设与some.js共在一个目录下
let some = require( "./some.js" );
console.log( some.someValName );
```

module.exports属性的值可以是一个对象，也可以是一个类(其实就是构造函数啦)。当模块输出了一个类，那可以干的事也非常多，比如类静态方法、静态变量、成员方法、成员变量...
```javascript
// Foo模块文件  foo.js
function Foo( name, age ){
    this.name = name;
    this.age = age;
}

Foo.prototype.getName = function () {
    return this.name;
}
Foo.prototype.setName = function ( newName ) {
    this.name = newName;
}
Foo.prototype.getAge = function () {
    return this.age;
}
Foo.prototype.setAge = function ( newAge ) {
    this.age = newAge;
}
module.exports = Foo;

// 业务文件  app.js
const Foo = require( "./foo" );

let foo = new Foo( "nitx", 31 );
console.log( foo.getName() );       // nitx
console.log( foo.getAge() );        // 31

foo.setName( "sxm" );
foo.setAge( "32" );

console.log( foo.getName() );       // sxm
console.log( foo.getAge() );        // 32
```

上面两个示例都是属于第三方模块，引用时需要指定文件路径，如果不想指定文件路径，而直接引用文件名，如nodejs核心模块引用那样`require( "http" )`，则需要将模块文件放到node_modules目录下。这种方式管理模块更为灵活方便，可以在node_modules目录下新建一个使用该模块命名的目录，再将该模块文件放置在这个子目录下，并将模块文件重命名为index.js即可，应用程序根目录下的node_modules子目录的foo目录下的index.js将被正确加载。
