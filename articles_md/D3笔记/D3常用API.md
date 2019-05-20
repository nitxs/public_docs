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

selection.datum( 11 )
         .text( function( d, i ){
            return d + " " + i;
         } )
</script>
```