# 项目介绍

使用vuecli3+ts搭建一个符合个人习惯的小型工程，本来要加上eslint和prettier的，但实在逼死强迫症，就暂时放下，等以后找到让我心里舒服的方案再说吧。

本工程也是专为学习ts并有个实践场地而做的，所以如果有想找个地儿练习ts又不想自己整工程的可以拿去，按照自己习惯改即可。

## 前置知识

具备vue实际开发经验，能灵活使用vuex、vueRouter，熟练掌握nodejs、ES6。

## 页面实例

以index页面为例：
``` typescript
// test.vue
<template>
  <div class="test-wrap">
    {{ data.pageName }}
    <div>{{data.showAuthor}}</div>
    <div>{{data.message}}</div>
    <div>{{reversedMessage}}</div>
  </div>
</template>

<script lang="ts" src="./test.ts"></script>

<style lang="scss">
@import './test.scss';
</style>



// test.ts
import { Component, Vue, Emit, Watch } from 'vue-property-decorator';
import { State, Getter, Action, Mutation, namespace } from 'vuex-class';
import { TestData } from '@/types/views/test.interface';
// import {  } from '@/components'; // 组件

@Component({})
export default class Test extends Vue {

  /**
   * Vuex 数据与方法管理
   */
  // Vuex的State状态库数据，
  // 括号里面的字符串是store统一导出的 store module 的名称，
  // 后面定义的自定义变量用于获取该module的State状态库，例如通过this.indexState可获取 Index module的状态库State对象
  @State( "Index" ) indexState:any
  @State( "Test" ) testState:any
  // Vuex计算属性
  @Getter authorDatatest:any;
  // Mutation 同步计算库
  @Mutation UPDATE_STATE:any;
  // Action 异步计算库
  @Action UPDATE_STATE_ASYN:any;

  /**
   * 定义页面data数据 ==================================
   * 1.添加将data定义为对象，将页面数据添加为data对象的属性，新增属性前需先在 @/types/views/xx.interface.ts 中的接口对象里添加对应数据类型
   * 2.也可以用定义类变量的方式直接指定具体的data变量
   * 它们都是响应式数据
   */
  data: TestData = {
    pageName: 'test',
    message: "helloworld",
    showAuthor: ''
  };

  /**
   * 生命周期函数 ==================================
   */
  /**
   * data已存在，页面未渲染
   */
  private created (): void{
    // 获取名称为Index的State module中的state状态库
    console.log( this.indexState );
    // 获取名称为Test的State module中的state状态库
    console.log( this.testState );
    // 通过vuex的getter计算属性获取
    this.data.showAuthor = this.authorDatatest;

    setTimeout( function(_this:any){

      // 3秒后通过vuex的Mutation同步更改author值
      _this.changeAuthor( 'sxm' )
      _this.data.showAuthor = _this.authorDatatest;

      // 测试计算属性响应式变化
      _this.data.message = "hhwawffer"

    }, 3000, this )

    setTimeout( function( _this:any ){
      // 5秒后通过vuex的action异步更改state.author的值
      _this.changeAuthorAsyn( 'nz' )
      _this.data.showAuthor = _this.authorDatatest;
    }, 5000, this )

  };

  /**
   * 页面渲染完毕
   */
  private mounted (): void{

    // 监听emit-todo事件并执行回调
    this.$on('emit-todo', function( n:string ) {
      console.log(n)
    })
    this.emitTodo('world');

  };

  /**
   * 页面更新
   */
  private updated (): void{ };

  /**
   * 页面销毁
   */
  private destroyed (): void{ };

  /**
   * 计算属性 computed
   * 在函数名前添加get前缀即可使其成为计算属性所属函数
   */
  private get reversedMessage(): string{
    return this.data.message.split('').reverse().join('');
  };

  /**
   * 侦听属性 watch
   * 使用@Watch装饰器来替换Vue中的watch属性,以此来监听值的变化.
   */
  @Watch('child')
  onChangeValue(newVal: string, oldVal: string){
    // todo...
  };

  /**
   * 方法Method ==================================
   */
  // 初始化函数
  public init():void{
    // todo...
  };

  // 同步更改state数据
  public changeAuthor( newAuthor:string ):void{
    this.UPDATE_STATE( newAuthor );
  }

  // 异步更改state数据
  public changeAuthorAsyn( newAuthor:string ):void{
    this.UPDATE_STATE_ASYN( newAuthor );
  }

  /**
   * 事件的监听与触发 ==================================
   * 1.@Emit()不传参数,那么它触发的事件名就是它所修饰的函数名.
   * 2.@Emit(name: string),里面传递一个字符串,该字符串为要触发的事件名.执行完emitTodo函数后就会触发该事件
   */
  @Emit()
  emitTodo( n: string ){
    console.log('hello');
  };
}
```

以下是vuex配置：
```typescript
// index.ts
import Vue from 'vue'
import Vuex from 'vuex'

// 导入vuex模块
import Login from './module/login'
import Index from './module/index'
import Test from './module/test'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    // 状态库
  },
  mutations: {
    // 同步计算库 使用commit触发
  },
  actions: {
    // 异步计算库 使用dispatch触发
  },
  modules: {
    // 分模块
    Login,
    Index,
    Test
  }
})

// module/test.ts
import { TestState } from '@/types/views/test.interface'
import { GetterTree, MutationTree, ActionTree } from 'vuex'
import * as TestApi from '@/api/test'

// vuex数据状态库
const state: TestState = {
  author: undefined
}

// 强制使用getter获取state, getter是store的计算属性，其返回值会根据它的依赖被缓存起来，且只有当它的依赖值发生改变时才会被重新计算
// getter会暴露为store.getter对象，可以以属性形式访问该对象的值
// getter接受state作为其第一个参数；也可以接受其他getter作为第二个参数；
// 另外还可以通过让 getter 返回一个函数，来实现给 getter 传参，这在对 store 里的数组进行查询时非常有用。
const getters: GetterTree<TestState, any> = {
  authorDatatest( state: TestState ){
    return state.author
  }
}

// 更改state
const mutations: MutationTree<TestState> = {
  // 更新state.author的方法
  UPDATE_STATE(state: TestState, anotherAuthor:string) {
    state.author = anotherAuthor;
  }
}

const actions: ActionTree<TestState, any> = {
  // 使用同步的状态变更方法以异步方式调用
  UPDATE_STATE_ASYN({ commit, state: TestState }, anotherAuthor: string) {
    commit('UPDATE_STATE', anotherAuthor)
  },
  // 异步调用获取接口数据
  GET_DATA_ASYN({ commit, state: TestState }) {
    TestApi.getData()
  }
}

export default {
  state,
  getters,
  mutations,
  actions
}
```