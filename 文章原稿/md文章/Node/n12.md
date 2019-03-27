前面几篇都在复习nodejs创建HTTP服务器的若干知识点，本篇将使用原生AJAX和nodejs的HTTP服务器配合写几个DEMO，加深运用理解，也方便时间长回顾备查，客户端使用`file`访问协议，服务端代码写在app.js中，客户端代码写在index.html中，所有demo均亲测可用。

表单submit提交数据
```javascript
//app.js
const http = require( "http" );
const queryString = require( "querystring" );
let app = http.createServer( function ( req, res ) {
    if( req.url !== "/favicon.ico" ){
        let postData = "";
        // 监听ajax提交时请求对象req的data事件，由于发送的数据是分片段给来，所以每接收到一段数据dataChunk就会触发data事件，
        req.on( "data", function ( postDataChunk ) {
            postData += decodeURIComponent( postDataChunk );
        } )
        req.on( "end", function () {
            try{
                res.setHeader( "Content-Type", "application/json;charset=utf-8" );
                res.write( "你填写的名字是：" + queryString.parse( postData ).name + "；" );
                res.write( "你填写的年龄是：" + queryString.parse( postData ).age + "；" );
                res.write( "你填写的兴趣1是：" + queryString.parse( postData ).interests[0] + "；" );
                res.write( "你填写的兴趣2是：" + queryString.parse( postData ).interests[1] + "；" );
                res.write( "你填写的兴趣3是：" + queryString.parse( postData ).interests[2] + "。" );
            }catch( e ){
                console.log( e );
            }
            res.end();
        } )
    }
} ).listen( 1335, ()=>{ console.log( "service is running at port 1335." ); } )


//index.html
<form action="http://127.0.0.1:1335" method="POST">
    <input type="text" name="name">
    <input type="text" name="age">
    <input type="checkbox" name="interests" value="敲代码">敲代码
    <input type="checkbox" name="interests" value="玩PS4">玩PS4
    <input type="checkbox" name="interests" value="看书">看书
    <input type="submit" value="提交">
</form>
```

表单ajax提交数据
```javascript
// app.js
const http = require( "http" );
let app = http.createServer( function ( req, res ) {
    if( req.url !== "favicon.ico" ){
        try{
            let reqData = "";
            req.on( "data", function ( dataChunk ) {
                reqData += decodeURIComponent( dataChunk );
            } )
            req.on( "end", function () {
                res.setHeader( "Content-Type", "application/json;charset=utf-8" );
                res.setHeader( "Access-Control-Allow-Origin", "*" );
                res.write( reqData );
                res.end();
            } )
        }catch( e ){
            console.log( e );
        }
    }
} ).listen( 1338, ()=>{ console.log( "service is running at port 1338." ); } )

// index.html
<body>
    <form action="http://127.0.0.1:1338" method="POST" id="formData">
        <input type="text" name="name">
        <input type="text" name="age">
        <input type="checkbox" name="interests" value="敲代码">敲代码
        <input type="checkbox" name="interests" value="玩PS4">玩PS4
        <input type="checkbox" name="interests" value="看书">看书
        <input type="button" id="subBtn" value="提交">
    </form>
</body>
let subBtn = document.getElementById( "subBtn" );
subBtn.onclick = function( e ){
    let form = document.querySelector( "#formData" );
    let formData = new FormData( form );
    let xhr = new XMLHttpRequest();
    xhr.open( "POST", form.action );
    xhr.setRequestHeader( "Content-Type", "multipart/form-data");
    xhr.onreadystatechange = function () {
        if( xhr.readyState === 4 ){
            if( (xhr.status >= 200 && xhr.status < 300) || (xhr.status === 304) ){
                let resData = xhr.response;
                console.log( resData );
            }
        }else {
            console.log( xhr.readyState );
            console.log( "请求发送中..." );
        }
    }
    xhr.send( formData );
}
```

ajax的无参GET请求
```javascript
// app.js
const http = require( "http" );
let app = http.createServer( function ( req, res ) {
    if( req.url !== "/favicon.ico" ){
        try{
            let resData = {name: "nitx", age: 31};
            res.setHeader( "Content-Type", "application/json;charset=utf-8" );
            // 设置跨域
            res.setHeader( "Access-Control-Allow-Origin", "*" );
            res.write( JSON.stringify( resData ) );
            res.end();
        }catch( e ){
            console.log( e );
        }
    }
} ).listen( 1336, ()=>{ console.log( "service is running at port 1336." ); } )

//index.html
<body>
    <button type="button" id="btn">GET请求获取响应数据</button>
    <div id="div"></div>
</body>
let btn = document.getElementById( "btn" );
btn.onclick = function ( e ) {
    let xhr = new XMLHttpRequest();
    xhr.open( "GET", "http://127.0.0.1:1336" );
    // 设置xhr对象的responseType属性值为json时，浏览器就会自动对返回数据调用JSON.parse()方法。该属性值默认是text
    xhr.responseType = "json";
    // xhr对象的onreadystatechange属性指向一个监听函数，当readystate属性变化时执行
    xhr.onreadystatechange = function () {
        if( xhr.readyState === 4 ){
            if( (xhr.status >= 200 && xhr.status <300) || (xhr.status === 304) ){
                let resData = xhr.response;
                document.getElementById( "div" ).innerHTML = resData.name;
            }else {
                console.log( xhr.statusText );
            }
        }else {
            console.log( xhr.readyState );
            console.log( "ajax请求中..." );
        }
    }
    xhr.send( null );
}
```

ajax的带参GET请求
```javascript
// app.js
const http = require( "http" );
const url = require( "url" );
let app = http.createServer( function ( req, res ) {
    if( req.url !== "favicon.ico" ){
        try{
            let decodeUrl = url.parse( decodeURIComponent( req.url ), true );
            let query = decodeUrl.query;
            res.setHeader( "Content-Type", "application/json;charset=utf-8" );
            res.setHeader( "Access-Control-Allow-Origin", "*" );
            res.write( JSON.stringify( query ) );
        }catch( e ){
            console.log( e );
        }
        res.end();
    }
} ).listen( 1337, ()=>{ console.log( "service is running at port 1337" ); } );

// index.html
<body>
    <button type="button" id="btn">GET提交数据并获取响应数据</button>
    <div id="div"></div>
</body>
let btn = document.getElementById( "btn" );
btn.onclick = function ( e ) {
    let xhr = new XMLHttpRequest();
    xhr.open( "GET", "http://127.0.0.1:1337?name=nitx&age=31" );
    xhr.responseType = "json";
    xhr.onreadystatechange = function () {
        if( xhr.readyState === 4 ){
            if( (xhr.status >= 200 && xhr.status < 300) || ( xhr.status === 304 ) ){
                let resData = xhr.response;
                console.log( resData );
                document.getElementById( "div" ).innerHTML = resData.name + "：" + resData.age;
            }
        }else {
            console.log( xhr.readyState );
            console.log( "ajax加载中..." );
        }
    };
    xhr.send( null );
}
```

ajax的POST传参请求
```javascript
// app.js
const http = require( "http" );

let app = http.createServer( function ( req, res ) {
    if( req.url !== "/favicon.ico" ){
        let reqData = "";
        req.on( "data", function ( dataChunk ) {
            reqData += decodeURIComponent( dataChunk );
        } )
        req.on( "end", function () {
            try{
                res.setHeader( "Content-type", "application/json;charset=utf-8" );
                res.setHeader( "Access-Control-Allow-Origin", "*" );
                res.write( reqData );
                res.end();
            }catch( e ){
                console.log( e );
            }
        } )
    }
} ).listen( 1340, ()=>{ console.log( "service is running at port 1340." ); } )


// index.html
<body>
    <button type="button" id="btn">POST请求</button>
    <div id="div"></div>
</body>
let paramData = { a: 1, b: 2 };
let btn = document.getElementById( "btn" );
btn.onclick = function () {
    let xhr = new XMLHttpRequest();
    xhr.open( "POST", "http://127.0.0.1:1340" );
    xhr.onreadystatechange = function () {
        if( xhr.readyState === 4 ){
            if( xhr.status === 200 ){
                let resData = xhr.response;
                console.log( JSON.parse( resData ) );
            }
        }else {
            console.log( xhr.readyState );
            console.log( "请求加载中..." );
        }
    }
    xhr.send( JSON.stringify( paramData ) );
}
```
