1. 定义分页组件DOM

```javascript
<div id="pagination" class="pagination"></div>
```

2. 定义分页组件类及实例方法：

```javascript
// 分页组件类
function Pagination(_ref) {
    this.id = _ref.id;      //分页组件挂载的DOM节点
    this.curPage = _ref.curPage || 1; //初始页码
    this.draw = _ref.draw;      // 初始化分页请求次数
    this.pageSize = _ref.pageSize || 5; //分页个数
    this.pageLength = _ref.pageLength; //每页多少条
    this.pageTotal = 0; //总共多少页
    this.dataTotal = 0; //总共多少数据
    this.ajaxParam = _ref.ajaxParam;   // 分页ajax
    this.showPageTotalFlag = _ref.showPageTotalFlag || false; //是否显示数据统计
    this.showSkipInputFlag = _ref.showSkipInputFlag || false; //是否支持跳转
    this.ul = document.createElement('ul');

    this.init();
};

// 给实例对象添加公共属性和方法
Pagination.prototype = {
    init: function() {
        var pagination = document.getElementById(this.id);
        pagination.innerHTML = '';
        this.ul.innerHTML = '';
        pagination.appendChild(this.ul);
        var _this = this;
        _this.getPage(_this.curPage)
        .then( function( data ){
            //首页
            _this.firstPage();
            //上一页
            _this.lastPage();
            //分页
            _this.getPages().forEach(function (item) {
                var li = document.createElement('li');
                if (item == _this.curPage) {
                    li.className = 'active';
                } else {
                    li.onclick = function () {
                        _this.curPage = parseInt(this.innerHTML);
                        _this.init();
                    };
                }
                li.innerHTML = item;
                _this.ul.appendChild(li);
            });
            //下一页
            _this.nextPage();
            //尾页
            _this.finalPage();

            //是否支持跳转
            if (_this.showSkipInputFlag) {
                _this.showSkipInput();
            }
            //是否显示总页数,每页个数,数据
            if (_this.showPageTotalFlag) {
                _this.showPageTotal();
            }
        } )
        
    },
    // 分页数据请求
    getPage: function( curPage ){
        var _this = this;
        _this.draw++;
        return new Promise( function( resolve, reh ){
            $.ajax( {
                url: _this.ajaxParam.url,
                type: _this.ajaxParam.type,
                dataType: "json",
                data: {
                    curPage: curPage,
                    pageLength: 10,
                    draw: _this.draw
                },
                success: function(data) {
                    if( data.isSuccess === true ){
                        var data = data;
                        _this.pageTotal = Math.ceil( parseFloat( data.data.totalResult/_this.pageLength ) ),
                        _this.dataTotal = data.data.totalResult,
                        _this.draw = data.data.draw;
                        resolve( data )
                    }else {
                        reject( "请求错误" )
                    }
                },
                error: function(err) {
                    reject( err )
                }
            } )
        })
    },
    //首页
    firstPage: function() {
        var _this = this;
        var li = document.createElement('li');
        li.innerHTML = '首页';
        this.ul.appendChild(li);
        li.onclick = function () {
            var val = parseInt(1);
            _this.curPage = val;
            _this.init();
        };
    },
    //上一页
    lastPage: function() {
        var _this = this;
        var li = document.createElement('li');
        li.innerHTML = '<';
        if (parseInt(_this.curPage) > 1) {
            li.onclick = function () {
                _this.curPage = parseInt(_this.curPage) - 1;
                _this.init();
            };
        } else {
            li.className = 'disabled';
        }
        this.ul.appendChild(li);
    },
    //分页
    getPages: function() {
        var pag = [];
        if (this.curPage <= this.pageTotal) {
            if (this.curPage < this.pageSize) {
                //当前页数小于显示条数
                var i = Math.min(this.pageSize, this.pageTotal);
                while (i) {
                    pag.unshift(i--);
                }
            } else {
                //当前页数大于显示条数
                var middle = this.curPage - Math.floor(this.pageSize / 2),
                    //从哪里开始
                    i = this.pageSize;
                if (middle > this.pageTotal - this.pageSize) {
                    middle = this.pageTotal - this.pageSize + 1;
                }
                while (i--) {
                    pag.push(middle++);
                }
            }
        } else {
            console.error('当前页数不能大于总页数');
        }
        if (!this.pageSize) {
            console.error('显示页数不能为空或者0');
        }
        return pag;
    },
    //下一页
    nextPage: function() {
        var _this = this;
        var li = document.createElement('li');
        li.innerHTML = '>';
        if (parseInt(_this.curPage) < parseInt(_this.pageTotal)) {
            li.onclick = function () {
                _this.curPage = parseInt(_this.curPage) + 1;
                _this.init();
            };
        } else {
            li.className = 'disabled';
        }
        this.ul.appendChild(li);
    },
    //尾页
    finalPage: function() {
        var _this = this;
        var li = document.createElement('li');
        li.innerHTML = '尾页';
        this.ul.appendChild(li);
        li.onclick = function () {
            var yyfinalPage = _this.pageTotal;
            var val = parseInt(yyfinalPage);
            _this.curPage = val;
            _this.init();
        };
    },
    //是否支持跳转
    showSkipInput: function() {
        var _this = this;
        var li = document.createElement('li');
        li.className = 'totalPage';
        var span1 = document.createElement('span');
        span1.innerHTML = '跳转到';
        li.appendChild(span1);
        var input = document.createElement('input');
        input.setAttribute("type","number");
        input.onkeydown = function (e) {
            var oEvent = e || event;
            if (oEvent.keyCode == '13') {
                var val = parseInt(oEvent.target.value);
                if (typeof val === 'number' && val <= _this.pageTotal && val>0) {
                    _this.curPage = val;
                }else{
                    alert("请输入正确的页数 !")
                }
                _this.init();
            }
        };
        li.appendChild(input);
        var span2 = document.createElement('span');
        span2.innerHTML = '页';
        li.appendChild(span2);
        this.ul.appendChild(li);
    },
    //是否显示总页数,每页个数,数据
    showPageTotal: function() {
        var _this = this;
        var li = document.createElement('li');
        li.innerHTML = '共&nbsp' + _this.pageTotal + '&nbsp页';
        li.className = 'totalPage';
        this.ul.appendChild(li);
        var li2 = document.createElement('li');
        li2.innerHTML = '每页&nbsp' + _this.pageLength + '&nbsp条';
        li2.className = 'totalPage';
        this.ul.appendChild(li2);
        var li3 = document.createElement('li');
        li3.innerHTML = '共&nbsp' + _this.dataTotal + '&nbsp条数据';
        li3.className = 'totalPage';
        this.ul.appendChild(li3);
        var li4 = document.createElement('li');
        li4.innerHTML =  _this.curPage + "/" + _this.pageTotal;
        li4.className = 'totalPage';
        this.ul.appendChild(li4);
    }
};
```

3. 实例化分页组件

```javascript
let pageInstance = new Pagination({
    id: 'pagination',
    curPage:1,  // 初始页码,不填默认为1
    draw: 0,    // 当前渲染次数统计
    pageLength: 10,  //每页多少条
    pageSize: 5, //分页个数,不填默认为5
    showPageTotalFlag:true, //是否显示数据统计,不填默认不显示
    showSkipInputFlag:true, //是否支持跳转,不填默认不显示
    ajaxParam: {    //分页ajax
        url: 'https://www.easy-mock.com/mock/5cc6fb7358e3d93eff3d812c/page',
        type: "get",
    }
})
```