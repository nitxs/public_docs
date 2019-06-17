Vuex是专为vue应用程序开发的状态管理模式。

Vuex可以帮助开发者管理应用程序的共享状态。

每个Vuex应用的核心是store(仓库)。这个`store`是一个容器，包含着应用中大部分状态。

1. Vuex的状态存储是响应式的。当vue组件从store中读取状态时，若store中的状态发生变化，那么相应的组件也会高效的更新。
2. 开发者不能直接更改store中的状态，只能通过显式的**提交mutation**来更改store中的状态。

## Vuex的引入，state、getters、mutaions、actions的应用

以webpack4构建项目为例(项目示例看[这里](https://github.com/nitxs/private_materials/tree/master/webapck4/webpack4~vue/src))

首先安装vuex`npm i vuex -S`；

在`src`目录新建文件`store/index.js`，在`index.js`文件中引入vuex：
```javascript
import Vue from "vue";
import Vuex from "vuex";

Vue.use( Vuex );

export default new Vuex.Store( {
    state: {
        count: 0
    },
    getters: {      // 可以认为是 store 的计算属性。就像计算属性一样，getter 的返回值会根据它的依赖被缓存起来，且只有当它的依赖值发生了改变才会被重新计算。
        doneToDos( state ){
            return state.todos.filter( function( todo ){
                return todo.done;
            } )
        },
        doneToDosLength( state, getters ){  // Getter 也可以接受其他 getter 作为第二个参数：
            return getters.doneToDos.length;
        },
        getToDoById( state ){
            return function( id ){      // 也可以通过让 getter 返回一个函数，来实现给 getter 传参。在你对 store 里的数组进行查询时非常有用。
                return state.todos.find( function( todo ){
                    return todo.id === id;
                } )
            }
        }
    },
    mutations: {    // mutations必须是同步函数
        increment( state ){
            state.count++;
        }
    },
    actions: {      // Action 提交的是 mutation，而不是直接变更状态，Action 可以包含任意异步操作
        /*
        Action 函数接受一个与 store 实例具有相同方法和属性的 context 对象，因此你可以调用 context.commit 提交一个 mutation，或者通过 context.state 和 context.getters 来获取 state 和 getters。
        */
        increment2 (context) {
            context.commit('increment', {num: 9})
        },
        incrementSync( context ){
            setTimeout(() => {
                context.commit('increment', {num: 13})
            }, 1000)
        }
    }
} )
```

然后在vue项目入口文件`main.js`中引入`store/index.js`文件：

```javascript
import Vue from "vue";
import App from "./App";
import router from "./router";
import store from "./store";

// 其他代码略...

new Vue( {
    el: "#root",
    // 把 store 对象提供给 “store” 选项，这可以把 store 的实例注入所有的子组件
    store,
    router,
    components: { App },
    template: '<App/>'
} )
```

官方建议**通过 `store.state` 来获取状态对象，以及通过 `store.commit` 方法触发状态变更**。

此时在子组件中就可以使用Vuex了，获取store.state对象中的属性count值是通过`this.$store.state.count`，更改store.state对象中属性count值是通过`this.$store.commit( "increment" )`。

由于 store 中的状态是响应式的，在组件中调用 store 中的状态简单到仅需要在**计算属性computed**中返回即可。触发变化也仅仅是在组件的 methods 中提交 mutation。

```javascript
<template>
    <div class="wrap">
        <div id="app-1">
            <p>{{count}}</p>
            <button type="button" @click="add">自增</button>
            <button type="button" @click="add2">自增2</button>
        </div>
    </div>
</template>

<script>
export default {
    data(){
        return {

        }
    },
    computed: {
        count(){
            return this.$store.state.count;     // 每当 this.$store.state.count 变化的时候, 都会重新求取计算属性，并且触发更新相关联的 DOM。
        }
    },
    methods: {
        add(){
            this.$store.commit( "increment" );  // 触发状态变更

            // store中的getter可以通过属性访问
            console.log( this.$store.getters.doneToDos );   // Getter 会暴露为 store.getters 对象，可以以属性的形式访问这些值
            console.log( this.$store.getters.doneToDosLength ); // getter 在通过属性访问时是作为 Vue 的响应式系统的一部分缓存其中的
            console.log( this.$store.getters.getToDoById(2) );
        },
        add2(){
            this.$store.dispatch( 'increment2' )
            this.$store.dispatch( 'incrementSync' ) // 分发action，action内部可以执行异步操作，Actions 支持同样的载荷方式和对象方式进行分发：
        }
    }
}
</script>
```

vuex中执行同步操作放在`mutations`中，执行异步操作放在`actions`中。

store.dispatch 可以处理被触发的 action 的处理函数返回的 Promise，并且 store.dispatch 仍旧返回 Promise。具体案例看[这里](https://vuex.vuejs.org/zh/guide/actions.html)。

## vuex的modules

由于使用单一状态树，应用的所有状态会集中到一个比较大的对象。当应用变得非常复杂时，store 对象就有可能变得相当臃肿。

为解决这个问题，vuex可以将store分割成模块(module)，每个模块拥有自己的 state、mutation、action、getter、甚至是嵌套子模块——从上至下进行同样方式的分割：示例看[这里](https://vuex.vuejs.org/zh/guide/modules.html)