在js中this有4种指向，分别为：

- 作为对象的方法调用 
- 作为普通函数调用
- 构造器调用 
- Function.prototype.call或Function.prototype.apply调用

1、当作为对象的方法调用时，该方法中的this就指向了该对象
```javascript
var obj = {
    name: 'nitx',
    getName: function(){
        console.log(this === obj)      //true
        console.log(this.name)         //nitx
    }
}
obj.getName();
```

2、作为普通函数调用时，函数中的this指向全局对象，在浏览器环境中，指向的就是全局对象window
```javascript
window.name = 'globalName'

var func = function(){
    console.log(this.name)
}

func();    //globalName

//或者

var obj = {
    name: 'nitx',
    getName: function(){
        console.log(this.name)
    }
}

var func2 = obj.getName;
func2()     //globalName
/*这里打印结果依然是指向全局对象的原因是： 将obj对象中的getName方法赋值给新的变量func2时，func2就是一个全局作用域中的普通函数，而非obj对象中的方法，已经与getName方法是两个完全独立的方法，拥有完全不同的作用域上下文*/

```

3、在构造器中调用this
先要理解js中的构造器。
除了宿主环境中的内置函数外，大多数函数都既能当普通函数，也能当构造函数。区别在于调用方法：

当函数名加括号的调用时就是普通函数，

当用new运算符调用函数时就是构造函数，并且该构造函数调用时总是会返回一个对象，即实例对象，该构造函数中的this就是指向这个返回的实例对象。
```javascript
var Func = function(name, age){
    this.name = name
    this.age = age
}
var func = new Func('nitx', 30)
console.log(func.name)  //nitx
```
这里还需要注意一个问题，如果构造函数显式的返回一个**Object类型的对象**，则`new 构造函数名()`的运算结果是返回这个对象，而不是原先new出来的实例对象，所以返回出来的这个对象中的this指向需要注意是指向这个返回对象的。
```javascript
var Func = function(){
    this.name = 'nitx'
    return {
        name: 'sxm'
    }
}
var func2 = new Func()
console.log(func2.name);    //sxm
```
如果构造器不显式的返回任何数据，或者返回一个非对象类型的数据，就不会出现上述问题。

4、Function.prototype.call或Function.prototype.apply调用this
通过call或apply，可以动态改变传入函数的this
```javascript
var obj1 = {
    name: 'nitx',
    getName: function(){
        return this.name
    }
}

var obj2 = {
    name: 'sxm'
}

console.log(obj1.getName())     //nitx
console.log(obj1.getName.call(obj2))        //sxm
```

对于call和apply的理解

要想理解上文第4点中的call调用改变this的具体实现原理，需要先了解call和apply的作用。

Function.prototype.call或Function.prototype.apply，它们的作用是完全一样的，都是改变函数的this指向。区别在于两者传入参数的不同。

apply接收两个参数，第一个参数指定了调用apply的函数体内this对象的指向，第二个参数是一个带下标的集合，该集合可以是数组，也可以是类数组，apply方法把这个集合中的所有元素作为参数依次传递给调用apply的函数:
```javascript
var func = function(a, b, c){
    console.log([a, b, c])
}

func.apply(null, [1, 2, 3])     //[1, 2, 3]
```
call方法传入的参数中，第一个参数也是指定调用call的函数体内this对象的指向，从第二个参数开始往后，每个参数被依次传入函数中。

当使用apply或call时，如果传入的第一个参数是null，则函数体内的this会指向默认的宿主对象，在浏览器中就是window，但在严格模式下,函数体内的this还是为null:
```javascript
var func = function(){  
    //非严格模式下，函数调用apply或call时，第一个参数设为null时，函数体内的this指向全局对象
    console.log(this === window)        //true
}   

func.apply(null)

var func = function(){
    'use strict'    //严格模式下this依然指向null
    console.log(this === null)        //true
}

func.apply(null)
```
所以有时如果使用apply或call的目的不是指定函数体内的this指向，而只是借用该函数方法进行某种运算时，可以传入null来代替某个具体对象。
```javascript
Math.max.apply(null, [1, 2, 3, 4, 5])       //借用Math.max方法来计算数据[1,2,3,4,5]中的最大值
```

再来回顾下本文重点：

this在不同的调用情况下指向也不同。

当在对象方法内调用时指向该对象；

当在普通函数内调用时指向宿主环境中的全局对象；

当在构造器中调用时分为两种情况。构造器无return返回值或返回值不为对象类型数据时，构造器中的this指向被构造器new出来的实例对象；构造器有return返回值且值为Object对象类型的数据时，this指向该构造器运算后返回出来的对象值；

当在Function.prototype.call或Function.prototype.apply情况下，前面调用apply或call的函数体内的this原有指向被更改为指向apply或call方法中的第一个参数。

关于apply或call，两者的作用完全一致，都是更改调用apply或call的函数体内的this对象指向。
区别仅在于两者的第二个参数传入不同：

```javascript
func.apply(
    [参数一：将调用apply方法的函数体内的this对象指向改为指向本参数], 
    [参数二：传入调用apply方法的函数体内的参数集合(数组或类数组)]
    )
```
```javascript
func.call(
    [参数一：将调用call方法的函数体内的this对象指向改为指向本参数], 
    [参数二：传入调用call方法的函数体内的参数1]  //从第二个参数开始，每个参数被依次传入函数func中
    [参数三：传入调用call方法的函数体内的参数2]
    [参数四：传入调用call方法的函数体内的参数3]
    ...
    )
```
如果只是想通过apply或call来借用某个函数方法进行某种运算，则只需将apply或call的第一个参数设为null来代替某个具体对象。

原因？

因为在非严格模式下，此时调用apply或call的函数体内的this会指向宿主环境中的全局对象；在严格模式下此时调用apply或call的函数体内的this会指向null。

延伸应用：

理解了this、call、apply后，在实际js开发中，可以很方便的实现对象的继承

继承demo1：

```javascript
var Parent = function(){
    this.name = 'nitx';
    this.job = 'frontEnd'
}

var child = {};

console.log(child)      //空对象 {}

Parent.call(child)

console.log(child)      //已继承Parent对象的child  {name: "nitx", job: "frontEnd"}
```

继承demo2：
```javascript
//子类继承父类的属性和方法

//定义父类
var Person = function(name, job){
    this.name = name;
    this.job = job;
}

Person.prototype.showName = function(){
    console.log(this.name)
}

Person.prototype.showJob = function(){
    console.log(this.job)
}

//定义子类
var Worker = function(name, job, age){
    Person.call(this, name, job)  //把父类Person中的this对象指向改为指向子类Worker运算new出来的实例对象
    this.age = age;  
}

//子类从父类(父原型)继承方法有三种，会全部列出来，但我推荐使用第三种方法，原因在注释中

//方法一：缺点 --子类原型与父类原型本质都是指针，各自指向内存中作为它们原型的对象，通过赋值操作会将子类原型指针指向父类原型对象，产生的问题就是如果修改子类原型方法(也叫实例方法)，父类的原型方法(实例方法)也会发生同步改变
//Worker.prototype = Person.prototype

//方法二：将子类的原型指向父类的实例对象，缺点不够优雅
//Worker.prototype = new Person()

//方法三：将父类方法通过for...in...枚举进子类原型方法中
for(var i in Person.prototype){
    Worker.prototype[i] = Person.prototype[i]
}

Worker.prototype.showAge = function(){
    console.log(this.age)
}


var p1 = new Person('sxm', 'count')
var w1 = new Worker('nitx', 'frontend', 30)

console.log(p1)
console.log(w1)

```





