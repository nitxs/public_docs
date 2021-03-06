在HTTP服务中，服务器端可以从客户端请求所用的url中获取很多信息。nodejs中有`url`模块和`queryString`模块，分别用来获取完整url字符串中信息和查询字符串中信息。

先上代码：
```javascript
const url = require( "url" );
const queryString = require( "querystring" );

let clientUrl = "http://www.maigangle.com/mallList?usr=nitx&age=31&sex=male#hash";

// url模块中的parse()方法可以将url字符串转换成一个对象
let urlObj = url.parse( clientUrl );
console.log( urlObj );

// url模块中的format()方法可以将url字符串经过转换后的对象还原成一个url字符串
let urlStr = url.format( urlObj );
console.log( urlStr );


var queryStr = urlObj.query;
console.log( queryStr );
// queryString模块中的parse()方法可以将 url 中的查询字符串转换成一个对象
let queryObj = queryString.parse( queryStr );
console.log( queryObj );
```
然后是所有的打印结果截图：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190214_2.png?raw=true)

解下来就是详细的解释url和queryString这两个模块的用法。

url模块中的`parse()`方法可以将服务器端从客户端获取的url字符串转换成一个对象，这个对象中可能有如下属性：
- `href`：被转换的原URL字符串
- `protocol`：客户端发出请求时使用的协议
- `slashes`：在协议与路径之间是否使用"//"分隔符，是个布尔值
- `host`：URL字符串中的完整地址和端口号
- `auth`：URL字符串中的认证信息
- `hostname`：URL字符串中的完整地址和端口号
- `port`：URL字符串中的端口号
- `pathname`：URL字符串中的路径，不包括查询字符串
- `path`：URL字符串中的路径，包含查询字符串
- `search`：URL字符串中的查询字符串，包含起始字符"?"
- `query`：URL字符串中的查询字符串，不包含起始字符"?"，或根据该查询字符串而转换的对象(这里受parse()方法所用的第二个参数决定)
- `hash`：URL字符串中散列字符串，包含起始字符"#"

`parse()`方法使用方式：`url.parse( urlStr, [parseQUeryString] )`，第一个参数为指定需要转换的URL字符串必填，第二个参数为选填，是个布尔值，用来决定是否将查询字符串query转换成对象，默认为false。

在使用`url.parse( urlStr )`将指定URL字符串转换成对象后，还可以使用`url.format( urlObj )`将转换后的URL对象还原成URL字符串。

queryString模块中的`parse()`方法可以将查询字符串转换成对象，所谓的查询字符串，指在一个完整URL字符串中，从"?"字符之后(不包括"?"字符)到"#"字符之前(如果存在"#"字符)或者到该URL字符串结束(如果不存在"#"字符)的这一部分。例如上例中完整URL字符串为`http://www.maigangle.com/mallList?usr=nitx&age=31&sex=male#hash`，那么正确的查询字符串就是`usr=nitx&age=31&sex=male`这部分。

queryString模块中的`parse()`使用方法为：`queryString.parse( queryStr, [sep], [eq], [options] )`。

其中第一个参数queryStr为查询字符串，必填。后面三个参数则为可选参数，sep参数用于指定该查询字符串的分割字符，默认值为"&"；eq参数用于指定该查询字符串中的分配字符，默认值为"="，options参数值是一个对象，可以在该对象中使用一个整数值类型的 `maxKeys` 属性来指定转换后的对象中的属性个数，如果将maxKeys属性值设为0，则等于不使用maxKeys属性值。示例如下：
```javascript
let queryStr = "usr=nitx&age=31&sex=male";
let res = queryString.parse( queryStr, "&", "=", {maxKeys: 2} );
console.log( res );
// { usr: 'nitx', age: '31' }
```

关于查询字符串的parse()，除了用于URL字符串中查询字符串参数的处理，还可以用于表单数据提交时的接收处理。当在客户端提交表单数据且表单中存在复选框时，提交的查询字符串中存在类似`interests=code&interests=ps4`这种形式的字符串时，它们会被转换成对象中的一个数组。
```javascript
const queryString = require( "querystring" );

let queryStr = "usr=nitx&age=31&sex=male&interests=code&interests=ps4";
let res = queryString.parse( queryStr );

console.log( res );
// 打印：
/*
{ usr: 'nitx',
  age: '31',
  sex: 'male',
  interests: [ 'code', 'ps4' ] 
}
*/
```

下面来写个表单提交的查询字符串获取示例：
```javascript
// app.js
const http = require( "http" );
const queryString = require( "querystring" );

let app = http.createServer( function ( req, res ) {
    if( req.url !== "facivon.ico" ){
        req.on( "data", function ( data ) {
            let queryStr = decodeURIComponent( data );
            let queryObj = queryString.parse( queryStr );
            console.log( queryObj );
        } )
        req.on( "end", function () {

        } )
    }
    res.end();
} )
app.on( "connection", function () {
    console.log( "客户端连接已建立" );
} )
app.on( "error", function ( e ) {
    console.log( e );
} )
app.on( "close", function () {
    console.log( "服务器端已关闭" );
} )

app.listen( 1336, "127.0.0.1", ()=>{ console.log( "service is running at port 1336." ); } );

//打印结果：
/*
客户端连接已建立
{ name: 'ntx', age: '31', interests: [ 'code', 'PS4' ] }
客户端连接已建立
*/

// index.html
<body>
    <form action="http://127.0.0.1:1336/" method="POST">
        <input type="text" name="name">
        <input type="number" name="age">
        <input type="checkbox" name="interests" value="code">敲代码
        <input type="checkbox" name="interests" value="PS4">玩PS4
        <input type="submit" value="提交">
    </form>
</body>
```
在上例中，之所以控制台输出两次"客户端连接已建立"字符串，是因为浏览器在访问HTTP服务器时，浏览器会发出两次客户端请求，一次是用户发出的请求，另一次是浏览器为页面在收藏夹中的显示图标(默认为favicon.ico)而自动发出的请求。所以在createServer()方法，也通过`req.url !== "facivon.ico"`来筛掉非用户请求，减少服务器的无效响应。
