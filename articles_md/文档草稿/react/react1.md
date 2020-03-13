# React语法速查

## JSX介绍

JSX语法中，可以在大括号内放置任何有效的JavaScript表达式。例如`2+2`、`user.firstName`或`formatName(user)`等均是有效的JavaScript表达式。

JSX可以通过使用引号，来将属性指定为字符串字面量，也可以使用大括号来在属性值中插入一个JavaScript表达式。

```javascript
class JSXShow extends React.Component{
    constructor( props ){
        super(props);
        this.state = {
            user: {
                firstName: 'n',
                lastName: 'tx'
            }
        }
    }

    formatName( user ){
        return user.firstName + '·' + user.lastName;
    }

    render(){
        return(
            <div>
                <div>my name is {this.formatName( this.state.user )}</div>
                <div tabIndex="0"></div>;
                <img src={user.avatarUrl}></img>;
            </div>
        )
    }
}
```

## 元素渲染

要将一个元素渲染为DOM，可以定义一个根节点`<div id="root"></div>`，该节点内所有内容都由React DOM管理。

想要将一个 React 元素渲染到根 DOM 节点中，只需把它们一起传入 `ReactDOM.render()`：

```javascript
const element = <h1>Hello, world</h1>;
ReactDOM.render(
    element,
    document.getElementById('root')
);
```

React 元素是不可变对象。一旦被创建，你就无法更改它的子元素或者属性。一个元素就像电影的单帧：它代表了某个特定时刻的 UI。

想要更新已渲染的元素，最简单的方式是创建一个全新的元素，并将其传入`ReactDOM.render()`。但在实践中，大多数 React 应用只会调用一次 ReactDOM.render()。所以就需要将相应代码封装进有状态组件中去。

React DOM 会将元素和它的子元素与它们之前的状态进行比较，并只会进行必要的更新来使 DOM 达到预期的状态。

## 组件

组件是将UI拆分为独立可复用的代码片段，并对每个片段进行独立构思。

从概念上，组件类似于JavaScript函数，它接受任意的传参(即props)，并返回用于描述页面展示内容的React元素。

所以定义组件最简单的方式是编写JavaScript函数，以下函数就是一个有效的React组件，它接收唯一带有数据的props参数，并返回一个React元素。这称为函数组件。

```javascript
function Welcome( props ){
    return <h1>Hello, {props.name}</h1>
}
```

也可以使用ES6的class来定义组件。

```javascript
class Welcome extends React.Component {
    constructor( props ){
        super(props)
    }

    render() {
    return <h1>Hello, {this.props.name}</h1>;
    }
}
```

无论是函数声明组件还是class声明组件，都决不能修改自身的props。所有 React 组件都必须像纯函数一样保护它们的 props 不被更改。

当然，应用程序的 UI 是动态的，并会伴随着时间的推移而变化。为满足动态变化需求，另有一种称之为 “state”。在不违反上述规则的情况下，state 允许 React 组件随用户操作、网络响应或者其他变化而动态更改输出内容。

## State

state类似于props，但state是当前class组件内部私有的，并且完全受控于当前class组件。

以下引用官方文档示例：

```javascript
class Clock extends React.Component{
    constructor( props ){
        super( props );
        this.state = {
            date: new Date()
        };
    }

    // 生命周期方法： componentDidMount() 方法会在组件已经被渲染到 DOM 中后运行
    componentDidMount(){
        this.timerID = setInterval( ()=>{
            this.tick();
        }, 1000 )
    }

    // 生命周期方法： componentWillUnmount() 方法会当组件被销毁时释放所占用的资源
    componentWillUnmount(){
        clearInterval( this.timerID );
    }

    tick(){
        this.setState( ( state, props )=>{
            console.log( state );
            console.log( props );
            return {
                date: new Date()
            }
        } )
    }

    render(){
        return(
            <div>
                <h1>Hello World!</h1>
                <h2>It is {this.state.date.toLocaleTimeString()}</h2>
            </div>
        )
    }
}
```

代码逻辑如下：

- 当 `<Clock />` 被传给 `ReactDOM.render()`的时候，React 会调用 Clock 组件的构造函数。因为 Clock 需要显示当前的时间，所以它会用一个包含当前时间的对象来初始化 `this.state`。我们会在之后更新 state。

- 之后 React 会调用组件的 `render()` 方法。这就是 React 确定该在页面上展示什么的方式。然后 React 更新 DOM 来匹配 Clock 渲染的输出。

- 当 Clock 的输出被插入到 DOM 中后，React 就会调用 `ComponentDidMount()` 生命周期方法。在这个方法中，Clock 组件向浏览器请求设置一个计时器来每秒调用一次组件的 `tick()` 方法。

- 浏览器每秒都会调用一次 `tick()` 方法。 在这方法之中，Clock 组件会通过调用 `setState()` 来计划进行一次 UI 更新。得益于 `setState()` 的调用，React 能够知道 state 已经改变了，然后会重新调用 `render()` 方法来确定页面上该显示什么。这一次，`render()` 方法中的 `this.state.date` 就不一样了，如此以来就会渲染输出更新过的时间。React 也会相应的更新 DOM。

- 一旦 Clock 组件从 DOM 中被移除，React 就会调用 `componentWillUnmount()` 生命周期方法，这样计时器就停止了。


class组件中正确使用state应了解以下3件事：

- 不要直接修改state，如`this.state.comment = 'Hello';`，而应使用`setState()`：`this.setState({comment: 'Hello'});`。构造函数是唯一可以给 this.state 赋值的地方。

- State 的更新可能是异步的，出于性能考虑，React 可能会把多个 setState() 调用合并成一个调用。因为 this.props 和 this.state 可能会异步更新，所以你不要依赖他们的值来更新下一个状态。
  例如，此代码可能会无法更新计数器：
  ```javascript
    // Wrong
    this.setState({
    counter: this.state.counter + this.props.increment,
    });
  ```
  要解决这个问题，可以让 setState() 接收一个函数而不是一个对象。这个函数用上一个 state 作为第一个参数，将此次更新被应用时的 props 做为第二个参数：
  ```javascript
    // Correct
    this.setState((state, props) => ({
    counter: state.counter + props.increment
    }));
  ```

- State 的更新会被合并。当你调用 setState() 的时候，React 会把你提供的对象合并到当前的 state。

数据是向下流动的，组件可以选择把它的state作为props向下传递到它的子组件中:`<h2>It is {this.state.date.toLocaleTimeString()}.</h2>`，这点也适用于自定义组件：`<FormattedDate date={this.state.date} />`

## 事件处理

React元素的事件处理类似于DOM元素，区别在语法不同：React事件的命名采用小驼峰，而非DOM元素的纯小写；使用JSX语法时需要传入一个函数作为事件处理函数，而非字符串。

```javascript
// 传统HTML
<button onclick="activateLasers()">
  Activate Lasers
</button>

// React
<button onClick={activateLasers}>
  Activate Lasers
</button>
```

react事件中不能通过返回false的方式阻止默认行为，你必须显示的使用preventDefault()。另外函数中的参数`e`是一个合成事件。

```javascript
handleClick( e ){
    e.preventDefault();
    console.log( '.....123123' );
}

render(){
    return (
        <div>
            <a href="www.baidu.com" onClick={this.handleClick}>
                点击，此时阻止默认行为(即阻止默认跳转链接)
            </a>
        </div>
    )
}
```

当使用class组件时，通常会将事件处理函数声明为class中的方法，以下为示例：

```javascript
class Toggle extends React.Component {
  constructor(props) {
    super(props);
    this.state = {isToggleOn: true};

    // 为了在回调函数中使用 `this`，这个绑定是必不可少的
    this.handleClick = this.handleClick.bind(this);
  }

  handleClick() {
    this.setState(state => ({
      isToggleOn: !state.isToggleOn
    }));
  }

  render() {
    return (
      <button onClick={this.handleClick}>
        {this.state.isToggleOn ? 'ON' : 'OFF'}
      </button>
    );
  }
}
```

由于在class组件中，方法默认不会绑定this，所以需要如上例所示在构造器函数constructor中显式为事件处理函数绑定this。除了这个方法外，还有两种方式也可以解决this绑定问题。

方法一是使用 class fields 正确的绑定回调函数：

```javascript
class Toggle extends React.Component {
  constructor(props) {
    super(props);
    this.state = {isToggleOn: true};
  }

  handleClick =( e )=>{
        console.log( e );
        this.setState( ( state )=>{
            return {
                isToggleOn: !state.isToggleOn
            }
        } )
    }

  render() {
    return (
      <button onClick={this.handleClick}>
        {this.state.isToggleOn ? 'ON' : 'OFF'}
      </button>
    );
  }
}
```

方法二是在回调中使用箭头函数：

```javascript
class Toggle extends React.Component {
  constructor(props) {
    super(props);
    this.state = {isToggleOn: true};
  }

  handleClick =( e )=>{
        console.log( e );
        this.setState( ( state )=>{
            return {
                isToggleOn: !state.isToggleOn
            }
        } )
    }

  render() {
    return (
        // 此语法确保 `handleClick` 内的 `this` 已被绑定。
        <button onClick={(e)=>this.handleClick(e)}>
            {this.state.isToggleOn?'ON':'OFF'}
        </button>
    );
  }
}
```

方法二的问题在于每次渲染 Toggle组件时都会创建不同的回调函数。在大多数情况下，这没什么问题，但如果该回调函数作为 prop 传入子组件时，这些组件可能会进行额外的重新渲染。

所以官方的推荐是在构造器constructor中使用`bind`绑定this 或者 使用方法一class fileds语法来避免方法二造成的性能问题。

在事件处理函数实践中，向事件处理函数传递参数应用场景很多。比如循环时通常会向事件处理函数传递额外的参数。以下示例中id是要删除的那一行的ID，有两种方式都可以向事件处理函数传递参数：

```javascript
class TepCom1 extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  deleteRow( id, a, b, c, d ){
        console.log( id );
        console.log( a );
        console.log( b );
        console.log( c );
        console.log( d );
    }

  render() {
    return (
        // 通过箭头函数的方式： react的事件对象e必须显示的进行传递，事件对象e显式传递的位置由开发者决定，这里我定在参数列表的末位，也可以根据实际需要放在参数列表的任意位置
        <button onClick={(e)=>this.deleteRow( 'AA', 'BB', 'CC', 'GG', e )}>
            delete Row
        </button>
    );
  }
}
// 以下为点击触发事件处理函数打印结果，可以看到当事件对象e显式传递时，才会被传递给事件处理函数参数d。如事件对象e没有显式传递，console.log( d )的打印结果将会为undefined
/*
console.log( id )： BB
console.log( a )： cc
console.log( b )： GGQ
console.log( c )： df
console.log( d )： Class {dispatchConfig: {…}, _targetInst: FiberNode, nativeEvent: MouseEvent, type: "click", target: button, …}
*/

class TepCom2 extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  deleteRow( id, a, b, c, d ){
        console.log( id );
        console.log( a );
        console.log( b );
        console.log( c );
        console.log( d );
    }

  render() {
    return (
        // 通过 bind 的方式: react的事件对象e会被隐式的进行传递，且它的位置永远处于参数列表的末位
        <button onClick={this.deleteRow.bind( this, 'BB', 'cc', 'GGQ', 'df' )}>
            del Row
        </button>
    );
  }
}
// 以下为点击触发事件处理函数打印结果，可以看到尽管事件对象e尽管没有显式传递，但仍被传递给事件处理函数参数d
/*
console.log( id )： BB
console.log( a )： cc
console.log( b )： GGQ
console.log( c )： df
console.log( d )： Class {dispatchConfig: {…}, _targetInst: FiberNode, nativeEvent: MouseEvent, type: "click", target: button, …}
*/
```

以上两种方式等价，分别是通过箭头函数和`Function.prototype.bind`来实现。

在这两种情况下，React 的事件对象 e 会被作为第二个参数传递。如果通过箭头函数的方式，事件对象必须显式的进行传递，而通过 bind 的方式，事件对象以及更多的参数将会被隐式的进行传递。

这里补充下React事件对象e的一个知识点，如要想从React事件对象中访问系统属性value时，可以通过`e.target.value`，如想从React事件对象中访问自定义属性时，可以通过`e.target.dataset`。

## 条件渲染

在React中，可以创建不同的组件来封装各种需要的行为。然后依据应用的不同状态，可以只渲染对应状态下的部分内容。

```javascript
// 1.创建不同组件来封装不同行为
function UserGreeting( props ){
    return (
        <h1>Welcome back!</h1>
    )
}

function GuestGreetin( props ){
    return (
        <h1>Please sing up.</h1>
    )
}

// 登陆登出时显示的问候文案组件
class Greeting extends React.Component{
    constructor( props ){
        super( props );
        this.state = {}
    }

    render(){
        if( this.props.isLoginInProp ){
            return <UserGreeting />
        }else {
            return <GuestGreetin />
        }
    }
}

// 登陆状态控制组件
class LoginControl extends React.Component{
    constructor( props ){
        super(props);
        this.state = {
            isLoginIn: false
        }

        this.handleLoginClick = this.handleLoginClick.bind( this )
        this.handleLogOutClick = this.handleLogOutClick.bind( this )
    }

    handleLoginClick(e){
        console.log( e );
        this.setState( {
            isLoginIn: true
        } )
    }

    handleLogOutClick(){
        this.setState( {
            isLoginIn: false
        } )
    }

    render(){
        // 2.依据应用的不同状态，可以只渲染对应状态下的部分内容
        let isLoggedIn = this.state.isLoginIn;
        let buttonCom;

        if( isLoggedIn ){
            buttonCom = <button onClick={this.handleLogOutClick}>登出</button>
        }else {
            buttonCom = <button onClick={this.handleLoginClick}>登陆</button>
        }

        return (
            <div>
                {/* 子组件Greeting根据是否登陆来显示问候文案 */}
                <Greeting isLoginInProp={isLoggedIn} />
                {buttonCom}
            </div>
        )
    }
}
```

阻止组件渲染的方法是让 `render` 方法直接返回 `null`。示例如下：

```javascript
// 根据不同状态返回内容
function WarnBanner( props ){
    if( !props.warn ){
        return null;
    }

    return (
        <div className="warning">
            Warning!
        </div>
    )
}

class Page extends React.Component{
    constructor( props ){
        super( props );
        this.state = {
            showWarn: true
        };
    }

    handleShowWarn(e){
        this.setState( {
            showWarn: !this.state.showWarn
        } )
    }

    render(){
        return (
            <div>
                <WarnBanner warn={this.state.showWarn} />
                <button type="button" onClick={this.handleShowWarn.bind( this )}>
                    点击
                </button>
            </div>
        )
    }
}
```

## 列表

react中列表的渲染有如下示例，同时需添加key属性，key能帮助React识别哪些元素改变，通常建议取值为该元素在列表中的独一无二的字符串，一般使用id来作为元素的key，而当元素确定没有id时，万不得已也可使用元素索引index作为key的值，但如果列表项目顺序未来可能会发生变化时，则不建议使用索引来作为key值，因为这会导致性能变差，还可能引起组件状态问题。如果不指定显式key值，React会默认使用索引作为列表项目的key值。

```javascript
function ListItem( props ){
    return (
        <li>{props.value}</li>
    )
}

class ListItems extends React.Component{
    constructor( props ){
        super(props);
        this.state = {

        }
    }

    render(){
        let numbers = [ 1, 2, 3, 4, 5 ];
        let listNumbers = numbers.map( (num, index)=> 
            <ListItem key={num.toString()} value={num} />
        );

        return (
            <div>
                <ul>
                    {listNumbers}
                </ul>
            </div>
        )

    }
}
```

## React表单

HTML表单元素通常自己维护state(状态)，并根据用户输入进行更新。而在React中，可变状态通常保存在组件的state属性中，并且只能通过`setState()`来更新。

所以React表单组件可以结合以上两点，既可以使react表单组件的state成为唯一数据源，还可以控制用户输入过程中表单发生的操作。被 React 以这种方式控制取值的表单输入元素就叫做“受控组件”：

```javascript
class NameForm extends React.Component{
    constructor( props ){
        super( props );
        this.state = {
            value: ''
        }
    }

    handleChange( e ){
        this.setState( {
            value: e.target.value
        } )
    }

    handleSubmit( e ){
        console.log( `提交的名称是： ${this.state.value}` );
        e.preventDefault();
    }

    render(){
        return (
            <div>
                <form action="" onSubmit={this.handleSubmit.bind( this )}>
                    <input type="text" value={this.state.value} onChange={this.handleChange.bind( this )}/>
                    <input type="submit" value="提交"/>
                </form>
            </div>
        )
    }
}
```

由于在表单元素上设置了 value 属性，因此显示的值将始终为 this.state.value，这使得 React 的 state 成为唯一数据源。由于 handlechange 在每次按键时都会执行并更新 React 的 state，因此显示的值将随着用户输入而更新。

对于受控组件来说，每个 state 突变都有一个相关的处理函数。这使得修改或验证用户输入变得简单。例如，如果我们要强制要求所有名称都用大写字母书写，我们可以将 handlechange 改写为：

```javascript
handleChange(e) {
  this.setState({value: e.target.value.toUpperCase()});
}
```

不同于HTML中`<textarea>`元素通过其子元素定义其文本，React中`<textarea>`使用`value`属性代替。如此就使得`<textarea>`类似于单行`input`元素。具体参照上例。

HTML中`select`创建下拉列表标签时，会在`option`中根据`selected`属性来表示该项已被选中。但在React中，不使用`selected`属性，而是根 select 标签上使用 `value` 属性。这在受控组件中更便捷，因为您只需要在根标签中更新它：

```javascript
class FlavorForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {value: 'coconut'};

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(event) {
    this.setState({value: event.target.value});
  }

  handleSubmit(event) {
    alert('你喜欢的风味是: ' + this.state.value);
    event.preventDefault();
  }

  render() {
    return (
      <form onSubmit={this.handleSubmit}>
        <label>
          选择你喜欢的风味:
          <select value={this.state.value} onChange={this.handleChange}>
            <option value="grapefruit">葡萄柚</option>
            <option value="lime">酸橙</option>
            <option value="coconut">椰子</option>
            <option value="mango">芒果</option>
          </select>
        </label>
        <input type="submit" value="提交" />
      </form>
    );
  }
}
```

如要对`select`标签实行多选时，可以将数组传入根select标签的value属性中：`<select multiple={true} value={['B', 'C']}>`。

以上3个表单标签：`<input type="text">`、`<textarea>`和`<select>`都接收一个`value`属性，可以以此来实现受控组件。

当需要处理多个 input 元素时，我们可以给每个元素添加 name 属性，并让处理函数根据 event.target.name 的值选择要执行的操作：

```javascript
class CkAndInput extends React.Component{
    constructor( props ){
        super(props);
        this.state = {
            inputCk: true,
            inputName: 2
        }
    }

    handleChange( e ){
        let target = e.target;
        let value = target.type === 'checkbox' ? target.checked : target.value;
        let name = target.name;

        // 由于 setState() 自动将部分 state 合并到当前 state, 只需调用它更改部分 state 即可
        this.setState( {
            [name]: value
        } )
    }

    render(){
        return (
            <div>
                <form action="">
                    <div>
                        复选框：<input type="checkbox" name="inputCk" onChange={this.handleChange.bind(this)} checked={this.state.inputCk} />
                    </div>
                    <div>
                        名称：<input type="text" name="inputName" onChange={this.handleChange.bind( this )} value={this.state.inputName} />
                    </div>
                </form>
            </div>
        )
    }
}
```


