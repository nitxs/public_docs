上一篇引出了面向委托设计模式的理论，这篇就写实际的应用代码。

实际需求，web开发中有一个典型的前端场景，创建UI控件(按钮、下拉列表等)。用jq的选择器来简化选择过程，与实现思路不冲突。

先看下ES5中原型面向对象的写法：
```javascript
// 父类
function Widget(width, height){
    this.width = width || 50;
    this.height = height || 50;
    this.$elem = null;
}
Widget.prototype.render = function($where){
    if(this.$elem){
        this.$elem.css({
            width: this.width,
            height: this.height
        }).appendTo($where);
    }
}

// 子类
function Button(width, height, label){
    Widget.call(this, width, height);
    this.label = label || "Default";
    this.$elem = $("<button>").text(this.label);
}
//通过[[Propertype]]关联到父类Widget
Button.prototype = Object.create(Widget.prototype);
// 子类重写render方法
Button.prototype.render = function($where){
    Widget.prototype.render.call(this, $where);
    this.$elem.click( this.onclick.bind(this) );
}
Button.prototype.onclick = function(event){
    console.log("Button "+ this.label + " clicked.");
}

// 实例化
var $body = $(document.body);
var btn1 = new Button(40, 50, "btn1");
var btn2 = new Button(60, 80, "btn2");
btn1.render($body); 
btn2.render($body);
```

下面是ES6中的class关键字创建对象写法：
```javascript
// 父类
class Widget{
    constructor(width, height){
        this.width = width || 50;
        this.height = height || 50;
        this.$elem = null;
    }

    render($where){
        if(this.$elem){
            this.$elem.css({
                width: this.width,
                height: this.height
            }).appendTo($where)
        }
    }
}

// 子类  继承父类
class Button extends Widget{
    constructor(width, height, label){
        super(width, height);
        this.label = label || "Default";
        this.$elem = $("<button>").text(this.label);
    }

    render($where){
        super.render($where);
        this.$elem.click( this.onClick.bind(this) )
    }

    onClick(event){
        console.log(`Button ${this.label} clicked.`);
    }
}

// 实例化
var $body = $(document.body);
var btn1 = new Button(40, 50, "btn1");
var btn2 = new Button(50, 100, "btn2");

btn1.render($body);
btn2.render($body);
```
使用上ES6的class语法糖后，和java中的class代码实现真是非常像了，并且也不用写难懂的call显式绑定this了，感觉世界非常美好。但这种依然是用类的概念来对问题(UI控件)进行建模。

下面来用对象关联委托来实现：
```javascript
// 对象关联委托
var Widget = {
    init: function(width, height){
        this.width = width || 50;
        this.height = height || 50;
        this.$elem = null;
    },
    render: function($where){
        if(this.$elem){
            this.$elem.css({
                width: this.width + "px",
                height: this.height + "px",
            }).appendTo($where)
        }
    }
}


var Button = Object.create(Widget);
Button.setup = function(width, height, label){
    //委托调用
    this.init(width, height);
    this.label = label || "Default";
    this.$elem = $("<button>").text(this.label)
}
Button.build = function($where){
    this.render($where);
    this.$elem.click( this.onClick.bind(this) );  
}
Button.onClick = function(event){
    console.log(`Button ${this.label} clicked.`);
}

var $body = $(document.body);
var b1 = Object.create(Button);
var b2 = Object.create(Button);

b1.setup(40, 50, "btn1");
b2.setup(60, 80, "btn2");

b1.build($body);
b2.build($body);
```
使用对象关联风格来编写代码时不需要把Widget和Button当成父类和子类。Widget只是一个对象，包含一组通用的函数，任何类型的控件都可以委托，Button同样也只是一个对象，它会通过委托关联到Widget对象。

在上述对象关联设计模式中，并没有像类一样在两个对象中定义同名的方法，相反使用的是更具描述性的方法名，除此以外，还应避免使用显式伪多态调用(比如Widget.call和Widget.prototype.render.call)，代之以相对简单的调用this.inti()和this.render()。

并且`var b1 = Object.create(Button);`和`b1.setup(40, 50, "btn1");`虽然相比原型面向对象风格的多了一步的初始化过程，但这能更好的支持**关注分离**原则，创建和初始化并不需要合并为一个步骤，这样更加灵活。

最后对这几篇来个总结，js软件架构中可以采用类和继承设计模式，也可以采用行为委托设计模式，前者很常见，但后者虽然少见但更强大。行为委托认为对象之间是兄弟关系，互相委托，而不是父类和子类的关系。JS中的`[[Prototype]]`机制本质上就是行为委托机制。在js中可以努力使用类机制，也可以使用更自然的`[[Prototype]]`委托机制。

当使用对象关联来设计代码时，不仅可以让语法更简洁，而且可以让代码结构更清晰。对象关联是一种编码风格，它倡导的是直接创建和关联对象，不把它们抽象成类。对象关联可以用基于`[[Prototype]]`的行为委托非常自然的实现。