<#-- importJavaScript -->
<#macro importJavaScript>
<script src="${base}/js/jquery/jquery-2.1.4.js"></script>
<script src="${base}/js/jquery/jquery-ui-1.11.4.js"></script>
<script src="${base}/js/jquery/jquery.treetable-3.2.0.js"></script>
<script src="${base}/js/jquery/jquery.backstretch.min.js"></script>
<script src="${base}/js/jquery/jquery-md5.js"></script>
<script src="${base}/js/bootstrap.min-3.3.5.js"></script>
<script src="${base}/js/jquery/bootbox.min.js"></script>
<script src="${base}/js/scripts.js"></script>
<style>
    .liu{display:none;height:370px;!important}
</style>
</#macro>

<#-- importMenuInfo -->
<#macro importMenuInfo menuInfo>
<ul class="nav navbar-nav">
    <#assign text>
    ${userInfo}
    </#assign>
    <#assign json=text?eval />
    <#if json.isLogin == '1'>
        <li><a name="menuUrl" href="#" url="user/useDoc/${json.uid}">使用说明</a></li>
        <li><a name="menuUrl" href="#" url="user/">告警配置</a></li>
    </#if>
</ul>
</#macro>

<#macro importHeaderInfo userInfo>
<input type="hidden" id="baseUrl" value="${base}">
<input type="hidden" id="traceId" value="${traceId!''}">
<div class="navbar navbar-inverse navbar-fixed-top">
    <div class="container">
        <div class="navbar-header">
            <a class="navbar-brand" href="./">Sky Walking</a>
        </div>
        <div class="collapse navbar-collapse">
            <@common.importSearchInfo isLogin="${userInfo}" />
        <@common.importUserInfo userInfo="${userInfo}" />
        </div>
    </div>
</div>
</#macro>

<#-- importSearchInfo -->
<#macro importSearchInfo isLogin>
    <#assign text>
    ${userInfo}
    </#assign>
    <#assign json=text?eval />
<form class="navbar-form navbar-left" role="search">
    <div class="form-group">
        <#if json.isLogin == '1'>
            <input id="srchKey" type="text" class="form-control" style="width: 750px" placeholder="TraceId">
        <#else>
            <input id="srchKey" type="text" class="form-control" style="width: 750px" placeholder="TraceId">
        </#if>
    </div>
    <button id="srchBtn" type="button" class="btn btn-default">Search</button>
</form>
</#macro>

<#-- importUserInfo -->
<#macro importUserInfo userInfo>
<ul class="nav navbar-nav navbar-right">
    <#assign text>
    ${userInfo}
    </#assign>
    <#assign json=text?eval />
    <#if json.isLogin == '1'>
        <li class="dropdown">
            <a href="javascript:void(0);" class="dropdown-toggle"
               data-toggle="dropdown" role="button" aria-haspopup="true"
               aria-expanded="false"> ${json.userName!} <span class="caret"></span></a>
            <ul class="dropdown-menu">
                <#if json.menuList??>
                    <#list json.menuList?eval as menu>
                        <li><a name="menuUrl" href="javascript:void(0);" url="${menu.url!}">${menu.menuName!}</a></li>
                    </#list>
                    <li role="separator" class="divider"></li>
                </#if>
                <li><a id="logout" href="javascript:void(0);" url="logout">退出</a></li>
            </ul>
        </li>
    <#else>
        <li><a id="login" href="${base}/login">登录</a></li>
        <li><a id="regist" name="menuUrl" href="${base}/regist">注册</a></li>
    </#if>
</ul>
</#macro>

<#-- dealTraceLog -->
<#macro dealTraceLog>
    <#if valueList??>
    <div id="row" style="overflow:hidden">
        <div class="col-md-12" style="overflow:hidden">
            <h5 style="color:white">
                ${traceId!}</br>
                调度入口IP：${(valueList[0].address)!}，开始时间：${beginTime?number_to_datetime}，${(valueList?size)!}条调用记录，消耗总时长：${(endTime - beginTime)!'0'}
                ms。<a id="originLog" href="javascript:void(0);">显示原文</a>
            </h5>
            <div id="tableDiv">
                <table id="example-advanced">
                    <caption>
                        <button type="button" class="btn btn-success" href="#"
                                onclick="jQuery('#example-advanced').treetable('expandAll'); return false;">Expand all
                        </button>
                        &nbsp;
                        <button type="button" class="btn btn-warning" href="#"
                                onclick="jQuery('#example-advanced').treetable('collapseAll'); return false;">Collapse
                            all
                        </button>
                    </caption>
                    <thead>
                    <tr>
                        <th style="width: 25%">服务名</th>
                        <th style="width: 5%">类型</th>
                        <th style="width: 5%">状态</th>
                        <th style="width: 20%">服务/方法</th>
                        <th style="width: 15%">主机信息</th>
                        <th style="width: 30%">时间轴</th>
                    </tr>
                    </thead>
                    <tbody>
                        <#list valueList as logInfo>
                            <#if logInfo.colId == "0">
                            <tr name='log' statusCodeStr="${logInfo.statusCodeStr!}" data-tt-id='${logInfo.colId!}'>
                            <#else>
                            <tr name='log' statusCodeStr="${logInfo.statusCodeStr!}" data-tt-id='${logInfo.colId!}'
                                data-tt-parent-id='${logInfo.parentLevel!}'>
                            </#if>
                            <td><b>${logInfo.applicationIdStr!}</b></td>
                            <td>${logInfo.spanTypeName!'UNKNOWN'}</td>
                            <td>${logInfo.statusCodeName!'MISSING'}</td>
                            <td>
                                <a href="#" name="detailInfo" data-toggle="tooltip" data-placement="bottom"
                                   title="${logInfo.viewPointId!}">${logInfo.viewPointIdSub!}</a>
                            </td>
                            <td>${logInfo.address!}</td>
                            <td>
                                <#assign totalTime=(endTime-beginTime)*1.15>
                                <div class="progress">
                                    <#if (logInfo.timeLineList?size=1)>
                                        <#list logInfo.timeLineList as log>
                                            <input type="hidden" beginTime="${beginTime}" endTime="${endTime}"
                                                   total_time="${totalTime}" cost="${log.cost}"
                                                   curStartTime="${log.startTime}"
                                                   beforePer="${100*(log.startTime-beginTime)/totalTime}"
                                                   curPer="${100*log.cost/totalTime}">
                                            <div class="progress-bar"
                                                 style="width: ${100*(log.startTime-beginTime)/totalTime}%"></div>
                                            <div class="progress-bar progress-bar-b progress-bar-striped"
                                                 style="color:black;min-width: ${100*log.cost/totalTime}%;"></div>
                                            <div class="progress-bar progress-split progress-bar-striped"
                                                 style="color:black;">&nbsp;${log.cost}ms
                                            </div>
                                        </#list>
                                    </#if>

                                    <#if (logInfo.timeLineList?size=2)>
                                        <#if (logInfo.timeLineList[1].startTime) < (logInfo.timeLineList[0].startTime)>
                                        <#--服务端开始时间 小于 客户端开始时间(异常,直接显示服务端时间轴)-->
                                            <#assign a=(logInfo.timeLineList[1].startTime - beginTime)! />
                                            <#assign b=(logInfo.timeLineList[1].cost)! />
                                            <input type="hidden" a="${a!}" b="${b!}" beginTime="${beginTime!}"
                                                   totalTime="${totalTime!}">
                                            <div class="progress-bar" style="width: ${100*(a)/totalTime}%"></div>
                                            <div class="progress-bar progress-bar-b progress-bar-striped"
                                                 style="color:black;min-width: ${100*(b)/totalTime}%;"></div>
                                            <div class="progress-bar progress-split progress-bar-striped"
                                                 style="color:black;">&nbsp;${b}ms
                                            </div>
                                        <#elseif (logInfo.timeLineList[1].startTime >= logInfo.timeLineList[0].startTime) && ((logInfo.timeLineList[1].startTime) <= (logInfo.timeLineList[0].startTime + logInfo.timeLineList[0].cost))>
                                        <#--服务端开始时间 大于等于 客户端开始时间,并且 小于等于 客户端的结束时间-->
                                            <#if (logInfo.timeLineList[1].startTime + logInfo.timeLineList[1].cost) <= (logInfo.timeLineList[0].startTime + logInfo.timeLineList[0].cost)>
                                            <#--服务端结束时间 小于等于 客户端结束时间(客户端时间段包含服务端时间段)-->
                                                <#assign a=(logInfo.timeLineList[0].startTime - beginTime)! />
                                                <#assign b=(logInfo.timeLineList[1].startTime - logInfo.timeLineList[0].startTime)! />
                                                <#assign c=(logInfo.timeLineList[1].startTime + logInfo.timeLineList[1].cost - logInfo.timeLineList[1].startTime)! />
                                                <#assign d=(logInfo.timeLineList[0].startTime + logInfo.timeLineList[0].cost - logInfo.timeLineList[1].startTime - logInfo.timeLineList[1].cost)! />
                                                <input type="hidden" a="${a!}" b="${b!}" c="${c!}" d="${d!}"
                                                       beginTime="${beginTime!}" totalTime="${totalTime!}">
                                                <div class="progress-bar" style="width: ${100*(a)/totalTime}%"></div>
                                                <div class="progress-bar progress-bar-b progress-bar-striped"
                                                     style="color:black;min-width: ${100*(b)/totalTime}%;"></div>
                                                <div class="progress-bar progress-bar-a progress-bar-striped"
                                                     style="color:black;min-width: ${100*(c)/totalTime}%;"></div>
                                                <div class="progress-bar progress-bar-b progress-bar-striped"
                                                     style="color:black;min-width: ${100*(d)/totalTime}%;"></div>
                                                <div class="progress-bar progress-split progress-bar-striped"
                                                     style="color:black;">&nbsp;${b}/${c}/${d}ms
                                                </div>
                                            <#else>
                                            <#--服务端开始时间 大于 客户端开始时间(客户端时间轴与服务端时间轴有一部分重合，重合后的部分算为服务端)-->
                                                <#assign a=(logInfo.timeLineList[0].startTime - beginTime)! />
                                                <#assign b=(logInfo.timeLineList[1].startTime - logInfo.timeLineList[0].startTime)! />
                                                <#assign c=(logInfo.timeLineList[1].startTime + logInfo.timeLineList[1].cost - logInfo.timeLineList[1].startTime)! />
                                                <input type="hidden" a="${a!}" b="${b!}" c="${c!}"
                                                       totalTime="${totalTime!}">
                                                <div class="progress-bar" style="width: ${100*(a)/totalTime}%"></div>
                                                <div class="progress-bar progress-bar-b progress-bar-striped"
                                                     style="color:black;min-width: ${100*(b)/totalTime}%;"></div>
                                                <div class="progress-bar progress-bar-a progress-bar-striped"
                                                     style="color:black;min-width: ${100*(c)/totalTime}%;"></div>
                                                <div class="progress-bar progress-split progress-bar-striped"
                                                     style="color:black;">&nbsp;${a}ms->${b}ms->${c}ms
                                                </div>
                                            </#if>
                                        <#else>
                                        <#--服务端开始时间 大于 客户端结束始时间(客户端一段时间，一段空格，一段服务端时间)-->
                                            <#assign a=(logInfo.timeLineList[0].startTime - beginTime)! />
                                            <#assign b=(logInfo.timeLineList[0].cost)! />
                                            <#assign c=(logInfo.timeLineList[1].startTime - logInfo.timeLineList[0].startTime)! />
                                            <#assign d=(logInfo.timeLineList[1].cost)! />
                                            <input type="hidden" a="${a!}" b="${b!}" c="${c!}" d="${d!}"
                                                   beginTime="${beginTime!}" totalTime="${totalTime!}">
                                            <div class="progress-bar" style="width: ${100*(a)/totalTime}%"></div>
                                            <div class="progress-bar progress-bar-b progress-bar-striped"
                                                 style="color:black;min-width: ${100*(b)/totalTime}%;"></div>
                                            <div class="progress-bar progress-bar-striped"
                                                 style="color:black;min-width: ${100*(c)/totalTime}%;"></div>
                                            <div class="progress-bar progress-bar-b progress-bar-striped"
                                                 style="color:black;min-width: ${100*(d)/totalTime}%;"></div>
                                            <div class="progress-bar progress-split progress-bar-striped"
                                                 style="color:black;">&nbsp;${b}/${d}ms
                                            </div>
                                        </#if>
                                    </#if>
                                </div>
                            </td>
                        </#list>
                    </tbody>
                </table>
            </div>
        </div>
        <!-- show detailTraceLog -->
        <@common.detailTraceLog />
    </div>
    </#if>
</#macro>

<#macro importOriginLog>
<div id="originRow" style="display:none">
    <div class="col-md-12">
        <table class="table table-bordered table-hover" style="color: white;">
            <thead>
            <tr>
                <th style="width:2%">#</th>
                <th style="width:98%">日志内容</th>
            </tr>
            </thead>
            <#setting datetime_format="yyyy-MM-dd HH:mm:ss"/>
            <#if valueList??>
                <tbody>
                    <#list valueList as logInfo>
                    <tr>
                        <th scope="row">
                            <#if (logInfo.parentLevel!)?length lte 0>
                                ${logInfo.levelId}
                               <#else>
                            ${logInfo.parentLevel + "." +logInfo.levelId}
                            </#if>
                        </th>
                    <#--<td>${logInfo.originData!}</td>-->
                        <td>
                            <div class="accordion-group">
                                <div class="accordion-heading">
                                    <li class="accordion-toggle list-group-item active testClass"
                                        index="${logInfo_index}"
                                        style="background-color:rgb(133, 145, 156); border: 0px;cursor:pointer">
                                    ${logInfo.viewPointId}
                                    </li>
                                </div>
                                <div id="collapse${logInfo_index}"
                                     style="height: 0px;display:none " >
                                    <ul class="list-group" style="color: black;">
                                        <li class="list-group-item" style="word-wrap:break-word">
                                            <strong>服务/方法：</strong>${logInfo.viewPointId!''}</li>
                                        <li class="list-group-item">
                                            <strong>调用类型：</strong>${logInfo.spanTypeName!'UNKNOWN'}</li>
                                        <li class="list-group-item">
                                            <strong>调用时间：</strong>${logInfo.startDate?number?number_to_datetime}</li>
                                        <li class="list-group-item">
                                            <strong>花费时间：</strong>${logInfo.cost}<strong>毫秒</strong>
                                        </li>
                                        <li class="list-group-item"><strong>业务字段：</strong>${logInfo.businessKey!}</li>
                                        <li class="list-group-item"><strong>应用Code：</strong>${logInfo.applicationId}
                                        </li>
                                        <li class="list-group-item"><strong>主机信息：</strong>${logInfo.address!}</li>
                                        <li class="list-group-item"><strong>调用进程号：</strong>${logInfo.processNo!}</li>
                                        <li class="list-group-item"><strong>异常堆栈：</strong>
                                            <#if (logInfo.exceptionStack!)?length == 0>
                                                无
                                            <#else>
                                            ${logInfo.exceptionStack}
                                            </#if>
                                        </li>
                                    </ul>
                                </div>
                            </div>

                        </td>
                    </tr>
                    </#list>
                </tbody>
            </#if>
        </table>
    </div>
    <script>
//        $(".testClass").each(function(){
//            var index = $(this).attr("index");
//            $('#collapse' + index).collapse({
//                toggle: true
//            })
//        });
    </script>
</div>
</#macro>

<#macro detailTraceLog>
<div class="modal fade bs-example-modal-lg" id="detailLog" tabindex="-1" role="dialog"
     aria-labelledby="myLargeModalLabel" style="display: none;">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">

            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span
                        aria-hidden="true">×</span></button>
                <h4 class="modal-title" id="myLargeModalLabel">日志详细信息</h4>
            </div>
            <div class="modal-body">
                <!-- form content -->
                <form class="form-horizontal" id="detailContent">

                </form>
            </div>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div>
</#macro>

