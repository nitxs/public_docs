1. 先定义小程序中要施加渐入动画的DOM元素，注意该元素的css样式里要添加下`opaction`属性，通常设为0，意为从全透明开始渐入。另外还需要根据实际场景设定该元素的`left`或`right`值，以供动画方法定义滑动距离。

```wxml
<view class="animation-class" animation="slideleft">向左滑入渐入动画DOM元素</view>
```

2. 定义小程序内公共动画方法

```javascript
// animation.js
/**
 * X轴滑动渐入动画
 */
function fadeXAnimation( _this, param, px, opacity ){
  let animation = wx.createAnimation({
    duration: 800,
    timingFunction: "ease"
  })
  animation.translateX( px ).opacity( opacity ).step();
  // 将param转换为key
  let json = '{"'+ param +'":""}';
  json = JSON.parse( json );
  json[param] = animation.export();
  // 设置动画
  _this.setData( json );
}

module.exports = {
  fadeXAnimation: fadeXAnimation
}
```

3. 业务代码js中引入公共动画方法js文件，并选择符合自身业务场景的地方调用动画方法，这里我选择`onshow`生命周期内执行动画方法，另外也可以将该方法放到定时器中延时执行或在`wx.createAnimation`方法中定义`delay`延时。

```javascript
// index.js
const animation = require('../../utils/tools/animation.js')

onshow(){
    animation.fadeXAnimation(this, "slide_left_locks", -100, 1);
}
```

可以在此基础上，添加Y轴渐入、渐出等动画。微信小程序动画API还支持旋转、放大等，方法的套路都差不多。