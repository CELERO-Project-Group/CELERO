<script>
    function updateReport() {
        if (false) {

        } else {
            $.messager.progress();
            var checkedArray = Array("");
            checkedArray = $("#tt_tree").tree("getChecked");
            console.log(checkedArray);
            var attrStr = "";
            $.each(checkedArray, function (index, obj) {

                attrStr += obj.id + ','
                //attrStr='6,7,';
            });
            var row = $('#tt_grid').datagrid('getSelected');
            console.log(attrStr);
            $('#ff').form({
                ajax: true,
                //url:'../../../../slim2_ecoman_admin/',
                url: '../../../../slim2_ecoman_admin/report.php/updateReport_rpt',
                queryParams: {
                    //url : 'insertReport_rpt',
                    attr: attrStr,
                    name: $('#tt_textReportName').textbox('getText'),
                    consultant_id: document.getElementById('consultant_id').value,
                    company_id: $('#company_dropdown').combobox('getValue'),
                    id: row.id
                    //'row='+JSON.stringify($('#tt_grid_dynamic5').datagrid('getRows'))+'&text='+$('#tt_textReportName').textbox('getText')
                },
                onSubmit: function () {
                    var isValid = $(this).form('validate');
                    if (!isValid) {
                        $.messager.progress('close');
                    }
                    //$.messager.alert('is valid ');
                    return isValid;	// return false will stop the form submission
                },
                success: function (data) {
                    var jsonObj = $.parseJSON(data);
                    if (jsonObj['found'] == true) {
                        if (jsonObj["id"] > 0) {
                            noty({ text: 'Report updated succesfully', type: 'success' });
                            $('#tt_grid').datagrid('reload');
                            $.messager.progress('close');
                        } else {
                            noty({ text: 'Report name has been inserted before, please enter another report name', type: 'warning' });
                            $('#tt_grid').datagrid('reload');
                            $.messager.progress('close');
                        }

                    } else if (data["found"] == false) {
                        //$.messager.alert('Save Error', 'Error occured');
                        noty({ text: 'Report could not be  updated ', type: 'error' });
                        $.messager.progress('close');	// hide progress bar while submit successfully
                    }

                }
            });
            $('#ff').submit();
        }
    }


    function resetFormReport() {
        $('#tt_tree').tree({
            url: '../../../../Proxy/SlimProxyAdmin.php',
            queryParams: { url: 'reportAttributes_rpt' },
            method: 'get',
            animate: true,
            checkbox: true,
            cascadeCheck: false,
        });
        $("#tt_tree").tree('reload');
        $("#tt_textReportName").textbox('setText', '');
        $("#company_dropdown").combobox('select', '');
        $("#saveReport").linkbutton({
            //text: 'Update Report'
            disabled: false
        });
        $("#updateReport").linkbutton({
            //text: 'Update Report'
            disabled: true
        });
    }

    function reportEditView(report_name, report_id, company_name, company_id) {
        console.log(report_name);
        console.log(report_id);
        console.log(company_name);
        console.log(company_id);
        $('#tt_tree').tree({
            url: '../../../../Proxy/SlimProxyAdmin.php',
            queryParams: {
                url: 'reportAttributesForEdit_rpt',
                report_id: report_id
            },
            method: 'get',
            animate: true,
            checkbox: true,
            cascadeCheck: false,
        });
        $("#tt_tree").tree('reload');
        $("#tt_textReportName").textbox('setText', report_name);
        $("#company_dropdown").combobox('select', company_id);
        $("#saveReport").linkbutton({
            //text: 'Update Report'
            disabled: true
        });
        $("#updateReport").linkbutton({
            //text: 'Update Report'
            disabled: false
        });
    }

    function saveReport() {
        var checkedArray = Array("");
        checkedArray = $("#tt_tree").tree("getChecked");
        if (typeof checkedArray !== 'undefined' && checkedArray.length > 0) {


            console.log(checkedArray);
            var attrStr = "";
            $.each(checkedArray, function (index, obj) {

                attrStr += obj.id + ','
                //attrStr='6,7,';
            });
            console.log(attrStr);
            $('#ff').form({
                ajax: true,
                //url:'../../../../slim2_ecoman_admin/',
                url: '../../../../slim2_ecoman_admin/report.php/insertReport_rpt',
                queryParams: {
                    //url : 'insertReport_rpt',
                    attr: attrStr,
                    name: $('#tt_textReportName').textbox('getText'),
                    consultant_id: document.getElementById('consultant_id').value,
                    company_id: $('#company_dropdown').combobox('getValue'),
                    //'row='+JSON.stringify($('#tt_grid_dynamic5').datagrid('getRows'))+'&text='+$('#tt_textReportName').textbox('getText')
                },
                onSubmit: function () {
                    $.messager.progress();
                    var isValid = $(this).form('validate');
                    if (!isValid) {
                        $.messager.progress('close');
                    }
                    //$.messager.alert('is valid ');
                    return isValid;	// return false will stop the form submission
                },
                success: function (data) {
                    var jsonObj = $.parseJSON(data);
                    if (jsonObj['found'] == true) {
                        if (jsonObj["id"] > 0) {
                            noty({ text: 'Report inserted succesfully', type: 'success' });
                            $('#tt_grid').datagrid('reload');
                            $.messager.progress('close');
                        } else {
                            noty({ text: 'Report has been inserted before, please enter another report name', type: 'warning' });
                            $('#tt_grid').datagrid('reload');
                            $.messager.progress('close');
                        }

                    } else if (data["found"] == false) {
                        //$.messager.alert('Save Error', 'Error occured');
                        noty({ text: 'Report could not be  inserted ', type: 'error' });
                        $.messager.progress('close');	// hide progress bar while submit successfully
                    }

                }
            });
            $('#ff').submit();
        } else {
            noty({ text: 'Please select report property from report attributes tree', type: 'warning' });
        }


    }


    function submitFormFlowFamily() {
        console.log($('#flowFamily').val());
        $.ajax({
            url: '../../../../slim2_ecoman_admin/report.php/insertReport',
            type: 'POST',
            dataType: 'json',
            data: 'flow=' + $('#flowFamily').val(),
            success: function (data, textStatus, jqXHR) {
                console.warn('success text status-->' + textStatus);
                if (data["found"] == true) {
                    //$.messager.alert('Success','Success inserted Flow family!','info');
                    if (data["id"] > 0) {
                        noty({ text: 'Report inserted succesfully', type: 'success' });
                        $('#tt_tree').tree('reload');
                    } else {
                        noty({ text: 'Report has been inserted before, please enter another report name', type: 'warning' });
                        $('#tt_tree').tree('reload');
                    }

                } else if (data["found"] == false) {
                    //$.messager.alert('Insert failed','Failed to insert Flow Family !','error');
                    noty({ text: 'Report could not be  inserted ', type: 'error' });
                    $('#tt_tree').tree('reload');
                }
            },
            error: function (jqXHR, textStatus, errorThrown) {
                //console.warn('error text status-->'+textStatus);
                noty({ text: 'Report could not be  inserted ', type: 'error' });
            }
        });
    }


    jQuery(document).ready(function () {


        $('#tt_grid').datagrid({
            url: '../../../Proxy/SlimProxyAdmin.php',
            queryParams: {
                url: 'getReports_rpt',
                //flows : JSON.stringify(arrayLeaf),
                //prj_id : $('#prj_id').val()
            },
            sortName: 'r_date',
            collapsible: true,
            idField: 'id',
            //toolbar:'#tb',
            rownumbers: "true",
            pagination: "true",
            remoteSort: true,
            multiSort: true,
            singleSelect: true,
            scroll: true,
            columns: [[
                { field: 'report_name', title: 'Report Name', width: 100, sortable: true },
                { field: 'r_date', title: 'Report Date', width: 100, sortable: true },
                { field: 'company_name', title: 'Company', width: 100, sortable: true },
                { field: 'company_id', title: 'Company ID', width: 100, sortable: true, hidden: true },
                { field: 'user_name', title: 'User Name', width: 100 },
                { field: 'name', title: 'Name', width: 100 },
                { field: 'surname', title: 'Surname', width: 100 },
                {
                    field: 'report', title: 'Report', width: 100, align: 'center',
                    formatter: function (value, row, index) {
                        //console.log('row satır id bilgileri'+row.id);

                        var x = '<a href="#add" class="easyui-linkbutton" \n\
                                    iconCls="icon-save" \n\
                                    onclick="document.getElementById(\'myFrame\').setAttribute(\'src\',\n\
                                    \'http://88.249.18.205:8445/jasperPhpEcoman/master/index.php?Configuration_ID='+ row.id + '&Rapor_ID=1\')"> See Report</a>';
                        //return e+d;
                        return x;

                    }
                },
                {
                    field: 'flow_details', title: 'Flow Details', width: 100, align: 'center',
                    formatter: function (value, row, index) {
                        //console.log('row satır id bilgileri'+row.id);

                        var y = '<a href="#add" class="easyui-linkbutton" \n\
                                    iconCls="icon-save" \n\
                                    onclick="document.getElementById(\'myFrame\').setAttribute(\'src\',\n\
                                    \'http://88.249.18.205:8445/jasperPhpEcoman/master/index.php?Configuration_ID='+ row.id + '&Rapor_ID=2\')"> See Flow Details</a>';
                        //return e+d;
                        return y;

                    }
                },
                {
                    field: 'edit', title: 'Edit', width: 50, align: 'center',
                    formatter: function (value, row, index) {
                        //console.log('row satır id bilgileri'+row.id);
                        //console.log('row satır name bilgileri'+row.report_name);
                        var x = '<a href="" class="easyui-linkbutton" \n\
                                    iconCls="icon-save" \n\
                                    onclick="reportEditView(\''+ row.report_name + '\',' + row.id + ', \'' + row.company_name + '\', ' + row.company_id + ' );event.preventDefault();"> Edit</a>';
                        //return e+d;
                        return x;

                    }
                },


            ]],
        });
        //$('#tt_grid2').datagrid('loadData', data);
        $('#tt_grid').datagrid({
            url: '../../../Proxy/SlimProxyAdmin.php',
            queryParams: {
                url: 'getReports_rpt',
                //flows : JSON.stringify(arrayLeaf),
                //prj_id : $('#prj_id').val()
            }
        });



        $('#tt_tree').tree({
            url: '../../../../Proxy/SlimProxyAdmin.php',
            queryParams: { url: 'reportAttributes_rpt' },
            method: 'get',
            animate: true,
            checkbox: true,
            cascadeCheck: false,
        });


        var treeValue;
        var parentnode;
        $("#tt_tree").tree({
            onCheck: function (node, checked) {
                var parentnode = $("#tt_tree").tree("getParent", node.target);
                if (parentnode) {
                    $("#tt_tree").tree('check', parentnode.target);

                } /*else {
                            //console.log('parent node bulunamadı');
                        }*/

            },
            onClick: function (node) {
                console.log(node);
                console.log(node.attributes.notroot);
                /*parentnode=$("#tt_tree").tree("getParent", node.target);
                console.log(parentnode);
                if(parentnode==null) {
                    console.log('parent node null');
                } else {
                    console.log('parent node null değil');
                }
                var roots=$("#tt_tree").tree("getRoots");
                console.log(parentnode.attributes);*/
                /*if() {
                    
                } else {
                    
                }*/
                var treeValue;
                if (node.state == undefined) {
                    var de = parentnode.text;
                    var test_array = de.split("/");
                    treeValue = test_array[1];
                } else {
                    //treeValue=parentnode.text;
                }

                //var imagepath=parentnode.text+"/"+node.text;
            },
            onDblClick: function (node) {
                var deneme = "test";
                var parent = $("#tt_tree").tree("getParent", node.target);
                if (parent) {

                } else {
                }
            }
        });

        $.ajax({
            url: '../../../../Proxy/SlimProxyAdmin.php',
            type: 'GET',
            dataType: 'json',
            data: { url: 'totalProjects' },
            success: function (data, textStatus, jqXHR) {
                //console.warn('success text status-->'+textStatus);
                //console.warn(data);
                $('#totalProjects').html(data['totalProjects']);
            }
        });

        $.ajax({
            //url: '../slim_2/index.php/columnflows_json_test',
            url: '../../../../Proxy/SlimProxyAdmin.php',
            type: 'GET',
            dataType: 'json',
            data: { url: 'totalUsers' },
            success: function (data, textStatus, jqXHR) {
                //console.warn('success text status-->'+textStatus);
                //console.warn(data);
                $('#totalUsers').html(data['totalUsers']);
            }
        });

        $.ajax({
            //url: '../slim_2/index.php/columnflows_json_test',
            url: '../../../../Proxy/SlimProxyAdmin.php',
            type: 'GET',
            dataType: 'json',
            data: { url: 'totalISProjects' },
            success: function (data, textStatus, jqXHR) {
                //console.warn('success text status-->'+textStatus);
                //console.warn(data);
                $('#totalISProjects').html(data['totalISProjects']);
            }
        });

        $.ajax({
            //url: '../slim_2/index.php/columnflows_json_test',
            url: '../../../../Proxy/SlimProxyAdmin.php',
            type: 'GET',
            dataType: 'json',
            data: { url: 'totalProducts' },
            success: function (data, textStatus, jqXHR) {
                //console.warn('success text status-->'+textStatus);
                //console.warn(data);
                $('#totalProducts').html(data['totalProducts']);
            }
        });






    });


</script>
<input type="hidden" value='<?php echo $userID; ?>' id='consultant_id' name='consultant_id'></input>
<div class="container-fluid">
    <div class="row-fluid">

        <!-- left menu starts -->
        <div class="span2 main-menu-span">
            <div class="well nav-collapse sidebar-nav">
                <ul class="nav nav-tabs nav-stacked main-menu">
                    <li class="nav-header hidden-tablet">
                        <?= lang("Validation.adminmenu"); ?>
                    </li>
                    <li><a class="ajax-link" href="<?= base_url('admin/newFlow'); ?>"><i class="icon-edit"></i><span
                                class="hidden-tablet">
                                <?= lang("Validation.flowslink"); ?>
                            </span></a></li>
                    <li><a class="ajax-link" href="<?= base_url('admin/newProcess'); ?>"><i class="icon-edit"></i><span
                                class="hidden-tablet">
                                <?= lang("Validation.processlink"); ?>
                            </span></a></li>
                    <li><a class="ajax-link" href="<?= base_url('admin/newEquipment'); ?>"><i
                                class="icon-edit"></i><span class="hidden-tablet">
                                <?= lang("Validation.equipmentslink"); ?>
                            </span></a></li>
                    <li><a class="ajax-link" href="<?= base_url('admin/industrialZones'); ?>"><i
                                class="icon-edit"></i><span class="hidden-tablet">
                                <?= lang("Validation.zoneslink"); ?>
                            </span></a></li>
                    <li><a class="ajax-link" href="<?= base_url('admin/clusters'); ?>"><i class="icon-edit"></i><span
                                class="hidden-tablet">
                                <?= lang("Validation.clusterslink"); ?>
                            </span></a></li>
                    <li><a class="ajax-link" href="<?= base_url('admin/employees'); ?>"><i class="icon-edit"></i><span
                                class="hidden-tablet">
                                <?= lang("Validation.clusteremplink"); ?>
                            </span></a></li>
                    <li><a class="ajax-link" href="<?= base_url('admin/consultants'); ?>"><i class="icon-edit"></i><span
                                class="hidden-tablet">
                                <?= lang("Validation.zoneconsultantslink"); ?>
                            </span></a></li>
                    <li><a class="ajax-link" href="<?= base_url('admin/reports'); ?>"><i class="icon-edit"></i><span
                                class="hidden-tablet">
                                <?= lang("Validation.reportslink"); ?>
                            </span></a></li>

                </ul>


                <ul class="nav nav-tabs nav-stacked main-menu">
                    <li class="nav-header hidden-tablet">
                        <?= lang("Validation.mainmenu"); ?>
                    </li>
                    <li><a class="ajax-link" href="<?= base_url(); ?>"><i class="icon-home"></i><span
                                class="hidden-tablet">
                                <?= lang("Validation.mainpage"); ?>
                            </span></a></li>

                    <li><a class="ajax-link" href="<?= base_url('users'); ?>"><i class="icon-user"></i><span
                                class="hidden-tablet">
                                <?= lang("Validation.consultants"); ?>
                            </span></a></li>
                    <li><a class="ajax-link" href="<?= base_url('user'); ?>/<?= $userName; ?>"><i
                                class="icon-user"></i><span class="hidden-tablet">
                                <?= lang("Validation.myprofile"); ?>
                            </span></a></li>
                    <li><a class="ajax-link" href="<?= base_url('profile_update'); ?>"><i class="icon-edit"></i><span
                                class="hidden-tablet">
                                <?= lang("Validation.updateprofile"); ?>
                            </span></a></li>


                    <li><a class="ajax-link" href="<?= base_url('mycompanies'); ?>"><i class="icon-calendar"></i><span
                                class="hidden-tablet">
                                <?= lang("Validation.mycompanies"); ?>
                            </span></a></li>
                    <!--<li><a class="ajax-link" href="<?= base_url('projectcompanies'); ?>"><i class="icon-calendar"></i><span class="hidden-tablet"><?= lang("Validation.myprofile"); ?>Project Companies</span></a></li>-->
                    <li><a class="ajax-link" href="<?= base_url('companies'); ?>"><i class="icon-calendar"></i><span
                                class="hidden-tablet">
                                <?= lang("Validation.allcompanies"); ?>
                            </span></a></li>
                    <li><a class="ajax-link" href="<?= base_url('newcompany'); ?>"><i class="icon-edit"></i><span
                                class="hidden-tablet">
                                <?= lang("Validation.createcompany"); ?>
                            </span></a></li>


                    <li><a class="ajax-link" href="<?= base_url('myprojects'); ?>"><i class="icon-globe"></i><span
                                class="hidden-tablet">
                                <?= lang("Validation.myprojects"); ?>
                            </span></a></li>
                    <li><a class="ajax-link" href="<?= base_url('projects'); ?>"><i class="icon-globe"></i><span
                                class="hidden-tablet">
                                <?= lang("Validation.allprojects"); ?>
                            </span></a></li>
                    <li><a class="ajax-link" href="<?= base_url('newproject'); ?>"><i class="icon-edit"></i><span
                                class="hidden-tablet">
                                <?= lang("Validation.createproject"); ?>
                            </span></a></li>


                    <li><a class="ajax-link" href="<?= base_url('cpscoping'); ?>"><i class="icon-th"></i><span
                                class="hidden-tablet">
                                <?= lang("Validation.cpidentification"); ?>
                            </span></a></li>
                    <li><a class="ajax-link" href="<?= base_url('cost_benefit'); ?>"><i class="icon-th"></i><span
                                class="hidden-tablet">
                                <?= lang("Validation.costbenefitanalysis"); ?>
                            </span></a></li>
                    <li><a class="ajax-link" href="<?= base_url('ecotracking'); ?>"><i class="icon-th"></i><span
                                class="hidden-tablet">
                                <?= lang("Validation.ecotracking"); ?>
                            </span></a></li>

                    <li><a class="ajax-link" href="<?= base_url('isScopingPrjBaseMDF'); ?>"><i class="icon-th"></i><span
                                class="hidden-tablet">
                                <?= lang("Validation.industrialsimbiosis"); ?>
                            </span></a></li>
                    <li><a class="ajax-link" href="<?= base_url('map'); ?>"><i class="icon-th"></i><span
                                class="hidden-tablet">
                                <?= lang("Validation.gis"); ?>
                            </span></a></li>

                    <li><a class="ajax-link" href="<?= base_url('logout'); ?>"><i class="icon-ban-circle"></i><span
                                class="hidden-tablet">
                                <?= lang("Validation.logout"); ?>
                            </span></a></li>
                    <!--<li><a class="ajax-link" href="#"><i class="icon-font"></i><span class="hidden-tablet">Logs</span></a></li>
            <li><a class="ajax-link" href="#"><i class="icon-picture"></i><span class="hidden-tablet"> Admin Reports</span></a></li>
            <li class="nav-header hidden-tablet">Secondary Menu</li>
            <li><a class="ajax-link" href="#"><i class="icon-align-justify"></i><span class="hidden-tablet"> Users, Roles and Privileges</span></a></li>
            <li><a class="ajax-link" href="#"><i class="icon-calendar"></i><span class="hidden-tablet"> Companies</span></a></li>
            <li><a class="ajax-link" href="#"><i class="icon-th"></i><span class="hidden-tablet">Projects</span></a></li>
            <li><a href="#"><i class="icon-globe"></i><span class="hidden-tablet">Configurations</span></a></li>
            <li><a class="ajax-link" href="#"><i class="icon-star"></i><span class="hidden-tablet"> Access Logs</span></a></li>
            <li><a href="#"><i class="icon-ban-circle"></i><span class="hidden-tablet"> Error Logs</span></a></li>-->

                </ul>
                <!--<label id="for-is-ajax" class="hidden-tablet" for="is-ajax"><input id="is-ajax" type="checkbox">Ajax Menü</label>-->
            </div><!--/.well -->
        </div><!--/span-->
        <!-- left menu ends -->

        <noscript>
            <div class="alert alert-block span10">
                <h4 class="alert-heading">Warning!</h4>
                <p>You need to have <a href="http://en.wikipedia.org/wiki/JavaScript" target="_blank">JavaScript</a>
                    enabled to use this site.</p>
            </div>
        </noscript>


        <div id="content" class="span10">
            <!-- content starts -->
                <ul class="breadcrumb">
                    <li>
                        <a href="<?= base_url(''); ?>">
                            <?= lang("Validation.mainpage"); ?>
                        </a> <span class="divider">/</span>
                    </li>
                    <li>
                        <a href="<?= base_url('admin/reports'); ?>">
                            <?= lang("Validation.reportslink"); ?>
                        </a>
                    </li>
                </ul>
            </div>


            <div class="sortable row-fluid">
                <a id='toplam_anket_link' data-rel="" title="" class="well span3 top-block" href="#">
                    <span class="icon32 icon-red icon-user"></span>
                    <div>Total users count</div>
                    <div id='totalUsers'></div>
                    <span id='totalUsers_by_today' class="notification"></span>
                </a>

                <a data-rel="tooltip" title=" new pro members." class="well span3 top-block" href="#">
                    <span class="icon32 icon-color icon-inbox"></span>
                    <div>Total projects count</div>
                    <div id='totalProjects'></div>
                    <span id='totalProjects_by_today' class="notification green">4</span>
                </a>

                <a data-rel="tooltip" title="$34 new sales." class="well span3 top-block" href="#">
                    <span class="icon32 icon-color icon-cart"></span>
                    <div>Total IS projects count</div>
                    <div id="totalISProjects"></div>
                    <span class="notification yellow"></span>
                </a>

                <a data-rel="tooltip" title="12 new messages." class="well span3 top-block" href="#">
                    <span class="icon32 icon-color icon-wrench"></span>
                    <div>Total products</div>
                    <div id="totalProducts"></div>
                    <span class="notification red"></span>
                </a>
            </div>


            <div class="row-fluid sortable">
                <div class="box span4">
                    <div class="box-header well" data-original-title>
                        <h2><i class="icon-user"></i>Report Attributes</h2>
                        <div class="box-icon">
                            <a href="#" class="btn btn-minimize btn-round"><i class="icon-chevron-up"></i></a>
                            <!--<a href="#" class="btn btn-close btn-round"><i class="icon-remove"></i></a>-->
                        </div>
                    </div>
                    <div class="box-content" style='padding: 0px;'>

                        <div class="easyui-panel" title="Report Attributes" style="height:250px;" data-options="">
                            <ul id="tt_tree" checkbox="true"></ul>
                        </div>

                    </div>
                </div><!--/span-->

                <div class="box span8">
                    <div class="box-header well" data-original-title>
                        <h2><i class="icon-user"></i> Save Report</h2>
                        <div class="box-icon">
                            <a href="#" class="btn btn-minimize btn-round"><i class="icon-chevron-up"></i></a>
                            <!--<a href="#" class="btn btn-close btn-round"><i class="icon-remove"></i></a>-->
                        </div>
                    </div>

                    <div class="box-content" style='padding: 0px;'>
                        <div id="p2" class="easyui-panel" style="height:250px;"
                            title="Write a report name and pick a company" style="margin: auto 0;height:480px;"
                            data-options="iconCls:'icon-save',collapsible:true,closable:true">
                            <form id="ff" method="post">
                                <div style="padding:10px 60px 20px 60px">
                                    <div style="margin-bottom: 4px;margin-left: -8px;">
                                        <label style="margin-right:18px;">Report Name:</label>
                                        <input id="tt_textReportName" class="easyui-textbox" type="text" name="name"
                                            data-options="required:true"></input>
                                    </div>

                                    <div style="margin-left:-8px;">
                                        <label style="margin-right: 17px;
                                                                                padding-bottom: 3px;">Company:</label>
                                        <input class="easyui-combobox" name="company_dropdown" id="company_dropdown"
                                            data-options="

                                                                            url :'../../../../Proxy/SlimProxyAdmin.php?url=getCompanies_rpt',
                                                                            //queryParams : { url : 'getCompanies_rpt'},
                                                                            method:'get',
                                                                            valueField:'id',
                                                                            textField:'text',
                                                                            panelHeight:'auto',
                                                                            /*icons:[{
                                                                                iconCls:'icon-eye-open'
                                                                            }],*/
                                                                            required:true,
                                                                    ">
                                    </div>

                                </div>



                                <div data-options="region:'south',border:false"
                                    style="text-align:left;padding:5px 0 0;">
                                    <!--<input type="submit" value="Save IS potentials table">-->
                                    <a class="easyui-linkbutton" id="saveReport" name="saveReport"
                                        style='margin-left: 50px;' data-options="iconCls:'icon-ok'"
                                        href="javascript:void(0)" onclick="saveReport();" style="">Save Report</a>
                                    <a class="easyui-linkbutton" id="updateReport" name="updateReport"
                                        style='margin-left: 7px;' data-options="iconCls:'icon-ok',disabled:true"
                                        href="javascript:void(0)" onclick="updateReport();" style="">Update Report</a>
                                    <a class="easyui-linkbutton" style='margin-left: 7px;'
                                        data-options="iconCls:'icon-ok'" href="javascript:void(0)"
                                        onclick="resetFormReport();" style="">Reset Form</a>
                                    <!--<a class="easyui-linkbutton" data-options="iconCls:'icon-ok'" href="javascript:void(0)" onclick="submitForm();" style="">Save IS potentials table</a>-->
                                    <!--<a class="easyui-linkbutton" data-options="iconCls:'icon-cancel'" href="javascript:void(0)" onclick="windowManualISQuitWithoutSaving();" style="">Quit without saving</a>-->
                                </div>
                            </form>

                        </div>
                    </div>

                </div><!--/span-->
            </div>



            <!-- zeynel dağlı flow tree ve form -->
            <div class="row-fluid sortable">
                <div class="box span12">
                    <div class="box-header well" data-original-title>
                        <h2><i class="icon-th"></i> Reports Datagrid</h2>
                        <div class="box-icon">
                            <!--<a href="#" class="btn btn-setting btn-round"><i class="icon-cog"></i></a>-->
                            <a href="#" class="btn btn-minimize btn-round"><i class="icon-chevron-up"></i></a>
                            <!--<a href="#" class="btn btn-close btn-round"><i class="icon-remove"></i></a>-->
                        </div>
                    </div>
                    <div class="box-content" style="padding: 0px;">
                        <div class="row-fluid">

                            <div class="span12">
                                <div id="p2" class="easyui-panel" title="Reports already prepared"
                                    style="margin: auto 0;height:350px;"
                                    data-options="iconCls:'icon-save',collapsible:true,closable:true">
                                    <table id="tt_grid" data-options="" title="Company Report Sets" contenteditable=""
                                        style="height:440px;" accesskey="">
                                    </table>
                                </div>


                            </div>

                        </div>
                    </div>
                </div><!--/span-->
            </div>

            <!-- zeynel dağlı jasper report -->
            <div class="row-fluid sortable">
                <div class="box span12">
                    <div class="box-header well" data-original-title>
                        <h2><i class="icon-th"></i> Report</h2>
                        <div class="box-icon">
                            <!--<a href="#" class="btn btn-setting btn-round"><i class="icon-cog"></i></a>-->
                            <a href="#" class="btn btn-minimize btn-round"><i class="icon-chevron-up"></i></a>
                            <!--<a href="#" class="btn btn-close btn-round"><i class="icon-remove"></i></a>-->
                        </div>
                    </div>
                    <div class="box-content" style="padding: 0px;">
                        <div class="row-fluid">

                            <div class="span12">
                                <a href="#" name="add" onclick="event.preventDefault();"></a>
                                <!-- <iframe src="" id="myFrame" width="100%" marginwidth="0" height="100%" marginheight="0"
                                    align="middle" scrolling="auto">
                                </iframe> -->
                            </div>

                        </div>
                    </div>
                </div><!--/span-->
            </div>



            <!-- content ends -->
        </div><!--/#content.span10-->
    </div><!--/fluid-row-->

    <hr>

    <div class="modal hide fade" id="myModal">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal">×</button>
            <h3>Settings</h3>
        </div>
        <div class="modal-body">
            <p>Here settings can be configured...</p>
        </div>
        <div class="modal-footer">
            <a href="#" class="btn" data-dismiss="modal">Close</a>
            <a href="#" class="btn btn-primary">Save changes</a>
        </div>
    </div>

    <footer>
        <p class="pull-left">&copy; <a href="" target="_blank">Celero</a> 2015</p>
        <p class="pull-right">Powered by: <a href=""></a></p>
    </footer>

</div>