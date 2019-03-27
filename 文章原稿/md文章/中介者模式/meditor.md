中介者对象践行了最少知识原则，指一个对象尽可能少的了解别的对象，从而尽量减少对象间耦合程度。这样各个对象只需关注自身实现逻辑，对象间的交互关系交由中介者对象来实现和维护。

需求背景：

手机购买页面，在购买流程中，可以选择手机的颜色及输入购买数量，同时页面有两个展示区域，分别向用户展示刚选择好的颜色和数量。还有一个按钮动态显示下一步的操作，我们需要查询该颜色手机对应的库存，如果库存数量少于这次购买的数量，按钮将被禁用并显示库存不足，反之按钮可以点击并显示放入购物车。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>中介者模式 购买商品</title>
</head>
<body>
    选择颜色： 
    <select id="colorSelect">
        <option value="">请选择</option>
        <option value="red">红色</option>
        <option value="blue">蓝色</option>
    </select>

    输入购买数量：
    <input type="text" id="numberInput">

    您选择了颜色：<div id="colorInfo"></div><br>
    您输入了数量：<div id="numberInfo"></div><br>

    <button id="nextBtn" disabled>请选择手机颜色和购买数量</button>
    
</body>
<script>

// 最初级的写法
var colorSelect = document.getElementById('colorSelect'),
    numberInput = document.getElementById('numberInput'),
    colorInfo = document.getElementById('colorInfo'),
    numberInfo = document.getElementById('numberInfo'),
    nextBtn = document.getElementById('nextBtn');

var goods = {
    'red': 3,
    'blue': 6
}

colorSelect.onchange = function(){
    var color = this.value,
        number = numberInput.value,
        stock = goods[color]

    colorInfo.innerHTML = color;

    if(!color){
        nextBtn.disabled = true;
        nextBtn.innerHTML = '请选择手机颜色';
        return;
    }

    if( ( (number-0) | 0 ) !== number-0 ){      //用户输入的购买数量是否为正整数
        nextBtn.disabled = true;
        nextBtn.innerHTML = '请输入正确的购买数量';
        return;
    }

    if(number > stock){     //当前选择数量大于库存量
        nextBtn.disabled = true;
        nextBtn.innerHTML = '库存不足';
        return;
    }

    nextBtn.disabled = false;
    nextBtn.innerHTML = '放入购物车';
}

numberInput.oninput = function(){
    var color = colorSelect.value,
        number = this.value,
        stock = goods[color]

    colorInfo.innerHTML = color;

    if(!color){
        nextBtn.disabled = true;
        nextBtn.innerHTML = '请选择手机颜色';
        return;
    }

    if( ( (number-0) | 0 ) !== number-0 ){      //用户输入的购买数量是否为正整数
        nextBtn.disabled = true;
        nextBtn.innerHTML = '请输入正确的购买数量';
        return;
    }

    if(number > stock){     //当前选择数量大于库存量
        nextBtn.disabled = true;
        nextBtn.innerHTML = '库存不足';
        return;
    }

    nextBtn.disabled = false;
    nextBtn.innerHTML = '放入购物车';
}


</script>
</html>
```

在上个示例中，对象间联系高度耦合，只是两个输入框还好，但如果有多个的话，相互联系就非常复杂了，此时就要考虑用到中介者模式。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>中介者模式 购买商品</title>
</head>
<body>
    选择颜色： 
    <select id="colorSelect">
        <option value="">请选择</option>
        <option value="red">红色</option>
        <option value="blue">蓝色</option>
    </select>

    选择内存： 
    <select id="memorySelect">
        <option value="">请选择</option>
        <option value="32G">32G</option>
        <option value="16G">16G</option>
    </select>

    输入购买数量：
    <input type="text" id="numberInput">

    您选择了颜色：<div id="colorInfo"></div><br>
    您选择了内存：<div id="memoryInfo"></div><br>
    您输入了数量：<div id="numberInfo"></div><br>

    <button id="nextBtn" disabled>请选择手机颜色、内存和购买数量</button>
</body>
<script>
    var goods = {
        'red|32G': 3,
        'red|16G': 0,
        'blue|32G': 1,
        'blue|16G': 6
    }

    //引入中介者
    var mediator = (function(){
        var colorSelect = document.getElementById('colorSelect'),
            memorySelect = document.getElementById('memorySelect'),
            numberInput = document.getElementById('numberInput'),
            colorInfo = document.getElementById('colorInfo'),
            memoryInfo = document.getElementById('memoryInfo'),
            numberInfo = document.getElementById('numberInfo'),
            nextBtn = document.getElementById('nextBtn');

        return {
            changed: function(obj){
                var color = colorSelect.value,
                    memory = memorySelect.value,
                    number = numberInput.value,
                    stock = goods[color + '|' + memory];

                if(obj == colorSelect){      //如果改变的是选择颜色下拉框
                    colorInfo.innerHTML = color;
                }else if(obj == memorySelect){
                    memoryInfo.innerHTML = memory;
                }else if(obj == numberInput){
                    numberInfo.innerHTML = number;
                }

                if(!color){
                    nextBtn.disabled = true;
                    nextBtn.innerHTML = '请选择手机颜色';
                    return;
                }

                if(!memory){
                    nextBtn.disabled = true;
                    nextBtn.innerHTML = '请选择手机内存';
                    return;
                }

                if(!number){
                    nextBtn.disabled = true;
                    nextBtn.innerHTML = '请填写手机数量';
                    return;
                }

                if( ( (number-0) | 0 ) !== number-0 ){      //用户输入的购买数量是否为正整数
                    nextBtn.disabled = true;
                    nextBtn.innerHTML = '请输入正确的购买数量';
                    return;
                }

                if(number > stock){     //当前选择数量大于库存量
                    nextBtn.disabled = true;
                    nextBtn.innerHTML = '库存不足';
                    return;
                }

                nextBtn.disabled = false;
                nextBtn.innerHTML = '放入购物车';
            }
        }
    })()

    colorSelect.onchange = function(){
        mediator.changed(this)
    }

    memorySelect.onchange = function(){
        mediator.changed(this)
    }

    numberInput.oninput = function(){
        mediator.changed(this)
    }

    //以后如果想要再增加选项，如手机CPU之类的，只需在中介者对象里加上相应配置即可。
</script>
</html>
```

>在实际开发中，还是要注意选择利弊，中介者对象因为包含对象间交互的复杂性，所以维护成本可能也会较高。在实际开发中，最优目的还是要快速完成项目交付，而非过度设计和堆砌模式。有时对象间的耦合也是有必要的，只有当对象间复杂耦合确实已经导致调用与维护难以为继，才考虑用中介者模式。

