在nodejs中实现对文件及目录读写操作的功能是fs模块。另外与文件及目录操作相关的一个模块是path模块。

fs模块可以实现所有有关文件及目录的创建、写入与删除操作。这些操作分为同步与异步两种方法。两者的区别在于：同步方法立即返回操作结果，但会阻塞后续代码执行；异步方法不会阻塞后续代码执行，只需等到该异步执行完成调用相应回调函数来返回结果。出于性能考虑多数情况下都是使用异步方法，少数场景会用到同步方法，例如要读取配置文件并启动服务器时。

#### 对文件的读
完整读取文件可以使用fs模块的`readFile`或`readFileSync`方法。看名字就知道，前者是异步方法，后者是同步方法。

`fs.readFile( filename, [options], callback )`：在异步方法readFile中使用三个参数，其中filename参数与callback参数为必须指定，options参数是可选的。filename参数用于指定读取文件的完整文件路径及文件名；options参数值可以是一个对象，在其中指定读取文件需要使用的选项，在该参数值对象中有encoding属性和flag属性，encoding属性值是字符串或null，指定使用何种字符串编码格式来读取文件。flag属性值用于指定对该文件采取什么操作，默认值是"r"，即读取文件，如果文件不存在则抛出异常。options参数值也可以是一个单纯的字符串，那它就是用来指定字符编码。如果没有指定encoding属性值，则文件读取结果返回原始的buffer；callback参数用于文件读取完毕时执行的回调函数。
```javascript
const fs = require( "fs" );
// 异步读文件方法
fs.readFile( "./test.txt", "utf-8", function( err, data ){
    // 读取文件test.txt后执行的回调函数，
    // 参数err是读取文件错误时返回的结果
    // 参数data是读取文件成功时返回的文件中的数据，编码格式依据第encoding属性值决定，不定义encoding属性时默认以buffer格式显示
    if( err ){
        console.log( "文件读取错误" );
    }else {
        console.log( data );
    }
} )
```

`let data = fs.readFileSync( filename, [options] );`：在同步方法readFileSync方法中使用两个参数，它们与异步方法readFile中对应的参数含义完全相同。
```javascript
const fs = require( "fs" );
// 同步读文件方法
try{
    let data = fs.readFileSync( "./test.txt", "utf-8" );
    console.log( data ); // 打印文件中的数据，按照utf-8编码格式
}catch( e ){
    console.log( "读取文件时错误" );
}
```

#### 对文件的写
完整写入一个文件时，使用fs模块中的writeFile方法和writeFileSync方法。它们同样分别是异步方法和同步方法，执行后如果文件不存在将创建文件并写入数据。

`fs.writeFile( filename, data, [options], callback );`除Options参数是可选外，其他参数是必须指定的。data参数用于指定需要写入的内容，参数值可以是一个字符串或一个buffer对象，该字符串或缓存区中的内容将被完整地写入到文件中。options参数对象除了flag属性和encoding属性外，还新加了一个mode属性，用于指定当文件被打开时对该文件的读写权限，默认值是0666(可读写)。callback参数指定文件执行完毕时回调函数，注意该回调函数只有一个参数err。
```javascript
const fs = require( "fs" );
// 异步写文件
let data = "我是nitx";
fs.writeFile( "./text2.txt", data, "utf-8", function( err ){
    if( err ){
        console.log( "文件写入失败" );
    }else {
        console.log( "文件写入成功，已保存" );
    }
} );
```

`fs.writeFileSync( filename, data, [options] )`：同步写方法的参数与异步写方法的参数含义一样。

#### 文件中追加数据
要将一个字符串或一个缓存区中的数据追加到一个文件底部时，可以使用fs模块中的appendFile或appendFileSync方法。

`fs.appendFile( filename, data, [options], callback );`，它的四个参数与writeFile()方法中的参数大致相同，区别在于options参数值对象中，flag属性值默认是"a"，表示在文件底部追加写入数据，如果文件不存在，则创建该文件。
```javascript
const fs = require( "fs" );

fs.appendFile( "./test3.txt", "这是追加的数据", "utf-8", function ( err ) {
    if( err ){
        console.log( "数据追加失败" );
    }else{
        console.log( "数据追加成功" );
    }
} )
```
`fs.appendFileSync( filename, data, [options] )`，同步方法使用三个参数，仔细从上面看过来，想必都明白这些参数的含义，不赘述了。

#### 从指定位置处读写文件
要实现从指定位置处开始读写文件的处理，首先需要使用fs模块的open方法或openSync方法打开文件。

`fs.open( filename, flags, [mode], function( err, fd ){} )`。flag参数定义文件的系统标志，例如值"r"表示打开文件用于读取，如果文件不存在则会发生异常。可选参数mode表示文件的读写权限，默认值是0666，即可读写。回调函数中第二个参数fd的参数值是一个整数值，代表打开文件时返回的文件描述符(windows下称为文件句柄)。
```javascript
const fs = require( "fs" );
fs.open( "./test3.txt", "r", function ( err, fd ) {
    console.log( fd );      // 3
} )
```

`fs.openSync( filename, flags, [mode] )`，参数同上。注意该方法返回被打开文件的描述符，也即异步方法回调函数中的fd参数值。

在打开文件后，可以在回调函数中使用fs模块中的read方法或readSync方法从文件的指定位置处读取文件，可以使用fs模块中的write方法或writeSync方法从文件指定处开始写入数据。

read方法从文件指定的位置处读取文件，一起读取到文件的底部，然后将读取到的内容输出到一个缓存区中。

`fs.read( fd, buffer, offset, length, position, callback )`：该异步方法使用6个参数，均为必指定参数，fd参数值必须是open()方法所使用的回调函数中返回的文件描述符或openSync方法返回的文件描述符；buffer参数值为一个Buffer对象，用于指定将文件数据读取到哪个缓存区中；offset参数值、length参数值、position参数值均为一个整数，offset参数值用于指定向缓存区中写入数据时的开始写入位置(以字节为单位)，length参数用于指定从文件中读取的字节数，position参数用于指定读取文件时的开始位置(以字节为单位)。callback回调函数`function (err, bytesRead, buffer){}`使用三个参数，err都懂，bytesRead参数值是一个整数值，代表实际被读的字节数(由于文件的开始读取位置+指定读取的字节数可能大于文件长度，指定读取的字节数可能并不等于实际读取到的字节数)，buffer参数值为被读取的缓存区对象。
```javascript
const fs = require( "fs" );

// StringDecoder对象实例的write方法可以将buffer对象中的数据转换成字符串，这个方法作用类似buffer.toString()，但更优秀
const StringDecoder = require( "string_decoder" ).StringDecoder;
let decoder = new StringDecoder("utf-8");

let buf = new Buffer(255);
fs.open( "./test3.txt", "r", function ( err, fd ) {
    console.log( fd );      // 3
    fs.read( fd, buf, 0, 9, 1, function ( err, bytesRead, buffer ) {
        if( err ){
            console.log( "文件读取失败" );
        }else {
            console.log( decoder.write(buffer.slice( 0, bytesRead )) );
        }
    } )
} )
```

`fs.readSync( fd, buffer, offset, length, position )`，该方法返回实际从文件中读取到字节数。

在打开文件后，可以使用fs模块中的write方法或writeSync方法从一个缓存区中读取数据并且从文件指定处开始写入这些数据。

`fs.write( fd, buffer, offset, length, position, callback )`，fd参数值必须是open()方法所使用的回调函数中返回的文件描述符或openSync方法返回的文件描述符；buffer参数值为一个Buffer对象，用于指定从哪个缓存区中读取数据；offset参数值、length参数值、position参数值均为一个整数，offset参数值用于指定从缓存区中读取数据时的开始读取位置(以字节为单位)，length参数用于指定从缓存区中读取的字节数，position参数用于指定写入文件时的开始位置(以字节为单位)。callback回调函数`function (err, written, buffer){}`使用三个参数，err都懂，written参数值是一个整数值，代表被写入的字节数，buffer参数值为被读取的缓存区对象。
```javascript
const fs = require( "fs" );
let buf = new Buffer( "sxm" );
fs.open( "./test4.txt", "w", function ( err, fd ) {
    if( err ){
        console.log( "文件打开失败" );
    }else {
        // 写入buffer数据时，文件中内容为二进制
        fs.write( fd, buf, 0, 3, 6, function ( err, written, buffer ) {
            if( err ){
                console.log( "写文件操作失败" );
            }else {
                console.log( "写入文件操作成功" );
                console.log( written );     // 3
                console.log( buffer.toString() );   // sxm
            }
        } )

        // 写入字符串时，
        fs.write( fd, "sxm", 0, "utf-8", function ( err, written, str ) {
            if( err ){
                console.log( "写文件操作失败" );
            }else {
                console.log( "写入文件操作成功" );
                console.log( written );
                console.log( str );
            }
        } )
    }
} )
```
上面的例子中，fs.write()有两种不同的方法，分别是**将 buffer 写入到 fd 指定的文件**和**将 string 写入到 fd 指定的文件**，这类似于方法的重载，同一个方法名，只是传入参数不同。

将 buffer 写入到 fd 指定的文件：`fs.write( fd, buffer, offset, length, position, callback )`。参数的介绍在上面有。

将 string 写入到 fd 指定的文件：`fs.write( fd, string[, position[, encoding]], callback )`。如果 string 不是字符串，则该值将被强制转换为字符串。encoding 是期望的字符串编码。

在同一文件上多次使用 fs.write() 且不等待回调是不安全的。 对于这种情况，建议使用 fs.createWriteStream()。

#### 关闭文件
当对文件的读写执行完毕后，要关闭文件。

fs模块中，提供close和closeSync方法以关闭文件。

`fs.close( fd, [callback] )`。其中fd参数必为open()方法所使用回调函数中返回的文件描述符(文件句柄)，callback则是一个可选参数，如选用回调函数，则其使用一个参数，参数值是关闭文件操作失败时触发的错误对象。当然这个回调函数还是建议加上的，在异步函数中添加回调是较优实践。

在写出示例前，有个地方需要注意：在使用write或writeSync方法在文件中写入数据时，操作系统的做法是首先将该部分数据读到内存中，再把数据写到文件中。当数据读完并不代表数据已经写完，因为还有一部分可能会留在内存缓冲区中。这里如果调用close或closeSync方法关闭文件，就会导致部分数据丢失。这些可以调用fs模块的fsync方法将内存缓冲区中的剩余数据全部写入文件，确保不会出现写入数据丢失的情况。
```javascript
const fs = require( "fs" );
let str = "sxm"
fs.open( "./test5.txt", "w", function ( err, fd ) {
    if( err ){
        console.log( "文件打开失败" );
    }else {
        fs.write( fd, str, 0, "utf-8", function ( err, written, str ) {
            if( err ){
                console.log( "写文件操作失败" );
            }else {
                console.log( "写入文件操作成功" );
                console.log( written );
                console.log( str );
            }
        } );
        // 将内存缓冲区中的剩余数据全部写入文件，确保不会出现写入数据丢失的情况
        fs.fsync( fd, function ( err ) {
            console.log( err );
        } );  
        // 关闭已打开的文件
        fs.close( fd, function ( err ) {
            if( err ){
                console.log( "关闭文件失败" );
            }else {
                console.log( "成功关闭文件" );
            }
        } );
    }
} )
```