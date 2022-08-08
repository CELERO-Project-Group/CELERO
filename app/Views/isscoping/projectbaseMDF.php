
<link rel="stylesheet" type="text/css" href="<?= base_url('assets/is/themes/bootstrap/easyui.css'); ?>">
<link rel="stylesheet" type="text/css" href="<?= base_url('assets/is/themes/icon.css'); ?>">


<script src="<?= base_url('assets/is/src/datagrid-filter.js'); ?>"></script>
<script type="text/javascript" src="https://www.jeasyui.com/easyui/datagrid-detailview.js"></script>
<?php if($language == 'turkish') { ?>
    <script src="<?= base_url('assets/is/IS_js/js2_scen_slim2_project_base_mdf_tr.js'); ?>"></script>
<?php } else { ?>
    <script src="<?= base_url('assets/is/IS_js/js2_scen_slim2_project_base_mdf.js'); ?>"></script>
<?php }  ?>
     
<!-- Zeynel Da�l�
    02-02-2015
    proje id de�eri session i�inden al�nacak
-->

<input type ="hidden" value="<?= $project_id; ?>" id ="prj_id"  name="prj_id"></input>  
<input type ="hidden" value="<?= $userID; ?>" id ="consultant_id"  name="consultant_id"></input>


    <div class="easyui-layout" id="cc" data-options="" style="width:100%;height:1000px;">
        <!--<div data-options="region:'north'" style="height:50px"></div>-->
        <div data-options="region:'south',split:true" style="height:600px;">
            
            
            <div id="cc2" class="easyui-layout" data-options="fit:true">
                <!--<div data-options="region:'north',split:true,border:false" style="height:50px"></div>-->
                <div data-options="region:'north',split:true,border:true,collapsed:true" style="width:100%;height:400px">
                      <div id="p" class="easyui-panel" title="IS Companies Location" 
                           data-options="iconCls:'icon-ok',tools:'#tt',toolbar:'#tbclosemap'" style="margin: auto 0;height:400px">  
                            <?php
                                $company_array = array();
                                foreach ($companies as $com => $k) {
                                    $company_array[$com][0] = $k['latitude'];
                                    $company_array[$com][1] = $k['longitude'];
                                    $company_array[$com][2] = "<a href='".base_url('company/'.$k['id'])."'>".$k['name']."</a>";
                            } ?>
                            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.3.4/leaflet.css" />
                            <script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.3.4/leaflet.js"></script>
                            <div id="map"></div>
                            <script type="text/javascript">

                            var planes = <?= json_encode($company_array); ?>;
                            var bounds = new L.LatLngBounds(planes);

                            var map = L.map('map').setView([47.5596, 7.5886], 4);
                            map.fitWorld().zoomIn();

                            map.on('resize', function(e) {
                                map.fitWorld({reset: true}).zoomIn();
                            });
                            mapLink =
                                '<a href="https://openstreetmap.org">OpenStreetMap</a>';
                            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                                attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
                            }).addTo(map);

                            for (var i = 0; i < planes.length; i++) {
                                marker = new L.marker([planes[i][0],planes[i][1]])
                                    .bindPopup(planes[i][2])
                                    .addTo(map);
                            }
                            </script>
                          <div id="tt">
                                <a href="javascript:void(0)" onclick="event.preventDefault();closeMapPanel()" 
                                   class="icon-remove" ></a>
                            </div>
                        </div>   
                </div>
                <div id="tbclosemap" style="padding:5px;height:auto">
                    <div style="margin-bottom:5px">
                        <!--<a href="#" onclick="deleteISPotential();" class="easyui-linkbutton" iconCls="icon-cut" plain="true">Remove row</a>-->
                        
                        <a href="#" onclick="closeMapPanel();event.preventDefault();" class="easyui-linkbutton" iconCls="icon-remove" plain="true">Close Map</a>
                        <a href="#" class="easyui-linkbutton" data-options="iconCls:'icon-save'"><?= lang("Validation.save"); ?></a>
                        
                    </div>
                </div>
                
                <div data-options="region:'west',split:true,border:true" style="width:50%;height:200px">
                    <table id="tt_grid_dynamic2" class="easyui-datagrid" title="Step 2:  <?= lang("Validation.selectfromselectedcompany"); ?>" style=""
                    data-options="singleSelect:false,
                                    collapsible:true,
                                    /*url:'datagrid_data1.json',*/
                                    /*url:'../slim_rest/index.php/companies',*/
                                    method:'get',
                                    idField:'id'">


                    </table>
                </div>
                <!--<div data-options="region:'east',split:true,border:false" style="width:50%"></div>-->
                <div data-options="region:'center',border:true,split:true" style="width:50%;height:200px">   
                      <table id="tt_grid_dynamic3"  title="Step 3: <?= lang("Validation.specificflow"); ?> " style=""
                    data-options="singleSelect:false,
                                    collapsible:true,
                                    /*url:'datagrid_data1.json',*/
                                    /*url:'../slim_rest/index.php/companies',*/
                                    method:'get',
                                    idField:'id'">

                    </table>
                    
                </div>
                <!--<div data-options="region:'south',split:true,border:true"  style="width:100%;">
                    <div id="p" class="easyui-panel" title="IS Companies Location" data-options="" style="margin: auto 0;height:500px">  
                            <iframe src="../IS_OpenLayers/mapDefault.php" id="myFrame" width="100%" marginwidth="0" 
                                height="100%" 
                                marginheight="0" 
                                align="middle" 
                                scrolling="auto">
                            </iframe>
                        </div>
                </div>-->
                
            </div>
            
        </div>
        <!--<div data-options="region:'east',split:true" title="East" style="width:100px;"></div>-->
        <!--<div data-options="region:'west',split:true" title="Step 1: Flows" style="width:10%;">
            <ul id="tt_tree2" class="easyui-tree" ></ul>
            
        </div>-->
        <div data-options="region:'center',iconCls:'icon-ok'">
            
            <div id="p" class="easyui-panel" title="<?= lang("Validation.manualispotentialssettings"); ?>" style="margin: auto 0;"
                 data-options="iconCls:'icon-tip',collapsible:true,closable:true,fit:true">
                     <table id="tt_grid2" data-options="fit:true" class="easyui-datagrid" title="Step 1: <?= lang("Validation.selectcompanyflowmatching"); ?>" 
                            style="height:440px" 
                           accesskey=""></table>
                
            </div>
            
        </div>
        <div data-options="region:'east',split:true" style="width:30%;">
            <table id="tt_grid_dynamic4" class="easyui-datagrid" title="Step 4: <?= lang("Validation.ispotentials"); ?>" style="height:100%"
                data-options="singleSelect:false,
                            collapsible:true,
                            /*url:'datagrid_data1.json',*/
                            /*url:'../slim_rest/index.php/companies',*/
                            method:'get',
                            idField:'id'">

            </table>
            
        </div>
    </div>



    <div id="tb" style="padding:5px;height:auto">
        <div style="margin-bottom:5px">
            <!--<a href="#" onclick="addRow();" class="easyui-linkbutton" iconCls="icon-add" plain="true">Add Potential IS</a>-->
            <a id="startbutton" href="#specificFlow" onclick="beginISPotential();" class="easyui-linkbutton" iconCls="icon-edit" plain="true"><?= lang("Validation.getflowdetailsforthiscompany"); ?></a>
            <!--<a href="#" onclick="beginISPotentialByAllFlows();" class="easyui-linkbutton" iconCls="icon-edit" plain="true">IS Process By All Flows</a>-->
            <!--<a href="#" onclick="beginISPotentialByFlows();" class="easyui-linkbutton" iconCls="icon-edit" plain="true">IS Process By Selected Flows</a>-->
            <!--<a href="#" onclick="openIsScenarios();" class="easyui-linkbutton" iconCls="icon-edit" plain="true">IS Table management</a>-->
            <!--<a href="#" onclick="savePotentials();" class="easyui-linkbutton" iconCls="icon-save" plain="true">Save a table with relevant IS potentials</a>-->
        </div>
         <div>
            <label style="margin-right:7px;font-size:13px;" title="<?= lang("Validation.isscenariotooltip"); ?>" ><?= lang("Validation.isscenariotype"); ?>:</label>
            <input class="easyui-combobox" 
               name="IS_search2" id="IS_search2"
               data-options="
                       url:'<?= base_url('assets/is/combobox_data1.json'); ?>',
                       method:'get',
                       valueField:'id',
                       textField:'text',
                       panelHeight:'auto'
               ">
         </div>
    </div>

    <div id="tb2" style="padding:5px;height:auto">
        <div style="margin-bottom:5px">
            <a href="#" name="specificFlow" onclick="event.preventDefault();beginFlowPotential();" class="easyui-linkbutton" iconCls="icon-edit" plain="true"><?= lang("Validation.createflowmatching"); ?></a>
            <!--<a href="#" onclick="addRow();" class="easyui-linkbutton" iconCls="icon-add" plain="true">Add Potential IS</a>-->
        </div>

    </div>

    <div id="tb4" style="padding:5px;height:auto">
        <div style="margin-bottom:5px">
            <!--<a href="#" onclick="deleteISPotential();" class="easyui-linkbutton" iconCls="icon-cut" plain="true">Remove row</a>-->
            <a href="#" onclick="event.preventDefault();savePotentials();" class="easyui-linkbutton" iconCls="icon-save" plain="true"><?= lang("Validation.savetable"); ?></a>
            <a href="#" onclick="event.preventDefault();deleteAllISPotential();" class="easyui-linkbutton" iconCls="icon-remove" plain="true"><?= lang("Validation.clearall"); ?></a>
            <a href="#" onclick="closeMapPanel();event.preventDefault();" class="easyui-linkbutton" iconCls="icon-remove" plain="true"><?= lang("Validation.closemap"); ?></a>
        </div>
    </div>

    <div id="tb3" style="padding:5px;height:auto">
        <div style="margin-bottom:5px">
            <a href="#" onclick="event.preventDefault();addRow();" class="easyui-linkbutton" iconCls="icon-add" plain="true"><?= lang("Validation.addpotentialis"); ?></a>
        </div>
    </div>

    <div id="saveWindow" class="easyui-window" IS_synergy ="test" title="Save IS Scenario" data-options="modal:true,closed:true,iconCls:'icon-save'" style="width:500px;height:300px;padding:10px;">
        <div class="easyui-layout" data-options="fit:true">
            <div data-options="region:'center'" style="padding:10px;">
                <form id="ff" method="post">
                <div style="padding:10px 60px 20px 60px">
                    <div style="margin-bottom: 10px;">
                        <label style="margin-right: 0px;
                                      margin-left: 0px;"><?= lang("Validation.isscenarioname"); ?>:</label>
                        <input id="tt_text" class="easyui-textbox" type="text" name="name" data-options="required:true"></input>
                    </div>
                    <div style="margin-bottom: 10px;">
                        <label style="margin-right:0px;"><?= lang("Validation.isscenariotype"); ?>:</label>
                        <input class="easyui-combobox" 
                            name="IS" id="IS"
                            data-options="
                                    url:'<?= base_url('assets/is/combobox_data1.json'); ?>',
                                    method:'get',
                                    valueField:'id',
                                    textField:'text',
                                    panelHeight:'auto'
                            ">
                    </div>
                    <div style="margin-bottom: 10px;">
                        <label style="margin-right: 0px;
                                        padding-bottom: 3px;"><?= lang("Validation.isscenariostatus"); ?>:</label>
                        <input class="easyui-combobox" 
                            name="IS_status" id="IS_status"
                            data-options="
                                    
                                    url :'../../../Proxy/SlimProxy.php?url=getScanarioStatus_scn',
                                    //queryParams : { url : 'getScanarioStatus_scn},
                                    method:'get',
                                    valueField:'id',
                                    textField:'text',
                                    panelHeight:'auto',
                                    required:true,
                            ">
                    </div>
                    
                </div>
               
                   
            </div>
            <div data-options="region:'south',border:false" style="text-align:center;padding-bottom: 10px;padding-top: 10px;">
                <a class="easyui-linkbutton" data-options="iconCls:'icon-ok'" href="javascript:void(0)" onclick="saveISScenario();" style="">Save IS potentials table</a>
                <a class="easyui-linkbutton" data-options="iconCls:'icon-cancel'" href="javascript:void(0)" onclick="windowManualISQuitWithoutSaving();" style="">Quit without saving</a>
            </div>
            </form>
        </div>
    </div>
