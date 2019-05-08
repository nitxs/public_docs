回顾下js原型继承，js版的继承与传统面向对象的继承的区别主要是不复制对象，而是通过对象的内置属性`[[Propertype]]`来关联需要“继承”的对象，这样当引擎在对象中查找不到预期的属性或方法时，应付通过`[[Propertype]]`属性来查找关联的上一层对象，如果依然没有，继续重复上一步骤，直到找到或查找到最终的`Object.protptype`对象上依然没有时则返回undefined为止。

这个将对象间通过`[[Propertype]]`关联起来的链条就是原型链，通过这个原型链的回朔查找模拟出了传统面向对象中的继承。

所以我们可以这样理解js的原型继承机制，其本质就是对象间的关联关系。

好，弄明白了这个对象间的关联关系，才能理解js中的对象委托。

通过对象属性`[[Propertype]]`关联成的原型链来查找属性和方法的过程其实就是一个不断委托的过程。这种面向委托的设计，代表一种不同于类的设计模式。

所以在写js时，心里要有个思想转换，要从类思维模式转为委托思维模式。

为了方便转换思维，下面给出类和委托的伪代码：

类的写法：先定义一个通用父类，命名为Students，在Students类中定义所有任务都有的行为。接着定义子类oneStudent，它继承自Stdudents并且会添加一些特殊的行为处理对应的任务。这里有个重点是类设计模式鼓励在继承时使用方法重写，比如在子类oneStudent中重写父类Students中定义的一些通用方法，甚至在添加新行为时通过super调用这个方法的原始版本。许多行为都是先抽象到父类然后在子类中重写的。
```java
public class Stdudents{
    private id;
    private name;

    public Students(String id, String name){
        this.id = id;
        this.name = name;
    }

    public String getName(){
        return name;
    }

    public void setName(String name){
        this.name = name;
    }

    public void readBook(){
        System.out.println(this.name + "正在读书");
    }
}
public class oneStudent extends Stdudents{
    oneStudent(){
        super();
    }
}
```
可以实例化子类oneStudent然后使用这些实例来执行任务，这些实例会**复制**父类Students定义的通用行为以及子类oneStudent定义的特殊行为。在构造完成后，通常只需要操作这些实例(而不是类)，因为每个实例都已经拥有需要完成任务的所有行为。

同样的功能委托的写法是：首先定义一个Students对象，它既不是类也不是函数，它包含所有任务都可以使用(写作使用，读作委托)的具体行为。然后对于每个任务都会定义一个对象来存储对应的数据和行为，接着把这些特定的任务对象通过`[[Propertype]]`都关联到Students对象上，让它们在需要的时候可以进行委托。

可以想象成Students对象和oneStudent对象原本是两个互不统属的独立对象，并且在执行任务过程中也无需把它们放在一起，只是通过原型链来将它们关联起来，当执行任务过程中，可以通过oneStudent对象委托Students对象来执行相应任务。
```javascript
var Students = {
    setId: function(id){this.id = id},
    outputId: function(){console.log(this.id)}
}
// 将oneStudent对象的[[Propertype]]属性指向Students对象
// 让oneStudent对象委托Students对象
var oneStudent = Object.create(Students);   
oneStudent.operId = function(id, label){
    this.setId(id);
    this.label = label;
}
oneStudent.outputSubId = function(){
    this.outputId();
    console.log(this.label);
}
```
上例中Students和oneStudent是两个独立的对象，而不是类或者函数。通过`[[Propertype]]`将oneStudent对象委托到Students对象，实现js版的继承。这样oneStudent对象可以通过原型委托调用到Students对象的setId()方法和outputId()方法及其他所有属性和方法。并且基于this的何处调用和隐式绑定规则这两个机制，当operId()方法中执行`this.setId(id);`时，通过隐式绑定规则，将setId()方法中的this绑定到operId()内部本身的this对象上。

这样仔细一对比，是不是类设计模式和委托设计模式的区别就很明显了？

类有行为的复制过程。而委托没有，只是通过对象关联产生的委托关系来调用被委托对象中的行为。

看了委托的机制，有人可能想既然可以单方委托，那是不是可以互相委托？可以是可以，但强烈不建议，那样调试起来就是欲仙欲死了。

下面来个典型的原型面向对象风格的：
```javascript
function Foo(name){
    this.name = name;
}
Foo.prototype.identify = function(){
    return "I am " + this.name;
}
function Bar(who){
    Foo.call(this, who);
}
//将Bar.prototype对象委托给Foo.prototype对象
Bar.prototype = Object.create(Foo.prototype);
Bar.prototype.speak = function(){
    console.log("Hello, everyone. " + this.identify() + ". Nice to meet you.");
}

var b1 = new Bar("b1");
var b2 = new Bar("b2");

// b1和b2对象的原型委托给Bar.prototype对象
b1.speak();     // b1
b2.speak();     // b2
```
用熟悉的语言描述就是，子类Bar继承父类Foo，然后生成b1和b2两个实例，b1和b2两个实例都委托了Bar.prototype对象，Bar.prototype对象又委托了Foo.prototype对象。

下面是使用对象关联风格来编写功能完全相同的代码：
```javascript
var Foo = {
    init: function(name){
        this.name = name;
    },
    identify: function(){
        return "I am " + this.name;
    }
}
var Bar = Object.create(Foo);
Bar.speak = function(){
    console.log("Hello, everyone. " + this.identify() + ". Nice to meet you.")
}
var b1 = Object.create(Bar);
b1.init( "nitx" );
var b2 = Object.create(Bar);
b2.init("sxm");

b1.speak();     // Hello, everyone. I am nitx. Nice to meet you.
b2.speak();     // Hello, everyone. I am sxm. Nice to meet you.
```
上例同样利用`[[Propertype]]`把b1和b2对象委托给Bar对象，并把Bar对象委托给Foo对象，同样实现了三个对象的关联。

可以看出关联风格的代码更简洁，并且还完全抛弃令人迷惑的构造函数、new和原型。

因为这种代码只关注一件事：**对象间的关联关系**。
