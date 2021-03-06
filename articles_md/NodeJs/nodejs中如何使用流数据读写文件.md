在nodejs中，可以使用fs模块的readFile方法、readFileSync方法、read方法和readSync方法读取一个文件的内容，还可以使用fs模块的writeFile方法、writeFileSync方法、write方法和writeSync方法向一个文件中写入内容。

它们各自的区别如下：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190222_0.png?raw=true)


在使用readFile、readFileSync读文件或writeFile、writeFileSync写文件时，nodejs会将该文件内容视为一个整体，为其分配缓存区并一次性将内容读取到缓存区中，在这期间，nodejs将不能执行任何其他处理。

在使用read、readSync读文件时，nodejs将不断地将文件中一小块内容读入缓存区，最后从该缓存区中读取文件内容。使用rite、writeSync写文件时，nodejs执行如下过程：1、将需要书写的数据写到一个内存缓冲区；2、待缓冲区写满之后再将该缓冲区内容写入文件中；3、重复执行过程1和过程2，直到数据全部写入文件为止。所以用这4种方法在读写文件时，nodejs可以执行其他处理。

但在很多时候，并不关心整个文件的内容，而只关注是否从文件中读取到某些数据，以及在读取到这些数据时所需执行的处理，此时可以使用nodejs中的文件流来执行。

所谓的"流"：**在应用程序中，流是一组有序的、有起点和终点的字节数据的传输手段**。在应用程序中各种对象之间交换和传输数据时，总是先将该对象中所包含的数据转换成各种形式的流数据(即字节数据)，再通过流的传输，到达目的对象后再将流数据转换为该对象中可以使用的数据。

nodejs中使用实现了stream.Readable接口的对象来将对象数据读取为流数据，所有这些对象都是继承了EventEmitter类的实例对象，在读取数据的过程中，会触发各种事件。

这些实现了stream.Readable接口的对象有：
- fs模块专用于将文件数据读成流数据的fs.ReadStream方法
- 代表客户端请求对象的http.IncommingMessage对象，这个在前面http模块方面文章中经常用到，`http.createServer( function( req, res ){} )`中的req对象就是典型的http.IncommingMessage对象
- net.Socket对象，即一个socket端口对象
- child.stdout对象，用于创建子进程的标准输出流
- child.stderr对象，用于创建子进程的标准错误输出流
- process.stdin对象，用于创建进程的标准输入流
- Gzip/Deflate/DeflateRaw对象，用于实现数据压缩

以上这些实现了stream.Readable接口的对象可能会触发的事件有：
- readable事件，当可以从流中读出数据时触发
- data事件，当读取到来自文件、客户端、服务器端等对象的新的数据时触发，常见的有创建服务器监听客户端请求数据时的`req.on( "data", function( dataChunk ){} )`
- end事件，当读取完所有数据时触发，此时data事件将不再会触发
- error事件，当读取数据过程中产生错误时触发
- close事件，当关闭用于读取数据流的对象时触发。

实现了stream.Readable接口的对象具有如下方法：
- read方法，用于读取数据
- setEncoding方法，用于指定用什么编码方式读取数据
- pause方法，用于通知对象停止触发data事件
- resume方法，用于通知对象恢复触发data事件
- pipe方法，用于设置一个数据通道，然后取出所有流数据并将其输出到通道另一端所指向的目标对象中
- unpipe方法，用于取消在pipe方法中设置的通道
- unshift方法，当对流数据绑定一个解析器时，可以使用该方法取消该解析器的绑定，使用流数据可以使用其他方式解析

用于写入数据的实现了stream.Readable接口的对象和读取数据的相应对象差不多，常见的有：
- fs.WriteSteam对象，用于写入文件
- http.ClientRequest对象，用于写入HTTP客户端请求数据
- http.ServerResponse对象，用于写入HTTP服务器端响应数据
...

这些用于写入流数据的对象可能会触发的事件有：
- drain事件，当用于写入数据的write方法返回false时触发，表示操作系统缓存区中的数据已全部输出到目标对象中，可以继续向操作系统缓存区中写入数据
- finish事件，当end方法被调用且数据全部被写入操作系统缓存区时触发
- pipe事件，当用于读取数据的对象的pipe方法被调用时触发
- unpipe事件，当用于读取数据的对象的unpipe方法被调用时触发
- error事件，当写入数据过程中产生错误时触发

这些用于写入流数据的对象的方法有：
- write方法，用于写入数据
- end方法，当没有数据再被写入流中时调用该方法。这会迫使操作系统缓存区中的剩余数据被立即写入目标对象中，当该方法被调用时，将不能继续在目标对象中写入数据。

#### 使用ReadStream对象读文件 fs.createReadStream
使用ReadStream对象读文件就是将文件数据读成流数据，可以使用fs模块中的`fs.createReadStream( path, [options] )`方法，其中path为必指定参数，用于指定需要被读取的文件的完整路径及文件名。options参数值是一个对象，其中的属性为：
```javascript
options = {
    flags: "r",     // 用于指定对该文件采用什么操作，默认为r
    encoding: null, // 用于指定用什么编码格式读取文件，默认null，可指定属性为 utf8、base64、ascii
    autoClose: true,// 用于指定是否关闭在读取文件时操作系统内部使用的文件描述符，默认为true，当文件读取完毕或读取文件过程中产生错误时文件关闭
    start: --,      // 使用整数值来指定文件的开始读取位置，单位为字节数
    end: --         // 使用整数值来指定文件的结束位置，单位为字节数
}
```
当文件被打开时，将触发ReadStream对象的open事件，在该事件触发时调用的回调函数可以使用一个参数，参数值是被打开文件的文件描述符(也即文件句柄fd)。

下面给个使用fs.createReadStream()方法打开文件并读取数据流的demo：
```javascript
const fs = require( "fs" );

// 创建一个将文件内容读取为流数据的ReadStream对象
let fileReadStream = fs.createReadStream( "./a1.txt", {encoding: "utf-8", start: 0, end: 24} );

// 打开文件，回调函数参数fd是打开文件时返回的文件描述符（文件句柄）
fileReadStream.on( "open", function ( fd ) {
    console.log( "文件被打开，文件句柄为%d", fd );
} );

// 暂停文件读取
fileReadStream.pause();

// 1秒后取消暂停，继续读取文件流
setTimeout( function () {
    fileReadStream.resume();
}, 2000 );

// 读取到文件新的数据时触发的事件，回调函数参数dataChunk为存放了已读到的数据的缓存区对象或一个字符串
fileReadStream.on( "data", function ( dataChunk ) {
    console.log( "读取到数据：" );
    console.log( dataChunk );
} );

// 读取完所有数据时触发，此时将不会再触发data事件
fileReadStream.on( "end", function () {
    console.log( "文件已经全部读取完毕" );
} );

// 用于读取数据流的对象被关闭时触发
fileReadStream.on( "close", function () {
    console.log( "文件被关闭" );
} );

// 当读取数据过程中产生错误时触发
fileReadStream.on( "error", function ( err ) {
    console.log( "文件读取失败。" );
} )
```

#### 使用ReadStream对象写入文件 fs.createWriteStream
`fs.createWriteStream( path, [options] )`方法可以创建一个将流数据写入文件的WriteSteam对象。该方法的参数说明如下(这里采用新说明方式，参数options为对象，直接在对象名边列出对象属性说明，属性值为该参数属性的默认值，这属于伪代码，请勿写入实际代码中)：
```javascript
fs.createWriteStream( 
    path,               // 必写，用于指定需要被写入数据的文件的完整
    options{
        flags: "w",     // 用于指定对该文件采用什么操作，默认为 w
        encoding: null, // 用于指定用什么编码格式读取文件，默认null，可指定属性为 utf8、base64、ascii
        start:          // 使用整数值来指定文件的开始写入位置，单位为字节数，如果要在文件追加写入数据，需将flag属性设为 a
    }
)
```
当文件被打开时，将触发WriteStream对象的open事件，在该事件触发时调用的回调函数可以使用一个参数，参数值是被打开文件的文件描述符(也即文件句柄fd)。

WriteStream对象写入的方法是write()，用于将流数据写入到目标对象中。`writeable.write( chunk, [encoding], [callback] )`，chunk参数是一个buffer对象或一个字符串，用于指定要写入的数据，当为字符串时，可以使用encoding参数来指定以何种编码格式写入文件，可以使用callback参数来指定当数据被写入完毕时所调用的回调函数，该回调中不使用任何参数。write方法返回一个布尔值，当操作系统缓存区中写满时为false。

WriteStream对象的end()方法指在写入文件的场合中，当没有数据再被写入时可调用，此时会将缓存区中剩余数据立即写入文件中。`writeable.end( [chunk], [encoding], [callback] )`，参数含义与write方法完全一样，同样的回调函数不使用任何参数。

WriteStream对象还有一个对象bytesWritten属性，属性值是当前已在文件中写入数据的字节数。

下面给出一个根据fs.createWriteStream对象执行的WriteStream示例demo:
```javascript
const fs = require( "fs" );

let file = fs.createReadStream( "./a1.txt", { encoding: "utf8", start: 0, end: 20 } );
let out = fs.createWriteStream( "./a2.txt", { encoding: "utf8", start: 0 } );

file.on( "data", function ( dataChunk ) {
    out.write( dataChunk, function () {
        console.log( "将数据传入a2.txt文件中" );
    } )
} )

out.on( "open", function ( fd ) {
    console.log( "文件描述符为%d的文件正在被打开，它将被写入来自a1.txt中的数据。", fd );
} )

file.on( "end", function () {
    out.end( "，再见", function () {
        console.log( "文件全部写入完毕" );
        console.log( "共写入%d字节数据", out.bytesWritten );
    } )
} )
```

**喜欢本文请扫下方二维码，关注微信公众号： 前端小二，查看更多我写的文章哦，多谢支持。**
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190107095151263.jpg)