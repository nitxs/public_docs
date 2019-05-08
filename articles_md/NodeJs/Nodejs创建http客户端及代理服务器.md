nodejs除了可以通过http模块创建服务器，还能创建客户端，类似于浏览器那样很轻松的去向别的服务器发送请求并获取响应数据。

在http模块中，可以使用request方法实现向其他服务器请求数据：`http.request( options, callback )`。

在request方法中可以使用两个参数，options参数值是一个对象或字符串，用于指定请求的目标URL地址，如果参数值是一个字符串，将自动使用url模块中的parse方法转换为一个对象。在options参数值对象或使用parse转换后的对象中，可以指定的属性及属性值有：
- `host`：用于指定域名或目标主机的IP地址，默认属性是`localhost`
- `hostname`：用于指定域名或目标主机的IP地址，默认属性是`localhost`。如果hostname属性值和host属性值都被指定，则优先使用hostname属性值。
- `port`：用于指定目标服务器用于客户端连接的端口号。
- `localAddress`：用于指定专用于网络连接的本地接口。
- `socketPath`：用于指定目标Unix域端口。
- `method`：用于指定HTTP请求方式，默认属性值是"GET"。
- `path`：用于指定请求路径及查询字符串，默认属性值是"/"。
- `headers`：用于指定客户端请求头对象。
- `auth`：用于指定认证信息部分，例如`user:password`。
- `agent`：用于指定HTTP代理。

http模块request()方法中的callback参数是用来指定当获取到目标服务器所返回的响应流时调用的回调函数。该回调函数的指定方法：`function( response ){ /* 回调函数执行体 */ }`。在该回调函数中，使用一个参数，参数值是一个http.IncomingMessage对象，可以利用该对象来读取响应流中的数据。

http.request( options, callback )方法返回一个http.ClientRequest客户端对象实例，代表一个客户端请求。这点类似于http.createServer()方法返回一个http服务器端实例，其代表一个服务器端实例。
```javascript
const http = require( "http" );
let clientRequest = http.request( options, callback );
```
上例中的变量clientRequest就是一个http.ClientRequest客户端对象实例的引用，指代一个客户端请求。

当http客户端请求获取到服务器端的响应数据时，会触发http.ClientRequest对象的response事件，可以不在http.request方法中使用callback参数，而是通过http.ClientRequest对象监听response事件并指定事件回调函数的方法来指定当获取到其他服务器返回的响应流时执行的处理，该事件回调函数的指定方法：`clientRequest.on( "response", function( res ){ /* 回调函数执行体 */ } )`。在该回调函数中，使用一个参数，参数值是一个http.IncomingMessage对象，可以利用该对象来读取响应流中的数据。

在使用http.request()方法后，还可以使用http.ClientRequest对象的write方法向目标服务器发送数据，使用方法：`clientRequest.write( chunk, [encoding] )`。

在write方法中可以使用两个参数，chunk参数是必须指定参数，encoding参数是可选参数。chunk参数用于指定发送内容，参数值可以是一个Buffer对象或一个字符串，如果参数值是一个字符串，可以使用encoding参数来指定如何编码该字符串，encoding参数默认值是 utf-8 。

在使用http.ClientRequest对象的end方法结束本次请求前，可以调用多次write方法，这点也种http服务器端中多次调用`res.write()`一样。

可以使用http.ClientRequest对象的end方法结束本次请求，每次发送请求最后，必须调用该方法来结束请求。使用方法：`clientRequest.end( [chunk], [encoding] )`。

下面来写个实例，用http.request方法向目标服务器`http://127.0.0.1:1341`请求数据，当获取到服务器端返回的响应流时在控制台中分别输出服务器端返回的状态码、响应头和响应内容。client.js中是http客户端，server.js中http服务器端。
```javascript
// client.js
const http = require( "http" );
let options = {
    url: "http://127.0.0.1",
    port: "1342",
    path: "/",
    method: "GET"
}
let clientRequest = http.request( options, function ( res ) {
    console.log( "状态码：" + res.statusCode );
    console.log( "响应头：" + JSON.stringify( res.headers ) );
    res.on( "data", function ( chunk ) {
        console.log( "响应内容：" + chunk );
    } )
    res.on( "end", function () {
        console.log( "响应结束" );
    } )
} );
// 监听error事件，当请求失败时，将触发error事件的回调函数
clientRequest.on( "error", function ( err ) {
    console.log( "请求出错，错误代码为：" + err.code );
} )
clientRequest.end();


// server.js
const http = require( "http" );
let app = http.createServer( function ( req, res ) {
    try{
        res.setHeader( "Content-Type", "application/json;charset=utf-8" );
        res.write( "你好" );
    }catch( e ){
        console.log( e );
    }
    res.end();
} ).listen( 1342, ()=>{ console.log( "service is running at port 1342." ); } )
```
结果截图如下：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190219_0.png?raw=true)

可以使用http.ClientRequest对象的write()方法向服务器端发送数据，注意要将请求method改为POST请求。
```javascript
// client.js
const http = require( "http" );
let options = {
    url: "http://127.0.0.1",
    port: "1342",
    path: "/",
    method: "POST"
}
let clientRequest = http.request( options, function ( res ) {
    console.log( "状态码：" + res.statusCode );
    console.log( "响应头：" + JSON.stringify( res.headers ) );
    res.on( "data", function ( chunk ) {
        console.log( "响应内容：" + chunk );
    } )
    res.on( "end", function () {
        console.log( "响应结束" );
    } )
} );
clientRequest.write( "嗨，你好呀！" );
// 设置请求超时，当超时就使用http.ClientRequest对象的abort()方法终止请求。
clientRequest.setTimeout( 20000, function () {
    clientRequest.abort();
} )
// 建立连接过程中，当为该连接分配端口时，触发http.ClientRequest对象的socket事件，指定的回调函数使用一个参数，参数值是用于分配的socket端口对象
clientRequest.on( "socket", function ( socket ) {
    // console.log( socket );
    socket.setTimeout( 1000 );
    socket.on( "timeout", function () {
        clientRequest.abort();
        // socket超时终止本次请求时触发的错误代码为ECONNRESET
    } )
} )
// 监听error事件，当请求失败时，将触发error事件的回调函数
clientRequest.on( "error", function ( err ) {
    if( err.code === "ECONNRESET" ){
        console.log( "socket端口超时" );
    }else {
        console.log( "请求出错，错误代码为：" + err.code );
    }
} )
clientRequest.end( "再见" );

// server.js
const http = require( "http" );
let app = http.createServer( function ( req, res ) {
    if( req.url !== "/favicon.ico" ){
        req.on( "data", function ( dataChunk ) {
            console.log( "接收到的数据是：%s", decodeURIComponent( dataChunk ) );
        } )
        req.on( "end", function () {
            try{
                res.setHeader( "Content-Type", "application/json;charset=utf-8" );
                res.write( "你也好呀~~" );
            }catch( e ){
                console.log( e );
            }
            res.end();
        } )
    }
} ).listen( 1342, ()=>{ console.log( "service is running at port 1342." ); } )
```

由于http模块既可以用来创建服务器端，也能用来创建客户端，所以它就可以用来作为前端请求与企业服务器之间的桥梁，充当一个代理服务器，例如用nodejs创建一个服务器，当这个服务器接收到前端网站请求后，就向企业服务器端请求数据，当它从企业服务器端数据接收到响应数据后，就可以再将响应数据发送给客户端。这个中间过程，nodejs创建的代理服务器可以对数据进行相应操作，同时也可以对企业服务器提供前置保护。
```html
<!-- index.html -->
<body>
    <button type="button" id="btn">点击获取代理服务器里的数据</button>    
    <div id="div"></div>
</body>
<script>
    let btn = document.getElementById( "btn" );
    btn.onclick = function ( e ) {
        let xhr = new XMLHttpRequest();
        xhr.open( "POST", "http://127.0.0.1:1343" );
        xhr.onreadystatechange = function () {
            if( xhr.readyState === 4 ){
                if( xhr.readyState === 200 ){
                    let resData = xhr.response;
                    console.log( resData );
                }
            }
        }
        xhr.send();
    }
</script>
```
以下是代理服务器和企业服务器的文件
```javascript
// proxyServer.js  代理服务器文件
// 创建一个代理服务器
const http = require( "http" );
const url = require( "url" );

// 创建一个代理服务器直接和浏览器直接交互，接收客户端请求
let proxy = http.createServer( function ( preq, pres ) {
    if( preq.url !== "/favicon.ico" ){
        let url_parts = url.parse( preq.url );
        let options = {
            url: "http://127.0.0.1",
            port: "1344",
            method: preq.method,
            headers: preq.headers,
            path: url_parts.pathname
        }

        // 转发给企业服务器端
        let proxyRequest = http.request( options, function ( cres ) {
            pres.writeHead( cres.statusCode, cres.headers );
            let body = "";
            // 收到企业服务器的响应
            cres.on( "data", function ( chunk ) {
                body += chunk;
            } );
            cres.on( "end", function () {
                // 将企业服务器的响应结果转发给浏览器
                pres.end( body );
            } )
        } )
        proxyRequest.end();
    }
} )
proxy.on( "error", function ( e ) {
    console.log( e );
} )
proxy.listen( 1343, ()=>{ console.log( "service is running at port 1343." ); } );

// server.js  企业服务器
const http = require( "http" );
let app = http.createServer( function ( req, res ) {
    if( req.url !== "/favicon.ico" ){
        res.writeHead( 200, {
            "Content-Type": "application/json;charset=utf-8",
            "Access-Control-Allow-Origin": "*",
        } )
        res.write( "你好呢。" );
        res.end();
    }
} ).listen( 1344, ()=>{ console.log( "service is running at port 1334" ); } )
```
