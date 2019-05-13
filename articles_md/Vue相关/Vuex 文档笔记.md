Vuex是专为vue应用程序开发的状态管理模式。

Vuex可以帮助开发者管理应用程序的共享状态。

每个Vuex应用的核心是store(仓库)。这个`store`是一个容器，包含着应用中大部分状态。

1. Vuex的状态存储是响应式的。当vue组件从store中读取状态时，若store中的状态发生变化，那么相应的组件也会高效的更新。
2. 开发者不能直接更改store中的状态，只能通过显式的**提交mutation**来更改store中的状态。

## Vuex的引入

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
    getters: {

    },
    mutations: {
        increment( state ){
            state.count++;
        }
    },
    actions: {

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
            return this.$store.state.count
        }
    },
    methods: {
        add(){
            this.$store.commit( "increment" )
        }
    }
}
</script>
```