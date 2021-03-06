在nodejs中可以很方便的创建服务器。nodejs提供了http模块和https模块，分别用于创建http服务器与http客户端、https服务器和https客户端。

## 创建HTTP服务器
以http模块为例，有两种创建服务器的方法。

1. 调用http模块中的`createServer()`方法，在该方法中，可以使用一个可选参数，参数值是一个回调函数，用于指定当接收到客户端请求时所需执行的处理。在该回调函数中，使用两个参数，第一个参数是`http.IncommingMessage`对象，代表一个客户端请求；第二个参数是一个`http.ServerResponse`对象，代表一个服务器端响应对象。示例如下：
```javascript
var http = require( "http" );

http.createServer( function ( req, res ) {
    // req 代表客户端请求对象
    // res 代表服务器端响应对象
    res.writeHead( 200, {'Content-Type': 'text/html'} )
    res.write( "<head><meta charset='utf8'></head>" );
    res.end( "哈哈我是nitx" );
} )
.listen( 1334, ()=>{
    console.log( "service is running at port 1334." );
} )
```
2. `createServer()`方法会返回被创建的服务器对象。如果不在`createServer()`方法中使用回调函数参数，则也可以通过监听该方法返回的服务器对象的`request`事件(当接收到客户端请求时触发)，并且指定该事件触发时调用的回调函数的方法来指定当接收到客户端请求时所需执行的处理，在该回调函数中可以使用两个参数，它们代表的对象与使用方法与`createServer()`方法中使用的回调函数的参数值所代表的对象与使用方法完全相同。示例如下：
```javascript
var http = require( "http" );
var server = http.createServer();   // createServer()方法调用时返回被创建的服务器对象，赋值给变量 server ，此时 server 就代表一个 HTTP 服务器

// 服务器对象的引用 server 通过 request 事件的监听器(回调函数) 来指定当接收到客户端请求时所需执行的处理
server.on( "request", function ( req, res ) {
    res.writeHead( 200, {'Content-Type': 'text/html'} )
    res.write( "<head><meta charset='utf8'></head>" );
    res.end( "哈哈我是nitx" );
} )
server.listen( 1335, function () {
    console.log( "server is running at port 1335." );
} )
```
HTTP服务器创建之后，还需要指定该服务器所要监听的地址及端口号。使用该HTTP服务器的`listen`方法，该方法的使用方式：`server.listen( port, [host], [backlog], [callback] )`。除第一个端口参数为必需指定外，其他都是可选的。具体示例可以看上面两个例子。
- port参数值用于指定需要监听的端口号，当参数值为0时将为HTTP服务器随机分配端口号，HTTP服务器将监听来自于这个随机端口号的客户端连接。
- host参数用于指定需要监听的地址，如果省略该参数，则服务器会监听来自于任何IPV4地址的客户端连接。
- backlog参数值为一个整数值，用于指定位于等待队列中的客户端连接的最大数量，一旦大于这个数量，HTTP服务器就会拒绝来自于新的客户端的连接，该参数的默认参数值是511，
- 当对HTTP服务器指定需要监听的端口和地址时，服务器端将开始监听来自于该地址和端口的客户端连接，这时就会触发该服务器的listening事件，可使用listen()方法的callback参数来指定触发listening事件时调用的回调函数，该回调函数不传任何参数。

可以使用HTTP服务器的`close()`方法来关闭服务器：`server.close();`。当服务器关闭时将会触发HTTP服务器的`close`事件，可以通过监听该事件并指定事件回调的方式来指定当服务器被关闭时所需执行的处理：
```javascript
var http = require( "http" );
// 调用http.createServer()方法返回创建的HTTP服务器
var server = http.createServer( function ( req, res ) {
                res.writeHead( 200, {'Content-Type': 'text/html'} )
                res.write( "<head><meta charset='utf8'></head>" );
                res.end( "哈哈我是nitx" );
            } )

server.listen( 1335, function () {
    console.log( "server is running at port 1335." );
    server.close(); // 关闭HTTP服务器
} )
// 当关闭HTTP服务器时触发close事件，指定回调函数处理
server.on( "close", function () {
    console.log( "HTTP服务器已关闭" );
} )
```

当对HTTP服务器指定需要监听的地址和端口时，如果地址或端口已被占用，将产生错误，错误码为"EADDRINUSE"(表示用于监听的地址和端口已被占用)，同时会触发HTTP服务器对象的`error`事件，可以通过对象error事件指定回调函数的方法来指定该错误产生时需要执行的处理：
```javascript
var http = require( "http" );
var server = http.createServer( function( req, res ){
    /*暂不指定接收到客户端请求时的处理*/
} )
.listen( 1336, ()=>{ console.log( "server is running at port 1336." ) } )

server.on( "error", function( e ){
    // 当地址及端口被占用时的错误码为 EADDRINUSE
    if( e.code === "EADDRINUSE" ){  
        // 此处指定地址及端口被占用时的错误处理程序
        console.log( "服务器地址及端口已被占用。" );
    }
} )
```

默认情况下，客户端和服务端建立每进行一次HTTP操作，都将建立一次连接，客户端与服务端之间的交互通信完成后该连接就中断。HTTP1.1中添加长连接支持，如果客户端发出的请求头信息或者服务器端发出的响应头信息中加入了"Connection: keep-alive"信息，则HTTP连接将继续保持，客户端可以继续通过相同的连接向服务器端发送请求。

nodejs中当客户端和服务器端建立连接时，会触发服务器对象的`connection`事件，可以监听该事件并在该事件触发的回调函数中指定当连接建立时所需执行的处理：
```javascript
var http = require( "http" );

var app = http.createServer( function ( req, res ) {
    res.writeHead( 200, {'Content-Type': 'text/html'} )
    res.write( "<head><meta charset='utf8'></head>" );
    res.end( "哈哈我是nitx" );
} )

app.on( "connection", function ( socket ) { 
    console.log( "客户端连接已建立。" );
} )

app.listen( 1337, ()=>{ console.log( "server is running at port 1337." ); } )
```
在服务器对象server触发connection事件时，对应的回调函数使用一个参数，参数值是服务器端用于监听客户端请求的socket端口对象。