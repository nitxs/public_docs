# 介绍

买钢乐前端使用requirejs进行包管理，整合jquery、datatables、echarts、socketIO、jquery validate、dialog、select2等第三方插件，另有若干自写组件。所有这些组件均通过`\mgljs\app\util.js`导出整体组件对象`util`，在各业务js文件中通过`require(['util'], function(){ /*业务js*/ })`引入`util`对象来调用该对象中的组件方法。

## 页面引入框架js

在页面中引入框架js需按相应顺序引入：

```javascript
<script src="${ctx}/mgljs/app/util.js"></script>
<script src="${ctx}/mgljs/require.js"></script>
<script src="${ctx}/mgljs/config.js"></script>
<script src="${ctx}/js/common/mgui.js"></script>
```

## 常用组件如何调用

以下将介绍常用组件的调用，包含对应html和js，如涉及css，也会加以说明。

### 1.datatable表格组件及衍生功能组件

包含datatable组件、

```html
<div class="panel-control clearfix custom">
    <input type="hidden" id="confCode" value="${confCode}"/>
    <div class="search-opt pos-relative ui-pw20 ui-col search-fixation">
        <!-- 筛选项显示控制 -->
        <div class="ui-fr pos-relative custom-box custom-filter " id="customFilterBox">
            <span  class=" btn-custom btn-custom-filter" id="customFilterBtn"><i class="icon-searchlist"></i></span>
            <div class=" custom-box-ul custom-filter-ul">
                <div class="ui-pl10 ui-blue" style="height: 20px;">请选择主界面筛选项（<span class="ui-red" id="filterCount"></span>）
                </div>
                <ul id="customFilter">
                </ul>
                <div class="ui-col search-criter__btns ui-txt-center ui-border-t ui-pt12 ui-mt10">
                    <button type="button" class="ui-btn ui-btn-primary btn-custom-close  ">完成</button>
                </div>
            </div>
        </div>
        <!-- 表格列显隐控制 -->
        <div class="ui-fr pos-relative  custom-box custom-list" id="customListBox">
                <span type="button" class="btn-custom  btn-custom-list" id="customListBtn"><i class="icon-liebiaoshitucaidan"></i></span>
                <div class=" custom-box-ul  custom-list-ul">
                <div class="ui-pl10 ui-blue" style="height: 20px;">请选择需要显示的列表项</div>
                <div class="check-all-box"><label class="ui-mt4 ui-ml8 ui-mr12"><input type="checkbox" class="ui-check ui-checkbox list-check-all">全选/全不选</label></div>
                <ul class="custom-li" id="customList">
                </ul>
                <div class="ui-col search-criter__btns ui-txt-center ui-border-t ui-pt6 ui-mt6">
                    <button type="button" class="ui-btn ui-btn-primary btn-custom-close ">完成</button>
                </div>
            </div>
        </div>
        <div class="ui-ml30 ui-pr30" id="searchOptBox">
        <!-- 表格筛选项 -->
        <form id="searchForm" method="post" class="search-form">
            <input type="hidden" name="changeType" id="changeType" value="${changeType}">
            <input type="hidden" value="${startLockApplyDate}" id="startLockApplyDateId">
            <input type="hidden" value="${endLockApplyDate}" ID="endLockApplyDateId">
            <!-- 筛选条件 -->
            <div class="ui-col search-criter filters-wrap">
                <div class="ui-col search-criter__btns">
                    <button type="button" class="ui-btn ui-btn-primary btn-search-data ui-mr10">查询</button>
                    <button type="button" class="ui-btn ui-btn-white" onclick="window.location.reload()">重置</button>
                </div>
            </div>
        </form>
        </div>
    </div>

    <div class="ui-col slide-overflow">
        <div class="main-cnt-scroll">
            <!-- 表格主体 -->
            <table class="ui-table" id="dataTableIndex">
                <thead>
                    <tr>
                        <th width="50px"><span><input type="checkbox" class="ui-check check-all"></span></th>
                        <th width="60px"  data-index="1"><span></span></th>
                        <th width="180px" data-index="2"><span>锁货时间</span></th>
                        <th width="180px" data-index="3"><span>买方</span></th>
                        <th width="80px" data-index="4"><span>销售基价</span></th>
                        <th width="80px" data-index="5"><span>升贴水</span></th>
                        <th width="80px" data-index="6"><span>合计卷价</span></th>
                        <th width="100px" data-index="7"><span>配送方式</span></th>
                        <th width="100px" data-index="8"><span>成交渠道</span></th>
                        <th width="100px" data-index="9"><span>商城挂货与否</span></th>
                        <th width="180px" data-index="10"><span>创建销售合同否</span></th>
                        <th width="120px" data-index="11"><span>规格</span></th>
                        <th width="100px" data-index="12"><span>参厚</span></th>
                        <th width="100px" data-index="13"><span>重量</span></th>
                        <th width="130px" data-index="14"><span>所在仓库</span></th>
                        <th width="100px" data-index="15"><span>等级</span></th>
                        <th width="140px" data-index="16"><span>卷号</span></th>
                        <th width="120px" data-index="17"><span>钢厂</span></th>
                        <th width="120px" data-index="18"><span>材质/表面</span></th>
                        <th width="80px" data-index="19"><span>长度</span></th>
                        <th width="120px" data-index="20"><span>公差范围</span></th>
                        <!-- <th width="120px" data-index="20"><span>理算厚度</span></th> -->
                        <th width="120px" data-index="21"><span>实测100mm厚度</span></th>
                        <th width="120px" data-index="22"><span>垛位</span></th>
                        <th width="80px" data-index="23"><span>垫纸Y/N</span></th>
                        <th width="80px" data-index="24"><span>套筒Y/N</span></th>
                        <th width="80px" data-index="25"><span>保证面</span></th>
                        <th width="100px" data-index="26"><span>发货计划</span></th>
                        <th width="100px" data-index="27"><span>发货单状态</span></th>
                        <th width="100px" data-index="28"><span>配车状态</span></th>
                        <th width="140px" data-index="29"><span>车牌号</span></th>
                        <th width="200px" data-index="30"><span>司机</span></th>
                        <th width="200px" data-index="31"><span>司机身份证</span></th>
                        <th width="260px" data-index="32"><span>收货地址</span></th>
                        <th width="180px" data-index="33"><span>收货联系人</span></th>
                        <th width="180px" data-index="34"><span>更新时间</span></th>
                        <th width="120px" data-index="35"><span>区域</span></th>
                        <th width="120px" data-index="36"><span>货物状态</span></th>
                    </tr>
                </thead>
            </table>
        </div> 
    </div>
</div>

<script>
// 列数据配置，配为data值；如果data值为null,则需在columnDefs数组中对该列进行具体数据配置
var columns=[
    {'data': null, 'sName': 'ck'},
    {'data': null},             // 显示“申请锁定中”和“已锁定”状态标记
    {'data': 'lockApplyDate'},      // 锁货时间
    {'data': 'buyUser'},      // 买方
    {'data': 'lockBasicPrice'},      // 销售基价
    {'data': 'floatPrice'},      // 升贴水    floatPrice
    {'data': 'dealPrice'},      // 合计卷价  dealPrice
    {'data': null},      // 配送方式
    {'data': null},      // 成交渠道
    {'data': null},        // 商城挂货与否
    {'data': 'saleContractNo'},        // 创建销售合同否
    {'data': null, 'sName': 'spec'},       // 规格（厚度*实宽*C）
    {'data': 'realThick'},      //参厚
    {'data': 'weight'},         // 重量
    {'data': 'dptName'},         // 所在仓库
    {'data': 'grade'},          // 等级
    {'data': 'volume'},          // 卷号
    {'data': 'mnfctName'},      //钢厂 
    {'data': null, 'sName': 'qualityAndSurface'},   // 材质表面
    {'data': 'acidLength'},     // 冷酸卷长度
    // {'data': 'stdThick'},     // 厚度
    {'data': 'tolerance'},     // 公差
    // {'data': 'adjustThick'},     // 理算厚度
    {'data': 'thickOhmm'},     // 理算厚度
    {'data': 'stackPosition'},         // 垛位
    {'data': 'packingPaper'},         // 垫纸
    {'data': 'sleeve'},   // 套筒
    {'data': 'assureSurface'},     // 保证面
    {'data': null, 'sName': 'deliveryStatus'},     // 发货计划状态
    {'data': null, 'sName': 'goodsDeliveryStatus'},     // 发货状态
    {'data': null, 'sName': 'matchStatus'},     // 配车状态
    {'data': 'takeCarNo'},     // 车牌号
    {'data': null, 'sName': 'driver'},     // 司机
    {'data': 'takeIdNo'},     // 司机身份证
    {'data': null, 'sName': 'address'},     // 收货地址
    {'data': null, 'sName': 'receivePerson'},     // 收货联系人
    {'data': 'uploadDate'},     // 更新时间
    {'data': 'area'},         // 区域
    {'data': null, 'sName': 'goodsStatus'},     // 货物状态
];
// 表格列
var columnDefs = [
    // {    // 这里配置某些项不进行排序
    //     orderable: false,
    //     targets: [0, 1]
    // },
    {
        targets: [0],
        render: function(data, type, full) {
            var html = '';
            html += '<input type="checkbox" class="ui-check ch-list" value="'+ data.goodsId +'">';
            html += "<input type='hidden' class='hid-weight' value='"+ data.weight +"'>"
            html += "<input type='hidden' class='hid-uploadUser' value='"+ data.uploadUser +"'>"
            html += "<input type='hidden' class='hid-goodsStatus' value='"+ data.goodsStatus +"'>"
            html += "<input type='hidden' class='hid-buyUser' value='"+ data.buyUser +"'>"
            html += "<input type='hidden' class='hid-lockBasicPrice' value='"+ util.replaceSpace(data.lockBasicPrice, '') +"'>"
            return html;
        }
    },
    {
        targets: [1],
        render: function(data, type, full) {
            var html = '';
            html += '<span></span>';
            return html;
        }
    },
    {
        targets: [7],
        render: function(data, type, full) {
            var html = '';
            if( data.deliveryType === 'A' ){
                html += '<span>买钢乐配送</span>';
            }else if( data.deliveryType === 'B' ){
                html += '<span>钢厂配送</span>';
            }else if( data.deliveryType === 'C' ){
                html += '<span>买方自提</span>';
            }
            return html;
        }
    },
    {
        targets: [8],
        render: function(data, type, full) {
            var html = '';
            if( data.dealType === 'A' ){
                html += '<span>商城</span>';
            }else if( data.dealType === 'B' ){
                html += '<span>线下</span>';
            }
            return html;
        }
    },
    {
        targets: [9],
        render: function(data, type, full) {
            var html = '';
            if( data.mallPublish === 'Y' ){
                html += '<span>挂货成功</span>';
            }else if( data.mallPublish === 'N' ){
                html += '<span>--</span>';
            }
            return html;
        }
    },
    {
        targets: [11],
        render: function(data, type, full) {
            var html = '';
            html += '<span>';
            if( data.stdThick ){
                html += data.stdThick + '*';
            }
            if( data.realWidth ){
                html += data.realWidth + '*';
            }
            html += 'C</span>';
            return html;
        }
    },
    {
        targets: [18],
        render: function(data, type, full) {
            var html = '';
            html += '<span>'+ data.quality + '/' + data.surface +'</span>';
            return html;
        }
    },
    {
        targets: [26],
        render: function(data, type, full) {
            var html = '';
            if( data.deliveryStatus === 'Y' ){
                html += '<span>已加入</span>';
            }else if( data.deliveryStatus === 'N' ){
                html += '<span>--</span>';
            }
            
            return html;
        }
    },
    {
        targets: [27],
        render: function(data, type, full) {
            var html = '';
            if( data.goodsDeliveryStatus === 'Y' ){
                html += '<span>已开发货单</span>';
            }else if( data.goodsDeliveryStatus === 'N' ){
                html += '<span>--</span>';
            }
            
            return html;
        }
    },
    {
        targets: [28],
        render: function(data, type, full) {
            var html = '';
            if( data.deliveryType === 'A' ){
                if( data.matchStatus === 'Y' ){
                    html += '<span>已配</span>';
                }else if( data.matchStatus === 'N' ){
                    html += '<span>未配</span>';
                }else {
                    html += '<span>--</span>'
                }
            }else if( data.deliveryType === 'B' || data.deliveryType === 'C' ){
                html += '<span>--</span>';
            }
            
            return html;
        }
    },
    {
        targets: [30],
        render: function(data, type, full) {
            var html = '';
            if( data.takeDriver || data.takeMobile ){
                html += '<span>'+ util.replaceSpace( data.takeDriver, '--' ) + ' ' + util.replaceSpace( data.takeMobile, '--' ) +'</span>';
            }else {
                html += '<span>--</span>';
            }
            
            return html;
        }
    },
    {
        targets: [32],
        render: function(data, type, full) {
            var html = '';
            html += '<span>'+ util.replaceSpace( data.receiveProvince, '' ) + util.replaceSpace( data.receiveCity, '' )+ util.replaceSpace( data.receiveCounty, '' )+ util.replaceSpace( data.receiveAddress, '' ) +'</span>';
            return html;
        }
    },
    {
        targets: [33],
        render: function(data, type, full) {
            var html = '';
            if( data.receivePerson || data.receiveMobile ){
                html += '<span>'+ util.replaceSpace( data.receivePerson, '--' ) + ' ' + util.replaceSpace( data.receiveMobile, '--' ) +'</span>';
            }else {
                html += '<span>--</span>'
            }

            return html;
        }
    },
    {
        targets: [36],
        render: function(data, type, full) {
            var html = '';
            if( data.goodsStatus === 'A' ){
                html += '<span>待售</span>';
            }else if( data.goodsStatus === 'B' ){
                html += '<span>锁货中</span>';
            }else if( data.goodsStatus === 'C' ){
                html += '<span>锁货成功</span>';
            }else if( data.goodsStatus === 'D' ){
                html += '<span>已售</span>';
            }else if( data.goodsStatus === 'E' ){
                html += '<span>删除</span>';
            }else if( data.goodsStatus === 'W' ){
                html += '<span>锁货失败</span>';
            }

            return html;
        }
    },
]

// datatables表格配置主体
util.datatable({
    selector: '#dataTableIndex',
    fixedColumns: {     // 控制表格列固定
        leftColumns: 1
    },
    ajax: {     // ajax获取列表数据
        url: ctx + '/rollMyLockResource/page',
        type: 'post',
        data: function(d){
            var frm_data = $('#searchForm').serializeArray();
            var dAll = '', dName = '', dPrecount = '';
            var moreArray='';
            $.each(frm_data, function(key, val) {
                dName = val.name;
                d[val.name] = val.value;
                if(key > 0) {
                    dPrecount = frm_data[key-1].name;
                    if(dName == dPrecount) {
                        moreArray += ',' + frm_data[key].value;
                        d[val.name] = moreArray;
                    }else{
                        moreArray=val.value
                    }
                }else{
                    moreArray=val.value
                }
                dAll += d[val.name] + ',';
            });
            dAll = dAll.substring(0, dAll.length-1);
            for (var i = 0; i < d.columns.length; i++) {
                column = d.columns[i];
                column.searchRegex = column.search.regex;
                column.searchValue = column.search.value;
                delete(column.search);
            }
        },
    },
    ordering: false,    // 整体表格禁用排序
    columns: columns,
    columnDefs: columnDefs,
    tableComplete: function(listDataTable){
        // 按钮全选绑定事件
        util.checkAll({
            itemBoxClass: '.datatable-index',
            checkAllClass: '.check-all',
            checkDomClass: '.ch-list',
            checkAllOn: function() {
                $('.btn-opt-dis').attr('disabled', false);
            },
            checkAllOff: function() {
                $('.btn-opt-dis').attr('disabled', true);
            }
        });
    },
    tableInit:function(listDataTable){
        //-----------------
        // 客户-列与筛选项自定义配置
        //-----------------
        util.tableListControl({
            confCode: 'CRM_SHARENEWRESOURCE_TODAY',
            listDataTable: listDataTable,
            ignoreCol: ['ck'],
            specialSearchShow: true
        });
    },
    createdRow: function( row, data, dataIndex ){
        // 创建行时的回调
    },
    drawCallback: function( settings, json ){
        // 列表重绘时的回调
    },
});
</script>
```

### 2.筛选组件配置

```html
<div class="ui-ml30 ui-pr30" id="searchOptBox">
    <form id="searchForm" method="post" class="search-form">
        <input type="hidden" name="changeType" id="changeType" value="${changeType}">
        <input type="hidden" value="${startLockApplyDate}" id="startLockApplyDateId">
        <input type="hidden" value="${endLockApplyDate}" ID="endLockApplyDateId">
        <!-- 筛选条件 -->
        <div class="ui-col search-criter filters-wrap">
            <div class="ui-col search-criter__btns">
                <button type="button" class="ui-btn ui-btn-primary btn-search-data ui-mr10">查询</button>
                <button type="button" class="ui-btn ui-btn-white" onclick="window.location.reload()">重置</button>
            </div>
        </div>
    </form>
</div>

<script>
util.filterComponents({
    filterItemArr: [
        [{
            defaultShow: true,
            dataName: 'lockApplyDate',
            labelName: '锁货时间',
            formType: 'date',
            formStartStyleClass: 'ui-col-50 ui-mr10',
            formEndStyleClass: 'ui-col-45',
            formStartClass: 'daterange-start',  // 调取日期组件的开始class
            formEndClass: 'daterange-end',      // 调取日期组件的结束class
            formStartPlaceHolder: '开始时间',
            formEndPlaceHolder: '结束时间',
            formStartName: 'startLockApplyDate',    // startname
            formEndName: 'endLockApplyDate',        // endname
            formDefaultStartDate: $("#startLockApplyDateId").val(),   // 设置默认开始日期
            formDefaultEndDate: $("#endLockApplyDateId").val(),      // 设置默认结束日期
        }],
        [{
            defaultShow: true,
            dataName: 'buyUser',
            labelName: '买方',
            formType: 'text',
            formPlaceHolder: '请输入买方',
            formName: 'buyUser',    // name
        },{
            defaultShow: true,
            dataName: 'area',
            labelName: '区域',
            formType: 'select',
            formName: 'area',       // 下拉name
            options: [
                {val: '', text: '全部'},
                {val: '无锡', text: '无锡'},
                {val: '佛山', text: '佛山'}
            ]
        },{
            dataName: 'lockUser',
            labelName: '业务员',
            formType: 'select',
            formClass: 'lock-users',    // 下拉option通过ajax获取后插入html的class选择器
            formName: 'lockUser',   // 下拉name
        }],
        [{
            dataName: 'realThick',
            labelName: '参厚范围',
            formType: 'intervalText',
            formMinPlaceHolder: '',
            formMaxPlaceHolder: '',
            formWidth: '300',
            formMinName: 'startRealThick',  // 区间startname
            formMaxName: 'endRealThick',    // 区间endname
        }],
        [{
            dataName: 'realThickStr',
            labelName: '参厚',
            formType: 'text',
            formWidth: '600',
            formClass: 'real-thick-str',
            formPlaceHolder: '搜多个参厚，按空格键或enter键隔开，如“0.506,0.761,0.884”',
            formName: 'realThickStr',
        }]
    ]
})

!function(){
    $.ajax({
        url: ctx + '/newShareResourceBase/select',
        type: 'POST',
        success: function(data){
            if(data.isSuccess === 'true'){
                var arr = data.dptNameList;
                var html = '';
                arr.forEach(function(val){
                    html += '<option value='+ val +'>'+ val +'</option>'
                })
                // 向select项中插入option
                $( ".lock-users" ).append( html )
            }
        }
    })
})
}
</script>
```

### 3.详情页组件

```html
<!-- 详情页的html就不放了，直接看项目中详情页，可全盘复制 -->
<script>
util.slideDetail({
    selector: '.table-list td:not(:first-child)',
    url: ctx + '/myNewContract/detail',     // 详情页跳转地址
    isLoad: true,
    data: { changeDetailType: $('#changeType').val() },
    slideInit: function(_this, el) {
        // tab切换
        util.swiperTab({
            tabNavClass: '.swiper-navgation',
            containerClass: '.tab-container',
            simulateTouch: false,
            speed: 0
        });
    },
    slideComplete: function(_t, el) {   // 详情页面加载完成时回调函数
        var contractIdVal = $(_t).parents('tr').find('.ch-list').val();
        // 赋值详情页id
        $('#detailID').val(contractIdVal);
        $('#contractStatusHid').val($(_t).parents('tr').find('.hid-status').val());
        $('#contractTypeHid').val($(_t).parents('tr').find('.hid-type').val());
        $('#currentFutureHid').val($(_t).parents('tr').find('.hid-currentFuture').val());
        $('#futureOutStatusHid').val($(_t).parents('tr').find('.hid-futureOutStatus').val());
        $('#urlFirmIdHid').val($(_t).parents('tr').find('.hid-firmId').val());
        //$('#changeDetailType').val($('#changeType').val());
        // 分布请求数据: type -> 页面状态。id -> 数据id
        getDeatilTabType($('#detailTabType').val(), contractIdVal);
    }
});

//-----------------------
// 详情tab切换，分步请求数据
//-----------------------
function getDeatilTabType(type, id) {
    id = id || $('#detailID').val();
    type = type || 'A';
    // 客户信息（加载头部）
    getMainInfo(id);
    shouDetailBtns();
    switch (type) {
        case 'A':   // tab为A时
            $('#detailTabType').val(type);
            // 概要
            break;
        case 'B':   // tab为B时
            $('#detailTabType').val(type);
            getGoodsDetail( id )
            break;
        case 'C':
            $('#detailTabType').val(type);
            getOtherDetail(id);
            break;
        case 'D':
            $('#detailTabType').val(type);
            getFutureDetail(id);
            break;
        case 'E':
            $('#detailTabType').val(type);
            selectBatchContractDetail(id);
            break;
    }
}
</script>
```

### 4.弹窗组件

```javascript
util.dialog({
    fixed: true,
    skin: 'crm-form',
    title: '删除',
    content: html,  // 变量html为弹窗中内容的html字符串
    okValue: '确认',
    ok: function () {   // 点击确认按钮提交时执行的回调
        $.ajax({
            url : ctx + '/newContractBase/deleteContract',
            type : 'post',
            data: {
                contractIdStr: $( "#detailID" ).val()
            },
            success : function(data) {
                if (data.isSuccess === 'true') {
                    setTimeout(function(){
                        window.location.reload();
                    }, 850)
                }
                util.promptMsg({
                    content: data.msg
                });
            }
        });
    },
    cancelValue: '取消',
    cancel: function() {},
    onshow: function(){
        // 弹窗打开时的回调，一般弹窗中的表单校验、方法定义均在这个回调里定义。
    }
});
```