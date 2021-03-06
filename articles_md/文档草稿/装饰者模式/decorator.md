在js函数开发中，想要为现有函数添加与现有功能无关的新功能时，按普通思路肯定是在现有函数中添加新功能的代码。这并不能说错，但因为函数中的这两块代码其实并无关联，后期维护成本会明显增大，也会造成函数臃肿。

比较好的办法就是采用装饰器模式。在保持现有函数及其内部代码实现不变的前提下，将新功能函数分离开来，然后将其通过与现有函数包装起来一起执行。

先来看个比较原始的js版装饰器模式实现：
```javascript
var Plane = function(){}

Plane.prototype.fire = function(){
    console.log('发射普通子弹');
}

//增加两个装饰类，导弹类和原子弹类
var MissileDecorator = function(plane){
    this.plane = plane;
}
MissileDecorator.prototype.fire = function(){
    this.plane.fire();
    console.log('发射导弹');
}

var AtomDecorator = function(plane){
    this.plane = plane;
}
AtomDecorator.prototype.fire = function(){
    this.plane.fire();
    console.log('发射原子弹');
}

var plane = new Plane();
console.log(plane);
plane = new MissileDecorator(plane);
console.log(plane);
plane = new AtomDecorator(plane);
console.log(plane);

plane.fire();

/*
发射普通子弹
发射导弹
发射原子弹
*/
```

升级版装饰器模式，通过为js的Function构造函数添加实例方法before和after来实现。

Function.prototype.before和Function.prototype.after接收一个函数作为参数，这个函数就是新添加的函数，它装载了新添加的功能代码。

接下来把当前的this保存起来，这个this指向原函数(Function是js中所有函数的构造器，所以js中的函数都是Function的实例，Function.prototype中的this就指向该实例函数)

然后返回一个'代理'函数，这个代理函数只是结构上像'代理'而已，并不承担代理的职责(比如控制对象的访问)。它的工作就是把请求分别转发给新添加的函数和原函数，且负责保证它们的执行顺序，让新添加的函数在原函数之前执行(前置装饰 Function.prototype.before; 后置装饰 Function.prototype.after)，从而实现动态装饰的效果。
```javascript
// AOP 装饰函数
Function.prototype.before = function(beforefn){
    var _self = this;       //保存原函数的引用
    return function(){      //返回包含了原函数和新函数的‘代理’函数
        beforefn.apply(this, arguments);        //先执行新函数，且保证this不会被劫持，新函数接受的参数也会原封不动的传入原函数，新函数在原函数之前执行
        return _self.apply(this, arguments);    //再执行原函数并返回原函数的执行结果，并保证this不被劫持
    }
}

Function.prototype.after = function(afterfn){
    var _self = this;       //保存原函数的引用
    return function(){      //返回包含了原函数和新函数的‘代理’函数
        var ret = _self.apply(this, arguments);  //先执行原函数并返回原函数的执行结果，并保证this不被劫持，原函数执行的结果会赋值给ret变量，交由'代理'函数最后return
        afterfn.apply(this, arguments);         //再执行新函数，且保证this不会被劫持，新函数接受的参数也会原封不动的传入原函数，新函数在原函数之前执行      
        return ret;    
    }
}

//定义原函数
var print = function(){
    console.log('打印原函数执行结果');
}

print = print.before(function(){
    console.log('打印前置装饰函数的执行结果');
})

print = print.after(function(){
    console.log('打印后置装饰函数的执行结果');
})

//执行装饰后的print函数，为原函数print函数添加的装饰器对用户来说看起来是透明的
print();

//打印结果
/*
打印前置装饰函数的执行结果
打印原函数执行结果
打印后置装饰函数的执行结果
*/
```

上例中的AOP装饰器是通过在Function.prototype上添加before和after方法实现的，但有时这种直接污染函数原型的方法并不好，可以做些变通，把原函数和新函数都作为参数传入before和after方法中

```javascript
var before = function(fn, beforefn){
    return function(){
        beforefn.apply(this, arguments)
        return fn.apply(this, arguments)
    }
}

var after = function(fn, agterfn){
    return function(){
        var ret = fn.apply(this, arguments)
        agterfn.apply(this, arguments)
        return ret;
    }
}

var a = function(){
    console.log('原函数执行结果');
}

a = before(a, function(){
    console.log('前置装饰函数执行结果');
})

a = after(a, function(){
    console.log('后置装饰函数执行结果');
})

a()
/*
前置装饰函数执行结果
原函数执行结果
后置装饰函数执行结果
*/
```

最后再来个装饰器模式的实例应用。

在实际开发中比较常见的需求是用户数据上报，一般会在项目开发差不多后，陆续有此类需求提出，但此时如果要在对应函数中添加数据上报功能代码时，就会改动原有函数，既麻烦又增加开发测试成本。此时最好的就是使用装饰器模式通过将上报函数装饰到原有函数上。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>装饰者模式应用数据上报</title>
</head>
<body>
    <button type="button" id="btn">点击登录并上报数据</button>
</body>
<script>
var showDialog = function(){
    console.log('显示登录弹窗');
}

var log = function(){
    console.log('计数上报');
}

var after = function(fn, afterFn){
    return function(){
        var ret = fn.apply(this, arguments)
        afterFn.apply(this, arguments)
        return ret;
    }
}

showDialog = after(showDialog, log)

document.getElementById('btn').onclick = showDialog;

</script>
</html>
```


