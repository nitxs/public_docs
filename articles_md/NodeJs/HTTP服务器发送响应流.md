Nodejs里http模块的`createServer()`方法的回调函数的第二个参数是一个`http.ServerResponse`对象，可以利用这个对象来发送服务器端的响应数据。

利用`http.ServerResponse`对象的`writeHead`方法或`setHeader()`方法来发送响应头信息。

其中`writeHead`方法可以使用三个参数：`res.writeHead( statusCode, [reasonPhrase], [headers] )`。其中的statusCode是必填参数，用于指定一个三位的HTTP状态码，例如200，404等。后两个参数是可选参数，reasonPhrase参数值是一个字符串，用于指定对于该状态码的描述信息；headers参数值是一个对象，用于指定服务器端创建的响应头对象。

响应头中包含常用字段如下：
- `Content-Type`：用于指定内容类型
- `location`：用于将客户端重定向到另一个URL地址
- `content-disposition`：用于指定一个被下载的文件名
- `content-length`：用于指定服务器端响应内容的字节数
- `set-cookie`：用于在客户端创建一个cookie
- `content-encoding`：用于指定服务器端响应内容的编码方式
- `Cache-Control`：用于开启缓存机制
- `Expries`：用于指定缓存过期时间
- `Etag`：用于指定当服务器端响应内容没有变化时不重新下载数据

如果没有用`http.ServerResponse`对象的`writeHead`方法指定响应头对象，也可以使用`http.ServerResponse`对象的`setHeader`方法单独设置响应头信息：`res.setHeader( name, value )`。其中name参数用于指定响应字段，value用于指定响应字符值。可以通过数组的使用在一个响应字段中指定多个字段值，比如`res.setHeader( "Set-Cookie", ["type=ninja", "language=javascript"] )`。可以通过多个setHeader方法的使用来设置多个响应字段。

下面看一个通过ajax获取HTTP服务器返回数据的示例：
```javascript
// app.js
const http = require( "http" );
let app = http.createServer( function ( req, res ) {
    if( req.url !== "/favicon.ico" ){
        try{
            res.setHeader( "Content-Type", "application/json;charset=utf-8" );
            res.setHeader( "Access-Control-Allow-Origin", "*" );
            let obj = { "a" : "10"};
            res.write( JSON.stringify( obj ) );
        }catch( e ){
            console.log( e );
        }
    }
    res.end();
} ).listen( 1337, "127.0.0.1", ()=>{ console.log( "service is running at port 1337." ); } );



// index.html
<body>
    <button id="btn1">点击获取数据</button>
    <div id="div"></div>
</body>
let btn = document.getElementById( "btn1" );
btn.onclick = function () {
    let xhr = new XMLHttpRequest();
    xhr.open( "GET", "http://127.0.0.1:1337" );
    xhr.onreadystatechange = function () {
        if( xhr.readyState === 4 ){
            if( xhr.status === 200 ){
                let res = JSON.parse( xhr.response );
                document.getElementById( "div" ).innerHTML = xhr.response;
                console.log( res );     // {a: "10"}
            }
        }
    }
    xhr.send( null );
}
```
此外`http.ServerResponse`对象还具有`getHeader()`方法、`removeHeader()`方法、`headersSent`属性(当响应头已发送时该属性值为true，否则为false)、`statusCode`属性(获取/设置HTTP服务器返回的状态码)、`sendDate`属性(将该属性值设置为false时会在响应头中删除Date字段)。

可以使用`http.ServerResponse`对象的`write`方法发送响应内容。如果在`write`方法使用之前没有设置响应头信息，nodejs就会隐式创建一个响应头。`write`方法的使用是：`res.write( chunk, [encoding] )`。其中chunk参数必填，encoding参数可选。chunk参数用于指定响应内容，参数值可以是一个Buffer对象或一个字符串。如果参数值是一个字符串，可以使用encoding参数指定如何编码该字符串，默认是"utf8"。在使用`http.ServerResponse`对象的`end`方法之前，可以多次调用`write`方法。

针对多次调用`write`方法的情况，在第一次调用`write`方法时，nodejs将立即发送缓存的响应头信息及write方法中指定的内容，之后再调用write方法时，nodejs就只单独发送write方法中指定的响应内容，该响应内容将与之前发送的响应内容一起缓存在客户端中。

`write`方法会返回一个布尔值，当数据直接发送到操作系统内核缓存区中时，返回true；当数据首先缓存在内存中时，返回false。因为有这样一个机制：在一个快速网络环境中，当数据时较小时nodejs总是将数据直接发送到操作系统的内核缓存区中，然后从该内核缓存区中取出数据发送给对方。在一个慢速网络中或需要发送大量数据时，HTTP服务器端发送的数据并不一定会立即被客户端接收，nodejs会将数据缓存在内存中，并在对方可以接收数据的情况下将内存中的数据通过操作系统内核缓存区发送给对方。
```javascript
const http = require( "http" );
const fs = require( "fs" );

let app = http.createServer( function ( req, res ) {
    if( req.url !== "/favicon.ico" ){
        fs.readFile( "./test.txt", function ( err, data ) {
            if( err ) console.log( "读取文件时发生错误" );
            else {
                res.setHeader( "Content-Type", "text/plain" );
                let flag = res.write( data );
                console.log( flag );        // true  读取的test.txt是数据量较小的文件，当该文件数据量过大或慢速网络环境中时，返回 false
            }
            res.end();
        } )
    }
} ).listen( 1336, ()=>{ console.log( "service is running at port 1336." ); } );
```

可以使用`http.ServerResponse`对象的`end`方法来结束响应内容的书写。在每次发送响应数据时，必须调用该方法来结束响应。`res.end( [chunk], [encodeing] )`。end方法中的两个可选参数作用与write方法中的参数作用完全相同。

可以使用`http.ServerResponse`对象的`setTimeout`方法设置响应超时时间。如果在指定时间内服务器没有做出响应(可能是网络连接出问题，也可能是服务器故障或网络防火墙阻止客户端与服务器端连接)，则响应超时，同时会触发`http.ServerResponse`对象的`timeout`事件，使用方法时：`res.setTimeout( ms, [callback] )`。ms是必填参数，callback是可选参数，ms参数值是一个整数，用于设置超时时间，单位为毫秒，callback用于指定当响应超时时调用的回调函数，该回调函数不使用任何参数。可以不在setTimeout方法中使用callback参数，而是通过监听`http.ServerResponse`对象的timeout事件并指定事件回调函数的方法来指定当响应超时时所需执行的处理，方法如下：
```javascript
res.on( "timeout", function(){
    /*响应超时时需执行的回调处理*/
} )
```
如果没有指定以上两种之一的超时回调，则当响应超时时将自动关闭与HTTP客户端连接的socket端口，如果指定超时回调，则当响应超时时不会自动关闭与HTTP客户端连接的socket端口。
```javascript
const http = require( "http" );
let app = http.createServer( function ( req, res ) {
    if( req.url !== "/favicon.ico" ){
        res.setTimeout( 1000 );     // 设置连接超时时间
        res.on( "timeout", function () { console.log( "连接超时" ); } );
        setTimeout( function () {
            res.setHeader( "Content-Type", "text/html" );
            res.write( "<html><head><meta charset='utf-8'></head>" );
            res.write( "你好" );
            res.end();
        }, 2000 )
    }
} )
app.on( "close", function () {
    console.log( "服务器已关闭连接" );
} )
app.listen( 1335, ()=>{ console.log( "service is running at port 1335." ); } );

//打印：
/*
service is running at port 1335.
连接超时
*/
```
尽管控制台打印连接超时，但由于设置超时回调，所以与HTTP客户端连接的socket端口没有关闭，页面仍然接收到2s后服务器端发送的响应数据并打印出“你好”。

如没有设置超时响应，则当连接超时时，与HTTP客户端的socket端口会自动关闭，网页就无法访问接收服务器端数据。
