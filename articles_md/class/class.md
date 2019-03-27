JS中的面向对象，在es6中有`class`类后，变得更容易理解了，虽然这个`class`只是JS原型思想构造函数的语法糖，但无疑让习惯了面向对象编程的开发者找到熟悉的套路。

JS中的构造函数：
```javascript
function People(name, age){
    this.name = name;
    this.age = age;
}
People.prototype.eat = function(){
    console.log([this.name, 'eat somthine'].join(' '))
}
People.prototype.speak = function(){
    console.log('My name is '+this.name+', age '+this.age)
}
```

将构造函数改写成类时的写法，类作为对象的模板：
```javascript
//People类
class People {
    constructor(name, age){
        this.name = name;
        this.age = age;
    } 

    eat(){
        console.log(`${this.name} eat somthing.`);
    }

    speak(){
        console.log(`My name is ${this.name}, age ${this.age}`);
    }
}

//类实例化
let nitx = new People('nitx', 30);
let sxm = new People('sxm', 31);

nitx.eat();
nitx.speak();

sxm.eat();
sxm.speak();

/*
打印： 
nitx eat somthing.
My name is nitx, age 30
sxm eat somthing.
My name is sxm, age 31
*/
```
上例`People`类中的`constructor`是构造方法，对应原来的构造函数，类的`this`和构造函数中的`this`一样代表实例对象。`People`类中的实例方法无需加上`function`关键字，直接定义函数名和函数体即可，方法之间不需要用逗号隔开。

```javascript
typeof People;  //function
People === People.prototype.constructor;    //true
```
上例代码表明**类的数据就是函数，类本身就指向构造函数。**在类的实例上调用方法，其实就是调用原型上的方法。

由于类的实例方法都是定义在`prototype`属性上的，所以`People`类的实例方法也可以使用`Object.assign`方法来一次性添加多个实例方法。
```javascript
class People {
  constructor(){
    // ...
  }
}
Object.assign(People.prototype, {
    eat(){
        console.log(`${this.name} eat somthing.`);
    },
    speak(){
        console.log(`My name is ${this.name}, age ${this.age}`);
    }
})
```
此外需要注意一点，**类中创建的实例方法都是不可枚举的，而构造函数创建的实例方法则是可枚举的，**这点需要注意。

还有几个注意点总结如下：
- es6的`class`类和模块内部默认遵循严格模式。
- `class`类默认就有`constructor`方法，即使在创建时没有在类中写有`constructor`，JS引擎也会自动添加。`constructor`默认返回实例对象，即`this`，也可手动更改返回的对象。
- `class`类调用必须使用`new`关键字，否则会报语法错误。
- 与es5的构造函数一样，`class`类实例的属性除非显示定义在其本身(即`this`对象)，否则都是定义在原型上的。
- 和es5构造函数一样，`class`类的所有实例共享同一个原型，所以当在某个实例对象上通过使用`Object.getPrototypeOf`获取该实例原型的方法来在原型上添加新的方法时，其他该类的实例对象也自动拥有新增的原型方法。
- 和函数一样，`class`类也可以用表达式来定义：命名类表达式和匿名类表达式。和命名函数表达式一样，这个命名只在类内部才能使用。而匿名类表达式和匿名函数表达式一样，可以写出立即执行的类，写法同立即执行匿名函数表达式。
- `class`不存在变量提升这个机制。

————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

接昨天继续以`class`类作为学习对象，回顾面向对象开发有三要素。

- 继承，子类继承父类
- 封装，数据的权限和保密
- 多态，同一接口不同实现

今天先复习下继承相关。

`class`可以通过`extends`关键字来实现子类继承父类。
```javascript
class People{
    constructor(name, age){
        this.name = name;
        this.age = age;
    }

    static speak(){     //类的静态方法
        console.log('I am speaking.');
    }

    selfIntro(){
        console.log(`Hello, my name is ${this.name}, i'm ${this.age} years old.`);
    }
}

let nitx = new People('nitx', 30);
nitx.selfIntro();
People.speak();

class Student extends People{
    constructor(name, age, score){
        super(name, age);   // 调用父类的constructor(x, y)
        this.score = score;
    }

    showScore(){
        console.log(`${this.name}'s score is ${this.score}, this guy's age is ${this.age}.`);
        return super.selfIntro();
    }
}

let sxm = new Student('sxm', 21, 'A1');
sxm.showScore();
Student.speak();
/**
打印：
Hello, my name is nitx, i'm 30 years old.
I am speaking.
sxm's score is A1, this guy's age is 21.
Hello, my name is sxm, i'm 21 years old.
I am speaking.
 */
```
上例可以看到，子类`Student`的`constructor`方法和`showScore`方法中，都用到了`super`关键字，它表示的是父类的构造函数，用来新建父类的`this`对象，注意，`super`虽然代表了父类的构造函数，但是返回的是子类的实例，即`super`内部的`this`指的是子类，因此`super()`在这里相当于`A.prototype.constructor.call(this)`。

>子类必须在`constructor`方法中调用`super`方法，否则新建实例时报错。这是因为子类自己的this对象，必须先通过父类的构造函数完成塑造，得到与父类同样的实例属性和方法，然后再对其进行加工，加上子类自己的实例属性和方法。如果不调用super方法，子类就得不到this对象。

ES5 的继承，实质是先创造子类的实例对象`this`，然后再将父类的方法添加到`this`上面（`Parent.apply(this)`）。ES6 的继承机制完全不同，实质是先将父类实例对象的属性和方法，加到`this`上面（所以必须先调用`super`方法），然后再用子类的构造函数修改`this`。

如果子类没有定义`constructor`方法，这个方法会被默认添加，也就是说，不管有没有显式定义，任何一个子类都有`constructor`方法。

父类的静态方法也会被子类所继承。

这里有个地方需要注意下，在子类的`constructor`构造函数中，必须先调用`super`方法，才能使用`this`，否则就会报错。因为子类实例的构建是基于父类实例的，所以必须先调用`super`方法获取父类的实例。

```javascript
class Student extends People{
    constructor(name, age, score){
        this.score = score;
        super(name, age);   // 调用父类的constructor(x, y)
    }

    /*
    原型方法(实例方法)
    */
}
//打印错误信息
/*
ReferenceError: Must call super constructor in derived class before accessing 'this' or returning from derived constructor
*/
```

子类的实例对象同时是子类和父类这两个类的实例，与es5的行为一致。
```javascript
console.log(sxm instanceof Student);    //true
console.log(sxm instanceof People);     //true
```

上面是知道父类和子类的继承关系的，但有时并不会完全清楚，此时就需要一个方法帮助开发者判断父类子类的关系`Object.getPrototypeOf()`
```javascript
console.log(Object.getPrototypeOf(Student));    //[Function: People]
console.log(Object.getPrototypeOf(Student) === People);    //true
```

继承的优势：
- `People`是父类，公共的，不仅仅服务于`Student`类
- 继承可将公共方法抽象出来，提高利用，减少冗余

________________________________________________________________________________________________________________________________________________
ES6中的`class`面向对象三要素之二是封装。今天继续回顾。

在`Java`中，实现了`public`完全开放、`protected`对子类开放、`private`对自己开放这三种封装的方式。但在ES6中目前并不支持，未来是否会支持也不知道，但这种封装的思想还是值得学习的，所以需要通过变通方法来模拟实现。

对于私有方法的模拟实现，有如下两种比较方便的实现方法。

方法一：在命名上加以区别，通常可以约定在类内部方法名前加下划线`_`来表示一个只限于内部的私有方法，但这种方法其实在外部依然可以被调用，只是一种约定而已，并不保险。

方法二：将私有方法放置在类外部，当类需要调用这个私有方法时，通过`apply`或`call`调用。
```javascript
class ThatOne{
    constructor(){}
    foo(person){
        show.call(this, person)
    }
}
function show(person){      //将私有方法移到类外部
    console.log('my lover is ' + person);
}
console.log( (new ThatOne()).foo('sxm') );
//my lover is sxm
```

类中私有属性的模拟实现，暂无合适的方法，就不作多讨论了。

封装的优势有以下两点：
- 减少耦合，不该暴露的不暴露
- 利于对数据、接口进行相应的权限管理

至于多态，在JS中应用的很少。

>多态的实际含义是：同一操作作用于不同的对象上面时，可以产生不同的解释和不同的执行结果。换句话说，就是给不同的对象发送同一消息时，这些消息会根据这个消息分别给出不同的反馈。

字面意思难以理解，直接上代码：
```javascript
class People{
    constructor(name){
        this.name = name;
    }
    sayName(){}
}
class A extends People{
    constructor(name){
        super(name);
    }
    sayName(){
        console.log('I am A');
    }
}
class B extends People{
    constructor(name){
        super(name);
    }
    sayName(){
        console.log('I am B');
    }
}
(new A()).sayName();
(new B()).sayName();
//打印：
/*
I am A
I am B
*/
```
从上例可以看到，多态的思想实际就是把“做什么”和“谁来做”分离开来，要做到这点需要消除类型之间的耦合关系，在Java中可以通过向上转型实现多态。但在JS中无需这么麻烦，js的变量类型在运行期是可变的，一个js对象的多态性是与生俱来的，js作为一门动态弱类型语言，在编译时没有类型检查的过程，既没检查创建对象的类型，也没检查传递的参数类型，所以js中对象实现多态不取决于是否为某个类型的对象，而只取决于它是否有该方法。

对象的继承、封装和多态这三个要素在设计模式中的使用非常重要，只有深入理解这些要素，才能真正理解和灵活使用设计模式。


————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————









