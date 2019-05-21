## 选择元素

d3中选择元素的API有两个：`select()`方法和`selectAll()`方法。

- `select`：返回匹配选择器的第一个元素，用于选择单个元素时使用；
- `selectAll`：返回匹配选择器的所有元素，用于选择多个元素时使用；

这两个选择元素的API方法的参数是选择器，即指定应当选择文档中的哪些元素。这个选择器参数可以是CSS选择器，也可以是已经被DOM API选择的元素(如`document.getElementById("id1")`)。不过为了简单易懂好维护，推荐使用CSS选择器。

此外如果要对选择集中的元素再进行一番选择，例如选择body中的所有p元素，除了使用CSS的派生选择器作为参数外，还可以采用这个方法`d3.select( "body" ).selectAll( "p" )`。这是类似于jQuery的链式调用写法。

## 选择集

选择集(`selection`)就是`d3.select()`和`d3.selectAll()`方法返回的对象。添加、删除、设置页面中的元素都需要用到这个选择集。

##### ①.查看选择集元素的状态

查看选择集的状态，有三个函数可用：

- `selection.empty()`：如果选择集为空，则返回`true`，非空返回`false`；
- `selection.node()`：返回第一个非空元素，如果选择集为空，返回`null`；
- `selection.empty()`：返回选择集中的元素个数；

```html
<body>
    <p>1</p>
    <p>2</p>
    <p>3</p>
</body>

<script>
let selection = d3.selectAll( "p" );

console.log( selection.empty() );   // false
console.log( selection.node() );    // <p>1</p>
console.log( selection.size() );    // 3
</script>
```

##### ②.获取和设置选择集元素的属性

d3中设置和获取选择集属性的API函数共有六个：

- `selection.attr( name[, value] )`：设置或获取选择集元素的属性，name是属性名，value是属性值，如果省略value，则返回当前name的属性值；如果不省略则将属性name的值设置为value。
- `selection.classed( name[, boolean] )`：设置或获取选择集元素的CSS类，name是类名，boolean是一个布尔值。布尔值表示该类是否开启。
- `selection.style( name[, value[, priority]] )`：设置或获取选择集元素的样式，name是样式名，value是样式值。如果只写第一个参数name，则返回该样式的值。
- `selection.property( name[, value] )`：设置或获取选择集元素的属性，name是属性名，value是属性值，如果省略value，则返回当前name的属性值；如果不省略则将属性name的值设置为value。有部分属性是不能用`attr()`来设置和获取的，最典型的是文本输入框的value属性，此属性不会在标签中显示。当使用第二个参数时，可以给文本框赋值。另外还有复选框等。
- `selection.text( [value] )`：设置或获取选择集元素的文本内容。如果省略value参数，则返回当前的文本内容。文本内容相当于DOM的innerText，不包括元素内部的标签。
- `selection.html( [value] )`：设置或获取选择集的内部HTML内容，相当于DOM的innerHTML，包括元素内部的标签。

## 操作选择集：添加、插入和删除

操作选择集的方法有添加、插入和删除。

- `selection.append( name )`：在选择集的末尾添加一个元素，name为元素名称。
- `selection.insert( name[, before] )`：在选择集中的指定元素之前插入一个元素，name是被插入的元素名称，before是CSS选择器名称。
- `selection.remove()`：删除选择集中的元素。该方法没有参数，就是单纯删除选择集对象对应的元素。

## 数据绑定

`d3.select()`和`d3.selectAll()`返回的元素选择集上是没有任何数据的。想要在选择集上绑定数据，就需要这样两个API方法：

- `selection.datum( [value] )`：选择集中的每一个元素都绑定相同的数据value，即
- `selection.data( [values[, key]] )`：选择集中的每一个元素分别绑定数组values中的每一项。key是一个键函数，用于指定绑定数组时的对应规则。

##### ①.datum()的工作过程

对于选择集中的每一个元素，`datum()`方法都为其增加一个`__data__`属性，属性值是`datum(value)`的参数value。value值类型任意，但如果值为`null`或`undefined`，则不会创建`__data__`属性。

![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190520_0.png?raw=true)

![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190520_1.png?raw=true)

数据被绑定到选择集元素上后，该如何使用呢？

以被绑定的数据替换元素中原本的文本为例：

```html
<body>
    <p>1</p>
    <p>2</p>
    <p>3</p>
</body>

<script>
let selection = d3.select( "body" ).selectAll( "p" );

selection.datum( 11 )       // 绑定数值11到所有选择集元素上
         .text( function( d, i ){   // 替换内容
            return d + " " + i;
         } )
</script>
```
上例的`text()`方法参数是一个匿名函数`function( d, i ){}`，该匿名函数的参数分别是`d`和`i`，表示数据和索引。

d3还能将被绑定的数据传递给子元素。例如

```javascript
selection.datum( 11 )
         .append( "span" )
         .text( function( d, i ){
            return d + " " + i;
         } ) )
```
此时在控制台打印的结果显示p的子元素span里也含有属性`__data__`，并且属性值也继承自p的`__data__`。

##### ②.data()的工作过程

`data()`能将数组各项分别绑定到选择集的各元素上，并且能指定绑定的规则。

当数组长度与选择集元素个数不一致时也可以处理：当数组长度大于元素数量时，为多余数据预留元素位置以便将来插入新元素；当数组长度小于元素数量时，能获取多余元素的位置，以便将来删除。

使用`data()`绑定数据的示例如下：

```html
<body>
    <p>1</p>
    <p>2</p>
    <p>3</p>
</body>

<script>
let dataset = [ 3, 6, 9 ];

let selection = d3.select( "body" ).selectAll( "p" );

let update = selection.data( dataset ); // 将数组绑定到选择集

console.log( update );  // 输出绑定结果
</script>
```
打印结果截图如下：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190520_2.png?raw=true)

上例中数据长度与选择集元素个数正好相等。当然也会有两者不等的情况。

根据数组长度与元素数量的关系，有以下三种情况：
- `update`：数组长度 === 元素数量
- `enter`：数组长度 > 元素数量
- `exit`：数组长度 < 元素数量

以上三种情况可以这样理解：
- 如果数组长度等于元素数量，则绑定数据的元素为`即将被更新 update`；
- 如果数组长度大于元素数量，则部分还不存在的元素`即将进入可视化 enter`；
- 如果数组长度小于元素数量，则多余的元素为`即将退出可视化 exit`；

以数组长度为5，元素数量为3为例：
```html
<body>
    <p>1</p>
    <p>2</p>
    <p>3</p>
</body>
<script>
let dataset = [ 3, 6, 9, 10, 2 ];

let selection = d3.select( "body" ).selectAll( "p" );

let update = selection.data( dataset ); // 将数组绑定到选择集

console.log( update );  // 输出绑定结果
</script>
```
结果截图：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190520_3.png?raw=true)

以数组长度为1，元素数量为3为例：
```html
<body>
    <p>1</p>
    <p>2</p>
    <p>3</p>
</body>
<script>
let dataset = [ 3 ];

let selection = d3.select( "body" ).selectAll( "p" );

let update = selection.data( dataset ); // 将数组绑定到选择集

console.log( update );  // 输出绑定结果
</script>
```
代码执行结果截图：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190520_4.png?raw=true)

从上面的截图可以看到，除了被绑定数据的三个p元素外，还有`enter()`和`exit()`两个函数，它们分别返回`enter`和`exit`部分。当数组长度大于元素数量时，`enter`函数有值,d3已为多余数组项10和2预留了位置以备将来添加元素；当数组长度小于元素数组时，`exit`函数有值。

##### ③.数据绑定的顺序

默认状态下，`data()`是按索引号顺序绑定的。如果需求要不按索引号绑定，可以使用`data()`方法的第二个参数，即键函数。注意，只有在选择集原来已有绑定数据的前提下，使用键函数才生效。

## 选择集的处理

之前讲过d3对数据绑定的操作。当数组长度与元素数量不一致时，有enter部分和exit部分，前者表示存在多余的数据待插入，后者表示存在多余的元素待删除。下面就来看下怎么d3是怎么处理这些多余的东西的，并给出一个处理模板，包含处理update、enter、exit。

##### ①.enter的处理方法

如果存在多余的数据待插入，即没有足够的元素，那么处理方法就是添加元素。

以下示例中p元素仅有一个，但数据有3个，因此enter部分就有多余的两个数据，解决办法是手动添加元素使其与多余数据对应，处理后就有3个p元素：
```html
<body>
    <p></p>
</body>

<script>
let dataset = [ 3, 6, 9 ];

let p = d3.select( "body" ).selectAll( "p" );

let update = p.data( dataset ),
    enter = update.enter();

    // update部分的处理方法是直接修改内容
    update.text( function( d, i ){
                return d;
              } )

    // enter部分的处理方法是添加元素后再修改内容
    enter.append( "p" )
         .text( function( d, i ){
            return d;
         } )
</script>
```

通常情况下，从服务器读取数据时，页面中是不会有与之相对应的元素的。此时最常用的方法是：**选择一个空集，然后使用enter().append()的方法来添加足够多的元素。**上例可以改为：

```html
<body>
</body>

<script>
let dataset = [ 3, 6, 9 ];

let body = d3.select( "body" );

body.selectAll( "p" )       // 选择body中的所有p元素，但由于没有p元素，所以返回的选择集对象是个空集
    .data( dataset )        // 绑定dataset数组
    .enter()                // 返回enter()部分
    .append( "p" )          // 添加p元素
    .text( function( d, i ){    // 修改p元素中的内容
        return d;
    } )
</script>
```

##### ②.exit的处理方法

如果存在多余的元素，但没有与之相对应的数据，即数组长度小于元素个数，那么d3就会使用`remove()`删除多余的元素。示例代码如下：

```html
<body>
    <p></p>
    <p></p>
    <p></p>
    <p></p>
    <p></p>
</body>

<script>
let dataset = [ 3, 6, 9 ];

let p = d3.select( "body" ).selectAll( "p" );

// 绑定数据后，分别获取update部分和exit部分
let update = p.data( dataset ),
    exit = update.exit();

    // update部分的处理方法是修改内容
    update.text( function( d, i ){
        return d;
    } )

    // exit部分的处理方法是删除元素
    exit.remove();
</script>
```
删除后页面上就不会有多余的空p元素。

##### ③.通用处理模板

在通常情况下，是不知道数组长度与元素个数关系的，所以需要给出一个通用的解决方案：

```html
<body>
</body>
<script>
let dataset = [ 3, 6, 9 ];

let p = d3.select( "body" ).selectAll( "p" );

// 绑定数据后分别返回update、enter、exit部分
let update = p.data( dataset );
let enter = update.enter();
let exit = update.exit();

// update部分的处理方法
update.text( function( d, i ){ return d; } );

// enter部分的处理方法
enter.append( "p" )
     .text( function( d, i ){ return d } );

// exit部分的处理方法
exit.remove();
</script>
```
如此，则不需要关心页面中的元素够不够，无论何种情况，页面中的元素和数组中每个数据都会一一对应显示，没有多余。这种通常模板在实际应用中是非常实用的。

##### ④.过滤器

有时需求要根据被绑定数据对某些选择集的元素进行筛选，从而获取选择集的子集，就要用到过滤器方法filter()。

```html
<body>
</body>
<script>
let dataset = [ 3, 6, 9 ];

let p = d3.select( "body" ).selectAll( "p" );

let update = p.data( dataset ),
    enter = update.enter(),
    exit = update.exit();

update.text( function( d, i ){
    return d;
} )

enter.append( "p" )
     .filter( function( d, i ){     // 筛选 数据大于6 的项显示
        if( d > 6 ){
            return true;
        }else {
            return false;
        }
     } )
     .text( function( d, i ){
        return d;
     } )

exit.remove();
</script>

```

##### ⑤.选择集的顺序

使用`sort()`可以将被绑定数据重新排列选择集中的元素。d3默认使用d3.ascending(递增)顺序排列。可以向`sort()`中传入一个匿名函数参数，来对选择集重新选择。

```html
<body>
</body>
<script>
let dataset = [ 3, 6, 9 ];

let p = d3.select( "body" ).selectAll( "p" );

let update = p.data( dataset ),
    enter = update.enter(),
    exit = update.exit();

update.text( function( d, i ){
    return d;
} )

enter.append( "p" )
     .sort( function( a, b ){   // 更改默认的递增排序为递减排序
        return b-a;
     } )
     .text( function( d, i ){
        return d;
     } )

exit.remove();
</script>

```

##### ⑥.each()

`each()`方法可以对选择集的各元素分别处理：

```html
<body>
</body>

<script>
let dataset = [
    {id: 3, name: 'nitx'},
    {id: 9, name: 'nz'},
    {id: 6, name: 'hx'}
];

let p = d3.select( "body" ).selectAll( "p" );

let update = p.data( dataset ),
    enter = update.enter(),
    exit = update.exit();

update.text( function( d, i ){
    return d.id + " " + d.age + ' ' + d.name;
} )

enter.append( "p" )
     .each( function( d, i ){
        d.age = i*20;
        return d;
     } )
     .text( function( d, i ){
        return d.id + " " + d.age + ' ' + d.name;
     } )

exit.remove();
</script>
```

##### ⑦.call()的应用

`call()`方法可以将选择集自身作为参数传入业务函数中，应用场景如拖拽、缩放元素等。

```html
<body>
</body>

<script>
let dataset = [
    {id: 3, name: 'nitx'},
    {id: 9, name: 'nz'},
    {id: 6, name: 'hx'}
];

let p = d3.select( "body" ).selectAll( "p" );


let update = p.data( dataset ),
    enter = update.enter(),
    exit = update.exit();

update.text( function( d, i ){
    return d.id + " " + d.age + ' ' + d.name;
} )

enter.append( "p" )
     .each( function( d, i ){
        d.age = i*20;
        return d;
     } )
     .call( fn )    // 将选择集传入call参数 fn 函数中进行操作
     .text( function( d, i ){
        return d.id + " " + d.age + ' ' + d.name;
     } )

exit.remove();

function fn( selection ){
    // 函数体内部定义对选择集的操作逻辑
    console.log( selection );
    console.log( selection.node() );
    selection.style( "color", "red" );
}
</script>
```

## d3中处理数组的API

尽管原生js中已有很多处理数组的API，甚至在ES6中又新增了好多方法，但并不能完全满足数据可视化的需求，d3为此封装了不少数组处理函数。

##### ①.排序

d3中对数组排序可以使用`sort()`方法，如果不传入比较函数，则默认是按钮`d3.ascending`(递增)排序，此外也可以定义成`d3.descending`(递减)排序。排序后会改变原数组。

```javascript
let arr = [ 10, 3, 5, 6, 7 ];
arr.sort( d3.ascending );   // [3, 5, 6, 7, 10]
arr.sort( d3.dscending );   // [10, 3, 5, 6, 7]
```

##### ②.求值

对数组求值的常用操作有最大值、最小值、中间值、平均值等。d3提供了相应的操作函数，它们类似于这样：`d3.fn( array[, accessor] )`。参数array就是目标操作数组，可选参数accessor是一个存取器函数，定义后数组各项会先执行accessor函数，然后再使用fn函数处理。注意以下方法中参数array里无效值(如null、undefined、NAN等在计算时会被忽略，不影响方法执行)

- `d3.min( array[, accessor] )`：返回数组最小值。
- `d3.max( array[, accessor] )`：返回数组最大值。
- `d3.extent( array[, accessor] )`：返回数组最小值和最大值，注意**返回值是一个数组**，第一项是最小值，第二项是最大值。
- `d3.sum( array[, accessor] )`：返回数组的总和，如果数组为空，则返回0
- `d3.mean( array[, accessor] )`：返回数组的平均值，如果数组为空，则返回undefind。注意由于数组中可能存在无效值，所以本方法求平均值并非按照`和/数组长度`来算，而是按照`和/去除无效值后的有效长度`来算的。
- `d3.median( array[, accessor] )`：求数组的中间值，如果数组为空，则返回undefined。如果数组的有效长度为奇数，则中间值为数组经递增排序后位于正中间的值；如果数组的有效长度为偶数，则中间值为经递增排序后位于正中间的两个数的平均值。
- `d3.quantile( numbers, p )`：求取p分位点的值，p的范围是[0, 1]。数组需要先递增排序。参数numbers是经递增排序后的数组。举例：`d3.quantile( numbers.sort(d3.ascending), 0.5 )`
- `d3.variance( array[, accessor] )`：求方差
- `d3.deviation( array[, accessor] )`：求标准差。方差和标准差用于度量随机变量和均值之间的偏离程度，多用于概率统计。其中标准差是方差的二次方根。这两个值越大，表示此随机变量偏离均值的程度越大。
- `d3.bisectLeft()`：获取某数组项左边的位置
- `d3.bisect()`：获取某数组项右边的位置
- `d3.bisectRight()`：获取某数组项右边的位置，以上这三方法用于**需要对数组中指定位置插入项时首先要获取指定位置**的需求。这几个方法可以配合`splice()`方法来插入项。

以上方法的代码示例：
```javascript
// 求最大最小值
let array1 = [ 30, 20, 10, 50, 40 ];
let min = d3.min( array1 );     // 10
let max = d3.max( array1 );     // 50
let extent = d3.extent( array1 );   // [10, 50]

// 在求值之前，先用accessor函数处理数据
let minAcc = d3.min( array1, function(d){ return d*3 } );       // 30
let maxAcc = d3.max( array1, function(d){ return d-5 } );       // 45
let extentAcc = d3.extent( array1, function(d){ return d%7 } ); // [1, 6]


// 求总和、平均值
let array2 = [ 69, 11, undefined, 53, 27, 82, 65, 34, NaN, null ];

let sum = d3.sum( array2, function( d, i ){ return d*2 } );     // 682
let mean = d3.mean( array2 );       // 48.714285714285715


// 求中间值
let array3 = [ 3, 1, 7, undefined, 9, NaN ];    // 数组有效长度为偶数
let median1 = d3.median( array3 );      // 5
let array4 = [ 3, 1, 7, undefined, 9, 10, NaN ];    // 数组有效长度为奇数
let median2 = d3.median( array4 );      // 7

// 求分位点的值
let array5 = [ 3, 1, 10 ];
array5.sort( d3.ascending );    // 递增
console.log( d3.quantile( array5, 0 ) );    // 1
console.log( d3.quantile( array5, 0.25 ) );    // 2
console.log( d3.quantile( array5, 0.5 ) );    // 3
console.log( d3.quantile( array5, 0.75 ) );    // 6.5
console.log( d3.quantile( array5, 0.9 ) );    // 8.600000000000001
console.log( d3.quantile( array5, 1 ) );    // 10

// 求方差和标准差，比较值偏离平均值的程度，结果显示虽然两个数组的平均值都是7.25，但是前者的方差和标准差大于后者，表明数组array6中的值偏离平均值程度更大
let array6 = [ 1, 9, 7, 9, 5, 8, 9, 10 ];
console.log( d3.mean( array6 ) );       // 平均值 7.25
console.log( d3.variance( array6 ) );   // 方差值 8.785714285714286
console.log( d3.deviation( array6 ) );  // 标准差值 2.9640705601780613

let array7 = [ 7, 8, 6, 7, 7, 8, 8, 7 ];
console.log( d3.mean( array7 ) );       // 平均值 7.25
console.log( d3.variance( array7 ) );   // 方差值 0.4999999999999999
console.log( d3.deviation( array7 ) );  // 标准差值 0.7071067811865475

// 在数组指定位置插入指定项
// 先回顾js的splice()方法是怎样删除和插入数组指定项的
let array8 = [ 'nitx', 'nz', 'sxm' ];

// 在数组索引为2的位置，删除0项，插入字符串hx
array8.splice( 2, 0, 'hx' );
console.log( array8 );  // ["nitx", "nz", "hx", "sxm"]

// 在数组索引为3的位置，删除1项，并插入字符串zn和xm
array8.splice( 3, 1, "zn", 'xm' );
console.log( array8 );  // ["nitx", "nz", "hx", "zn", "xm"]

// 在d3中，获取指定位置可以使用如 bisectLeft() 这样的方法：
let array9 = [ 20, 9, 16, 7 ];

// bisectLeft()所用的数组必须经过递增排序，第二个参数用于指定某项的位置，如果此项在数组中存在，则返回此位置的左边。如果此项在数组中不存在，则返回第一个大于此项的值的左边。
let iLeft = d3.bisectLeft( array9.sort( d3.ascending ), 16 );
console.log( iLeft );   // 2
// 在iLeft位置处删除0项，插入项 11
array9.splice( iLeft, 0, 11 );
console.log( array9 );  // [7, 9, 11, 16, 20]
```