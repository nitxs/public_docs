怎么理解面向对象中的“对象”？

    过程与数据的结合，对象以方法的形式包含了过程。

怎么理解闭包？

    在过程中以环境的形式包含了数据。

两者的编程思路恰恰相反，但道理又互通。所以通常用面向对象思想能实现的功能，用闭包也能实现。反之亦然。

简单举例： 

```javascript
//闭包
var count = function(){
    var val = 0;
    return function(){
        console.log(val)
        val++
    }
}
var calcute = count()
calcute()   //0
calcute()   //1
calcute()   //2

//面向对象
var count = {
    val: 0,
    add: function(){
        console.log(this.val)
        this.val++
    }
}
count.add() //0
count.add() //1
count.add() //2

//或者用构造函数写面向对象
var Count = function(val){
    this.val = val
}
Count.prototype.add = function(){
    console.log(this.val)
    this.val++
}
var c1 = new Count(0)
c1.add()    //0
c1.add()    //1 
c1.add()    //2

```

