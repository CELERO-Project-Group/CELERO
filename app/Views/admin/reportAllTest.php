<script>
    
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
        //alert($('#project_id').val());
        //alert($('#reportType_dropdown').combobox('getValue'));
        //alert($('#company_dropdown').combobox('getValue'));
        if($('#reportType_dropdown').combobox('getValue')>0 && $('#company_dropdown').combobox('getValue') > 0) {  
            if($('#reportType_dropdown').combobox('getValue')==2) {
                document.getElementById('myFrame').setAttribute('src','http://88.249.18.205:8445/jasperPhpEcoman/master/index.php?company_id='+$('#company_dropdown').combobox('getValue')+'&Rapor_ID=3');
            } else if ($('#reportType_dropdown').combobox('getValue')==3) {
                document.getElementById('myFrame').setAttribute('src','http://88.249.18.205:8445/jasperPhpEcoman/master/index.php?company_id='+$('#company_dropdown').combobox('getValue')+'&Rapor_ID=5');
            } else if($('#reportType_dropdown').combobox('getValue')==1){ 
                document.getElementById('myFrame').setAttribute('src','http://88.249.18.205:8445/jasperPhpEcoman/master/index.php?company_id='+$('#company_dropdown').combobox('getValue')+'&Rapor_ID=4');
            } else if($('#reportType_dropdown').combobox('getValue')==4) {
                document.getElementById('myFrame').setAttribute('src','http://88.249.18.205:8445/jasperPhpEcoman/master/index.php?company_id='+$('#company_dropdown').combobox('getValue')+'&Rapor_ID=6');
            } else if($('#reportType_dropdown').combobox('getValue')==5) {
                document.getElementById('myFrame').setAttribute('src','http://88.249.18.205:8445/jasperPhpEcoman/master/index.php?company_id='+$('#company_dropdown').combobox('getValue')+'&Rapor_ID=7');
            } else if($('#reportType_dropdown').combobox('getValue')==6) {
                document.getElementById('myFrame').setAttribute('src','http://88.249.18.205:8445/jasperPhpEcoman/master/index.php?company_id='+$('#company_dropdown').combobox('getValue')+'&Rapor_ID=17&project_id='+$('#project_id').val()+'');
            } else if($('#reportType_dropdown').combobox('getValue')==7) {
                document.getElementById('myFrame').setAttribute('src','http://88.249.18.205:8445/jasperPhpEcoman/master/index.php?Rapor_ID=18&project_id='+$('#project_id').val()+'');
            } else if($('#reportType_dropdown').combobox('getValue')==8) {
                document.getElementById('myFrame').setAttribute('src','http://88.249.18.205:8445/jasperPhpEcoman/master/index.php?company_id='+$('#company_dropdown').combobox('getValue')+'&Rapor_ID=19&project_id='+$('#project_id').val()+'');
            } else if($('#reportType_dropdown').combobox('getValue')==9) {
                document.getElementById('myFrame').setAttribute('src','http://88.249.18.205:8445/jasperPhpEcoman/master/index.php?company_id='+$('#company_dropdown').combobox('getValue')+'&Rapor_ID=20&project_id='+$('#project_id').val()+'');
            }      
            
            
            //document.getElementById('myFrame').setAttribute('src','http://88.249.18.205:8445/jasperPhpEcoman/master/index.php?company_id=132&Rapor_ID=3');
        }  else {
                noty({text: ' <?php echo lang("Validation.notyselectreportandcompany"); ?>', type: 'warning'});
        }
    }

    jQuery(document).ready(function() {
        
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
<input type ="hidden" value='<?php echo $project_id; ?>' id ='project_id' name='project_id'></input>
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
                                        <li class="navtus" data-rel="profiles"><a style="border:0px;font-size:18px;" id="l1" href="<?php echo base_url('users'); ?>"><span style="margin-top:4px;" class="icon16 icon-white icon-user"></span> <?php echo lang("Validation.profiles"); ?></a></li>
                                        <li class="navtus" data-rel="companies"><a style="border:0px;font-size:18px;" id="l2" href="<?php echo base_url('companies'); ?>"><span style="margin-top:4px;" class="icon16 icon-white icon-calendar"></span><?php echo lang("Validation.companies"); ?></a></li>
                                        <li class="navtus" data-rel="projects"><a style="border:0px;font-size:18px;" id="l3" href="<?php echo base_url('projects'); ?>"><span style="margin-top:4px;" class="icon16 icon-white icon-globe"></span><?php echo lang("Validation.projects"); ?></a></li>
                                        <li class="navtus" data-rel="analysis"><a style="border:0px;font-size:18px;" id="l4" href="<?php echo base_url('cost_benefit'); ?>" style="background-color: rgb(132, 191, 195);"><span style="margin-top:4px;" class="icon16 icon-white icon-th"></span><?php echo lang("Validation.analysis"); ?></a></li>
                                        
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
                                        
                                        <li class="navtus" data-rel="reporting"><a style="border:0px;font-size:18px;color:white;" id="l5" href="<?php echo base_url('allreports'); ?>" ><span style="margin-top:4px;" class="icon16 icon-black icon-list-alt"></span><?php echo lang("Validation.reporting"); ?> </a></li>
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
                                            <li><a href='<?php echo base_url('language/switch/turkish'); ?>' style="padding-right: 0px; border-right: 0px;border-left: 0px; "><img src="<?php echo base_url('assets/images/Turkey.png'); ?>"></a></li>
                                            <li><a href='<?php echo base_url('language/switch/english'); ?>' style="border-right: 0px;border-left: 0px;"><img src="<?php echo base_url('assets/images/United-States.png'); ?>"></a></li>
                                        </ul>
					<a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
						<i class="icon-user"></i><span class="hidden-phone"> <?php echo $userName;  ?></span>
						<span class="caret"></span>
					</a>
					<ul class="dropdown-menu">
						<li><a href="<?php echo base_url('user'); ?>/<?php echo $userName; ?>"><?php echo lang("Validation.profiles"); ?></a></li>
						<li class="divider"></li>
						<li><a href="<?php echo base_url('logout'); ?>"><?php echo lang("Validation.logout"); ?></a></li>
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
                    <a style="border:0px;font-size:18px;color:#fff;" id="l1" href="<?php echo base_url('createreport'); ?>">
                        <span style="margin-top:4px;" class="icon16 icon-dark icon-picture"></span><?php echo lang("Validation.createreport"); ?>
                    </a>
                </div>
                <div style="float:left;
                            margin: 17px 20px 16px 20px;">
                                <a style="border:0px;font-size:18px;color:#b30000" id="l1" href="<?php echo base_url('allreports'); ?>">
                                    <span style="margin-top:4px;" class="icon16 icon-black icon-list-alt"></span><?php echo lang("Validation.allreports"); ?> 
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
						<li class="nav-header hidden-tablet"><?php echo lang("Validation.mainmenu"); ?></li>
						<li><a class="ajax-link" href="<?php echo base_url(); ?>"><i class="icon-home"></i><span class="hidden-tablet"> <?php echo lang("Validation.mainpage"); ?></span></a></li>
                                                
                                                <li><a class="ajax-link" href="<?php echo base_url('users'); ?>"><i class="icon-user"></i><span class="hidden-tablet"><?php echo lang("Validation.consultants"); ?></span></a></li>
                                                <li><a class="ajax-link" href="<?php echo base_url('user'); ?>/<?php echo $userName; ?>"><i class="icon-user"></i><span class="hidden-tablet"><?php echo lang("Validation.myprofile"); ?></span></a></li>
                                                <li><a class="ajax-link" href="<?php echo base_url('profile_update'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("Validation.updateprofile"); ?></span></a></li>
                                                
                                                
						<li><a class="ajax-link" href="<?php echo base_url('mycompanies'); ?>"><i class="icon-calendar"></i><span class="hidden-tablet"><?php echo lang("Validation.mycompanies"); ?></span></a></li>
                                                <!--<li><a class="ajax-link" href="<?php echo base_url('projectcompanies'); ?>"><i class="icon-calendar"></i><span class="hidden-tablet"><?php echo lang("Validation.myprofile"); ?>Project Companies</span></a></li>-->
                                                <li><a class="ajax-link" href="<?php echo base_url('companies'); ?>"><i class="icon-calendar"></i><span class="hidden-tablet"><?php echo lang("Validation.allcompanies"); ?></span></a></li>
                                                <li><a class="ajax-link" href="<?php echo base_url('newcompany'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("Validation.createcompany"); ?></span></a></li>
                                                
                                                
                                                <li><a class="ajax-link" href="<?php echo base_url('myprojects'); ?>"><i class="icon-globe"></i><span class="hidden-tablet"><?php echo lang("Validation.myprojects"); ?></span></a></li>
                                                <li><a class="ajax-link" href="<?php echo base_url('projects'); ?>"><i class="icon-globe"></i><span class="hidden-tablet"><?php echo lang("Validation.allprojects"); ?></span></a></li>
                                                <li><a class="ajax-link" href="<?php echo base_url('newproject'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("Validation.createproject"); ?></span></a></li>
                                                
                                                
						<li><a class="ajax-link" href="<?php echo base_url('cpscoping'); ?>"><i class="icon-th"></i><span class="hidden-tablet"><?php echo lang("Validation.cpidentification"); ?></span></a></li>
                                                <li><a class="ajax-link" href="<?php echo base_url('cost_benefit'); ?>"><i class="icon-th"></i><span class="hidden-tablet"><?php echo lang("Validation.costbenefitanalysis"); ?> </span></a></li>
                                                <li><a class="ajax-link" href="<?php echo base_url('ecotracking'); ?>"><i class="icon-th"></i><span class="hidden-tablet"><?php echo lang("Validation.ecotracking"); ?> </span></a></li>
                                                
                                                <li><a class="ajax-link" href="<?php echo base_url('isScopingPrjBaseMDF'); ?>"><i class="icon-th"></i><span class="hidden-tablet"><?php echo lang("Validation.industrialsimbiosis"); ?> </span></a></li>
                                                <li><a class="ajax-link" href="<?php echo base_url('map'); ?>"><i class="icon-th"></i><span class="hidden-tablet"><?php echo lang("Validation.gis"); ?> </span></a></li>
                           
						<li><a class="ajax-link" href="<?php echo base_url('logout'); ?>"><i class="icon-ban-circle"></i><span class="hidden-tablet"><?php echo lang("Validation.logout"); ?> </span></a></li>
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
						<a href="/ecoman"><?php echo lang("Validation.mainpage"); ?></a> <span class="divider">/</span>
					</li>
					<li>
						<a href="<?php echo base_url('createreport'); ?>"><?php echo lang("Validation.allreports"); ?></a>
					</li>
				</ul>
			</div>
                        
                        
                        
                        
                        
			<div class="sortable row-fluid">
                            <a  id='toplam_anket_link' data-rel="" title="" class="well span3 top-block" href="#">
					<span class="icon32 icon-red icon-user"></span>
					<div><?php echo lang("Validation.totaluserscount"); ?></div>
					<div id='totalUsers'></div>
					<span id ='totalUsers_by_today' class="notification"></span>
				</a>
 
				<a data-rel="tooltip" title="" class="well span3 top-block" href="#">
					<span class="icon32 icon-color icon-inbox"></span>
					<div><?php echo lang("Validation.totalprojectscount"); ?></div>
					<div id='totalProjects'></div>
					<span id='totalProjects_by_today' class="notification green"></span>
				</a>

				<a data-rel="tooltip" title="" class="well span3 top-block" href="#">
					<span class="icon32 icon-color icon-cart"></span>
					<div><?php echo lang("Validation.totalisprojectscount"); ?></div>
					<div id="totalISProjects"></div>
					<span class="notification yellow"></span>
				</a>
				
				<a data-rel="tooltip" title="" class="well span3 top-block" href="#">
					<span class="icon32 icon-color icon-wrench"></span>
					<div><?php echo lang("Validation.totalproducts"); ?></div>
					<div id="totalProducts"></div>
					<span class="notification red"></span>
				</a>
			</div>
                         
                        <div class="row-fluid sortable">  
                             <div class="box span12">
					<div class="box-header well" data-original-title>
						<h2><i class="icon-user"></i><?php echo lang("Validation.allreports"); ?></h2>  
						<div class="box-icon">
							<a href="#" class="btn btn-minimize btn-round"><i class="icon-chevron-up"></i></a>
							<!--<a href="#" class="btn btn-close btn-round"><i class="icon-remove"></i></a>-->
						</div>
					</div>
					
                                        <div class="box-content" style='padding: 0px;'>
                                                <div id="p2" class="easyui-panel" style="height:250px;" title="<?php echo lang("Validation.notypickreporttypeandcompany"); ?>" 
                                                     style="margin: auto 0;height:480px;"
                                                    data-options="iconCls:'icon-save',collapsible:true,closable:true">
                                                      <form id="ff" method="post">
                                                        <div style="padding:10px 60px 20px 60px">
                                                            <div style="margin-bottom: 4px;margin-left: -8px;">
                                                                <label style="margin-right:18px;"><?php echo lang("Validation.reporttype"); ?>:</label>
                                                                <input class="easyui-combobox" 
                                                                    name="reportType_dropdown" id="reportType_dropdown"
                                                                    data-options="

                                                                            url :'../../../../Proxy/SlimProxyAdmin.php?url=getReportTypes_rpt',
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
                                                            
                                                            <div style="margin-left:-8px;">
                                                                <label style="margin-right: 17px;
                                                                                padding-bottom: 3px;"><?php echo lang("Validation.companyname"); ?>:</label>
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
                                                           onclick="saveReport();" style=""><?php echo lang("Validation.seereport"); ?></a>
                                                        <!--<a class="easyui-linkbutton" id="updateReport" name="updateReport"
                                                           style='margin-left: 7px;'
                                                           data-options="iconCls:'icon-ok',disabled:true" 
                                                           href="javascript:void(0)" 
                                                           onclick="updateReport();" style="">Update Report</a>-->
                                                        <!--<a class="easyui-linkbutton" 
                                                           style='margin-left: 7px;'
                                                           data-options="iconCls:'icon-ok'" 
                                                           href="javascript:void(0)" 
                                                           onclick="resetFormReport();" style="">Reset Form</a>-->
                                                        <!--<a class="easyui-linkbutton" data-options="iconCls:'icon-ok'" href="javascript:void(0)" onclick="submitForm();" style="">Save IS potentials table</a>-->
                                                        <!--<a class="easyui-linkbutton" data-options="iconCls:'icon-cancel'" href="javascript:void(0)" onclick="windowManualISQuitWithoutSaving();" style="">Quit without saving</a>-->
                                                    </div>
                                                    </form>  

                                               </div>
                                        </div>
					
				</div><!--/span-->
                        </div>
                        
                        <!-- zeynel dağlı jasper report -->
                        <div class="row-fluid sortable">
                            <div class="box span12">
                                    <div class="box-header well" data-original-title>
                                            <h2><i class="icon-th"></i> <?php echo lang("Validation.report"); ?> </h2>
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
				<h3><?php echo lang("Validation.notyselectreportandcompany"); ?>Settings</h3>
			</div>
			<div class="modal-body">
				<p><?php echo lang("Validation.notyselectreportandcompany"); ?>Here settings can be configured...</p> 
			</div>
			<div class="modal-footer">
				<a href="#" class="btn" data-dismiss="modal">Close</a>
				<a href="#" class="btn btn-primary"><?php echo lang("Validation.notyselectreportandcompany"); ?>Save changes</a>
			</div>
		</div>

		<footer>
			<p class="pull-left">&copy; <a href="" target="_blank">CELERO</a> 2015</p>
			
		</footer>
		
	</div>

