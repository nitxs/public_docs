socketIo客户端代码，客户端需引入socket.io-client：
```javascript
import io from 'socket.io-client';
//服务端js在 private_materials/node/test17/service.js
// WebSocket协议-Socket.io 客户端API https://www.jianshu.com/p/d5616dc471b9   https://www.w3cschool.cn/socket/socket-k49j2eia.html
// WebSocket协议-Socket.io 服务端API https://www.jianshu.com/p/8d28d3e0b43e   https://www.w3cschool.cn/socket/socket-odxe2egl.html

const socket = io( "http://192.168.8.52:3000/chat" );

// 连接成功监听
socket.on('connect', function () {
    console.log( 'socket 已连接啦' );
    console.log( socket.id );   // 标识socket session独一无二的符号，在客户端连接到服务端被设置
});

// 监听服务器端触发 serviceEventA 事件，并接收发来的数据
socket.on( "serviceEventA", function( data ){
    console.log( data );
} )
// 监听服务器端触发 serviceEventC 事件，并接收发来的多个参数数据
socket.on( "serviceEventC", function( data1, data2, data3 ){
    console.log( data1 );
    console.log( data2 );
    console.log( data3 );
} )
// 监听服务器端触发 serviceEventB 事件，并接收发来的数据，再将获取的数据发送回服务器端
socket.on( "serviceEventB", function( data, fn ){
    console.log( data );
    fn( data + ' aaaa' )
} )

socket.on( "message", function( data ){
    console.log(  "服务器发送的send事件：" + data );
} )

setTimeout( function(){
    // 客户端主动向服务器端发送数据
    socket.emit( "clientEventA", "i am clientA" )
    socket.emit( "clientEventB", "i am clientB", function( data ){
        console.log( data );
    } )
    socket.send( "这是一个客户端发送的send操作，由服务器端监听message事件获取此消息" )
}, 5000 )



// 连接错误触监听
socket.on('connect_error', function(error){
    socket.send( {userName: 'zh', message: '9999'} )
    console.log( error );
});

// 断开连接监听
socket.on( "disconnect", function( reason ){
    console.log( reason );
    console.log( 'socket已断开连接' );
} )

// 页面关闭时手动关闭客户端对服务器的链接               
$(window).on('beforeunload unload', function() {  
    socket.send( {userName: 'nitx1', message: '9999'} ); 
    socket.close();
}); 

// 重连API
socket.on('reconnecting', function( attempt ){
    console.log('reconnecting尝试重连时触发事件');
    console.log( '重连次数：' + attempt );
});
socket.on('reconnect_attempt', function( attempt ){
    console.log('reconnect_attempt尝试重连时触发事件');
    console.log( '重连次数：' + attempt );
});
socket.on('reconnect', function( attempt ) {
    console.log('成功重新连接到服务器');
    console.log( '重连次数：' + attempt );
});
socket.on('reconnect_error', function(error){
    console.log( "重连错误" );
    console.log( error );
});
socket.on('reconnect_failed', function(){
    console.log( "重连失败" );
});
```
客户器端package.json所需安装包：
```javascript
"devDependencies": {
    "socket.io-client": "^2.2.0",
 }
```

服务器端代码，express + socket.io：
```javascript
// 客户端js代码在 private_materials\webapck4\webpack4~multHtml
var app = require('express')();     //初始化express，app作为HTTP服务器的回调函数
var http = require('http').createServer(app);
var io = require('socket.io')(http);    //传入http对象初始化socket.io的实例

const chat = io.of('/chat');

chat.on('connection', function (socket) {
    // 触发事件 serviceEventA, 发送消息给客户端
    socket.emit('serviceEventA', 'can you hear me A?' );
    // 触发事件 serviceEventC, 发送多个参数消息给客户端
    socket.emit('serviceEventC', 'can you hear me C?', 'second param', 'third param' );
    // 触发事件 serviceEventB, 发送消息给客户端，再接收客户端返回的数据
    socket.emit('serviceEventB', 'can you hear me B?', ( data )=>{
        console.log( data )
    });
    
    // 监听客户端事件 clientEventA，获取客户端发送过来的消息
    socket.on( "clientEventA", ( data )=>{
        console.log( data );
    } )
    socket.on( "clientEventB", ( data, fn )=>{
        console.log( data );
        fn( data + '1124' );
    } )
    socket.on( "message", function( data ){
        console.log( "客户端发送的send事件：" + data );
    } )

    setTimeout( function(){
        socket.send( "这是一个服务器端发送的send操作，由客户器端监听message事件获取此消息" )
    }, 5000 )
});


http.listen(3000, function () {
    console.log('listening on *:3000');
});
```

服务器端package.json所需安装包：
```javascript
"devDependencies": {
    "express": "^4.17.1",
    "socket.io": "^2.2.0"
 }
```