
<input type ="hidden" value='<?php echo $userID; ?>' id ='consultant_id' name='consultant_id'></input>

        <div class="container-fluid" style="background: #E0EDDF">
		<div class="row-fluid">
				
			<!-- left menu starts -->
			<div class="span2 main-menu-span">
				<div class="well nav-collapse sidebar-nav">
                                    
                                    
                                    <ul class="nav nav-tabs nav-stacked main-menu">
                                            <li class="nav-header hidden-tablet"><?php echo lang("Validation.adminmenu"); ?></li>
                                            <li><a class="ajax-link" href="<?php echo base_url('admin/newFlow'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("Validation.flowslink"); ?></span></a></li>
                                            <li><a class="ajax-link" href="<?php echo base_url('admin/newProcess'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("Validation.processlink"); ?></span></a></li>
                                            <li><a class="ajax-link" href="<?php echo base_url('admin/newEquipment'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("Validation.equipmentslink"); ?></span></a></li>
                                            <li><a class="ajax-link" href="<?php echo base_url('admin/industrialZones'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("Validation.zoneslink"); ?> </span></a></li>
                                            <li><a class="ajax-link" href="<?php echo base_url('admin/clusters'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("Validation.clusterslink"); ?></span></a></li>
                                            <li><a class="ajax-link" href="<?php echo base_url('admin/employees'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("Validation.clusteremplink"); ?> </span></a></li>
                                            <li><a class="ajax-link" href="<?php echo base_url('admin/consultants'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("Validation.zoneconsultantslink"); ?>  </span></a></li>
                                            <li><a class="ajax-link" href="<?php echo base_url('admin/newEquipment'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("Validation.equipmentslink"); ?></span></a></li>
                                            <li><a class="ajax-link" href="<?php echo base_url('admin/reports'); ?>"><i class="icon-edit"></i><span class="hidden-tablet"><?php echo lang("Validation.reportslink"); ?></span></a></li>

                                    </ul>
                                    
                                    
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
						<a href="<?php echo base_url(''); ?>"><?php echo lang("Validation.mainpage"); ?></a> <span class="divider">/</span>
					</li>
					<li>
						<a href="<?php echo base_url('admin/reports'); ?>"><?php echo lang("Validation.report"); ?></a>
					</li>
				</ul>
			</div>
                        
                        
                        
                        
                        
			<div class="sortable row-fluid">
                            <a  id='toplam_anket_link' data-rel="" title="" class="well span3 top-block" href="<?php echo base_url('admin/rpEmployeesList'); ?>">
					<span class="icon32 icon-red icon-user"></span>
					<div><?php echo lang("Validation.reportemployeelink"); ?></div>
					<div id=''></div>
					<span id ='' class="notification"></span>
				</a> 

				<a data-rel="tooltip" title="" class="well span3 top-block" href="<?php echo base_url('admin/rpConsultantsList'); ?>">
					<span class="icon32 icon-color icon-user"></span>
					<div><?php echo lang("Validation.reportconsultantslink"); ?></div>
					<div id=''></div>
					<span id='' class="notification green"></span>
				</a>

				<a data-rel="tooltip" title="" class="well span3 top-block" href="<?php echo base_url('admin/rpCompaniesInClustersList'); ?>">
					<span class="icon32 icon-color icon-globe"></span>
					<div><?php echo lang("Validation.reportcompaniesinclusterslink"); ?></div>
					<div id=""></div>
					<span class="notification yellow"></span>
				</a>
				
				<a data-rel="tooltip" href="<?php echo base_url('admin/rpEquipmentList'); ?>" title="" class="well span3 top-block" >
					<span class="icon32 icon-color icon-wrench"></span>
					<div><?php echo lang("Validation.reportzoneequipmentlink"); ?></div>
					<div id=""></div>
					<span class="notification red"></span>
				</a>
			</div>
                        
                        <div class="sortable row-fluid">
                            <a  id='toplam_anket_link' data-rel="" title="" class="well span3 top-block" href="<?php echo base_url('admin/rpCompaniesNotInClustersList'); ?>">
					<span class="icon32 icon-red icon-globe"></span>
					<div><?php echo lang("Validation.reportcompaniesnotinclusterslink"); ?></div>
					<div id=''></div>
					<span id ='totalUsers_by_today' class="notification"></span>
				</a> 

				<a data-rel="tooltip" title="" class="well span3 top-block" href="<?php echo base_url('admin/rpCompaniesWasteEmissionList'); ?>">
					<span class="icon32 icon-color icon-inbox"></span>
					<div><?php echo lang("Validation.reportwasteemissionlink"); ?></div>
					<div id=''></div>
					<span id='' class="notification green"></span>
				</a>

				<a data-rel="tooltip" title="" class="well span3 top-block" href="<?php echo base_url('admin/rpCompaniesProductionList'); ?>">
					<span class="icon32 icon-color icon-cart"></span>
					<div><?php echo lang("Validation.reportcompanyproductsink"); ?></div>
					<div id=""></div>
					<span class="notification yellow"></span>
				</a>
				
				<a data-rel="tooltip" title="" class="well span3 top-block" href="<?php echo base_url('admin/rpCompaniesProcessesList'); ?>">
					<span class="icon32 icon-color icon-wrench"></span>
					<div><?php echo lang("Validation.reportcompanyprocesseslink"); ?></div>
					<div id=""></div>
					<span class="notification red"></span>
				</a>
			</div>
                        
                        <div class="sortable row-fluid">
                            <a data-rel="tooltip" title="" class="well span3 top-block" href="<?php echo base_url('admin/rpCompaniesInfoList'); ?>">
					<span class="icon32 icon-yellow icon-users"></span>
					<div><?php echo lang("Validation.reporcompanyinfolink"); ?></div>
					<div id=""></div>
					<span class="notification red"></span>
				</a>

				<a data-rel="tooltip" title="" class="well span3 top-block" href="<?php echo base_url('admin/rpCompaniesList'); ?>">
					<span class="icon32 icon-orange icon-inbox"></span>
					<div><?php echo lang("Validation.reportzonecompanylink"); ?></div>
					<div id=''></div>
					<span id='' class="notification green"></span>
				</a>

				<a data-rel="tooltip" title="" class="well span3 top-block" href="<?php echo base_url('admin/rpCompaniesProjectsList'); ?>">
					<span class="icon32 icon-orange icon-inbox"></span>
					<div><?php echo lang("Validation.reportzonecompanyprojectslink"); ?></div>
					<div id=''></div>
					<span id='' class="notification green"></span>
				</a>
				
				<a data-rel="tooltip" title="" class="well span3 top-block" href="<?php echo base_url('admin/rpCompaniesProjectDetailsList'); ?>">
					<span class="icon32 icon-color icon-wrench"></span>
					<div><?php echo lang("Validation.reportzonecompanyprojectdetailslink"); ?></div>
					<div id=""></div>
					<span class="notification red"></span>
				</a>
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

