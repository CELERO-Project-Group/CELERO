<script>
    
    function deleteEditView(report_id) {
         
         $.messager.progress();
         $.ajax({
                url: '../../../../slim2_ecoman_admin/report.php/deleteIndustrialZonesClusterEmployees_rpt',
                type: 'POST',
                dataType : 'json',
                data: { url:'deleteIndustrialZonesClusterEmployees_rpt',
                id : report_id
                    },
                success: function(data, textStatus, jqXHR) {
                    
                             noty({text: '<?php echo lang("notyclusterempdeleted"); ?>', type: 'success'});
                             $('#tt_grid').datagrid('reload');
                             $.messager.progress('close');
                         

                   
                }
            });
         
         
     }
    
    
    function updateReport() {
        if(false) {
            
        }  else {
            $.messager.progress();
        
        var row = $('#tt_grid').datagrid('getSelected');  

        $('#ff').form({
            ajax : true,
            //url:'../../../../slim2_ecoman_admin/',
            url: '../../../../slim2_ecoman_admin/report.php/updateIndustrialZonesClusterEmployee_rpt',
            queryParams : {
                //url : 'insertReport_rpt',
                employee_name : $('#tt_textReportName').textbox('getText'),
                //consultant_id : document.getElementById('consultant_id').value,
                industrial_zone_id : $('#company_dropdown').combobox('getValue'),
                cluster_id : $('#cluster_dropdown').combobox('getValue'),
                role_id : $('#role_dropdown').combobox('getValue'),
                id : row.id
                //'row='+JSON.stringify($('#tt_grid_dynamic5').datagrid('getRows'))+'&text='+$('#tt_textReportName').textbox('getText')
            },
            onSubmit:function(){
                var isValid = $(this).form('validate');
                if (!isValid){
                        $.messager.progress('close');
                }
                //$.messager.alert('is valid ');
                return isValid;	// return false will stop the form submission
            },
            success:function(data){
                noty({text: '<?php echo lang("notyclusterempupdated"); ?>', type: 'success'});
                         $('#tt_grid').datagrid('reload');
                         $.messager.progress('close');

            }
            });
            $('#ff').submit();
        } 
    }
    
    
    function resetFormReport() {
        
         $("#tt_textReportName").textbox('setText', '');
         $("#company_dropdown").combobox('select', '');
         $("#cluster_dropdown").combobox('select', '');
         $("#role_dropdown").combobox('select', '');
         $("#saveReport").linkbutton({
            //text: 'Update Report'
            disabled: false
        });
        $("#updateReport").linkbutton({
            //text: 'Update Report'
            disabled: true
        });
    }
    
     function reportEditView(employee_name, company_id, cluster_id, role_id) {
         
         $("#tt_textReportName").textbox('setText', employee_name);
         $("#company_dropdown").combobox('select', company_id);
         $("#cluster_dropdown").combobox('select', cluster_id);
         $("#role_dropdown").combobox('select', role_id);
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

            $('#ff').form({
                ajax : true,
                //url:'../../../../slim2_ecoman_admin/',
                url: '../../../slim2_ecoman_admin/report.php/insertIndustrialZonesClusterEmployee_rpt',
                queryParams : {
                    //url : 'insertReport_rpt',
                    //attr : attrStr,
                    employee_name : $('#tt_textReportName').textbox('getText'),
                    //consultant_id : document.getElementById('consultant_id').value,
                    industrial_zone_id : $('#company_dropdown').combobox('getValue'),
                    cluster_id : $('#cluster_dropdown').combobox('getValue'),
                    role_id : $('#role_dropdown').combobox('getValue'),
                    //'row='+JSON.stringify($('#tt_grid_dynamic5').datagrid('getRows'))+'&text='+$('#tt_textReportName').textbox('getText')
                },
                onSubmit:function(){
                    $.messager.progress();
                    var isValid = $(this).form('validate');
                    if (!isValid){
                            $.messager.progress('close');
                    }
                    //$.messager.alert('is valid ');
                    return isValid;	// return false will stop the form submission
                },
                success:function(data){
                   
                             noty({text: '<?php echo lang("notyclusterempinserted"); ?>', type: 'success'});
                             $('#tt_grid').datagrid('reload');
                             $.messager.progress('close');
                         

                }
                });
                $('#ff').submit();
       
         
        
    }
    
    
    function submitFormFlowFamily(){  
            console.log($('#flowFamily').val()); 
            $.ajax({
                //url: '../../../../slim2_ecoman_admin/report.php/insertReport',
                url: '../../../slim2_ecoman_admin/report.php/insertIndustrialZonesClusters_rpt',
                type: 'POST',
                dataType : 'json',
                data: 'flow='+$('#flowFamily').val(),
                success: function(data, textStatus, jqXHR) {
                  console.warn('success text status-->'+textStatus);
                  if(data["found"]==true) {
                      //$.messager.alert('Success','Success inserted Flow family!','info');
                      if(data["id"]>0) {
                          noty({text: '<?php echo lang("notyclusterempinserted"); ?>', type: 'success'});
                      } else {
                          noty({text: '<?php echo lang("notyclusterempinsertedbefore"); ?>', type: 'warning'});
                          $('#tt_tree').tree('reload');
                      }
                      
                  } else if(data["found"]==false) {         
                      //$.messager.alert('Insert failed','Failed to insert Flow Family !','error');
                      noty({text: '<?php echo lang("notyclusterempnotinserted"); ?>', type: 'error'});  
                  }   
                },
                error: function(jqXHR , textStatus, errorThrown) {
                  //console.warn('error text status-->'+textStatus);
                  noty({text: '<?php echo lang("notyclusterempnotinserted"); ?>', type: 'error'});  
                }
            });
        }
    
    
    jQuery(document).ready(function() {
        
        
         $('#tt_grid').datagrid({
            url :'../../../Proxy/SlimProxyAdmin.php',
            queryParams : { url : 'getIndustrialZonesClusterEmployeeGrid_rpt',
                            //flows : JSON.stringify(arrayLeaf),
                            //prj_id : $('#prj_id').val()
                        },
            sortName : 'id',
            collapsible:true,
            idField:'id',
            //toolbar:'#tb',
            rownumbers: "true",
            pagination: "true",
            remoteSort : true,
            multiSort : true,
            singleSelect : true,
            scroll : true,
            columns:[[
                  {field:'employee_name',title:'<?php echo lang("clusteremp"); ?>',width:200,sortable:true},
                  {field:'role_name',title:'<?php echo lang("role"); ?>',width:200,sortable:true},
                  {field:'cluster_name',title:'<?php echo lang("clusterslink"); ?>',width:200,sortable:true},
                  {field:'industrial_zone_name',title:'<?php echo lang("zoneslink"); ?>',width:200,sortable:true},
                
                {field:'edit',title:'<?php echo lang("edit"); ?>',width:50,align:'center',
                    formatter:function(value,row,index){
                        //console.log('row satır id bilgileri'+row.id);
                        //console.log('row satır name bilgileri'+row.report_name);
                        var x = '<a href="" class="easyui-linkbutton" \n\
                                    iconCls="icon-save" \n\
                                    onclick="reportEditView(\''+row.employee_name+'\','+row.industrial_zone_id+', \''+row.cluster_id+'\', '+row.role_id+' );event.preventDefault();"><?php echo lang("edit"); ?></a>';
                        //return e+d;
                        return x;
                        
                    }
                },
                
                {field:'delete',title:'<?php echo lang("delete"); ?>',width:50,align:'center',
                    formatter:function(value,row,index){
                        //console.log('row satır id bilgileri'+row.id);
                        //console.log('row satır name bilgileri'+row.report_name);
                        var x = '<a href="" class="easyui-linkbutton" \n\
                                    iconCls="icon-save" \n\
                                    onclick="deleteEditView('+row.id+');event.preventDefault();"><?php echo lang("delete"); ?></a>';
                        //return e+d;
                        return x;
                        
                    }
                },
                

                  ]],
                });
            //$('#tt_grid2').datagrid('loadData', data);
            $('#tt_grid').datagrid({
               url :'../../../Proxy/SlimProxyAdmin.php',
               queryParams : { url : 'getIndustrialZonesClusterEmployeeGrid_rpt',
                               //flows : JSON.stringify(arrayLeaf),
                               //prj_id : $('#prj_id').val()
                           }
            });
        
            $.ajax({
                url: '../../../../Proxy/SlimProxyAdmin.php',
                type: 'GET',
                dataType : 'json',
                data: { url:'totalProjects' },
                success: function(data, textStatus, jqXHR) {
                  //console.warn('success text status-->'+textStatus);
                  //console.warn(data);
                  $('#totalProjects').html(data['totalProjects']);
                }
            }); 
            
            $.ajax({
                //url: '../slim_2/index.php/columnflows_json_test',
                url: '../../../../Proxy/SlimProxyAdmin.php',
                type: 'GET',
                dataType : 'json',
                data: { url:'totalUsers' },
                success: function(data, textStatus, jqXHR) {
                  //console.warn('success text status-->'+textStatus);
                  //console.warn(data);
                  $('#totalUsers').html(data['totalUsers']);
                }
            }); 
            
            $.ajax({
                //url: '../slim_2/index.php/columnflows_json_test',
                url: '../../../../Proxy/SlimProxyAdmin.php',
                type: 'GET',
                dataType : 'json',
                data: { url:'totalISProjects' },
                success: function(data, textStatus, jqXHR) {
                  //console.warn('success text status-->'+textStatus);
                  //console.warn(data);
                  $('#totalISProjects').html(data['totalISProjects']);
                }
            });
            
            $.ajax({ 
                //url: '../slim_2/index.php/columnflows_json_test',
                url: '../../../../Proxy/SlimProxyAdmin.php',
                type: 'GET',
                dataType : 'json',
                data: { url:'totalProducts' },
                success: function(data, textStatus, jqXHR) {
                  //console.warn('success text status-->'+textStatus);
                  //console.warn(data);
                  $('#totalProducts').html(data['totalProducts']);
                }
            });
              
        });
    
    
</script>
<input type ="hidden" value='<?php echo $userID; ?>' id ='consultant_id' name='consultant_id'></input>
<!-- topbar starts -->
	<div class="navbar">
		<div class="navbar-inner">
			<div class="container-fluid">
				<a class="btn btn-navbar" data-toggle="collapse" data-target=".top-nav.nav-collapse,.sidebar-nav.nav-collapse">
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
				</a>
				<a class="brand" href=""> <img style="height: 60px;width: 164px;" alt="CELERO logo" src="../assets/images/anasayfa.png" /> <span>CELERO</span></a>
				
				<!-- theme selector starts -->
				<div class="btn-group pull-right theme-container" >
                                        <ul class="nav navbar-nav navbar-right">
                                            <li><a href='<?php echo base_url('language/switch/turkish'); ?>' style="padding-right: 0px; border-right: 0px;border-left: 0px; "><img src="<?php echo asset_url('images/Turkey.png'); ?>"></a></li>
                                            <li><a href='<?php echo base_url('language/switch/english'); ?>' style="border-right: 0px;border-left: 0px;"><img src="<?php echo asset_url('images/United-States.png'); ?>"></a></li>
                                        </ul>
					<a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
						<i class="icon-tint"></i><span class="hidden-phone"><?php echo lang("changeskin"); ?> </span>
						<span class="caret"></span>
					</a>
					<ul class="dropdown-menu" id="themes"> 
						<li><a data-value="classic" href="#"><i class="icon-blank"></i>Classic</a></li>
						<li><a data-value="cerulean" href="#"><i class="icon-blank"></i>Cerulean</a></li>
						<li><a data-value="cyborg" href="#"><i class="icon-blank"></i>Cyborg</a></li>
					 	<li><a data-value="redy" href="#"><i class="icon-blank"></i>Redy</a></li>
						<li><a data-value="journal" href="#"><i class="icon-blank"></i>Journal</a></li>
						<li><a data-value="simplex" href="#"><i class="icon-blank"></i>Simplex</a></li>
						<li><a data-value="slate" href="#"><i class="icon-blank"></i>Slate</a></li>
						<li><a data-value="spacelab" href="#"><i class="icon-blank"></i>Spacelab</a></li>
						<li><a data-value="united" href="#"><i class="icon-blank"></i>United</a></li>
					</ul>
				</div>
				<!-- theme selector ends -->
				
				<!-- user dropdown starts -->
				<div class="btn-group pull-right" >
					<a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
						<i class="icon-user"></i><span class="hidden-phone"> <?php echo $userName;  ?></span>
						<span class="caret"></span>
					</a>
					<ul class="dropdown-menu">
						<li><a href="#"><?php echo lang("myprofile"); ?></a></li>
						<li class="divider"></li>
						<li><a href="../logout"><?php echo lang("logout"); ?></a></li>
					</ul>
				</div>
				<!-- user dropdown ends -->
				
				<div class="top-nav nav-collapse">
					<ul class="nav">
						<li><a href="../../ecoman"><?php echo lang("mainpage"); ?></a></li>
						<li>
							<!--<form class="navbar-search pull-left">-->
								<input placeholder="<?php echo lang("search"); ?>" class="search-query span2" name="query" type="text">
							<!--</form>-->
						</li>
					</ul>
				</div><!--/.nav-collapse -->
			</div>
		</div>
	</div>
	<!-- topbar ends -->
        
        <div class="container-fluid" style="background: #E0EDDF">
		<div class="row-fluid">
				
			<!-- left menu starts -->
			<div class="span2 main-menu-span">
				<div class="well nav-collapse sidebar-nav">
                                    
                                          <ul class="nav nav-tabs nav-stacked main-menu">
                                                <li class="nav-header hidden-tablet"><?php echo lang("adminmenu"); ?></li>
                                            <li><a class="ajax-link" href="<?php echo base_url('admin/newFlow'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("flowslink"); ?></span></a></li>
                                            <li><a class="ajax-link" href="<?php echo base_url('admin/newProcess'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("processlink"); ?></span></a></li>
                                            <li><a class="ajax-link" href="<?php echo base_url('admin/newEquipment'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("equipmentslink"); ?></span></a></li>
                                            <li><a class="ajax-link" href="<?php echo base_url('admin/industrialZones'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("zoneslink"); ?> </span></a></li>
                                            <li><a class="ajax-link" href="<?php echo base_url('admin/clusters'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("clusterslink"); ?></span></a></li>
                                            <li><a class="ajax-link" href="<?php echo base_url('admin/employees'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("clusteremplink"); ?> </span></a></li>
                                            <li><a class="ajax-link" href="<?php echo base_url('admin/consultants'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("zoneconsultantslink"); ?>  </span></a></li>
                                            <li><a class="ajax-link" href="<?php echo base_url('admin/reports'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("reportslink"); ?></span></a></li>

                                        </ul>
                                    
					<ul class="nav nav-tabs nav-stacked main-menu">
						<li class="nav-header hidden-tablet"><?php echo lang("mainmenu"); ?></li>
						<li><a class="ajax-link" href="<?php echo base_url(); ?>"><i class="icon-home"></i><span class="hidden-tablet"> <?php echo lang("mainpage"); ?></span></a></li>
                                                
                                                <li><a class="ajax-link" href="<?php echo base_url('users'); ?>"><i class="icon-user"></i><span class="hidden-tablet"><?php echo lang("consultants"); ?></span></a></li>
                                                <li><a class="ajax-link" href="<?php echo base_url('user'); ?>/<?php echo $userName; ?>"><i class="icon-user"></i><span class="hidden-tablet"><?php echo lang("myprofile"); ?></span></a></li>
                                                <li><a class="ajax-link" href="<?php echo base_url('profile_update'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("updateprofile"); ?></span></a></li>
                                                
                                                
						<li><a class="ajax-link" href="<?php echo base_url('mycompanies'); ?>"><i class="icon-calendar"></i><span class="hidden-tablet"><?php echo lang("mycompanies"); ?></span></a></li>
                                                <!--<li><a class="ajax-link" href="<?php echo base_url('projectcompanies'); ?>"><i class="icon-calendar"></i><span class="hidden-tablet"><?php echo lang("myprofile"); ?>Project Companies</span></a></li>-->
                                                <li><a class="ajax-link" href="<?php echo base_url('companies'); ?>"><i class="icon-calendar"></i><span class="hidden-tablet"><?php echo lang("allcompanies"); ?></span></a></li>
                                                <li><a class="ajax-link" href="<?php echo base_url('newcompany'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("createcompany"); ?></span></a></li>
                                                
                                                
                                                <li><a class="ajax-link" href="<?php echo base_url('myprojects'); ?>"><i class="icon-globe"></i><span class="hidden-tablet"><?php echo lang("myprojects"); ?></span></a></li>
                                                <li><a class="ajax-link" href="<?php echo base_url('projects'); ?>"><i class="icon-globe"></i><span class="hidden-tablet"><?php echo lang("allprojects"); ?></span></a></li>
                                                <li><a class="ajax-link" href="<?php echo base_url('newproject'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("createproject"); ?></span></a></li>
                                                
                                                
						<li><a class="ajax-link" href="<?php echo base_url('cpscoping'); ?>"><i class="icon-th"></i><span class="hidden-tablet"><?php echo lang("cpidentification"); ?></span></a></li>
                                                <li><a class="ajax-link" href="<?php echo base_url('cost_benefit'); ?>"><i class="icon-th"></i><span class="hidden-tablet"><?php echo lang("costbenefitanalysis"); ?> </span></a></li>
                                                <li><a class="ajax-link" href="<?php echo base_url('ecotracking'); ?>"><i class="icon-th"></i><span class="hidden-tablet"><?php echo lang("ecotracking"); ?> </span></a></li>
                                                
                                                <li><a class="ajax-link" href="<?php echo base_url('isScopingPrjBaseMDF'); ?>"><i class="icon-th"></i><span class="hidden-tablet"><?php echo lang("industrialsimbiosis"); ?> </span></a></li>
                                                <li><a class="ajax-link" href="<?php echo base_url('map'); ?>"><i class="icon-th"></i><span class="hidden-tablet"><?php echo lang("gis"); ?> </span></a></li>
                           
						<li><a class="ajax-link" href="<?php echo base_url('logout'); ?>"><i class="icon-ban-circle"></i><span class="hidden-tablet"><?php echo lang("logout"); ?> </span></a></li>
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
					<p>You need to have <a href="http://en.wikipedia.org/wiki/JavaScript" target="_blank">JavaScript</a> enabled to use this site.</p>
				</div>
			</noscript>
			
			<div id="content" class="span10">
			<!-- content starts -->
			

			<div>
				<ul class="breadcrumb">
					<li>
						<a href="<?php echo base_url(''); ?>"><?php echo lang("mainpage"); ?></a> <span class="divider">/</span>
					</li>
					<li>
						<a href="<?php echo base_url('admin/employees'); ?>"><?php echo lang("clusteremplink"); ?></a>
					</li>
				</ul>
			</div>
                        
                        
                        
                        
                        
			<div class="sortable row-fluid">
                            <a  id='toplam_anket_link' data-rel="" title="" class="well span3 top-block" href="#">
					<span class="icon32 icon-red icon-user"></span>
					<div><?php echo lang("totaluserscount"); ?></div>
					<div id='totalUsers'></div>
					<span id ='totalUsers_by_today' class="notification"></span>
				</a>
 
				<a data-rel="tooltip" title="" class="well span3 top-block" href="#">
					<span class="icon32 icon-color icon-inbox"></span>
					<div><?php echo lang("totalprojectscount"); ?></div>
					<div id='totalProjects'></div>
					<span id='totalProjects_by_today' class="notification green"></span>
				</a>

				<a data-rel="tooltip" title="" class="well span3 top-block" href="#">
					<span class="icon32 icon-color icon-cart"></span>
					<div><?php echo lang("totalisprojectscount"); ?></div>
					<div id="totalISProjects"></div>
					<span class="notification yellow"></span>
				</a>
				
				<a data-rel="tooltip" title="" class="well span3 top-block" href="#">
					<span class="icon32 icon-color icon-wrench"></span>
					<div><?php echo lang("totalproducts"); ?></div>
					<div id="totalProducts"></div>
					<span class="notification red"></span>
				</a>
			</div>
                        
                        
                        <div class="row-fluid sortable">
                            
                                
                                <div class="box span12">
					<div class="box-header well" data-original-title>
						<h2><i class="icon-user"></i><?php echo lang("insertemployee"); ?> </h2>
						<div class="box-icon">
							<a href="#" class="btn btn-minimize btn-round"><i class="icon-chevron-up"></i></a>
							<!--<a href="#" class="btn btn-close btn-round"><i class="icon-remove"></i></a>-->
						</div>
					</div>
					
                                        <div class="box-content" style='padding: 0px;'>
                                                <div id="p2" class="easyui-panel"  title="<?php echo lang("employeeinfo"); ?>" 
                                                     style="margin: auto 0;height:380px;"
                                                    data-options="iconCls:'icon-save',collapsible:true,closable:true">
                                                      <form id="ff" method="post">
                                                        <div style="padding:10px 60px 20px 60px">
                                                            <div style="margin-bottom: 4px;margin-left: -8px;">
                                                                <label style="margin-right:18px;"><?php echo lang("employee"); ?>:</label>
                                                                <input id="tt_textReportName" class="easyui-textbox" type="text" name="name" data-options="required:true"></input>
                                                            </div>
                                                            
                                                            <div style="margin-left:-8px;">
                                                                <label style="margin-right: 17px;
                                                                                padding-bottom: 3px;"><?php echo lang("role"); ?>:</label>
                                                                <input class="easyui-combobox" 
                                                                    name="role_dropdown" id="role_dropdown"
                                                                    data-options="

                                                                            url :'../../../../Proxy/SlimProxyAdmin.php?url=getClusterEmployeeRoles_rpt',
                                                                            //queryParams : { url : 'getClusterEmployeeRoles_rpt'},
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
                                                            
                                                            <div style="margin-left:-8px;">
                                                                <label style="margin-right: 17px;
                                                                                padding-bottom: 3px;"><?php echo lang("zoneslink"); ?>:</label>
                                                                <input class="easyui-combobox" 
                                                                    name="company_dropdown" id="company_dropdown"
                                                                    data-options="

                                                                            url :'../../../../Proxy/SlimProxyAdmin.php?url=getZones_rpt',
                                                                            //queryParams : { url : 'getZones_rpt'},
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
                                                            
                                                            <div style="margin-left:-8px;">
                                                                <label style="margin-right: 17px;
                                                                                padding-bottom: 3px;"><?php echo lang("clusterslink"); ?>:</label>
                                                                <input class="easyui-combobox" 
                                                                    name="cluster_dropdown" id="cluster_dropdown"
                                                                    data-options="

                                                                            url :'../../../../Proxy/SlimProxyAdmin.php?url=getClusters_rpt',
                                                                            //queryParams : { url : 'getClusters_rpt'},
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



                                                    <div data-options="region:'south',border:false" style="text-align:left;padding:5px 0 0;">
                                                        <!--<input type="submit" value="Save IS potentials table">-->
                                                        <a class="easyui-linkbutton" id="saveReport" name="saveReport"
                                                           style='margin-left: 50px;'
                                                           data-options="iconCls:'icon-ok'" 
                                                           href="javascript:void(0)" 
                                                           onclick="saveReport();" style=""><?php echo lang("savedata"); ?></a>
                                                        <a class="easyui-linkbutton" id="updateReport" name="updateReport"
                                                           style='margin-left: 7px;'
                                                           data-options="iconCls:'icon-ok',disabled:true" 
                                                           href="javascript:void(0)" 
                                                           onclick="updateReport();" style=""><?php echo lang("update"); ?></a>
                                                        <a class="easyui-linkbutton" 
                                                           style='margin-left: 7px;'
                                                           data-options="iconCls:'icon-ok'" 
                                                           href="javascript:void(0)" 
                                                           onclick="resetFormReport();" style=""><?php echo lang("resetform"); ?></a>
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
                                            <h2><i class="icon-th"></i><?php echo lang("employee"); ?> </h2>
                                            <div class="box-icon">
                                                    <!--<a href="#" class="btn btn-setting btn-round"><i class="icon-cog"></i></a>-->
                                                    <a href="#" class="btn btn-minimize btn-round"><i class="icon-chevron-up"></i></a>
                                                    <!--<a href="#" class="btn btn-close btn-round"><i class="icon-remove"></i></a>-->
                                            </div>
                                    </div>
                                    <div class="box-content" style="padding: 0px;">
                                        <div class="row-fluid" >
                                            
                                            <div class="span12">
                                                <div id="p2" class="easyui-panel"  
                                                     title="<?php echo lang("employee"); ?>" 
                                                     style="margin: auto 0;height:350px;"
                                                    data-options="iconCls:'icon-save',collapsible:true,closable:true">
                                                    <table id="tt_grid" data-options="" 
                                                           title="<?php echo lang("employee"); ?>" 
                                                               contenteditable="" style="height:440px;" 
                                                      accesskey="">
                                                    </table>
                                                </div>
						
                                                
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
			<p class="pull-left">&copy; <a href="" target="_blank">CELERO</a> 2015</p>
			
		</footer>
		
	</div>

