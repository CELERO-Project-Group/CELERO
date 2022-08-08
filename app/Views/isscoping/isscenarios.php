
<link rel="stylesheet" type="text/css" href="<?= base_url('assets/is/themes/bootstrap/easyui.css'); ?>">
<link rel="stylesheet" type="text/css" href="<?= base_url('assets/is/themes/icon.css'); ?>">

<script type="text/javascript" src="<?= base_url('assets/is/jquery.easyui.min.js'); ?>"></script>
<!--<script type="text/javascript" src="<?= base_url('assets/is/locale/easyui-lang-tr.js'); ?>"></script>-->
<?php if ($language == 'turkish') {?>
    <script type="text/javascript" src="<?= base_url('assets/is/locale/easyui-lang-tr.js'); ?>"></script>
<?php }?>
<script type="text/javascript" src="https://www.jeasyui.com/easyui/datagrid-detailview.js"></script>

<!--<script src="<?php /*echo base_url('assets/is/src/datagrid-filter.js');*/?>"></script>-->

<?php if ($language == 'turkish') {?>
    <script src="<?= base_url('assets/is/IS_js/scenarios_tr.js'); ?>"></script>
<?php } else {?>
    <script src="<?= base_url('assets/is/IS_js/scenarios.js'); ?>"></script>
<?php }?>

<!-- Zeynel Dağlı
    02-02-2015
    proje id değeri session içinden alınacak
-->
<input type ="hidden" value='<?= $project_id; ?>' id ='prj_id' name='prj_id'></input>
<input type ="hidden" value='<?= $userID; ?>' id ='userID' name='userID'></input>
<div class="col-md-12">
    <div id="cc" class="easyui-layout" data-options="fit:true" style="height:1500px;">

        <!--<div data-options="region:'south',split:true" style="height:550px; padding-bottom:200px;">
            <div class="easyui-layout" data-options="fit:true">
                <div id="zeyn"   data-options="region:'west',split:true" style="width:50%;">
                    <table  id="tt_grid_dynamic"  title="Dynamic table with IS potentials" >

                    </table>
                </div>
                <div id="tt_grid_dynamic5_div" data-options="region:'center'" style="width:50%;">
                    <table id="tt_grid_dynamic5" class="easyui-datagrid" title="IS potentials" style="height:100%"
                        data-options="singleSelect:false,
                                    collapsible:true,
                                    /*url:'datagrid_data1.json',*/
                                    /*url:'../slim_rest/index.php/companies',*/
                                    method:'get',
                                    idField:'id'">

                    </table>
                </div>
            </div>
        </div>-->

        <!--<div data-options="region:'west',split:true" title="Flow Categories" style="width:10%;">
            <ul id="tt_tree" class="easyui-tree" ></ul>
        </div>-->
        <!--<div id="tt_grid_div" data-options="region:'center',title:'IS Scenarios Analysis Settings'">-->

            <!--<div id="p" class="easyui-panel" title="Company/Flow Panel" style="margin: auto 0;height:440px"
                 data-options="iconCls:'icon-save',collapsible:true,closable:true">
                     <table id="tt_grid" data-options="fit:true" class="easyui-datagrid" title="Company Flow Sets" style=""
                           accesskey=""></table>

            </div>-->

            <div id="p2" class="easyui-panel" style="margin: auto 0;height:480px;"
                 data-options="iconCls:'icon-save',collapsible:true,closable:true">
                <table id="tt_grid_scenarios" data-options="fit:true"  title="<?= lang("Validation.isscenarios"); ?>" style="">
                </table>

            </div>

            <div id="p" class="easyui-panel" title="<?= lang("Validation.isscompanieslocation"); ?>"
                 data-options="collapsed:true,collapsible:true"
                 style="margin: auto 0;height:400px">

                <?php
                $company_array = array();
                foreach ($companies as $com => $k) {
                    $company_array[$com][0] = $k['latitude'];
                    $company_array[$com][1] = $k['longitude'];
                    $company_array[$com][2] = "<a href='" . base_url('company/' . $k['id']) . "'>" . $k['name'] . "</a>";
                }?>
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
            </div>

            <div id="p3" class="easyui-panel" style="margin: auto 0;height:300px;"
                 data-options="iconCls:'icon-save',collapsible:true,closable:true">
                   <table id="tt_grid_scenarios_details" data-options="fit:true"   title="<?= lang("Validation.isscenariodetails"); ?>" style="">
                </table>

            </div>

            <!-- <div id="p4" class="easyui-panel" title="<?= lang("Validation.isprojecteditdetails"); ?>" style="margin: auto 0;height:200px;"
                 data-options="iconCls:'icon-save',collapsible:true,closable:true">
                   <table id="tt_grid_scenarios_details_edit" data-options="fit:true"   title="<?= lang("Validation.isscenariodetails"); ?>" style="">
                </table>

            </div> -->






            <div id="tb" style="padding:5px;height:auto">
                <div style="margin-bottom:5px">
                    <!--<a href="#" onclick="loadData();" class="easyui-linkbutton" iconCls="icon-add" plain="true"></a>-->
                    <a href="#" name="del" onclick="showScnDetailsButton();" class="easyui-linkbutton" iconCls="icon-edit" plain="true"><?= lang("Validation.isscenariodetails"); ?></a>
                    <a href="<?= base_url('isScopingPrjBaseMDF'); ?>" onclick="" class="easyui-linkbutton" iconCls="icon-back" plain="true"><?= lang("Validation.gotoismanualpage"); ?></a>
                    <a href="<?= base_url('isScopingAutoPrjBaseMDF'); ?>" onclick="" class="easyui-linkbutton" iconCls="icon-back" plain="true"><?= lang("Validation.gotoisautopage"); ?></a>
                    <a href="#" onclick="closeMapPanel();event.preventDefault();" class="easyui-linkbutton" iconCls="icon-remove" plain="true"><?= lang("Validation.closemap"); ?></a>
                    <!--<a href="#" onclick="saveAutoPotentials();" class="easyui-linkbutton" iconCls="icon-save" plain="true">Save a table with relevant IS potentials</a>
                    <a href="#" onclick="selectAllCompanies();" class="easyui-linkbutton" iconCls="icon-edit" plain="true">Select all companies</a>
                    <a href="#" onclick="openIsScenarios();" class="easyui-linkbutton" iconCls="icon-edit" plain="true">IS Table management</a>
                    <a href="#" id="printGrid" onclick="/*javascript:window.print();*/" class="easyui-linkbutton" data-options="iconCls:'icon-print'" plain="true">Print</a>-->

                </div>
            </div>
        </div>
    </div>
</div>