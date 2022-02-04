
<link rel="stylesheet" type="text/css" href="<?= asset_url('is/themes/bootstrap/easyui.css'); ?>">
<link rel="stylesheet" type="text/css" href="<?= asset_url('is/themes/icon.css'); ?>">
  
<script type="text/javascript" src="<?= asset_url('is/jquery.easyui.min.js'); ?>"></script>
<!--<script type="text/javascript" src="<?= asset_url('is/locale/easyui-lang-tr.js'); ?>"></script>-->
<!--<script type="text/javascript" src="<?= asset_url('is/locale_IS/IS_lang_tr.js'); ?>"></script>-->

<script src="<?= asset_url('is/print/jQuery.print.js'); ?>"></script> 
<script src="<?= asset_url('is/src/datagrid-filter.js'); ?>"></script>
<script type="text/javascript" src="http://www.jeasyui.com/easyui/datagrid-detailview.js"></script>
<script src="<?= asset_url('is/IS_js/js1_scen_slim2_project_base_mdf.js'); ?>"></script>

<!-- Zeynel Dağlı
    02-02-2015
    proje id değeri session içinden alınacak
-->
<input type ="hidden" value='<?= $project_id; ?>' id ='prj_id' name='prj_id'></input>
<!--<div class="col-md-12">-->

    <div class="easyui-layout" data-options="" style="width:100%;height:1320px;">
        <!--<div data-options="region:'north'" style="height:50px"></div>-->
        <div data-options="region:'south',split:true" style="height:800px;">
            
            
            <div class="easyui-layout" data-options="fit:true">
                <!--<div data-options="region:'north',split:true,border:false" style="height:50px"></div>-->
                <div data-options="region:'west',split:true,border:true" style="width:50%;height:300px">
                    <table  id="tt_grid_dynamic"  title="Dynamic table with IS potentials" style="height:300px">
                        
                    </table>
                </div>
                <!--<div data-options="region:'east',split:true,border:false" style="width:50%"></div>-->
                <div data-options="region:'center',border:true,split:true" style="width:50%;">
                    <table id="tt_grid_dynamic5" class="easyui-datagrid" title="IS potentials" style="height:300px"
                        data-options="singleSelect:false,
                                    collapsible:true,
                                    /*url:'datagrid_data1.json',*/
                                    /*url:'../slim_rest/index.php/companies',*/
                                    method:'get',
                                    idField:'id'">

                    </table>
                    
                </div>
                <div data-options="region:'south',split:true,border:true"  style="width:100%;">
                    <div id="p" class="easyui-panel" title="IS Companies Location" data-options="" style="margin: auto 0;height:500px">  
                            <iframe src="http://jquery.com/" id="myFrame" width="100%" marginwidth="0" 
                                height="100%" 
                                marginheight="0" 
                                align="middle" 
                                scrolling="auto">
                            </iframe>
                        </div>
                </div>
                
            </div>
            
        </div>
        <!--<div data-options="region:'east',split:true" title="East" style="width:100px;"></div>-->
        <div data-options="region:'west',split:true" title="Flows" style="width:150px;">
            <ul id="tt_tree" class="easyui-tree" ></ul>
            
        </div>
        <div data-options="region:'center',title:'IS Potentials Analysis Settings',iconCls:'icon-ok'">
            
            <div id="p" class="easyui-panel" title="Company/Flow Panel" style="margin: auto 0;"
                 data-options="iconCls:'icon-save',collapsible:true,closable:true,fit:true">
                     <table id="tt_grid" data-options="fit:true" class="easyui-datagrid" title="Company Flow Sets" 
                            style="height:440px" 
                           accesskey=""></table>
                
            </div>
            
        </div>
    </div>


    
    <div id="tb" style="padding:5px;height:auto">
                <div style="margin-bottom:5px">
                    <!--<a href="#" onclick="loadData();" class="easyui-linkbutton" iconCls="icon-add" plain="true"></a>-->
                    <a href="#add" onclick="getColumnsDynamic();getCompaniesISPotentials();" class="easyui-linkbutton" iconCls="icon-edit" plain="true">Calculate IS Potentials</a>
                    <a href="#" onclick="event.preventDefault();saveAutoPotentials();" class="easyui-linkbutton" iconCls="icon-save" plain="true">Save a table with relevant IS potentials</a>
                    <a href="#" onclick="event.preventDefault();selectAllCompanies();" class="easyui-linkbutton" iconCls="icon-edit" plain="true">Select all companies</a>
                    <!--<a href="#" onclick="openIsScenarios();" class="easyui-linkbutton" iconCls="icon-edit" plain="true">IS Table management</a>-->
                    <a href="#" id="printGrid" onclick="/*javascript:window.print();*/" class="easyui-linkbutton" data-options="iconCls:'icon-print'" plain="true">Print</a>

                </div>
                 
                 
                 <div>
                    <label style="margin-right:7px;">IS Scenario Type:</label>
                    <input class="easyui-combobox" 
                       name="IS_search" id="IS_search"
                       data-options="
                               url:'<?= asset_url('is/combobox_data1.json'); ?>',
                               method:'get',
                               valueField:'id',
                               textField:'text',
                               panelHeight:'auto',
                               icons:[{
                                   iconCls:'icon-add'
                               }]
                       ">
                     <!--<span>Company Name:</span>
                    <input id="company" style="line-height:26px;border:1px solid #ccc">
                    
                    <a href="#" class="easyui-linkbutton"  data-options="iconCls:'icon-search'" style="width:80px" onclick="search_by_company()">Search</a>-->
                 </div>
                 <!--<div>
                    <label style="margin-right:28px;">User Projects:</label>
                    <input class="easyui-combobox" 
                       name="IS_project" id="IS_project"
                       data-options="
                               url:'../../slim2_ecoman/index.php/get_user_projects?usrId=<?php /*echo $userID;*/ ?>',  
                               method:'get',
                               valueField:'id',   
                               textField:'text', 
                               panelHeight:'auto',
                               icons:[{
                                   iconCls:'icon-add'
                               }]
                       ">
                    
                 </div>-->
            </div>
    
    <div id="tb5" style="padding:5px;height:auto">
                <div  style="margin-bottom:5px">
                    
                    <a href="#" name="add" onclick="event.preventDefault();addRowAuto();" class="easyui-linkbutton" iconCls="icon-add" plain="true">Add Potential IS</a>
                    <a href="#" onclick="event.preventDefault();deleteAllAutoPotential();" class="easyui-linkbutton" iconCls="icon-remove" plain="true">Clear all</a>
                    <a href="#" id="printTest" onclick="/*javascript:window.print();*/" class="easyui-linkbutton" data-options="iconCls:'icon-print'" plain="true">Print</a>
                    
                </div>
            </div>
    
    
    
    
        <div id="saveWindowAuto" class="easyui-window" title="Save IS Scenario" data-options="modal:true,closed:true,iconCls:'icon-save'" style="width:500px;height:200px;padding:10px;">
        <div class="easyui-layout" data-options="fit:true">
            <!--<div data-options="region:'east',split:true" style="width:100px"></div>-->
            <div data-options="region:'center'" style="padding:10px;">
                <form id="ff" method="post">
                <div style="padding:10px 60px 20px 60px">
                    
                    <div style="margin-bottom: -8px;"><label style="margin-right:7px;">IS Group Name:</label><input id="tt_textAuto" class="easyui-textbox" type="text" name="name" data-options="required:true"></input></div></br>
                    <div style="margin-left:-11px;">
                        <label style="margin-right:7px;">IS Scenario Type:</label>
                        <input class="easyui-combobox" 
                            name="IS"
                            data-options="
                                    url:'<?= asset_url('is/combobox_data1.json'); ?>',
                                    method:'get',
                                    valueField:'id',
                                    textField:'text',
                                    panelHeight:'auto',
                                    icons:[{
                                        iconCls:'icon-add'
                                    }]
                            ">
                    </div>
                    
                </div>
               
                   
            </div>
            <div data-options="region:'south',border:false" style="text-align:right;padding:5px 0 0;">
                <a class="easyui-linkbutton" data-options="iconCls:'icon-ok'" href="javascript:void(0)" onclick="submitFormAuto();" style="">Save IS potentials table</a>
                <a class="easyui-linkbutton" data-options="iconCls:'icon-cancel'" href="javascript:void(0)" onclick="windowAutoISQuitWithoutSaving();" style="">Quit without saving</a>
            </div>
            </form>
        </div>
    </div>
    
    <div id="tb6" style="padding:5px;height:auto">
        <div style="margin-bottom:5px">
            <!--<a href="#" onclick="deleteISPotential();" class="easyui-linkbutton" iconCls="icon-cut" plain="true">Remove row</a>-->
            <a href="#" onclick="event.preventDefault();saveAutoPotentials();" class="easyui-linkbutton" iconCls="icon-save" plain="true">Save a table with relevant IS potentials</a>
            <a href="#" onclick="event.preventDefault();deleteAllISPotentialAuto();" class="easyui-linkbutton" iconCls="icon-remove" plain="true">Clear all</a>
            <a href="#" id="printGridPotentials" onclick="/*javascript:window.print();*/" class="easyui-linkbutton" data-options="iconCls:'icon-print'" plain="true">Print</a>
        </div>
    </div>
<!--</div>-->