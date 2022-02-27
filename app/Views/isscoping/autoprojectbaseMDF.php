
<link rel="stylesheet" type="text/css" href="<?= asset_url('is/themes/bootstrap/easyui.css'); ?>">
<link rel="stylesheet" type="text/css" href="<?= asset_url('is/themes/icon.css'); ?>">
  
<script type="text/javascript" src="<?= asset_url('is/jquery.easyui.min.js'); ?>"></script>
<?php if($language == 'turkish') { ?>
    <script type="text/javascript" src="<?= asset_url('is/locale/easyui-lang-tr.js'); ?>"></script>
<?php }  ?>
<!--<script type="text/javascript" src="<?= asset_url('is/locale_IS/IS_lang_tr.js'); ?>"></script>-->

<script src="<?= asset_url('is/src/datagrid-filter.js'); ?>"></script>
<script type="text/javascript" src="https://www.jeasyui.com/easyui/datagrid-detailview.js"></script>


<?php if($language == 'turkish') { ?>
    <script src="<?= asset_url('is/IS_js/js1_scen_slim2_project_base_mdf_tr.js'); ?>"></script>
<?php } else { ?>
    <script src="<?= asset_url('is/IS_js/js1_scen_slim2_project_base_mdf.js'); ?>"></script>
<?php }  ?>

<!-- Zeynel Dağlı
    02-02-2015
    proje id değeri session içinden alınacak
-->
<input type ="hidden" value='<?= $project_id; ?>' id ='prj_id' name='prj_id'></input>
<input type ="hidden" value="<?= $userID; ?>" id ="consultant_id"  name="consultant_id"></input>
<!--<div class="col-md-12">-->

    <div class="easyui-layout" data-options="" style="width:100%;height:1320px;">
        <!--<div data-options="region:'north'" style="height:50px"></div>-->
        <div data-options="region:'south',split:true" style="height:800px;">
            
            
            <div id="cc2" class="easyui-layout" data-options="fit:true">
                   
                
                <div data-options="region:'north',split:true,border:true,collapsed:true" style="width:100%;height:400px">
                      <!--<div id="p" class="easyui-panel" title="IS Companies Location" data-options="iconCls:'icon-ok',tools:[
				{
                                        text : 'Close Map',
					iconCls:'icon-remove',  
					handler:function(){closeMapPanel();event.preventDefault();}
				}]" style="margin: auto 0;height:400px">  -->
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
                        
                        <a href="#" onclick="closeMapPanel();event.preventDefault();" class="easyui-linkbutton" iconCls="icon-remove" plain="true"><?= lang("Validation.closemap"); ?></a>
                        <a href="#" class="easyui-linkbutton" data-options="iconCls:'icon-save'"><?= lang("Validation.save"); ?></a>
                        
                    </div>
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
                
                
                <!--<div data-options="region:'north',split:true,border:false" style="height:50px"></div>-->
                <div data-options="region:'west',split:true,border:true" style="width:50%;height:300px">
                    <!--<div id="ccTable" class="easyui-layout" data-options="fit:true">-->
                        <table  id="tt_grid_dynamic"  title="Step 3: <?= lang("Validation.ispotentials"); ?> " style="height:300px">
                        
                        </table>
                    <!--</div>-->
                </div>
                <!--<div data-options="region:'east',split:true,border:false" style="width:50%"></div>-->
                <div data-options="region:'center',border:true,split:true" style="width:50%;height:300px">
                    <table id="tt_grid_dynamic5" class="easyui-datagrid" title="Step 4: <?= lang("Validation.savetable"); ?>" style="height:300px"
                        data-options="singleSelect:false,
                                    collapsible:true,
                                    /*url:'datagrid_data1.json',*/
                                    /*url:'../slim_rest/index.php/companies',*/
                                    method:'get',
                                    idField:'id'">

                    </table>
                    
                </div>
                
                
            </div>
            
        </div>
        <!--<div data-options="region:'east',split:true" title="East" style="width:100px;"></div>-->
        <div data-options="region:'west',split:true" title="<span title='Start here by selecting a flow category or at least one single flow' >Step 1: <?= lang("Validation.flows"); ?></span>" style="width:150px;">
            <ul id="tt_tree" class="easyui-tree" ></ul>
            
        </div>
        <!-- <div data-options="region:'center',title:'<?= lang("Validation.ispotentialssettings"); ?>',iconCls:'icon-ok'"> -->
            
            <div id="p" class="easyui-panel" title="<?= lang("Validation.companyflowpanel"); ?>" style="margin: auto 0;"
                 data-options="region:'center', iconCls:'icon-tip',collapsible:true,closable:false">
                     <table id="tt_grid" data-options="fit:true" class="easyui-datagrid" title="Step 2: <?= lang("Validation.selectcompanycalculate"); ?>" 
                            style="height:440px" 
                           accesskey=""></table>
                
            </div>
            
        <!--</div>-->
    </div>


          
    <div id="tb" style="padding:5px;height:auto">                   
                <div style="margin-bottom:5px">
                    <!--<a href="#" onclick="loadData();" class="easyui-linkbutton" iconCls="icon-add" plain="true"></a>-->
                    <a href="#" id="matchbutton" onclick="getColumnsDynamic();getCompaniesISPotentials();" class="easyui-linkbutton" iconCls="icon-edit" plain="true" title="Click on this button to start the matching after you have selected at least one company and a flow on the left"><?= lang("Validation.calculateispotentials"); ?></a>
                    <!--<a href="#" onclick="event.preventDefault();saveAutoPotentials();" class="easyui-linkbutton" iconCls="icon-save" plain="true"><?= lang("Validation.savetable"); ?></a>-->
                    
                    <a href="#" onclick="event.preventDefault();selectAllCompanies();" class="easyui-linkbutton" iconCls="icon-edit" plain="true" title="Select all companies visible in the list below"><?= lang("Validation.selectallcompanies"); ?></a>
                    <a href="#" onclick="event.preventDefault();unselectAllCompanies();" class="easyui-linkbutton" iconCls="icon-edit" plain="true" title="Unselect all companies"><?= lang("Validation.unselectallcompanies"); ?></a>
                </div>     
                    
                 
                 <div>
                    <label style="margin-right:7px;font-size:13px;" title="<?= lang("Validation.isscenariotooltip"); ?>"><?= lang("Validation.isscenariotype"); ?>:</label>
                    <input class="easyui-combobox" 
                       name="IS_search" id="IS_search"
                       data-options="
                               url:'<?= asset_url('is/combobox_data1.json'); ?>',
                               method:'get',
                               valueField:'id',
                               textField:'text',
                               panelHeight:'auto'
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

            <a href="#" name="add" onclick="event.preventDefault();addRowAuto();" class="easyui-linkbutton" iconCls="icon-add" plain="true"><?= lang("Validation.addpotentialis"); ?></a>
            <a href="#" onclick="event.preventDefault();deleteAllAutoPotential();" class="easyui-linkbutton" iconCls="icon-remove" plain="true"><?= lang("Validation.clearall"); ?></a>
        </div>
    </div>
    
    
    <div id="saveWindowAuto" class="easyui-window" IS_synergy ="test" title="<?= lang("Validation.savetable"); ?>" data-options="modal:true,closed:true,iconCls:'icon-save'" style="width:500px;height:300px;padding:10px;">
        <div class="easyui-layout" data-options="fit:true">
            <!--<div data-options="region:'east',split:true" style="width:100px"></div>-->
            <div data-options="region:'center'" style="padding:10px;">
                <script>
                  /*console.log($("#saveWindow"));
                  console.log($("#saveWindow").attr( "IS_synergy" ));
                  console.log($("#saveWindow").attr( "IS_synergy" , "testtttt"));
                  console.log($("#saveWindow").attr( "IS_synergy" ));*/
                    
                </script>
                <form id="ff" method="post">
                <div style="padding:10px 60px 20px 60px">
                    <div style="margin-bottom: 4px;margin-left: -8px;">
                        <label style="margin-right:18px;"><?= lang("Validation.isscenarioname"); ?>:</label>
                        <input id="tt_textAuto" class="easyui-textbox" type="text" name="name" data-options="required:true"></input>
                    </div>
                    <div style="margin-left:-8px;">
                        <label style="margin-right:27px;"><?= lang("Validation.isscenariotype"); ?>:</label>
                        <input class="easyui-combobox" 
                            name="IS" id="IS"
                            data-options="
                                    url:'<?= asset_url('is/combobox_data1.json'); ?>',
                                    method:'get',
                                    valueField:'id',
                                    textField:'text',
                                    panelHeight:'auto'
                            ">
                    </div>
                    <div style="margin-left:-8px;">
                        <label style="margin-right: 17px;
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
            <div data-options="region:'south',border:false" style="text-align:right;padding:5px 0 0;">
                <!--<input type="submit" value="Save IS potentials table">-->
                <a class="easyui-linkbutton" data-options="iconCls:'icon-ok'" href="javascript:void(0)" onclick="saveISScenarioAuto();" style=""><?= lang("Validation.addpotentialis"); ?></a>
                <!--<a class="easyui-linkbutton" data-options="iconCls:'icon-ok'" href="javascript:void(0)" onclick="submitForm();" style="">Save IS potentials table</a>-->
                <a class="easyui-linkbutton" data-options="iconCls:'icon-cancel'" href="javascript:void(0)" onclick="windowManualISQuitWithoutSaving();" style=""><?= lang("Validation.quit"); ?></a>
            </div>
            </form>
        </div>
    </div>
    
        

    
    <div id="tb6" style="padding:5px;height:auto">
        <div style="margin-bottom:5px">
            <a href="#" onclick="event.preventDefault();saveAutoPotentials();" class="easyui-linkbutton" iconCls="icon-save" plain="true"><?= lang("Validation.savetable"); ?></a>
            <a href="#" onclick="closeMapPanel();event.preventDefault();" class="easyui-linkbutton" iconCls="icon-remove" plain="true"><?= lang("Validation.closemap"); ?></a>
            <a href="#" onclick="event.preventDefault();deleteAllISPotentialAuto();" class="easyui-linkbutton" iconCls="icon-remove" plain="true"><?= lang("Validation.clearall"); ?></a>
        </div>
    </div>

    <div id="tt_test">    
        <a href="javascript:void(0)" class="icon-add" onclick="javascript:alert('add')"></a>
        <a href="javascript:void(0)" class="icon-edit" onclick="javascript:alert('edit')"></a>
        <a href="javascript:void(0)" class="icon-cut" onclick="javascript:alert('cut')"></a>
        <a href="javascript:void(0)" class="icon-help" onclick="javascript:alert('help')"></a>
    </div>
<!--</div>-->