
## 1.Vue模板语法

#### 插值

vue中插入文本时使用双大括号语法，此时当绑定的数据对象值变动时，插值处的内容会实时更新。如果想执行一次性插值，当数据再次改变但插值处内容不会更新，可以使用`v-once`指令。

想要在模块上插入真正的html而非html代码，需要使用`v-html`指令。

如果想要动态修改html特性，如动态修改`id`、`disabled`之类的特性，可以使用`v-bind`指令。示例：`<span v-bind:id="dynamicId"></span>`，`<button v-bind:disabled="isButtonDisabled">btn</button>`。值得注意的是，当`isButtonDisabled`值为假时，`disabled`特性甚至不会被包含在渲染出来的`<button>`元素上。

#### 指令

指令是带有 `v-` 前缀的特殊特性，它的职责是，当表达示的值改变时，将其产生的连带影响，响应式的作用于DOM。

指令有`v-if`、`v-for`、`v-bind`、`v-on`。后两个指令可以在指令名称之后添加 " 冒号 + 参数 "来监听DOM事件或响应式的更新DOM特性。

例如`<a v-bind:href="url"></a>`，这里的`href`就是指令参数，意指将`a`元素的`href`特性与表达式`url`的值绑定; `<p v-on:click="doSomething">监听DOM</p>`，这里的`click`就是监听的事件名，`doSomething`就是`click`事件对应的事件处理函数。

#### 缩写

vue为`v-bind`和`v-on`这两个最常用的指令提供了特定简写：`<a v-bind:href="url"></a>`可以简写为`<a :href="url"></a>`；`<p v-on:click="doSomething">监听DOM</p>`可以简写为`<p @click="doSomething">监听DOM</p>`。

<hr>

## 2.计算属性和侦听器

对于复杂逻辑，可以在表达式中使用**计算属性**，这个计算属性定义在`computed`对象中，计算属性是一个进行逻辑运算并必须返回运算结果的函数，可以像绑定普通属性一样在模板中绑定计算属性名。

#### a.计算属性可缓存 / 方法不可缓存

如果计算属性中的运算逻辑依赖`data`对象中的数据属性(响应式依赖)，那么当对应的数据属性改变时，所有依赖该数据属性的计算属性就会重新求值。也就是说如果该数据属性值没有发生改变，即使多次访问计算属性也会立即返回之前的计算结果，而不必再次执行计算属性函数，这就是计算属性的特点：**可以缓存**。

通过在表达式中调用**方法**可以达到和计算属性一样的结果获取，但是**每当触发重新渲染时，调用方法总会再次执行。**

#### b.计算属性 / 侦听属性

侦听属性`watch`是一种更通用的用于观察和响应Vue实例上数据变动的方式。但容易滥用，通常情况下推荐使用计算属性而非命令式的`watch`回调。但是当需要在数据变化时执行异步或开销较大的操作时，选择侦听属性`watch`是更合适的。

所以对于**计算属性computed**、**方法methods**和**侦听属性watch**，各自选用的场景建议如下：

- 对于同步且性能开销较大且响应式依赖`data`对象中数据属性的运算逻辑，可以使用计算属性`computed`，这样当依赖的数据属性值不变时即便多次访问该计算属性也会立即返回之前计算并缓存的运算求值结果，直到依赖的数据属性值改变再次访问该计算属性时才会重新执行运算逻辑函数；

- 对函数运算结果没有缓存需求的情况，推荐在方法`methods`中添加运算函数；

- 当需要在数据变化时执行异步或者开销较大的操作时，推荐在侦听属性`watch`中添加运算函数。

应用计算属性`computed`的实例：需要动态变化的样式Class对象、内联Style对象。

<hr>

## 3.Class和Style绑定

动态控制元素的class和style属性列表是很常见的样式方面需求。在vue中由于它们都是属性，所以可以通过`v-bind`来处理：通过表达式计算出相应结果即可，结果类型可以是字符串、对象或数组。

#### a.绑定html的class

##### ①.对象语法

通过传给`v-bind:class`一个对象，可以动态切换class；在该对象中可以传入多个属性来动态切换多个class；`v-bind:class`指令还可以和普通class属性共存；被绑定的class对象不必内联定义在模块中，可将class对象定义在`data`属性中。官方推荐一种常用且强大的模式是绑定一个返回class对象的计算属性。

> 可以点击[这里](https://cn.vuejs.org/v2/guide/class-and-style.html)并 *搜索关键语句：绑定一个返回对象的计算属性* 快速查看官方示例。

##### ②.数组语法

也可以将一个数组传给`v-bind:class`以应用一个class列表；如果想根据条件来切换列表的class，可以使用三元表达式，当判断逻辑较复杂时可以在数组中使用对象语法。

##### ③.用于组件

当在一个自定义组件上使用class属性时，这些class类将被添加到该组件的根元素上，并且该根元素上已经存在的类不会被覆盖。

#### b.绑定内联样式 Style

##### ①.对象形式

`v-bind:style`的对象语法很直观，看起来很像普通css代码，但其实是一个js对象。其中的css属性名可以使用驼峰命名或短横线分隔(用单引号括起来)命名；通常更好的写法是直接绑定到一个样式对象上，如`<div v-bind:style="styleObj"></div>`，这让模板更清晰；官方推荐的写法是对象语法结合返回对象的计算属性使用，这个和class绑定的官方推荐一样。

##### ②.数组形式

`v-bind:style`的数组语法可以将多个样式对象应用到同一个元素上，如`<div v-bind:style="[baseStylesObj, overridingStylesObj]"></div>`

##### ③.自动添加前缀

在使用`v-bind:style`时，vue会自动帮需要添加浏览器引擎前缀的css属性添加相应的前缀，例如`display:flex`或者`transform`之类的css属性。

<hr>

## 4.条件渲染

vue中条件渲染有两种，分别是`v-if`和`v-show`。

其中`v-if`是“真正”的条件渲染，因为它会确保在切换过程中条件块内的事件监听器和子组件会适当的被销毁和重建，同时它是惰性的，当初始渲染条件为假时就什么不做，直到条件首次为真时才会渲染条件块，所以`v-if`有更高的切换开销；

而`v-show`则不管初始条件是什么，元素总会被渲染，并且只是简单地基于css进行切换，所以`v-show`有更高的初始渲染开销。

所以业务运行时需频繁切换的场景推荐使用`v-show`，业务运行时很少改变条件的场景推荐使用`v-if`。

另外注意官方不推荐同时使用`v-if`和`v-for`。即使两者都被应用在同一节点时，`v-for`的优先级也高于`v-if`，这意味着`v-if`将分别重复运行于每个`v-for`循环中，当想仅渲染某些循环出来的节点时，这种优先机制会很用；而如果目的是有条件的跳过循环的执行，可以将`v-if`置于外层元素或者`<template>`元素上。

#### a.条件渲染之 v-if

`v-if`指令被用于条件性的渲染一块内容。这块内容只会在指令的表达式返回真值时被渲染。

可以使用`v-if`、`v-else-if`和`v-else`进行元素的渲染条件判断。

由于`v-if`指令想要生效必须应用在某个具体元素上，所以当需求想根据某个判断条件同时渲染多个元素时，可以以`<template>`元素作为不可见的包裹元素包裹这些元素，并将`v-if`应用于`<template>`元素上。

vue会尽可能高效的渲染元素，所以通常会复用已有元素而不是重新渲染。比如当用户在不同登录场景切换时，切换出来的`input`输入框中已输入的内容不会被替换，因为vue使用的是同一个`input`元素，这样是为了提高渲染效率。但这不符合一些需求情况，它们会要求切换登录场景时重新渲染输入框以便清除之前输入的内容，此时就需要为输入框添加具有唯一值的属性`key`，它的作用是跟踪每个元素的身份从而重新渲染元素，具体代码示例可以看vue官方文档。

> 点击[这里](https://cn.vuejs.org/v2/guide/conditional.html)并 *搜索关键语句：用key管理可复用的元素* 查看。

#### b.条件渲染之 v-show

`v-show`指令也可条件展示元素。用法类似`v-if`，但是`v-show`不支持`template`元素，也不支持`v-else`。带有`v-show`的元素始终会被渲染并保留在DOM中，`v-show`也只是单纯切换元素的CSS属性`display`。

<hr>

## 5.列表渲染

列表渲染采用`v-for`指令。

#### a.用v-for通过数组元素迭代

`v-for`指令可以挨个渲染一组数组的所有迭代元素，使用的特殊语法是`item in items`，其中`items`是源数据数组，`item`是数组元素迭代别名。该特殊语法也可以写作`item of items`，即以`of`替代`in`作为分隔符，这类似于ES6中的迭代器语法。

`v-for`还支持一个可选的第二个参数作为当前项的索引，`(item, index) in items`。

在`v-for`循环的每个迭代块中，仍然拥有对父作用域属性的完全访问权限。

#### b.用v-for通过对象属性迭代

`v-for`指令遍历对象时，使用的特殊语法是`value in object`，可以看到遍历出来的结果是对象迭代属性的值。

除了默认的参数`value`外，`v-for`还支持第二个参数作为键名，第三个参数为索引，`(value, key, index) in object`。

vue中遍历对象是按`Object.keys()`的结果遍历的，这不能保证它的结果在所有的JS引擎下都一致。结合`v-for`迭代数组元素的特性，可以看出官方推荐用于遍历的数据结构是：由对象为元素组成的数组。

#### c.对v-for节点使用key

当vue使用`v-for`正在更新已经渲染过的元素列表时，默认使用"就地复用"策略，如果数据项的顺序被改变，vue将不会移动DOM元素来匹配数据项的顺序，而是简单地复用此处每个元素，并且确保它在特定索引下显示已被渲染过的每个元素。这种默认模式非常高效，但只适用于**不依赖子组件状态或临时DOM状态的列表渲染输出**。

如果需求需要能跟踪每个节点的身份，从而重用和重新排序现有元素，就需要为每项提供一个唯一`key`属性。这个`key`值应是每项都有的唯一id。

官方建议以在使用`v-for`时尽量提供绑定`key`值为最佳实践。

这个`key`是vue识别节点的一个通用机制，它不与`v-for`特别关联，还有其他用途。

设置`v-for`的`key`时应使用字符串或数据类型值，而不要使用对象或数组之类的非原始类型值。

#### d.数组更改检测

> 参考[这里](https://github.com/nitxs/private_materials/blob/master/webapck4/webpack4~vue/src/views/pages/test/TestF.vue)的代码实例

vue中包含一组观察数组的变异方法，执行这些方法会改变被这些方法调用的原始数组并触发视图更新，这些方法为：`push()`、`pop()`、`shift()`、`unshift()`、`splice()`、`sort()`、`reverse()`。

相对的也有非变异方法，执行这些方法不会改变原始数组，但总是返回一个新数组。这些方法为：`filter()`、`concat()`和`slice()`。由于这些方法不改变原始数组，所以如想触发视图更新，就需要将返回的新数组替换旧数组，例如`this.itemArr = this.itemArr.filter( function( item ){ return item.message.match( /Foo/ ) } )`，以此主动更改原始数组从而触发视图更新，并且这种操作不会造成性能担忧，因为官方表示在vue中将含有相同元素的数组替换原数组是非常高效的操作。

注意：除了非变异方法不能主动触发视图更新外，还有两种数组变动情况不会主动触发视图更新：

- 当利用索引直接设置一个项时(`vm.items[indexOfItem] = newVal`)；
- 当直接修改数组长度时(`vm.items.length = newLength`)。
  
这两种数组变动操作都是非响应性。

为解决第一类问题，可以使用以下两种方式实现第一类问题效果并触发视图更新：`Vue.set( vm.items, indexOfItem, newValue )`或者`vm.items.splice( indexOfItem, 1, newValue )`。其中`Vue.set()`方法还可以换成该方法的别名`vm.$set()`，它们所传参数一样。

为解决第二类问题，可以使用`vm.items.splice( newLength )`实现相同效果并能触发视图更新。

#### e.对象更改检测

同样由于JavaScript语言限制，Vue不能检测对象属性的添加或删除，也不能触发响应性视图更新。

如果要实现更改对象属性后可以触发视图更新的需求，可以有两种方法。

更改对象的单个属性：`Vue.set( objct, key, value )`或别名方法`vm.$set( object, key, value )`。

更改对象的多个属性：`vm.object = Object.assign( {}, vm.object, { key1: value1, key2: value2, ... } )`。

#### f.显示过滤/排序结果

当需求要显示一个数组的过滤或排序副本且不实际改变数组的原始数据时，可以考虑创建返回经过滤或排序的新数组的计算属性，当计算属性不适用时可以使用一个method方法。

#### g.v-for可以遍历一段取值范围

`v-for`可以遍历一个整数：`v-for="n in 10"`

`v-for`可以利用`<template>`渲染多个元素，类似`v-if`。

#### h.v-for可以用于组件

在自定义组件中可以使用`v-for`。但是由于组件有自己独立的作用域，`v-for`遍历的迭代数据不会自动传到组件内部，要通过`props`实现这个需求：`<myComponent v-for="(item, index) in items" :key="item.id" :item="item" :index="index"></myComponent>`。

<hr>

## 6.事件处理

> 参考[这里](https://github.com/nitxs/private_materials/blob/master/webapck4/webpack4~vue/src/views/pages/test/TestG.vue)的代码实例

#### a.监听事件

使用`v-on`指令监听DOM事件，如 "click" 事件、"mouseover"事件等。对应的指令参数有多种形式：js表达式(简单计算)、事件回调方法名、内联调用事件回调方法。

其中如选择将参数写成内联调用事件回调方法，可以对所调用回调进行传参，当方法逻辑中需要访问原始DOM事件时，可以将特殊变量`$event`作为参数传入回调方法，该变量的作用是可以访问原生js事件对象`event`。

#### b.事件修饰符

通常事件处理程序中会调用`event.preventDefault()`取消默认事件和`event.stopPropagation()`阻止冒泡与捕获事件。在vue中更好的方法是：方法中只有纯粹的数据逻辑，而不去处理DOM事件细节。为满足这种需求，vue为`v-on`提供了事件修饰符，是由点开头的指令后缀表示：

- `.stop`(阻止单击事件继续传播)；
- `.prevent`(取消默认事件)；
- `.capture`(启用捕获模式，即即元素自身触发的事件先在此处理，然后才交由内部元素进行处理)；
- `.self`(只当在 event.target 是当前元素自身时触发处理函数，即事件不是从内部元素触发的)；
- `.once`(点击事件将只会触发一次。还可被用到自定义组件上，其他修饰符不能)；
- `.passive`(点击[这里](https://cn.vuejs.org/v2/guide/events.html)查看，*搜索关键字passive*)；

#### c.按键修饰符 / 系统修饰符

vue中可以用`v-on`监听键盘事件，如`enter`、`tab`、`esc`等。可以监听`ctrl`、`alt`、`shift`等按键，通过`exact`修饰符还可以监听由精确的系统修饰符触发的事件，如单按`ctrl`时触发。

当一个ViewModel被销毁时，所有已定义的事件监听器会自动被删除。

<hr>

## 7.表单输入绑定

> 参考[这里](https://github.com/nitxs/private_materials/blob/master/webapck4/webpack4~vue/src/views/pages/test/TestH.vue)的代码实例

#### a.基础用法

可以通过`v-model`指令在表单元素上创建双向数据绑定，它会根据控件类型自动选取正确的方法更新元素，它负责监听用户的输入事件以更新数据。

`v-model`指令会忽略所有表单元素自身定义的`value`、`checked`和`selected`特性的初始值，而总是会将vue实例的数据作为数据来源，所以在定义表单元素时应在`data`选项中声明初始值：

- `v-model`应用于`<input type="text">`文本框时，会忽略`value`特性的初始值，而是将vue实例的数据作为数据来源；
- `v-model`应用于`<select>`单选下拉时，会忽略`selected`特性的初始值，而是将vue实例的数据作为数据来源；
- `v-model`应用于`<select multiple>`多选下拉时，会忽略`selected`特性的初始值，而是将vue实例的数据作为数据来源，此时应绑定到一个数组中；
- `v-model`应用于`v-for`渲染的`<select><option v-for=""></option></select>`动态下拉时，会忽略`selected`特性的初始值，而是将vue实例的数据作为数据来源，此时应绑定到一个数组中；
- `v-model`应用于`<textarea>`多行文本域时，会忽略`selected`特性的初始值，而是将vue实例的数据作为数据来源；
- `v-model`应用于`<input type="checkbox">`单个复选框时，会忽略`checked`特性的初始值，而是将vue实例的数据作为数据来源；
- `v-model`应用于`<input type="checkbox">`多个复选框时，会忽略`checked`特性的初始值，而是将vue实例的数据作为数据来源，将多个复选框的`v-model`绑定到同一个数组；
- `v-model`应用于`<input type="radio">`单选按钮时，会忽略`checked`特性的初始值，而是将vue实例的数据作为数据来源。

#### b.值绑定

对于单选按钮、复选框和选择框的选项，`v-model`绑定的值通常是静态字符串(对于复选框也可以是布尔值)，但有时需求要将值绑定到vue实例的一个动态属性上，就可以用`v-bind`实现，这个属性的值可以不是字符串。

#### c.修饰符

##### ①.`.lazy`修饰符

默认情况下，`v-model`在每次`input`事件触发后将输入框的值与数据进行同步。如果需求要将这种同步转为使用`change`事件同步，可以给`v-model`添加`.lazy`修饰符。

##### ②.`.number`修饰符

给`v-model`添加`.number`修饰符可以自动将用户的输入值转为数值类型。这通常很有用，因为即使在 `type="number"` 时，HTML 输入元素的值也总会返回字符串。如果这个值无法被 `parseFloat()` 解析，则会返回原始的值。

##### ③.`.trim`修饰符

给`v-model`添加`.trim`修饰符自动过滤用户输入的首尾空白字符。

<hr>

## 8.组件基础

> 参考[这里](https://github.com/nitxs/private_materials/blob/master/webapck4/webpack4~vue/src/views/pages/test/TestI.vue) 代码实例

组件必须注册才能使用，有两种组件注册类型：全局注册和局部注册。

全局注册是在Vue根入口js文件中通过`Vue.component( 'component-name', { /* component options... */ } )`注册，可被用于Vue根实例及其组件树中的所有子组件的模板中。

#### a.组件的复用

组件是可被任意次复用的vue实例，它与`new Vue`接收相同的选项，包括`data`、`computed`、`methods`、`watch`以及生命周期函数等。每用一次组件就会有一个它的新实例被创建，所以每个组件都会各自独立维护它的数据，这是因为组件的选项`data`必须是函数，每个组件实例都可以维护一份被`data`函数返回对象的独立的拷贝。如果让`data`直接提供一个对象，则同一组件复用多次时每个该组件的实例会共用同一份`data`数据对象。

#### b.通过prop特性向组件传递数据

prop是可以在组件上注册的一些自定义特性。当一个值传递给一个prop特性的时候，它就变成那个组件实例上的一个属性。可以使用`props`选项来放置该组件可接收的prop特性。

一个组件可以拥有任意数量的prop特性，任何值都可以传递给任何prop特性，在组件实例中访问prop特性就像访问`data`中的值一样。

在应用到组件的模板中，可以通过`v-bind:propName`来将值动态传递给组件的prop。

#### c.单个根元素

组件的所有html内容必须首先被包裹在一个父元素中。当组件的prop列表数量过多或复杂时，可以重构porp列表，改为只接受一个单独的`prop`特性，这个`prop`特性应该是一个包含多个元素的复杂数据结构，例如对象或包含对象元素的数组。这样当应用组件模板中为要传递给组件中`prop`特性的值添加新的属性时，在组件中自动可用，而无须在组件中再次添加新的prop。

#### d.监听组件中事件

当父子组件之间要进行沟通时，可以在父组件内通过`v-on`监听某个事件名，并定义该事件名对应的事件处理函数，同时在子组件内通过调用内建的`$emit`方法并传入该事件名来触发它。即可完成父子组件的事件通信。伪代码示例如下：

```javascript
// 父组件
<template>	
    <!-- 全局注册组件 -->
    <my-component v-on:listener="listenFn"></my-component>

    <!-- 局部注册组件 -->
    <component-one @localityListener="listenFn2"></component-one>
</template>
<script>
	import componentOne from "@/views/pages/componentTest/componentOne";
	export default {
		data(){
			return {}
		}
		methods: {
	        listenFn(){
	            /* 定义全局组件监听器执行函数执行时的逻辑 */
	        },
	        listenFn2(){
				/* 定义局部组件监听器执行函数执行时的逻辑 */
			}
	    },
	    components: {
	        'component-one': componentOne
	    }
	}
    
</script>

// 全局注册的子组件
Vue.component( "my-component", {
    props: [],
    template: `
        <div class="component-wrap">
            <button type="button" v-on:click="$emit( 'listener' )">子组件按钮</button>
        </div>
    `
} )

// 局部注册的子组件
<template>
    <div>
        <button type="button" @click="$emit( 'localityListener' )">点击</button>
    </div>
</template>
```

在子组件触发监听的事件名除了上述写法，还可以这样写：

```javascript
<template>
    <div>
        <button type="button" @click="emitFn">点击</button>
    </div>
</template>

<script>
    export default {
        methods: {
            emitFn(){
                this.$emit( 'localityListener', data )
            }
        }
    }
</script>
```

以上代码示例解释：父组件通过`v-on`监听事件名`listener`，并定义事件触发处理函数`listenFn`；子组件通过`v-on`绑定事件触发条件`click`，当条件满足(发生click事件)时通过内建方法`$emit()`触发被父组件监听的事件名，从而执行父组件中该事件监听器定义的事件处理函数`listenFn`。注意这里的子组件事件触发条件`click`仅为举例，请根据实际情况定义合适的触发条件；内建方法`$emit( eventName, [...args] )`中需要传入必选参数`eventName`，该参数为要触发的事件名，可选参数`[...args]`为传递给监听器回调的数据。

#### e.在组件上使用v-model

在了解组件上使用`v-model`功能之前，有个前置知识点，就是在不使用组件的常规场景中：

```javascript
<input type="text" v-model="inputText">
<p>{{inputText}}</p>

// 等价于

<input type="text" v-bind:value="inputText" v-on:input="inputText = $event.target.value">
<p>{{inputText}}</p>
```

所以要在组件中使用`v-model`时，需要在子组件中进行相应配置，示例如下：

```javascript
// 父组件中调用子组件component-two，并使用v-model功能
<template>
    <component-two v-model="inputText"></component-two>
    <p>{{inputText}}</p>

    // 等价于
    <component-two :value="inputText" @input="inputText = $event"></component-two>
    <p>{{inputText}}</p>
</template>

// 子组件
<template>
    <input type="text" :value="propValue" @input="$emit( 'input', $event.target.value )">
</template>
// props属性配置
<script>
export default {
    props: [ "propValue" ],
}
</script>
```

#### f.通过插槽分发内容

组件也可以像HTML标签那样在标签内添加相应内容，只需要使用Vue自定义的`<slot>`元素，也就是在组件定义时在需要插入元素的地方添加插槽元素`<slot></slot>`即可。

#### g.动态组件

有些业务场景需要实现不同组件之间的动态切换，此时可以通过Vue的`<component>`元素加一个特殊的`is`特性来实现：`<component :is="currentComponent"></component>`，这样组件会在`currentComponent`值改变时改变。`currentComponent`值可以包括两种：已注册组件的名字、一个组件的选项对象。

#### h.解析DOM模块时的注意事项

有些 HTML 元素，诸如 `<ul>`、`<ol>`、`<table>` 和 `<select>`，对于哪些元素可以出现在其内部是有严格限制的。而有些元素，诸如 `<li>`、`<tr>` 和 `<option>`，只能出现在其它某些特定的元素内部。

这会导致我们使用这些有约束条件的元素时遇到一些问题。例如：

```javascript
<table>
  <blog-post-row></blog-post-row>
</table>
```

这个自定义组件 `<blog-post-row>` 会被作为无效的内容提升到外部，并导致最终渲染结果出错。幸好这个特殊的 `is` 特性给了我们一个变通的办法：

```javascript
<table>
  <tr is="blog-post-row"></tr>
</table>
```

