异步I/O、事件驱动和单线程构成了Node的基调。与Node的事件驱动和异步I/O设计理念相接近的是Nginx，它采用纯C编写，性能非常优异。两者区别在于，Nginx具备面向客户端管理连接的强大能力，但它背后依然受限于各种同步方式的编程语言。而Node却是全方位的，既可以作为服务器去处理客户端带来的大量并发请求，也能作为客户端向网络中的各个应用进行并发请求。这就体现了Node名字的含义，是网络中灵活的一个节点。

Node中完整的异步I/O环节包括事件循环、观察者、请求对象和执行回调。

#### 事件循环
事件循环是一个类似于`while(true)`的循环，每执行一次循环体的过程称为Tick。每个Tick的过程就是查看是否有事件待处理，如果有，就取出事件及其相关的回调函数。如果存在关联的回调函数，就执行它们。然后进入下个循环，如果不再有事件处理，就退出进程。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20190131084134611.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM0ODMyODQ2,size_16,color_FFFFFF,t_70)

#### 观察者
在每个事件循环(Tick)的过程中，判断是否有事件需要处理的就是“观察者”。每个事件循环中有一个或多个观察者，而判断是否有事件要处理的过程就是向这些观察者询问是否有要处理的事件。

参考浏览器中的事件机制，其中的事件可能来自用户的点击或加载某些文件或代码时产生，而这些产生的事件都有对应的观察者。在Node中，事件的产生主要来源于网络请求、文件I/O等，这些事件对应的观察者有文件I/O观察者、网络I/O观察者等。观察者将事件进行分类。

事件循环就是一个包含若干个典型的发布/订阅模式的模型。其中异步I/O、网络请求等都是事件的发布者(trigger)，这些发布请求被传递到对应的订阅者(listen)那里时，事件循环就会从订阅者那里取出事件并处理。在Windows下，这个循环基于IOCP创建，而在*nix下则基于多线程创建。

下面给出一个观察者模式代码实现以供理解，代码解释看注释，注意下面这个是用js的面向对象委托写的，感兴趣的也可以改写成面向对象类的形式：
```javascript
// 定义发布/订阅对象
var ObserverEvent = (function (){
    var cacheList = {},     // 缓存列表，存放已订阅的事件回调
        listen,             // 订阅命名事件和对应事件回调
        trigger,            // 触发命名事件，必传第一个参数为事件的命名，其后参数为选传，数量不限，用于作为事件回调的实参传入
        remove;             // 取消命名事件订阅，并清除该命名事件对应的事件回调

    listen = function( key, fn ){
        //如果还没有订阅过此命名事件，就给该命名事件创建一个数组型的缓存列表
        if( !cacheList[key] ){  
            cacheList[key] = [];
        }

        //将对应的事件回调传入该命名事件的缓存列表中
        cacheList[key].push( fn );
    };

    trigger = function(){
            // 取出事件命名
        var key = Array.prototype.shift.call( arguments ),
            // 取出该命名事件对应的事件回调缓存列表
            fns = cacheList[key];

        // 如果没有订阅该命名事件或对应的事件回调缓存列表为空数组，则直接返回false
        if( !fns || fns.lenght === 0 ){
            return false;
        }

        // 遍历该命名事件对应的事件回调缓存列表数组，对数组中的每个事件回调传入处理后的实参列表，然后执行
        for(var i=0; i<fns.length; i++){
            fns[i].apply( this, arguments );
        }
    };

    remove = function( key, fn ){
        var fns = cacheList[key];

        if( !fns || fns.length === 0 ){
            return false;
        }

        if( !fn ){
            // 如果没有显式传入具体的事件回调函数，则清除该命名事件对应的所有事件回调缓存
            fns.length = 0;
        }else {
            for( var l=fns.length-1; l>=0; l-- ){
                var _fn = fns[l];
                if( _fn === fn ){
                    fns.splice( l, 1 );
                }
            }
        }
    };

    return {
        cacheList,
        listen,
        trigger,
        remove
    }
})()

// 定义发布订阅对象安装函数，该函数可以为指定对象安装发布-订阅功能
var installEvent = function( obj ){
    for( var i in ObserverEvent ){
        obj[ i ] = ObserverEvent[ i ]
    }
}

// 为pageData对象安装发布订阅功能
var pageData = {};
installEvent( pageData );

pageData.listen( "test", function(msg){
    console.log( msg );
} )

setTimeout( function(){
    pageData.trigger( "test", "发布-订阅模式测试成功！" )
}, 3000 )

// 在未被其他循环占用的情况下，3秒后打印字符串结果：
// 发布-订阅模式测试成功！
```
以上就是一个完整的发布-订阅模式，通过实践，可以看到，事件循环中有订阅者`pageData.listen(...)`，也有发布者`pageData.trigger(...)`，当3秒后发布请求被传递到对应的订阅者那时，事件循环就从订阅者那里取出事件并处理。

#### 请求对象
Node中请求对象其实就是JavaScript发起调用到内核执行完I/O操作过程的过渡中间产物，它是保存所有状态的一个对象，包括送入线程池等待执行以及I/O操作完毕后的执行回调处理。

以`fs.open()`为例，它的作用是根据指定路径和参数打开一个文件，从而得到一个文件描述符，这是所有后续I/O操作的初始操作。JavaScript层面的代码通过调用C/C++核心模块进行下层的操作，下面是调用示意图：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190131084153263.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM0ODMyODQ2,size_16,color_FFFFFF,t_70)

Node先从JavaScript核心模块所处的lib文件夹中调用`fs.js`模块，然后再调用C/C++核心模块所处的src文件夹中调用`node_file.cc`这个C++内建模块，再接下来就是进行系统平台的判定，然后继续执行下层操作。

#### 执行回调
当组装好保有状态的请求对象、送往I/O线程池(这块我看不懂，应是C/C++内建模块涉及的操作)等待执行，实际上就是完成了异步I/O的第一部分，回调通知是第二部分。

线程池中的I/O操作调用完毕后，会将获取的结果储存在`req->request`属性上，然后调用`PostQueuedCompletionStatus()`通知IOCP，告知当前对象操作已经完成。`PostQueuedCompletionStatus()`方法的作用是向IOCP提交执行状态，并将线程归还线程池。通过`PostQueuedCompletionStatus()`方法提交的状态，可以通过`GetQueuedCompletionStatus()`提取。

在这个过程中，其实还使用了事件循环的I/O观察者。在每次Tick执行中，它会调用IOCP相关的`GetQueuedCompletionStatus()`方法检查线程池中是否有执行完的请求，如果存在，则会将请求对象加入到I/O观察者队列中，然后将其当作事件处理。

I/O观察者回调函数的行为就是取出请求对象的`result`属性作为参数，取出`oncomplete_sym`属性作为方法，然后调用执行，以此达到调用JavaScript中传入的回调函数的目的。

到此，整个异步I/O的流程结束，事件循环、观察者、请求对象和执行回调是整个异步I/O的四个基本要素。下面给出示意图:
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190131084204414.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM0ODMyODQ2,size_16,color_FFFFFF,t_70)

在Node异步I/O的实现原理中，也基本弄清事件驱动的本质：**通过主循环加事件触发的方式来运行程度**。