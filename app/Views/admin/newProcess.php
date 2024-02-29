<?php  ?>
<script>
    
    function submitFormProcessFamily(){   
            console.log($('#processFamily').val()); 
            $.ajax({
                url: '../../../../slim2_ecoman_admin/index.php/insertProcessFamily',
                type: 'POST',
                dataType : 'json',
                data: 'processFamily='+$('#processFamily').val(),
                success: function(data, textStatus, jqXHR) {
                  console.warn('success text status-->'+textStatus);
                  if(data["found"]==true) {
                      //$.messager.alert('Success','Success inserted Flow family!','info');
                      if(data["id"]>0) {
                          noty({text: '<?php echo lang("Validation.notyprocessinserted"); ?>', type: 'success'});
                          $('#tt_tree_process').tree('reload');
                      } else {
                          noty({text: '<?php echo lang("Validation.notyprocessinsertedbefore"); ?>', type: 'warning'});
                          $('#tt_tree_process').tree('reload');
                      }
                  } else if(data["found"]==false) {         
                      //$.messager.alert('Insert failed','Failed to insert Flow Family !','error');
                      noty({text: '<?php echo lang("Validation.notyprocessnotinserted"); ?>', type: 'error'});  
                      $('#tt_tree_process').tree('reload');
                  }   
                },
                error: function(jqXHR , textStatus, errorThrown) {
                  //console.warn('error text status-->'+textStatus);
                  noty({text: '<?php echo lang("Validation.notyprocessnotinserted"); ?>', type: 'error'});  
                }
            });
        }
    
    
    jQuery(document).ready(function() { 
 
          $('#tt_tree_process').tree({
                url: '../../../../Proxy/SlimProxyAdmin.php',
                queryParams : { url:'processFamilies' },
                method:'get',
                animate:true,
                checkbox:false
            });
            
            
            var treeValue;
            var parentnode;
        $("#tt_tree_process").tree({
                    onClick: function(node){
                    console.log(node);
                    console.log(node.attributes.notroot);
                    /*parentnode=$("#tt_tree").tree("getParent", node.target);
                    console.log(parentnode);
                    if(parentnode==null) {
                        console.log('parent node null');
                    } else {
                        console.log('parent node null de�il');
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
                            treeValue=parentnode.text;
                    }
    
                    var imagepath=parentnode.text+"/"+node.text;
                },
                onDblClick: function(node){
                var deneme="test";
                    var parent=$("#tt_tree_process").tree("getParent",node.target);
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
                  console.warn('success text status-->'+textStatus);
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
                  console.warn('success text status-->'+textStatus);
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
                  console.warn('success text status-->'+textStatus);
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
                  console.warn('success text status-->'+textStatus);
                  //console.warn(data);
                  $('#totalProducts').html(data['totalProducts']);
                }
            });
            
            
                    
             
        });
    
    
</script>

		<div class="container-fluid">
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
					<!--<label id="for-is-ajax" class="hidden-tablet" for="is-ajax"><input id="is-ajax" type="checkbox">Ajax Men�</label>-->
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
						<a href="<?php echo base_url('admin/newProcess'); ?>"><?php echo lang("Validation.processlink"); ?></a>
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
                        
                        <!-- zeynel da�l� flow tree ve form -->
                        <div class="row-fluid sortable">
                            <div class="box span12">
                                    <div class="box-header well" data-original-title>
                                            <h2><i class="icon-th"></i><?php echo lang("Validation.insertprocessfamily"); ?> </h2>
                                            <div class="box-icon">
                                                    <a href="#" class="btn btn-setting btn-round"><i class="icon-cog"></i></a>
                                                    <a href="#" class="btn btn-minimize btn-round"><i class="icon-chevron-up"></i></a>
                                                    <a href="#" class="btn btn-close btn-round"><i class="icon-remove"></i></a>
                                            </div>
                                    </div>
                                    <div class="box-content">
                                        <div class="row-fluid">
                                            <div class="span4">
                                                <div class="easyui-panel" title="<?php echo lang("Validation.processfamily"); ?>" style="width:400px;height:auto;" data-options="">
                                                        <ul id="tt_tree_process" class="easyui-tree" ></ul>
                                                </div>
                                                <!--<div id="ft" style="padding:5px;">
                                                    Footer Content.
                                                </div>-->
                                                
                                            </div>
                                            <div class="span6">
                                                <form class="form-horizontal" style='padding-left:82px;'>
						  <fieldset>
							<legend><?php echo lang("Validation.insertprocessfamily"); ?></legend>
							<div class="control-group">
							  <label class="control-label" for="typeahead"><?php echo lang("Validation.processfamily"); ?></label>
							  <div class="controls">
								<input type="text"  name='processFamily' class="span6 typeahead" id="processFamily"  data-provide="typeahead" data-items="8" 
                                                                       data-source='["Main","energy"]'>
								
							  </div>
							</div>
							
          
							
							<div class="form-actions">
							  <button type="submit" onclick='event.preventDefault();submitFormProcessFamily();' class="btn btn-primary"><?php echo lang("Validation.savedata"); ?></button>
							  <button type="reset" class="btn"><?php echo lang("Validation.resetform"); ?></button>
							</div>
						  </fieldset>
						</form> 
                                                
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
				<button type="button" class="close" data-dismiss="modal">�</button>
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
			<p class="pull-right">Powered by: <a href=""></a></p>
		</footer>
		
	</div>

