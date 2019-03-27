JS中的`this`用法很灵活，使用场景不同，`this`的指向也会不同。

本文我先给出`this`在使用过程中指向的注意点，配合下文示例服用更佳：

- `this`的指向在函数定义的时候是确定不了的，只有函数执行的时候才能确定`this`到底指向谁，实际上`this`的最终指向的是那个调用它的对象
- 如果一个函数中有`this`，但是它没有被上一级的对象所调用，那么`this`指向的就是`window`，这里需要说明的是在js的严格模式中`this`指向的不是`window`
- 如果一个函数中有`this`，这个函数有被上一级的对象所调用，那么`this`指向的就是上一级的对象
- 如果一个函数中有`this`，这个函数中包含多个对象，尽管这个函数是被最外层的对象所调用，`this`指向的也只是它上一级的对象
- `this`永远指向的是最后调用它的对象，也就是看它执行的时候是谁调用的，例子4中虽然函数`fn`是被对象b所引用，但是在将`fn`赋值给变量j的时候并没有执行所以最终指向的是`window`，这和例子3是不一样的，例子3是直接执行了`fn`

例子一：
```javascript
function a(){
    var userName = 'Nitx';
    console.log(this.userName);  //undefined
    console.log(this);  //window
}

a();    //
```
解释：等同于window.a(),而this指向的是在函数执行时最终调用它的那个对象，在本例中就是window调用的，而window对象中又没有userName属性


例子二：
```javascript
var o = {
    a : 10,
    fn : function(){
        console.log(this.a)
    }
}
o.fn(); //10 
```
解释：fn函数执行时调用this的对象是o，所以this就指向了o，this.uer就是指的o.user的值，这里需求强调下，this的指向在函数创建时是决定不了的，只有当函数被调用时才能决定，谁调用就指向谁

例子三：
```javascript
var o = {
    a : 10,
    b : {
        a : 12,
        fn : function(){
            console.log(this.a);
        }
    }
}
o.b.fn();   //12 
```
解释：尽管fn函数被多层对象中的最外层对象o调用，但其中的this仍然指向该函数的上一级对象

//例子四：
```javascript
var o = {
    a : 10,
    b : {
        a : 12,
        fn : function(){
            console.log(this.a)
        }
    }
}

var j = o.b.fn;
j();    //undefined  
```
解释：这边怎么又指向window了呢？其实还需要记住一个关于this的关键用法，this永远指向最后调用它的那个对象，这个例子虽然函数fn被对象b所引用，但是在将fn函数赋值给变量j的时候，却没有执行，而最终是变量j()来执行的，那么这个问题又回到j变量是谁调用上来了，此时变量j是window对象下面的属性，所以就是window是最后调用的对象，所以this指向window

例子五 构造函数中的this指向：
```javascript
function Foo(){
    this.userName = 'Nitx';
}

var foo = new Foo();
console.log(foo.userName);  //'Nitx'  

console.log(typeof null)    //Object    表示null是一个对象
console.log(typeof undefined)   //undefined 表示undefined是一个undefined类型
```
解释：new关键字会改变this的指向，把this指向对象foo，为什么说foo是对象，因为用了new关键字就是创建一个对象实例，所以此处从Foo构造函数中new出来的对象实例foo其实就相当于复制了复制了一份Foo到对象实例foo里面，但此时仅只是创建，还没有执行，当调用这个函数Foo时（其实就是代码Foo(）表示调用），并且当调用函数Foo的是对象a时，this的指向就变更为指向foo对象实例上面，由于foo对象实例是从Foo构造函数中new出来的，所以Foo具有的各种属性和方法，foo对象实例也会具有。此时 foo.userName === this.userName === 'Nitx'

#### 当this遇到return时该怎么指向？

情况1：
```javascript
function fn(){
    this.user = 'Nitx';
    return {};	//返回一个空对象
}
var a = new fn();
console.log(a.user)	//undefined
```

情况2：
```javascript
function fn(){
    this.user = 'Nitx';
    return function(){}
}
var a = new fn();
console.log(a.user);	//undefined
```

情况3：
```javascript
function fn(){
    this.user = 'Nitx';
    return 1;	//返回值不是对象
}
var a = new fn();
console.log(a.user);	//Nitx 
```

情况4：
```javascript
function fn(){
    this.user = 'Nitx';
    return undefined;
}
var a = new fn();
console.log(a.user);	//Nitx
```

总结： 如果return返回值是一个对象，则this就指向那个返回的对象，如果return返回值不是一个对象，则this依旧指向new出来的对象实例。

但是有个例外特殊，就是null，虽然null也是一个对象，但是如果返回值是null的话，this依旧指向new出来的那个对象实例：
```javascript
function fn(){
    this.user = 'Nitx';
    return null;
}
var a = new fn();
console.log(a.user)	//Nitx
```

最后补充几个知识点：

1. 在严格模式下，默认的this指向不再是window，而是undefined
2. new操作符会改变this的指向，是因为new关键字会创建一个空的对象，然后自动调用一个函数apply方法，将this指向这个空对象，这样的话函数内部的this就会被这个空的对象所代替