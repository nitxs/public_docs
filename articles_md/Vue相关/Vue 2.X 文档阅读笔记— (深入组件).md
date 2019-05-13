# Vue 2.X 文档阅读笔记— (深入组件)

## 0.组件注册

#### 组件名

组件注册时需要起个名，不论是全局注册组件还是局部注册组件。

全局注册组件命名格式有两种写法：

1. **字母全小写且必须包含一个连字符**写法，示例：`Vue.component( "my-component", { /* ... */ } )`，引用这个组件元素时也必须使用相同格式，示例：`<my-component></my-component>`。

2. **大驼峰**写法，示例`Vue.component( "MyComponent", {/*...*/} )`，引用这个组件元素时，可以两种写法：字母全小写包含一个连字符`<my-component></my-component>`、大驼峰`<MyComponent></MyComponent>`。

官方推荐使用写法1来定义全局注册组件命名，以避免可能出现的与HTML元素相冲突的情况。

局部注册组件的命名通常为**大驼峰**写法，示例`MyComponent`，在引用该组件元素时官方同样推荐采用上述写法1来命名，示例`<my-component></my-component>`，当然可以写作`<MyComponent></MyComponent>`。

#### 全局注册

全局注册组件是在新创建的Vue根实例(`new Vue`)模板中通过`Vue.component()`方法创建的，它可以被用在该根实例对应的所有子模板中，并且多个全局注册组件在各自内部也都可以相互使用。

需要注意的是**全局注册的行为必须在根 Vue 实例 (通过 `new Vue`) 创建之前发生**。

#### 局部注册

由于全局注册会增加项目构建成本，使用户存在可能的JS下载冗余，所以除非必要，推荐采用局部注册组件。

最简单的定义局部注册组件方法是通过一个普通的JavaScript对象来定义组件，然后在`components`选项中定义该组件：

```javascript
// vue模板
// 定义局部注册组件
let ComponentA = {
    props: [],
    template: `
        <div>aa</div>
    `
}
export default {
    components: {
        "component-a": ComponentA
    }
}
```

`components`选项对象中的属性名是自定义组件元素的名，属性值是该组件的选项对象。

局部注册的组件是不能像全局注册组件那样在各自内部互相调用的，除非手动引用，如`import componentA from "./componentA.vue"`，然后再在`components`选项中定义组件元素。

#### 模块系统

##### ①.在模块系统中局部注册

如果vue项目构建使用了例如`babel`和`webpack`这样的模块系统，则官方推荐创建一个用于放置单文件组件的`components`目录。然后在需要使用局部注册组件的模板文件中导入并定义在`components`选项中即可：

```javascript
// 业务模板文件
import ComponentThr from "@/views/pages/componentTest/ComponentThr";

export default {
    components: {
        "component-thr": ComponentThr,
    }
}
```

##### ②.自动全局注册基础组件

所谓的基础组件，就是只包裹一个输入框或按钮之类的元素的相对通用的简单组件，这些简单组件通常会被频繁的用于一些逻辑较复杂的大组件中。一般情况下，这会导致很多大组件里都有一个包含基础组件的长列表：

```javascript
import BaseButton from './BaseButton.vue'
import BaseIcon from './BaseIcon.vue'
import BaseInput from './BaseInput.vue'

export default {
  components: {
    BaseButton,
    BaseIcon,
    BaseInput
  }
}
```

如果vue项目构建用了webpack，就可以在入口文件中使用`require.context`来全局注册这些非常通用的基础组件。具体代码示例官方文档有，可以点击[这里](https://cn.vuejs.org/v2/guide/components-registration.html) 并搜索关键字 *基础组件的自动化全局注册* 来查看。

<hr>

## 1.Prop

#### Prop类型

最简单的`props`选项的值是以字符串数据形式列出的prop：`props: [ "name", "age", "job" ]`。

但如果想要指定每个prop的类型，就需要以对象形式列出prop，对象的属性是prop名称，属性值是prop类型：

```javascript
export default {
  props: {
    title: String,
    likes: Number,
    isPublished: Boolean,
    commentIds: Array,
    author: Object,
    callback: Function,
    contactsPromise: Promise // or any other constructor
    }
}
```

#### 传递静态或动态Prop

如需向组件内传递静态值，可以这样写：`<my-component title="my news"></my-component>`。

如需向组件内传递动态值，可以通过`v-bind`来动态赋值：`<my-component :title="arc.title"></my-component>`，或者也可以动态赋予一个复杂表达式的值：`<my-component :title="arc.title1 + "-" + arc.title2"></my-component>`

以上两种组件传递prop值均为字符串，事实上，除了字符串，还可以传递其他任何类型的值。

##### ①.传入数字

传递一个数字类型的prop时，必须始终通过`v-bind`来告诉vue传递的是一个js表达式而非字符串：`<my-component :num="666"></my-component>`或`<my-component :num="arc.num"></my-component>`。

##### ②.传入布尔值

用变量进行动态赋值：`<my-component :isActive="arc.activeVar"></my-component>`。

同传入数字，即使传入的prop值是静态的，也需要使用`v-bind`：`<my-component :isActive="false"></my-component>`。

当传入的prop没有值时，其实意味着传入`true`：`<my-component isActive></my-component>`。

##### ③.传入数组

用变量进行动态赋值：`<my-component :idsArr="arc.idArr"></my-component>`。

同传入数字，即使传入的prop值是静态的，也需要使用`v-bind`：`<my-component :idsArr="[ 5, 1, 20 ]"></my-component>`。

##### ④.传入对象

用变量进行动态赋值：`<my-component :idsObj="arc.idObj"></my-component>`。

同传入数字，即使传入的prop值是静态的，也需要使用`v-bind`：`<my-component :idsObj="{ name: 'nitx', age: 31 }"></my-component>`。

##### ⑤.传入对象的所有属性

如果要将一个对象中的所有属性一次性全传入子组件，除了使用④中的直接传入对象给prop，还可以使用不带参数的`v-bind`将一个给定对象的所有属性全传入：

```javascript
// 使用v-bind直接将给定对象所有属性一次性全传到子组件的props列表中
`<my-component v-bind="arc.idObj"></my-component>`

// 等价于

`<my-component v-bind:title="arc.idObj.title" v-bind:author="arc.idObj.author"></my-component>`

<script>
export default {
    data(){
        return {
            arc: {
                idObj: {
                    title: '******',
                    author: 'nitx'
                }
            }
        }
    }
}
</script>
```

#### 单向数据流

> 参考 [这里](https://github.com/nitxs/private_materials/blob/master/webapck4/webpack4~vue/src/views/pages/test2/Test2B.vue)代码实例

在Vue组件中，父组件prop的更新会向下流动到子组件中，但反过来不行。这样会防止从子组件意外改变父组件的状态，从而导致程序的数据流难以理解。

每次父组件发生更新时，子组件中所有的prop都会刷新成为最新的值。所以不应该在子组件内部主动改变prop。如果这样做，浏览器会发出警告。

以下为两种常见试图改变子组件内部prop的业务场景：

1. 某个prop传递一个初始值，在子组件内部希望将其作为一个本地数据来使用。此时，推荐定义一个本地的data属性来将这个prop用作其初始值：

```javascript
props: ['initialCounter'],
data: function () {
  return {
    counter: this.initialCounter
  }
}
```

2. 某个prop以一种原始的值传入并且需要进行某种转换。此时推荐使用这个prop值来定义一个计算属性：

```javascript
props: ['size'],
computed: {
  normalizedSize: function () {
    return this.size.trim().toLowerCase()
  }
}
```

在子组件内部改变prop值时需要注意一点，如果prop值是数组或对象类型，那在子组件内部改变后会影响到父组件中的状态，因为在 JavaScript 中对象和数组是通过引用传入的。

#### Prop验证

> 参考 [这里](https://github.com/nitxs/private_materials/blob/master/webapck4/webpack4~vue/src/views/pages/test2/Test2C.vue)代码实例

可以为组件的prop指定验证要求，这会保证组件的正确使用，如未满足验证要求，vue会在浏览器中显示警告。

为定制prop的验证方式，可以`props`中的值提供一个带有验证需求的对象，而非字符串数组，可以看如下代码示例。需要注意的是prop会在组件实例创建之前就进行验证，所以实例属性如`data`或`computed`等在`default`或`validator`函数中是不可用的。

```javascript
<template>
    <div class="wrap">
        <component-A v-bind="valObj"></component-A>
    </div>
</template>

<script>
let ComponentA = {
    props: {
        // 基础的类型检查 ( null 和 undefined 会通过任何类型检查 )
        propA: null,
        // Number类型
        propB: Number,
        // 多个可能的类型
        propC: [ String, Number ],
        // 必填的字符串
        propD: {
            type: String,
            require: true
        },
        // 带有默认值的数字
        propE: {
            type: Number,
            default: 666
        },
        // 带有默认值的对象
        propF: {
            type: Object,
            // 对象或数组的默认值必须从一个工厂函数中return获取
            default: function(){
                return { message: 'ok' }
            }
        },
        // 自定义验证函数
        propG: {
            validator: function( value ){
                // propG的值必须匹配下列字符串中一个
                return [ "success", "warning", "danget" ].indexOf( value ) !== -1;
            }
        }

    },
    template: `
        <div class="sub-class">
            <p>{{propA}}</p>
            <p>{{propB}}</p>
            <p>{{propC}}</p>
            <p>{{propD}}</p>
            <p>{{propE}}</p>
            <p>{{propF}}</p>
            <p>{{propG}}</p>
        </div>
    `
}
export default {
    data(){
        return {
            valObj: {
                propA: 10,
                propB: 99,
                propC: "sxm",
                propD: "nitx",
                propE: 120,
                propF: { name: "sxm" },
                propG: "warning"
            }
        }
    },
    components: {
        'component-A': ComponentA
    }
}
</script>

<style lang="scss" scoped>

</style>
```

其中上面验证`type`的类型值可以是js中原生构造函数中的任一个，包括`Number`，`Number`,`Boolean`,`Array`,`Object`,`Date`,`Function`,`Symbol`。此外也可以自定义一个构造函数，prop的`type`验证会通过`instanceof`来检查确认，示例如下会验证prop`propH`的值是否是构造函数`Fn`的实例对象：

```javascript
// 自定义构造函数
function Fn( name, age ){
    this.name = name;
    this.age = age;
}

let ComponentA = {
    props: {
        propH: Fn
    }
}
```

#### 向子组件传递非Prop特性

当一个没有在子组件`props`列表中定义接收prop的特性被从父组件传递给子组件时，这个未定义接收prop的特性会被添加到子组件的根元素上。

还是以上面的prop验证代码为示例。

假设子组件`ComponentA`的`props`列表中未定义特性`data-propI`，在父组件调用该子组件元素时这样写：`<component-A v-bind="valObj" :data-propI="actived"></component-A>`，同时在父组件`data`选项中定义了`actived: 'active-class'`。当父组件发生更新时，子组件的根元素上就会多出一个特性`<div data-propi="active-class" class="sub-class">...</div>`。

这样就可以以另一种方法把值由父组件传递给子组件，应用场景有：可以给子组件根元素添加样式`class`(`<component-A v-bind="valObj" class="ui-color-9"></component-A>`)、预存某些值到子组件上....，等等，在实际开发中灵活性就很大了，可能就能实现某些比较奇怪的需求。

##### ①.替换/合并已有特性

再补充下，根据官方文档的说法，父组件传递给子组件的非prop特性中，如果传递的是`class`和`style`这样样式特性，会与子组件对应的`class`和`style`进行值合并。以上面第一个应用场景为例的话，，父组件这样传：`<component-A v-bind="valObj" :class="actived"></component-A>`，子组件根元素上会这样显示：`<div class="sub-class active-class">...</div>`，直接在已有`class`特性上合并添加了父组件传递来的非prop特性`class`的值。

##### ②.禁用特性继续

如果不想子组件的根元素继承特性，可以在组件选项中设置`inheritAttrs: false`。

<hr>

## 3.自定义事件

#### 事件名

由于事件名不存在任何自动化的大小写转换，所以触发的事件名需要完全匹配监听这个事件所用的名称。

#### 自定义组件的`v-model`

> 参考[这里](https://github.com/nitxs/private_materials/blob/master/webapck4/webpack4~vue/src/views/pages/test2/Test2E.vue)查看代码示例

在[Vue 2.X 文档阅读笔记一 (基础)](https://blog.csdn.net/qq_34832846/article/details/89945127)中有关于组件的`v-model`应用举例，但其中示例是以表单输入框元素为例的，而vue组件的`v-model`默认就是利用的名为`value`的prop和名为`input`的事件，那么如果组件中不是使用表单输入框元素，而是像单选框、复选框这样的表单元素控件呢，是不是就不能再用`v-model`了？

对这个问题，官方提供了组件中配置`model`选项来避免这样的冲突：

```javascript
Vue.component('base-checkbox', {
  model: {
    prop: 'checked',
    event: 'change'
  },
  props: {
    checked: Boolean
  },
  template: `
    <input
      type="checkbox"
      v-bind:checked="checked"
      v-on:change="$emit('change', $event.target.checked)"
    >
  `
})
```
这样当在这个组件上使用`v-model`时，就可以照常使用：`<base-checkbox v-model="lovingVue"></base-checkbox>`。

上述代码的解释照抄文档解释：这里的 `lovingVue` 的值将会传入这个名为 `checked` 的 prop。同时当 `<base-checkbox>` 触发一个 `change` 事件并附带一个新的值的时候，这个 `lovingVue` 的属性将会被更新。注意仍然需要在组件的 `props` 选项里声明 `checked` 这个 prop。

#### 将原生事件绑定到组件

> 参考[官方文档](https://cn.vuejs.org/v2/guide/components-custom-events.html)，搜索关键字 将原生事件绑定到组件

#### 实现某些场景的prop双向绑定需求

当有些情况下，需要对一个prop进行双向绑定时，vue自2.3.0版本开始也提供友好支持，官方推荐以 `update:myPropName` 的模式触发事件。

> 参考[官方文档](https://cn.vuejs.org/v2/guide/components-custom-events.html)，搜索关键字 .sync

<hr>

## 4.插槽

#### 插槽内容

##### ①.默认插槽(匿名插槽)

在业务模板中调用组件元素时，如想在组件元素起始标签和结束标签之间额外添加模板代码甚至是HTML时，需要在定义组件时就在其内部包含一个`<slot></slot>`元素，这个插槽元素就是默认插槽。

##### ②.插槽内容可访问的作用域

在业务模板中调用组件元素并在起始结束标签之间插入插槽内容时，如想在插槽内容中获取由业务模板传递到组件内部的prop值时，是**获取不到的**。这方面的规则是插槽内容可以访问业务模板实例属性所处作用域，而不能访问组件内部实例属性的作用域。官方给出的解释是这样的：**父级模板里的所有内容都是在父级作用域中编译的；子模板里的所有内容都是在子作用域中编译的。**

##### ③.预设插槽的默认内容

当在组件内插槽元素`<slot>`中设置默认内容，那么如果在业务模板里调用组件元素时没有提供插槽内容，vue就会渲染出定义好的默认插槽内容。

```javascript
<template>
    <div class="wrap">
        <!-- 插槽 -->
        <div id="app-2">
            <component-B url="/setting">
                <p>访问地址是 {{url}}</p>
                <p>aaa</p>
                <template v-slot:myname>
                    sxm
                </template>
            </component-B>
        </div>
    </div>
</template>

<script>
let ComponentB = {
    props: [ "url" ],
    template: `
        <div class="sub-class">
            <p>{{url}}</p>
            <p>组件内部可以显示出访问地址：{{url}}</p>
            <slot>nitx</slot>
            <!-- 设置插槽的默认内容 -->
            <slot name="myname">nitx</slot>
        </div>
    `
}
export default {
    data(){
        return {

        }
    },
    components: {
        'component-B': ComponentB
    }
}
</script>
```

#### 具名插槽

有时需求要在组件内部添加多个插槽，为了明确告知vue正确对应，需要利用到插槽元素`<slot>`的一个特殊特性：`name`。

通常插槽元素`<slot>`不带`name`时会默认带有隐含的名`default`，它被叫做***默认插槽***；而显式添加了`name`特性并给出对应名称值时，这样的插槽叫做**具名插槽**。

在业务模板调用含有具名插槽的组件时，如果要向具名插槽提供内容时，可以在一个`template`元素上使用`v-slot`指令，并以`v-slot`的参数形式提供其名称。示例代码如下：

```javascript
<template>
    <div class="wrap">
        <!-- 插槽 -->
        <component-A>
            <template v-slot:header>
                <div>这是页面头部</div>
            </template>
            <template v-slot:default>
                <div>这是页面主体内容</div>
            </template>
            <template v-slot:footer>
                <div>这是页面底部</div>
            </template>
        </component-A>
    </div>
</template>

<script>
let ComponentA = {
    props: [],
    template: `
        <div class="sub-class">
            <header>
                <slot name="header"></slot>
            </header>
            <main>
                <slot></slot>
            </main>
            <footer>
                <slot name="footer"></slot>
            </footer>
        </div>
    `
}
export default {
    data(){
        return {

        }
    },
    components: {
        'component-A': ComponentA
    }
}
</script>
```

#### 作用域插槽

在前面说了，业务模板里调用组件元素时添加的插槽只能访问业务模板实例属性所处作用域，而不能获取组件内部作用域。但有些业务场景会有需要能够获取组件内部数据，vue就提供了**作用域插槽**来实现这个功能。

类似组件prop绑定，可以在组件内`<slot>`元素上绑定prop特性，来将组件内特定数据传递到父作用域以供组件元素插槽内容获取使用。这个prop就叫做**插槽prop**。并且可以在父作用域中给`v-slot`赋予一个值来定义已提供的**包含所有插槽prop的对象**的名字：

```javascript
<template>
    <div class="wrap">
        <component-A :user="myUser">
            <template v-slot:default="slotProps">
                // slotProps 就是 包含所有插槽prop的对象 的名字
                {{slotProps.user.firstname}}
            </template>
        </component-A>
    </div>
</template>

<script>
let ComponentA = {
    props: {
        user: Object
    },
    template: `
        <div class="sub-class">
            // 为slot元素绑定插槽prop特性
            <slot v-bind:user="user">
                {{user.lastname}}
            </slot>
        </div>
    `
}
export default {
    data(){
        return {
            myUser: {
                firstname: 'nitx',
                lastname: 'sxm'
            },
        }
    },
    components: {
        'component-A': ComponentA
    }
}
</script>
```

对于插槽，知识点比较杂，可以总结成以下几点：

1. 插槽的意义：组件标签内插入任意内容，组件内插槽`<slot></slot>`元素控制内容插入位置，组件内可配置插槽数量不限；

2. 插槽有三种类型：默认插槽、具名插槽和作用域插槽，前两种插槽形式里父作用域不可获取组件内数据；

3. 默认插槽的`name`是`default`，当组件内只有一个插槽`<slot>`时，可不定义`name`；

4. 具名插槽的`name`根据实际场景自定义，当组件内插槽的数量大于1时就必须要使用具名插槽来定义每个插槽的`name`，以便在父作用域组件标签插入内容时通过对应`name`来确认插入内容将在组件内置入的位置；

5. 作用域插槽的意义是可以在父作用域获取组件内数据，方法是在组件内`<slot>`元素上通过`v-bind`来绑定**插槽prop**，以此来将包含所有插槽prop的对象传递到父作用域中，可在父作用域组件标签内要插入的内容包裹元素`<template>`上赋予`v-slot`一个自定义属性名来获取这个传递过来的**包含所有插槽prop的对象**。

6. 其他还有具名插槽的缩写、动态插槽名以及其他2.6后已废弃但尚未移除使用的插槽语法，在实际使用中再体会。

7. 最后在使用插槽时，只需要考虑两点，插槽是否需要具名？父作用域是否需要获取组件内数据？这两点弄明白，就大概知道怎么设计组件插槽了。

## 5.动态组件与异步组件

#### 用<keep-alive>元素缓存动态组件的状态

在[Vue 2.X 文档阅读笔记一 (基础)](https://blog.csdn.net/qq_34832846/article/details/89945127)中的**动态组件**小节中简单介绍了动态组件的写法，这在需求做多标签tab切换时是非常有用的。但这样的每次切换其实都是会创建一个新的组件实例。如果需求要在组件进行切换时保持组件原有状态，以避免反复渲染导致的性能问题，就可以用`<keep-alive>`元素将动态组件包裹起来。代码实例如下：

```javascript
<template>
    <div class="wrap">
        <!-- 点击不同按钮切换不同组件，并缓存组件状态 -->
        <button type="button" v-for="( val, index ) in btnArr" :key="index" :data-index="index" @click="changeComponent">{{val.btnText}}</button>
        <keep-alive>
            <component :is="currentComponent"></component>
        </keep-alive>
    </div>
</template>

<script>
let ComponentA = {
    props: [ "text" ],
    data(){
        return {
            liArr: [
                { liName: '1' },
                { liName: '2' },
                { liName: '3' },
            ],
            divCont: [
                {content: "aaaa"},
                {content: "bbbb"},
                {content: "cccc"}
            ],
            indexVal: 0
        }
    },
    template: `
        <div class="sub-class">
            <ul>
                <li v-for="(val,index) in liArr" :key="index" :data-index="index" @click="changeLi">{{val.liName}}</li>
            </ul>
            <div>
                {{ divCont[indexVal] }}
            </div>
        </div>
    `,
    methods: {
        changeLi( e ){
            let dataIndex = parseInt( e.target.dataset.index );
            this.indexVal = dataIndex;
        }
    }
}
let ComponentB = {
    props: [ "text2" ],
    template: `
        <div class="sub-class">
            <div>
                <p>add</p>
                <slot>{{text2}}</slot>
            </div>
        </div>
    `
}
export default {
    data(){
        return {
            btnArr: [
                { btnText: 'btn1' },
                { btnText: 'btn2' },
            ],
            currentComponent: 'component-A'
        }
    },
    components: {
        'component-A': ComponentA,
        'component-B': ComponentB
    },
    methods: {
        changeComponent( e ){
            let dataIndex = parseInt( e.target.dataset.index );
            console.log( dataIndex );
            if( dataIndex === 1 ){
                this.currentComponent = 'component-B';
            }else if( dataIndex === 0 ){
                this.currentComponent = 'component-A';
            }
        }
    }
}
</script>
```

#### 异步组件

> 我也没怎么用过，具体可以查看[官方文档](https://cn.vuejs.org/v2/guide/components-dynamic-async.html)的 异步组件 小节

## 处理边界情况

所谓处理边界情况，就是对vue的一些规则做小调整。但这些小调整都会比较危险，在程序debug时可能会造成额外的困扰。以下给出两个可以使用的，其他官方介绍的个人觉得尽量少用的就不列出，感兴趣的可以去看官方文档，点击[这里](https://cn.vuejs.org/v2/guide/components-edge-cases.html)查看。

#### 访问元素&组件

##### ①.访问根实例

在每个`new vue()`实例的子组件中，都可以通过`$root`属性访问其根实例，可以通过`this.$root`来写入/访问根组件的数据、属性或方法，所以也可以将这个属性作为全局`store`来访问或使用，但是官方也建议只可用于项目组件量很少的情况下使用，大多数情况下都推荐使用`Vuex`来管理应用的状态。

##### ②.访问父组件实例

类似于`$root`，在子组件可以通过`$parent`属性来访问父组件的实例。这样可以在后期随时触达父级组件，以代替将数据以prop的方式传入子组件的方式。但这样会存在导致难以理解和调试的问题，所以也应视情况少用。

##### ③.访问子组件实例或子元素

虽然存在prop和事件，但有时也会需要在js中直接访问一个子组件，为达到这个目的，可以通过`ref`特性为子组件赋予一个ID引用：`<component-A ref="inputComponent"></component-A>`，这样在JS中可以这样获取该子组件`this.$refs.inputComponent`。当然用`ref`也可以获取普通DOM元素，但vue推荐数据驱动，尽量少用类似jq的直接操作dom元素的模式。另外$`refs` 只会在组件渲染完成之后生效，并且它们不是响应式的，所以不要在计算属性中访问`refs`。

#### 程序化的事件侦听器

vue中最常用的事件侦听例子是父组件中`v-on`侦听事件名，在子组件中通过`$emit()`触发相应事件名。此外vue实例还提供其他几个事件接口：

- 通过`$on( eventName, eventHandler )`侦听一个事件
- 通过`$once(eventName, eventHandler)` 一次性侦听一个事件
- 通过 `$off(eventName, eventHandler)` 停止侦听一个事件

这个事件侦听器在官方文档给出应用场景示例代码，可以点击[这里](https://cn.vuejs.org/v2/guide/components-edge-cases.html)搜索关键字 *程序化的事件侦听器* 来查看代码示例与应用场景。