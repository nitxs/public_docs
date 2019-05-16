
## 什么是SVG

svg是指可缩放矢量图形，是用于描述二维矢量图形的一种图形格式。svg使用XML格式来定义图形，除ie8之前版本外，绝不部分浏览器均支持svg，可将svg文本直接嵌入HTML中显示。

svg优点是文件小、缩放旋转均不会失真、线条颜色平滑无锯齿。

svg矢量图是用数学方法描述的图，不适合表现自然度较高且复杂多变的图。

## svg图形元素

使用svg中的图形元素前，首先要定义一组`<svg>`标签元素，并向该标签添加属性`width`和`height`，分别表示绘制区域的宽度和高度。

需要绘制的图形元素都要添加之前定义的一组`<svg></svg>`之间。

svg中定义了七种形状元素：`矩形<rect>`、`圆形<circle>`、`椭圆<ellipse>`、`线段<line>`、`折线<polyline>`、`多边形<polygon>`、`路径<path>`。

#### ①.矩形

矩形的参数有6个：

- x: 矩形左上角的x坐标
- y: 矩形左上角的y坐标
- width: 矩形的宽度
- height：矩形的高度
- rx：对于圆角矩形，指定椭圆在x方向的半径
- ry：对于圆角矩形，指定椭圆在y方向的半径

示例代码：
```html
<svg width="300" height="300">
    <!-- 直角矩形 -->
    <rect x="20" y="20" width="200" height="100" style="fill:steeblue;stroke:blue;stroke-width:4;opacity:0.5;"></rect>
    <!-- 圆角矩形 -->
    <rect x="20" y="150" rx="20" ry="30" width="200" height="100" style="fill:yellow;stroke:black;stroke-width:4;opacity:0.5;"></rect>
</svg>
```

效果截图：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190515_3.png?raw=true)

#### ②.圆形与椭圆形

圆形的参数有3个：
- cx: 圆心的x坐标
- cy: 圆心的y坐标
- r: 圆的半径

椭圆的参数类似于圆形，只是半径分为水平半径和垂直半径
- cx: 圆心的x坐标
- cy： 圆心的y坐标
- rx: 椭圆的水平半径
- ry: 椭圆的垂直半径

示例代码
```html
<svg width="600" height="300">
    <!-- 圆形 -->
    <circle cx="150" cy="150" r="80" style="fill: yellow; stroke: black; stroke-width: 4;"></circle>
    <!-- 椭圆 -->
    <ellipse cx="350" cy="150" rx="110" ry="80" style="fill: #33ff33; stroke: blue; stroke-width: 4;"></ellipse>
</svg>
```

效果截图：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190515_4.png?raw=true)

#### ③.线段

线段的参数是起点和终点的坐标。
- x1：起点的x坐标
- y1: 起点的y坐标
- x2: 终点的x坐标
- x3：终点的y坐标

示例代码：
```html
<svg width="300" height="300">
    <line x1="20" y1="20" x2="300" y2="100" style="stroke: black;stroke-width: 4;"></line>
</svg>
```

效果截图：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190515_5.png?raw=true)

#### ④.多边形和折线

多边形和折线的参数相同，都只有一个`points`参数。这个参数的值是一系列的点坐标，不同之处是多边形会将起点与终点连接起来，而折线不会。

示例代码：
```html
<svg width="600" height="300">
    <!-- 多边形 -->
    <polygon points="100,20 20,90 60,160 140,160 180,90" style="fill:lightgreen; stroke: black; stroke-width: 4;"></polygon>
    <!-- 折线 -->
    <polyline points="100,20 20,90 60,160 140,160 180,90" style="fill: white; stroke: black; stroke-width: 4;" transform="translate( 200, 0 )"></polyline>
</svg>
```

效果截图：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190515_6.png?raw=true)

#### ⑤.路径

`<path>`标签的功能是所有图形元素中最强大的，所有其他图形元素都可以用路径`<path></path>`来制作出来。类似于折线，路径也是通过一系列点坐标来绘制的。

其用法是：给出一个坐标点，在坐标点前添加一个英文字母，表示如何运动到此坐标点的。

英文字母按照功能可以分成五类：

- 移动类
  1. M = moveto：将画笔移动到指定坐标。
- 直线类
  1. L = lineto：画直线到指定坐标
  2. H = horizontal lineto：画水平直线到指定坐标
  3. V = vertical lineto：画垂直直线到指定坐标
- 曲线类
  1. C = curveto：画三次贝塞尔曲线经两个指定控制点到达终点坐标
  2. S = shorthand/smooth curveto：与前一条三次贝塞尔曲线相连，第一个控制点为前一条曲线第二个控制点的对称点，只需输入第二个控制点和终点，即可绘制一个三次贝塞尔曲线
  3. Q = quadratic Bezier curveto：画二次贝塞尔曲线经一个指定控制点到达终点坐标
  4. T = shorthand/smooth quadratic Bezier curveto：与前一条二次贝塞尔曲线相连，控制点为前一条二次贝塞尔曲线控制点的对称点，只需输入终点，即可绘制一条二次贝塞尔曲线。
- 弧线类
  1. A = elliptical arc：画椭圆曲线到达指定坐标
- 闭合类
  1. Z = closepath：绘制一条直线连接起点和终点，用来封闭图形。

注意：以上命令均为大写表示，表示坐标系中的绝对坐标。也可以使用小写字母，表示的是相对坐标，也就是相对当前画笔所在点。

绘制直线：
```html
<svg width="600" height="300">
    <!-- 绘制直线 -->
    <path d=" M30,100 L270,300
              M30,100 H270
              M30,100 V300 "
          style="stroke: black; stroke-width:3">
    </path>
</svg>
```
效果截图：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190515_7.png?raw=true)

绘制三次贝塞尔曲线：
```html
<svg width="600" height="300">
    <!-- 三次贝塞尔曲线 -->
    <path d=" M30,100 
              C100,20 190,20 270,100 
              S400,180 450,100 " 
          style="fill:white;stroke:black;stroke-width: 3" >
    </path>
</svg>
```
效果截图：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190515_8.png?raw=true)

绘制二次贝塞尔曲线：
```html
<svg width="600" height="300">
    <!-- 二次贝塞尔曲线 -->
    <path d=" M30,100
              Q190,20 270,100
              T450,100 "
          style="fill:white;stroke:black;stroke-width: 3">
    </path>
</svg>
```
效果截图：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190515_9.png?raw=true)

绘制弧线，添加闭合：
```html 
<svg width="600" height="500">
    <!-- 弧线 + 闭合 -->
    <path d=" M100,200
              a200,150 0 1,0 150,-150
              Z "
          style="fill:yellow;stroke:blue;stroke-width:3">
    </path>
</svg>
```
弧线是根据椭圆来绘制的，对应的参数为`A( rx, ry, x-axis-rotation, large-arc-flag, sweep-flag, x, y )`。
- rx：椭圆x方向的半轴大小
- ry：椭圆y方向的半轴大小
- x-axis-rotation：椭圆的x轴与水平轴顺时针方向的夹角
- large-arc-flag：有两个值，(1：大角度弧线；0：小角度弧线)
- sweep-flag：有两个值，(1：顺时针到终点；0：逆时针到终点)
- x：终点x坐标
- y：终点y坐标

上述弧线示例代码的含义就是：起始画笔的位置是`M100,200`，a用了小写字母，表示相对坐标，则终点位置就是`100+150, 200-150`。包含弧线的椭圆的x和y方向的半径分别是200和150，椭圆x轴与水平轴的夹角是0度，采用了大角度弧线、逆时针走向终点。最后的Z表示将起点与终点闭合。

效果截图：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190515_10.png?raw=true)

#### ⑥.文字
在svg中可以使用`<text>`标签绘制文字，其属性如下：

- x：文字位置的x坐标
- y: 文字位置的y坐标
- dx：相对于当前位置在x方向上平移的距离(值为正则往右，负则往左)
- dy：相对于当前位置在y方向上平移的距离(值为正则往下，负则往上)
- textLength：文字的显示长度(不足则拉长，足则压缩)
- rotate：旋转角度(顺时针为正，逆时针为负)
- 如果要对文字中某一部分文字单独设置样式，可使用`<tspan></tspan>`标签

```html
<svg width="300" height="300">
    <text x="200" y="150" dx="-5" dy="5" rotate="360" textLength="90"> I Love <tspan fill="red">D3</tspan> </text>
</svg>
```

效果截图：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190515_11.png?raw=true)

#### ⑦.样式

svg中的样式，可以使用`class`类，也可以直接在元素中写样式。

直接在元素中写样式时支持两种写法：单独写、合并写。

单独写：`<line fill="yellow" stroke="blue" stroke-width="4" x1="20" y1="20" x2="100" y2="100"></line>`

合并写：`<line style="fill:white;stroke:black;stroke-width:3" x1="20" y1="20" x2="100" y2="100"></line>`

常见样式如下：
- fill：填充色，也可用于改变文字`<text>`的颜色
- stroke：边框的颜色
- stroke-width：边框的宽度
- stroke-linecap：线头端点的样式，圆角、直角等
- stroke-dasharray：虚线的样式
- opacity：透明度，0.0为完全透明，1.0为完全不透明
- font-family：字体
- font-size：字体大小
- font-weight：字体粗细，有`normal`、`bold`、`bloder`、`lighter`可选
- font-style：字体的样式，斜体等
- text-decoration：上划线、下划线等

#### ⑧.标记

标记`<marker>`可以贴附于`<path>`、`<line>`、`<polyline>`、`<polygon>`元素上。最典型应用是给线段添加箭头。

标记`<marker>`写在`<defs></defs>`之间。`<defs>`用于定义可重复利用的图形元素。

标记`<marker>`内有这些属性：
- viewBox：坐标系的区域
- refX、refY：在viewBox内的基准点，绘制时此点在直线端点上
- markerUnits：标记大小的基准，有两个值，即`strokeWidth`(线的宽度)和`userSpaceOnUse`(线前端的大小)
- markerWidth、markerHeight：标识的大小
- orient：绘制方向，可设定为auto(自动确认方向)和角度值
- id：标识的id号

然后就在`<marker></marker>`标签中定义图形，当调用这个标记时，就会绘制标记里的图形。

以定义一个箭头并调用为例：
```html
<svg width="600" height="300">
    <!-- 定义标记 -->
    <defs>
        <marker id="arrow" markerUnits="strokeWidth" markerWidth="12" markerHeight="12" viewBox="0 0 12 12" refX="6" refY="6" orient="auto">
            <path d="M2,2 L10,6 L2,10 L6,6 L2,2" style="fill:#000"></path>
        </marker>
    </defs>

    <!-- 带箭头的直线 -->
    <line x1="0" y1="30" x2="200" y2="50" stroke="red" stroke-width="2" marker-end="url(#arrow)"></line>

    <!-- 带箭头的曲线 -->
    <path d="M20,70 T80,100 T160,80 T200,90" fill="white" stroke="red" stroke-width="2" marker-start="url(#arrow)" marker-mid="url(#arrow)" marker-end="url(#arrow)"></path>
</svg>
```
其中`#arrow`表示使用id为arrow的标记。`marker-start`表示路径起点处，`marker-mid`表示路径中间端点处，`marker-end`表示路径终点处。由于使用`marker-mid`将绘制在路径的节点处，所以对于只有起点和终点的直线`<line></line>`，使用`marker-mid`无效。

效果截图：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190515_12.png?raw=true)

#### ⑨.滤镜

滤镜的标签是`<filter>`，和标记一样，也是定义在`<defs>`中的。

滤镜的种类很多，比如`feMorpholoty`、`feGaussianBlur`、`feFlood`等，还有定义光源的滤镜如`feDistantLight`、`fePointLight`、`feSpotLight`等。

以feGaussianBlur高斯模糊滤镜为例，其中`in`是使用滤镜的对象，`stdDeviation`是高斯模糊唯一的参数，数值越大，模糊程序越高：
```html
<svg width="600" height="300">
    <defs>
        <filter id="GaussianBlur">
            <feGaussianBlur in="SourceGraphic" stdDeviation="2"></feGaussianBlur>
        </filter>
    </defs>

    <!-- 未高斯模糊的矩形 -->
    <rect x="100" y="100" width="150" height="100" fill="blue"></rect>

    <!-- 高斯模糊的矩形 -->
    <rect x="300" y="100" width="150" height="100" fill="blue" filter="url(#GaussianBlur)"></rect>
</svg>
```

效果截图：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190515_13.png?raw=true)

#### ⑩.渐变
渐变表示一种颜色平滑过渡到另一种颜色。SVG有线性渐变`<linerGradient>`和放射性渐变`<radialGradient>`。

渐变也是定义在`<defs>`标签中。

```html
<svg width="600" height="300">
    <defs>
        <!-- 定义水平渐变 -->
        <linearGradient id="myGradient" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stop-color="#f00"></stop>
            <stop offset="100%" stop-color="#0ff"></stop>
        </linearGradient>
        <!-- 定义垂直渐变 -->
        <linearGradient id="myGradient2" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" stop-color="#f00"></stop>
            <stop offset="100%" stop-color="#0ff"></stop>
        </linearGradient>
    </defs>

    <!-- 水平线性渐变 -->
    <rect fill="url(#myGradient)" x="10" y="10" width="300" height="100"></rect>

    <!-- 垂直线性渐变 -->
    <rect fill="url(#myGradient2)" x="10" y="150" width="300" height="100"></rect>
</svg>
```
其中`x1`、`y1`、`x2`、`y2`定义渐变的方向。`offset`定义渐变开始的位置，`stop-color`定义此位置的颜色。

效果截图：
![](https://github.com/nitxs/public_docs/blob/master/image_hosting/19/190515_14.png?raw=true)
