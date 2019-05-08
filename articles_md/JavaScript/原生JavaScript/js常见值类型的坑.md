再来看下js中的值类型。

常见的值类型有数组(array)、字符串(string)、数字(number)等。

js中的数组可以容纳任何类型的值，可以是字符串、数字、布尔、对象甚至也可以是数组。对数组声明后即可向其中加入值，无需预先设定大小。这里有个小注意点，虽然可以用`delete`关键字来将单元从数组中删除，但单元删除后，数组的length属性并不会发生变化。

在创建稀疏数组(即含有空白或空缺单元的数组)时，其中的空白单元的值为undefined，但与将该单元显式赋值为undefined是有微妙区别的，这里注意。

类数组可以通过数组工具函数转换成数组。类数组有DOM查询返回的DOM元素列表、arguments对象等。

工具函数`slice()`经常被用于这类转换：
```javascript
function foo(){
    var arr = Array.prototype.slice.call(arguments);
    arr.push("bar");
    console.log(arr);
}
foo("baz", "fn");       //["baz", "fn", "bar"]
```
上例中，slice()方法返回了类数组`arguments`的一个数组副本。

再来看字符串，字符串也是一种类数组，也有length属性，也有一些和数组一样的方法如`indexOf()`和`concat()`方法等。js中的字符串是不可变的，而数组是可变的。字符串不可变是指字符串的成员函数不会改变其原始值，而是创建并返回一个新的字符串。而数组的成员函数都是在其原始值上进行操作的。
```javascript
var a = "nitx";
var c = a.toUpperCase();
a === c;        //  fasle
console.log(a);     // nitx
console.log(c);     // NITX
```
许多数组函数也可以借用来处理字符串，非常好使的：
```javascript
var a = "nitx";
console.log(a.join);    // undefined
console.log(a.map);     // undefined
var c = Array.prototype.join.call(a, "-");
var d = Array.prototype.map.call(a, function(v){
    return v.toUpperCase() + ".";
}).join("");
console.log(c);     // n-i-t-x
console.log(d);     // N.I.T.X.
```
借用数组成员函数的典型应用场景是字符串的反转：
```javascript
var a = "nitx";
var c = a.split("").reverse().join("");
console.log(c);     // xtin
```
这种方法是将字符串通过`split()`方法转成数组，然后使用数组的`reverse()`反转，再用`join()`方法重新拼成字符串。

之所以不能使用之前的`Array.prototype.reverse().call()`方法来直接反转字符串，就因为**字符串是不可变的**。

当如果有复杂字符串需要进行反转时，还不如直接使用数组，然后在需要字符串时，直接用`join()`方法转成字符串即可。