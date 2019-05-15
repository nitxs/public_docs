
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