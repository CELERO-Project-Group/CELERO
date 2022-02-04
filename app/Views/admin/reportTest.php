<script>
    function updateReport() {
        if(false) {
            
        }  else {
            $.messager.progress();
        var checkedArray = Array("");
        checkedArray = $("#tt_tree").tree("getChecked");
        console.log(checkedArray);
        var attrStr="";
        $.each(checkedArray, function( index, obj ) {
            
            attrStr+=obj.id+','
            //attrStr='6,7,';
          });
        var row = $('#tt_grid').datagrid('getSelected');
        console.log(attrStr);
        $('#ff').form({
            ajax : true,
            //url:'../../../../slim2_ecoman_admin/',
            url: '../../../../slim2_ecoman_admin/report.php/updateReport_rpt',
            queryParams : {
                //url : 'insertReport_rpt',
                attr : attrStr,
                name : $('#tt_textReportName').textbox('getText'),
                consultant_id : document.getElementById('consultant_id').value,
                company_id : $('#company_dropdown').combobox('getValue'),
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
                var jsonObj = $.parseJSON(data);
                if(jsonObj['found']==true)
                {
                    if(jsonObj["id"]>0) {
                         noty({text: '<?php echo lang("notyreportupdated"); ?>', type: 'success'});
                         $('#tt_grid').datagrid('reload');
                         $.messager.progress('close');
                     } else {
                         noty({text: '<?php echo lang("notyreportinsertedbefore"); ?>', type: 'warning'});
                         $('#tt_grid').datagrid('reload');
                         $.messager.progress('close');
                     }

                } else if(data["found"]==false){
                    //$.messager.alert('Save Error', 'Error occured');
                    noty({text: '<?php echo lang("notyreportnotupdated"); ?>', type: 'error'}); 
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
                queryParams : { url:'reportAttributes_rpt' },
                method:'get',
                animate:true,
                checkbox:true,
                cascadeCheck : false,
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
                queryParams : { url:'reportAttributesForEdit_rpt',
                                report_id: report_id },
                method:'get',
                animate:true,
                checkbox:true,
                cascadeCheck : false,
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
        if(typeof checkedArray !== 'undefined' && checkedArray.length > 0) {
             
        
            console.log(checkedArray);
            var attrStr="";
            $.each(checkedArray, function( index, obj ) {

                attrStr+=obj.id+','
                //attrStr='6,7,';
              });
            console.log(attrStr);
            $('#ff').form({
                ajax : true,
                //url:'../../../../slim2_ecoman_admin/',
                url: '../../../slim2_ecoman_admin/report.php/insertReport_rpt',
                queryParams : {
                    //url : 'insertReport_rpt',
                    attr : attrStr,
                    name : $('#tt_textReportName').textbox('getText'),
                    consultant_id : document.getElementById('consultant_id').value,
                    company_id : $('#company_dropdown').combobox('getValue'),
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
                    var jsonObj = $.parseJSON(data);
                    if(jsonObj['found']==true)
                    {
                        if(jsonObj["id"]>0) {
                             noty({text: '<?php echo lang("notyreportinserted"); ?>', type: 'success'});
                             $('#tt_grid').datagrid('reload');
                             $.messager.progress('close');
                         } else {
                             noty({text: '<?php echo lang("notyreportinsertedbefore"); ?>', type: 'warning'});
                             $('#tt_grid').datagrid('reload');
                             $.messager.progress('close');
                         }

                    } else if(data["found"]==false){
                        //$.messager.alert('Save Error', 'Error occured');
                        noty({text: '<?php echo lang("notyreportnotinserted"); ?>', type: 'error'}); 
                        $.messager.progress('close');	// hide progress bar while submit successfully
                    }

                }
                });
                $('#ff').submit();
        }  else {
                noty({text: '<?php echo lang("notyselectreportattribute"); ?>', type: 'warning'});
        }
         
        
    }
    
    
    function submitFormFlowFamily(){  
            console.log($('#flowFamily').val()); 
            $.ajax({
                //url: '../../../../slim2_ecoman_admin/report.php/insertReport',
                url: '../../../slim2_ecoman_admin/report.php/insertReport',
                type: 'POST',
                dataType : 'json',
                data: 'flow='+$('#flowFamily').val(),
                success: function(data, textStatus, jqXHR) {
                  console.warn('success text status-->'+textStatus);
                  if(data["found"]==true) {
                      //$.messager.alert('Success','Success inserted Flow family!','info');
                      if(data["id"]>0) {
                          noty({text: '<?php echo lang("notyreportinserted"); ?>', type: 'success'});
                          $('#tt_tree').tree('reload');
                      } else {
                          noty({text: '<?php echo lang("notyreportinsertedbefore"); ?>', type: 'warning'});
                          $('#tt_tree').tree('reload');
                      }
                      
                  } else if(data["found"]==false) {         
                      //$.messager.alert('Insert failed','Failed to insert Flow Family !','error');
                      noty({text: '<?php echo lang("notyreportnotinserted"); ?>', type: 'error'});  
                      $('#tt_tree').tree('reload');
                  }   
                },
                error: function(jqXHR , textStatus, errorThrown) {
                  //console.warn('error text status-->'+textStatus);
                  noty({text: '<?php echo lang("notyreportnotinserted"); ?>', type: 'error'});  
                }
            });
        }
    
    
    jQuery(document).ready(function() {
        
        
         $('#tt_grid').datagrid({
            url :'../../../Proxy/SlimProxyAdmin.php',
            queryParams : { url : 'getReports_rpt',
                            //flows : JSON.stringify(arrayLeaf),
                            //prj_id : $('#prj_id').val()
                        },
            sortName : 'r_date',
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
                  {field:'report_name',title:'<?php echo lang("report"); ?>',width:100,sortable:true},
                  {field:'r_date',title:'<?php echo lang("reportdate"); ?>',width:100,sortable:true},
                  {field:'company_name',title:'<?php echo lang("company"); ?>',width:100,sortable:true},
                  {field:'company_id',title:'<?php echo lang("company"); ?> ID',width:100,sortable:true,hidden:true},
                  {field:'user_name',title:'<?php echo lang("username"); ?>',width:100},
                  {field:'name',title:'<?php echo lang("name"); ?>',width:100},
                  {field:'surname',title:'<?php echo lang("surname"); ?>',width:100},
                  {field:'report',title:'<?php echo lang("report"); ?>',width:100,align:'center',
                    formatter:function(value,row,index){
                        //console.log('row satır id bilgileri'+row.id);

                        var x = '<a href="#add" class="easyui-linkbutton" \n\
                                    iconCls="icon-save" \n\
                                    onclick="document.getElementById(\'myFrame\').setAttribute(\'src\',\n\
                                    \'http://88.249.18.205:8445/jasperPhpEcoman/master/index.php?Configuration_ID='+row.id+'&Rapor_ID=1\')"><?php echo lang("seereport"); ?></a>';
                        //return e+d;
                        return x;        
                        
                    }  
                },
                /*{field:'flow_details',title:'Flow Details',width:100,align:'center',
                    formatter:function(value,row,index){
                        //console.log('row satır id bilgileri'+row.id);

                        var y = '<a href="#add" class="easyui-linkbutton" \n\
                                    iconCls="icon-save" \n\
                                    onclick="document.getElementById(\'myFrame\').setAttribute(\'src\',\n\
                                    \'http://88.249.18.205:8445/jasperPhpEcoman/master/index.php?Configuration_ID='+row.id+'&Rapor_ID=2\')"> See Flow Details</a>';
                        //return e+d;
                        return y;
                        
                    }
                },*/ 
                {field:'edit',title:'Edit',width:50,align:'center',
                    formatter:function(value,row,index){
                        //console.log('row satır id bilgileri'+row.id);
                        //console.log('row satır name bilgileri'+row.report_name);
                        var x = '<a href="" class="easyui-linkbutton" \n\
                                    iconCls="icon-save" \n\
                                    onclick="reportEditView(\''+row.report_name+'\','+row.id+', \''+row.company_name+'\', '+row.company_id+' );event.preventDefault();"><?php echo lang("edit"); ?></a>';
                        //return e+d;
                        return x;
                        
                    }
                },
                

                  ]],
                });
            //$('#tt_grid2').datagrid('loadData', data);
            $('#tt_grid').datagrid({
               url :'../../../Proxy/SlimProxyAdmin.php',
               queryParams : { url : 'getReports_rpt',
                               //flows : JSON.stringify(arrayLeaf),
                               //prj_id : $('#prj_id').val()
                           }
            });
        
        
 
          $('#tt_tree').tree({
                url: '../../../../Proxy/SlimProxyAdmin.php',
                queryParams : { url:'reportAttributes_rpt' },
                method:'get',
                animate:true,
                checkbox:true,
                cascadeCheck : false,
            });
            
            
            var treeValue;
            var parentnode;
        $("#tt_tree").tree({
                    onCheck: function(node, checked) {
                        var parentnode=$("#tt_tree").tree("getParent", node.target);
                        if(parentnode) {
                            $("#tt_tree").tree('check',parentnode.target);
                            
                        } /*else {
                            //console.log('parent node bulunamadı');
                        }*/
                       
                    },
                    onClick: function(node){
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
                    if(node.state==undefined) {
                            var de=parentnode.text;
                            var test_array=de.split("/");
                            treeValue=test_array[1];
                    } else {
                            //treeValue=parentnode.text;
                    }
    
                    //var imagepath=parentnode.text+"/"+node.text;
                },
                onDblClick: function(node){
                var deneme="test";
                    var parent=$("#tt_tree").tree("getParent",node.target);
                    if(parent) {
                    
                    } else {
                    }
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
	<div class="navbar" style="background: #2D8B42;margin-bottom: 0px;">
		<div class="navbar-inner" style="background: #2D8B42; height:76px;">
			<div class="container-fluid" style="margin-top: 20px">
				<!--<a class="btn btn-navbar" data-toggle="collapse" data-target=".top-nav.nav-collapse,.sidebar-nav.nav-collapse">
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
				</a>-->
				<!--<a class="brand" href=""> <img style="height: 60px;width: 164px;" alt="ECOMAN logo" src="../assets/images/anasayfa.png" /> <span>ECOMAN</span></a>-->
                                <div style="float:left;"><a  style="line-height: 1;
                                    padding-top: 26px;
                                    padding-bottom: 26px;
                                    font-size: 29px;
                                    font-weight: 700; 
                                    color:#fff;" class="navbar-brand" href="<?php echo base_url(''); ?>" style="color:white;">CELERO</a>
                                </div>
                                <div style="float:left;">
                                    <ul class="nav navbar-nav navbar-left ust-nav" style="margin-left: 37px;
                                                                                          font-size: 20px;  
                                                                                          font-weight: bold;">
                                        <li class="navtus" data-rel="profiles"><a style="border:0px;font-size:18px;" id="l1" href="<?php echo base_url('users'); ?>"><span style="margin-top:4px;" class="icon16 icon-white icon-user"></span> <?php echo lang("profiles"); ?></a></li>
                                        <li class="navtus" data-rel="companies"><a style="border:0px;font-size:18px;" id="l2" href="<?php echo base_url('companies'); ?>"><span style="margin-top:4px;" class="icon16 icon-white icon-calendar"></span> <?php echo lang("companies"); ?></a></li>
                                        <li class="navtus" data-rel="projects"><a style="border:0px;font-size:18px;" id="l3" href="<?php echo base_url('projects'); ?>"><span style="margin-top:4px;" class="icon16 icon-white icon-globe"></span> <?php echo lang("projects"); ?></a></li>
                                        <li class="navtus" data-rel="analysis"><a style="border:0px;font-size:18px;" id="l4" href="<?php echo base_url('cost_benefit'); ?>" style="background-color: rgb(132, 191, 195);"><span style="margin-top:4px;" class="icon16 icon-white icon-th"></span> <?php echo lang("analysis"); ?></a></li>
                                        
                                    </ul>
                                </div>  
                                <div style="float:left;
                                            height: 87px;
                                            //background: #F5F4CB;
                                            background: #00bdef;
                                            margin-top: -26px;
                                            margin-left: -11px;">
                                    <ul class="nav navbar-nav navbar-left ust-nav" style=" 
                                                                                          font-size: 20px;
                                                                                          font-weight: bold;
                                                                                          margin: 25px 0px 25px 0px;">  
                                        
                                        <li class="navtus" data-rel="reporting"><a style="border:0px;font-size:18px;color:white;" id="l5" href="<?php echo base_url('allreports'); ?>" ><span style="margin-top:4px;" class="icon16 icon-white icon-list-alt"></span> <?php echo lang("reporting"); ?></a></li>
                                    </ul>
                                </div> 
                                
                                    
				<!-- theme selector starts -->
				<!--<div class="btn-group pull-right theme-container" >
					<a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
						<i class="icon-tint"></i><span class="hidden-phone"> Change Theme/ Skin</span>
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
				</div>-->
				<!-- theme selector ends -->
				
				<!-- user dropdown starts -->
				<div class="btn-group pull-right" >
                                        <ul class="nav navbar-nav navbar-right">
                                            <li><a href='<?php echo base_url('language/switch/turkish'); ?>' style="padding-right: 0px; border-right: 0px;border-left: 0px; "><img src="<?php echo asset_url('images/Turkey.png'); ?>"></a></li>
                                            <li><a href='<?php echo base_url('language/switch/english'); ?>' style="border-right: 0px;border-left: 0px;"><img src="<?php echo asset_url('images/United-States.png'); ?>"></a></li>
                                        </ul>
					<a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
						<i class="icon-user"></i><span class="hidden-phone"> <?php echo $userName;  ?></span>
						<span class="caret"></span>
					</a>
					<ul class="dropdown-menu">
						<li><a href="<?php echo base_url('user'); ?>/<?php echo $userName; ?>"><?php echo lang("profiles"); ?></a></li>
						<li class="divider"></li>
						<li><a href="<?php echo base_url('logout'); ?>"><?php echo lang("logout"); ?></a></li>
					</ul>
				</div>
                                <div style="clear:both;"></div>
				<!-- user dropdown ends -->
				
				<!--<div class="top-nav nav-collapse">
					<ul class="nav">
						<li><a href="../../ecoman">Main Page</a></li>
						<li>
							<form class="navbar-search pull-left">
								<input placeholder="Search" class="search-query span2" name="query" type="text">
							</form>
						</li>
					</ul>
				</div><!--/.nav-collapse -->
			</div>
		</div>
	</div>
	<!-- topbar ends -->
        <div style="background: #00bdef; height:52px;margin-bottom: 20px;">
        <!--<div style="background: #F5F4CB; height:52px;margin-bottom: 20px;">-->
            <div>
                <div style="float:left;
                            margin: 17px 20px 16px 179px;">
                    <a style="border:0px;font-size:18px;color:#b30000" id="l1" href="<?php echo base_url('createreport'); ?>">
                        <span style="margin-top:4px;" class="icon16 icon-black icon-picture"></span> <?php echo lang('createreport'); ?>
                    </a>
                </div>
                <div style="float:left;
                            margin: 17px 20px 16px 20px;">
                                <a style="border:0px;font-size:18px;color:#fff" id="l1" href="<?php echo base_url('allreports'); ?>">
                                    <span style="margin-top:4px;" class="icon16 icon-black icon-list-alt"></span> <?php echo lang('allreports'); ?>
                                </a>
                </div>
                <div style="clear:both;"></div>
                <!--<ul class="nav navbar-nav navbar-left ust-nav" style="margin-left: 37px;
                                                                font-size: 20px;
                                                                font-weight: bold;
                                                                display: inline;">
                    <li class="navtus" data-rel="profiles"><a style="border:0px;font-size:18px;" id="l1" href="#"><span style="margin-top:4px;" class="icon16 icon-white icon-user"></span> Profiles</a></li>
                    <li class="navtus" data-rel="companies"><a style="border:0px;font-size:18px;" id="l2" href="#"><span style="margin-top:4px;" class="icon16 icon-white icon-info-sign"></span> Companies</a></li>
                    <li class="navtus" data-rel="projects"><a style="border:0px;font-size:18px;" id="l3" href="#"><span style="margin-top:4px;" class="icon16 icon-white icon-globe"></span> Projects</a></li>
                    <li class="navtus" data-rel="analysis"><a style="border:0px;font-size:18px;" id="l4" href="#" style="background-color: rgb(132, 191, 195);"><span style="margin-top:4px;" class="icon16 icon-white icon-th"></span> Analysis</a></li>

                </ul>-->
            </div>
            
        </div> 
        <div class="container-fluid" style="background: #E0EDDF">
		<div class="row-fluid">
				
			<!-- left menu starts -->
			<div class="span2 main-menu-span">
				<div class="well nav-collapse sidebar-nav">
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
						<a href="/ecoman"><?php echo lang("mainpage"); ?></a> <span class="divider">/</span>
					</li>
					<li>
						<a href="<?php echo base_url('createreport'); ?>"><?php echo lang("createreport"); ?></a>
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
                            <div class="box span4">
					<div class="box-header well" data-original-title>
						<h2><i class="icon-user"></i><?php echo lang("reportattr"); ?></h2>
						<div class="box-icon">
							<a href="#" class="btn btn-minimize btn-round"><i class="icon-chevron-up"></i></a>
							<!--<a href="#" class="btn btn-close btn-round"><i class="icon-remove"></i></a>-->
						</div>
					</div>
					<div class="box-content" style='padding: 0px;'>
						
							<div class="easyui-panel" title="<?php echo lang("reportattr"); ?>"  style="height:250px;" data-options="">
                                                            <ul id="tt_tree"  checkbox="true" ></ul>
                                                        </div>
						
					</div>
				</div><!--/span-->
                                
                                <div class="box span8">
					<div class="box-header well" data-original-title>
						<h2><i class="icon-user"></i><?php echo lang("savereport"); ?> </h2>
						<div class="box-icon">
							<a href="#" class="btn btn-minimize btn-round"><i class="icon-chevron-up"></i></a>
							<!--<a href="#" class="btn btn-close btn-round"><i class="icon-remove"></i></a>-->
						</div>
					</div>
					
                                        <div class="box-content" style='padding: 0px;'>
                                                <div id="p2" class="easyui-panel" style="height:250px;" title="<?php echo lang("notywritereportnameandcompany"); ?>" 
                                                     style="margin: auto 0;height:480px;"
                                                    data-options="iconCls:'icon-save',collapsible:true,closable:true">
                                                      <form id="ff" method="post">
                                                        <div style="padding:10px 60px 20px 60px">
                                                            <div style="margin-bottom: 4px;margin-left: -8px;">
                                                                <label style="margin-right:18px;"><?php echo lang("report"); ?>:</label>
                                                                <input id="tt_textReportName" class="easyui-textbox" type="text" name="name" data-options="required:true"></input>
                                                            </div>
                                                            
                                                            <div style="margin-left:-8px;">
                                                                <label style="margin-right: 17px;
                                                                                padding-bottom: 3px;"><?php echo lang("company"); ?>:</label>
                                                                <input class="easyui-combobox" 
                                                                    name="company_dropdown" id="company_dropdown"
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



                                                    <div data-options="region:'south',border:false" style="text-align:left;padding:5px 0 0;">
                                                        <!--<input type="submit" value="Save IS potentials table">-->
                                                        <a class="easyui-linkbutton" id="saveReport" name="saveReport"
                                                           style='margin-left: 50px;'
                                                           data-options="iconCls:'icon-ok'" 
                                                           href="javascript:void(0)" 
                                                           onclick="saveReport();" style=""><?php echo lang("savereport"); ?></a>
                                                        <a class="easyui-linkbutton" id="updateReport" name="updateReport"
                                                           style='margin-left: 7px;'
                                                           data-options="iconCls:'icon-ok',disabled:true" 
                                                           href="javascript:void(0)" 
                                                           onclick="updateReport();" style=""><?php echo lang("updatereport"); ?></a>
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
                                            <h2><i class="icon-th"></i><?php echo lang("allreports"); ?> </h2>
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
                                                     title="<?php echo lang("reportsalreadyprepared"); ?>" 
                                                     style="margin: auto 0;height:350px;"
                                                    data-options="iconCls:'icon-save',collapsible:true,closable:true">
                                                    <table id="tt_grid" data-options="" 
                                                           title="<?php echo lang("companyreportsets"); ?>" 
                                                               contenteditable="" style="height:440px;" 
                                                      accesskey="">
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
                                            <h2><i class="icon-th"></i><?php echo lang("report"); ?>  </h2>
                                            <div class="box-icon">
                                                    <!--<a href="#" class="btn btn-setting btn-round"><i class="icon-cog"></i></a>-->
                                                    <a href="#" class="btn btn-minimize btn-round"><i class="icon-chevron-up"></i></a>
                                                    <!--<a href="#" class="btn btn-close btn-round"><i class="icon-remove"></i></a>-->
                                            </div>
                                    </div>
                                    <div class="box-content" style="padding: 0px;">
                                        <div class="row-fluid" >
                                            
                                            <div class="span12">
                                                <a href="#" name="add" onclick="event.preventDefault();" 
                                                    ></a>  
                                               <iframe src="" id="myFrame" width="100%" marginwidth="0" 
                                                     height="100%" 
                                                     marginheight="0" 
                                                     align="middle" 
                                                     scrolling="auto">
                                                 </iframe>
						
                                                
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
				<p><?php echo lang("totalproducts"); ?>Here settings can be configured...</p> 
			</div>
			<div class="modal-footer">
				<a href="#" class="btn" data-dismiss="modal"><?php echo lang("totalproducts"); ?>Close</a>
				<a href="#" class="btn btn-primary"><?php echo lang("totalproducts"); ?>Save changes</a>
			</div>
		</div>

		<footer>
			<p class="pull-left">&copy; <a href="" target="_blank">CELERO</a> 2015</p>
			
		</footer>
		
	</div>

