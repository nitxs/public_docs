《你不知道的JavaScript》第二部分`this`和对象原型第 3 篇。

前面两篇讲了this的调用位置影响和绑定规则，在一般情况下想要弄清this的指向，只需找到函数的调用位置和并判断应当应用哪条绑定规则即可。但有时会出现某个调用位置可以应用多条绑定规则的情况，这个时候又该怎么办？也就是我们要弄清楚这些绑定规则的优先级问题。

首先可以知道**默认绑定**这条规则的优先级是最低的，所以在比较优化级条件时先剔除。

接下来就是要比较**隐式绑定**、**显式绑定**和**new绑定**。

先看隐式绑定和显示绑定。
```javascript
function fn(){
    console.log(this.a);
}
var obj1 = {
    a: 2,
    fn: fn
}
var obj2 = {
    a: 4,
    fn: fn
}
obj1.fn();   // 2
obj2.fn();   // 4

obj1.fn.call(obj2);     // 4
obj2.fn.call(obj1);     // 2
```
当对函数使用`call()`方法来进行this指向的显式绑定时，直接修改原先经隐式绑定上的值。

所以结论是：**显式绑定** 优先级 > **隐式绑定**

再来比较下隐式绑定和 new 绑定的优先级。
```javascript
function fn(something){
    this.a = something;
}
var obj1 = {
    fn: fn
}
var obj2 = {};
obj1.fn(2);
console.log(obj1.a);    // 2  

obj1.fn.call(obj2, 3);      
console.log(obj2.a);        // 3 

var bar = new obj1.fn(4);       
console.log(obj1.a);        // 2
console.log(bar.a);         // 4
```
代码解释：
`console.log(obj1.a);`  此时是隐式绑定，将this指向obj1对象，this.a操作就是在obj1对象上添加属性a，其值为fn函数传入的参数 2。

`obj1.fn.call(obj2, 3);` 此时是显式绑定，通过call方法将fn中this绑定到obj2对象上去，并且传入参数 3 来给obj2中属性a赋值 ，这里也再次印证 显式绑定优先级 高于 隐式绑定。

`var bar = new obj1.fn(4); `  对obj1.fn函数执行构造调用，返回一个新对象，obj1.fn函数中的this就指向这个新对象，并且构造调用时传入的参数 4 被赋值给了新对象的属性 a 。

所以结论是 **new 绑定** 优先级 > **隐式绑定** 。

好，现在有个初步结论，默认绑定 < 隐式绑定。

那么显式绑定和new绑定之间谁优先级高，再来比一比。

在举例前有个前提条件要先说下，new 和 call/apply 无法一起使用，因此无法通过 new fn.call(obj1) 来直接测试，但可以使用硬绑定来测试它们的优化级。毕竟硬绑定也是一种显式绑定。
```javascript
function fn(something){
    this.a = something;
}
var obj1 = {};
var bar = fn.bind(obj1);    // 通过bind硬绑定修改返回一个新函数，该函数中的this指向obj1
bar(2);
console.log(obj1.a);    // 2

var baz = new bar(4);       // 对bar函数执行构造调用，返回一个新对象baz，bar函数中的this指向新对象baz，构造调用时传入的参数 4 被赋值给 baz 对象 a
console.log(obj1.a);     // 2   
console.log(baz.a);     // 4
```
看到没！在代码执行过程中，先是通过bind方法返回一个新函数bar，bar函数内部的this此时是指向obj1 对象的，通过传入实参2，为obj1对象定义了一个值为2的属性a。然后再能bar函数进行构造调用新建了一个对象baz，并且在构造调用时传入实参4，其意思就是将bar函数中的this指向由obj1改为baz，并且通过`this.a`的赋值操作，为baz对象创建了一个值为4的属性a。由于这个new操作，其实已然修改bar函数中this的指针，所以obj1对象只是断开与this的连接，而其内部并未受到修改。所以最终打印结果就是如上所示。

所以结论是 **new绑定**优化级 > **显式绑定**。

最终this的四个绑定规则的优化级顺序为 **默认绑定** < **隐式绑定** < **显式绑定** < **new绑定**。

所以判断this的指向有一个比较完善的标准：

先查看函数的**调用位置**，然后再通过绑定规则来判定this指向：
- 函数如在new中调用，则函数中this绑定的就是新创建的对象，`var bar = new fn();`
- 函数如通过 call/apply 或者 硬绑定 调用，则this绑定是就是指定的对象，`var bar = fn.call(obj1);`、硬绑定`var baz = fn.bind(obj2);`
- 函数如果是在某个上下文对象中调用，即隐式绑定，则函数中this绑定的就是那个上下文对象，`var bar = obj.fn();`
- 如果以上情况都不是的话，就是默认绑定，这里分两种情况：如处于严格模式，则this被绑定到undefined上；如处于非严格模式，则this绑定到全局对象上。

以上就是this的绑定判断的标准答案了，但这是对于正常的函数调用的情况而言的。还是会有些例外情况的，时间关系，那些就留到下篇看吧。