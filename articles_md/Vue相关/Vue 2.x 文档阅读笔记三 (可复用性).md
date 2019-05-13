## 混入 mixin

**混入(mixin)**可用来分发组件中的复用功能。一个混入对象可以包含任意组件选项。

当组件使用混入对象时，所有混入对象的选项将被"混合"进行该组件本身的选项中。这个"混合"操作会遵循以下几条规则：

1. `data`数据对象在内部会进行递归合并，并在发生冲突时以组件数据为优化。
2. 同名钩子函数将合并为一个数组，因此都将被调用。但是混入对象的钩子将在组件自身钩子**之前**调用。
3. 值为对象的选项，例如`methods`、`components`、`directives`，将被合并为同一个对象。如果两个对象的键名冲突，则取组件对象的键值对。
4. `Vue.extend()` 也使用同样的策略进行合并。
5. 示例代码请点击[这里](https://github.com/nitxs/private_materials/blob/master/webapck4/webpack4~vue/src/views/pages/test3/Test3A.vue)参考。

## 自定义指令

vue除了有默认内置指令如`v-model`和`v-show`等之外，还支持开发者注册自定义指令。

#### ①.自定义指令注册

可以注册全局自定义指令和局部自定义指令。以下示例以自动聚焦输入框为例。

注册全局自定义指令：

```javascript
// 注册一个全局自定义指令 v-focus
Vue.directives( "focus", {
    inserted: function( el ){
        // 聚焦元素
        el.focus();
    }
} )
```

注册局部自定义指令：

```javascript
export default {
    data(){ return {} }
    // 在directives选项中
    directives: {
        focus: {
            // 指令的定义
            inserted: function( el ){
                el.focus();
            }
        }
    }
}
```

#### ②.自定义指令注册时的钩子函数

一个自定义指令对象在注册时可以使用以下几个可选的钩子函数：

1. `bind`：只调用一次，指令第一次绑定到元素时调用。在这里可以进行一次性的初始化设置。
2. `inserted`: 当被绑定的元素插入到 DOM 中时调用
3. `update`：所在组件的虚拟节点(VNode)更新时调用，**但是可能发生在其子虚拟节点更新之前**。
4. `componentUpdated`：指令所在组件的虚拟节点及其子虚拟节点全部更新后调用。
5. `unbind`：只调用一次，指令与元素解绑时调用。

#### ③.钩子函数参数

自定义指令钩子函数会被传入这些参数：
- `el`，指令所绑定的元素，可以用来直接操作 DOM
- `binding`，包含一些属性的对象，属性有指令名、指令绑定值等，具体可以自己打印看下或者点击[这里](https://cn.vuejs.org/v2/guide/custom-directive.html)查看官方文档
- `vnode`，Vue编译生成的虚拟节点
- `oldVnode`，指上一个虚拟节点，仅在`update`和`componentUpdated`钩子中可用。

注意除了参数`el`外，其他参数应都只是只读，不要修改。如需在钩子之间共享数据，应通过元素的`dataset`来进行。

如果指令需要多个值，可以传入一个js对象字面量，如`<div v-demo="{color: 'red', text: 'hello'}"></div>`。

## 渲染函数 & JSX

> 点击[这里](https://cn.vuejs.org/v2/guide/render-function.html)查看官方文档。

## 使用插件与开发插件

> 点击[这里](https://cn.vuejs.org/v2/guide/plugins.html)查看官方文档。

## 过滤器

vue中可以自定义过滤器，常被用于一些常见的文本格式化。

#### ①.定义过滤器

1. 在一个组件的选项中定义本地过滤器
```javascript
<template>
    <div class="wrap">
        <div>
            <p><input type="text" v-model="text"></p>
            首字母大写过滤后的值：<span>{{text | capitalize}}</span>
        </div>
    </div>
</template>

<script>
export default {
    data(){
        return {
            text: ''
        }
    },
    filters: {
        capitalize( value ){
            if( !value ) return ''
            value = value.toString();
            return value.charAt(0).toUpperCase() + value.slice(1);
        }
    }
}
</script>
```

2. 在创建Vue实例之前全局定义过滤器
```javascript
Vue.filter( "capitalize", function( value ){
    if( !value ) return ''
    value = value.toString();
    return value.charAt(0).toUpperCase() + value.slice(1);
} )

new Vue({
    // ...
})
```

#### ②.过滤器的应用

过滤器可以被应用在两种地方：双花括号插值、`v-bind`表达式。其中过滤器应被添加在js表达式尾部，由"管道"符号表示：

```javascript
// 在双花括号插值中，capitalize是过滤器
{{ msg | capitalize }}

// 在v-bind中，formatId是过滤器
<div v-bind:id="rawId | formatId"></div>
```

过滤器函数总是接收表达式的值作为第一个参数。

过滤器函数还可以串联应用：`{{ msg | filterA | filterB }}`，这里值`msg`作为参数被传递给过滤器函数`filterA`，然后再将`filterA`的结果传递到过滤器函数`filterB`中。

过滤器函数还可以接收别的参数：`{{ msg | filterA('arg1', arg2) }}`，`filterA` 被定义为接收三个参数的过滤器函数。其中 `msg` 的值作为第一个参数，普通字符串 'arg1' 作为第二个参数，表达式 `arg2` 的值作为第三个参数。