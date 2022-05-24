<?php // echo $map['js']; ?>
<?php
    global $company_ids;
    foreach ($companies as $company) {
        $company_ids.= $company['name'].',';
    }
    $company_ids = rtrim($company_ids,',');
?>
<script>
    console.log('<?= $company_ids;  ?>');
    function showMapPanelExpand() {
            //var panelWest = $('#cc').layout('panel','south');
            //var panelSouthNorth = $('#cc2').layout('panel','north');
            //$('#p').panel('expand');
            document.getElementById('myFrame').setAttribute('width','100%');
            document.getElementById('myFrame').setAttribute('height','500');
        }

        function showMapPanelCollapse() {
            //var panelWest = $('#cc').layout('panel','south');
            //var panelSouthNorth = $('#cc2').layout('panel','north');
            //$('#p').panel('expand');
            document.getElementById('myFrame').setAttribute('width','0');
            document.getElementById('myFrame').setAttribute('height','0');
        }

</script>
<div class="container">
	<div class="row">

		<div class="col-md-4">

					<?php if($is_consultant_of_project or $is_contactperson_of_project): ?>
			<div style="margin-bottom:20px; overflow:hidden;">
				<?php if(session()->project_id==$projects['id']): ?>
					<a class="btn btn-inverse btn-block" href="<?= base_url('closeproject'); ?>"><i class="fa fa-times-circle"></i> <?= lang("Validation.closeproject"); ?></a>
				<?php else: ?>
					<?= form_open('openproject'); ?>
						<input type="hidden" name="projectid" value="<?= $projects['id']; ?>">
						<button type="submit" class="btn btn-primary btn-block"><i class="fa fa-plus-square-o"></i> <?= lang("Validation.openproject"); ?></button>
					</form>
				<?php endif ?>
				<a style="margin-top: 10px;" class="btn btn-inverse btn-block" href="<?= base_url("update_project/".$projects['id']); ?>"><i class="fa fa-pencil-square-o"></i> <?= lang("Validation.editprojectinfo"); ?></a>
			    <!--<a onclick="event.preventDefault();window.open('../../IS_OpenLayers/map_prj.php?cmpny=<?= $company_ids; ?>','mywindow','width=900,height=900');" style = 'margin-right: 20px;' class="btn btn-info btn-sm pull-right" >See Project Companies On map</a>-->
					<!--<a onclick="showMapPanelExpand();document.getElementById('myFrame').setAttribute('src','../../IS_OpenLayers/map_prj_prj.php?prj_id=<?= $prj_id; ?>');event.preventDefault();"  class="btn btn-inverse btn-sm" >See Project Companies On map</a>
			    <a class="btn btn-inverse btn-sm" href="#" onclick="showMapPanelCollapse();event.preventDefault();">Close Companies Map</a> -->
				<button class="btn btn-block btn-inverse" style="width:100%; margin-top: 10px;" onclick="$('#target').toggle();">Add New Consultant</button>
					<div id="target" class="well" style="display: none; height:400px;">
						<p>
							Here you can give other Consultants access to your Project. Select Consultants to add.
						</p>
						<div class="content">
							<?= form_open('addConsultantToProject/'.$projects['id']); ?>
								<select id="users" class="info select-block" name="users">
								<?php foreach ($allconsultants as $users): ?>
									<option value="<?= $users['id']; ?>"><?= $users['name'].' '.$users['surname']; ?></option>
									<?php endforeach ?>
								</select>
								<button type="submit" class="btn btn-primary">Add Users</button>
							</form>
						</div>
					</div>
			 </div>
			<?php endif ?>
			<div class="clearfix"></div>

			<div class="form-group">
				<div class="swissheader" style="font-size:15px;"><i class="fa fa-phone"></i> <?= lang("Validation.projectcontact"); ?></div>
					<ul class="nav nav-list">
				<?php foreach ($contact as $con): ?>
					<li><a style="text-transform:capitalize;" href="<?= base_url('user/'.$con['user_name']); ?>"> <?= $con['name'].' '.$con['surname'];?></a></li>
				<?php endforeach ?>
				</ul>
			</div>
			<?php if(session()->role_id=='1'): ?>
				<a style="margin-top: 10px;" class="btn btn-danger btn-block" href="<?= base_url("deleteproject/".$projects['id']); ?>" onclick="return confirm('Are you sure you want to delete the project <?= $projects['name']; ?>? \r\n \r\nWarning: The project will be deleted permanently and cannot be restored!');"><i class="fa fa-trash" ></i> <?= lang("Validation.deleteproject"); ?></a>
			<?php endif ?>
		</div>

		<div class="col-md-8">
			<div class="swissheader">
			<?= $projects['name']; ?>
				<?php if(session()->project_id==$projects['id']): ?>
					<small class="pull-right" style="font-size:10px;"><?= lang("Validation.alreadyopenproject"); ?></small>
				<?php endif ?>
			</div>
			<div class="clearfix"></div>
			<table class="table table-bordered" style="font-size:14px; margin-bottom:10px;">
				<tr>
					<td style="width:100px;">
					<?= lang("Validation.startdate"); ?>
					</td>
					<td>
					<?= $projects['start_date']; ?>
					</td>
				</tr>
				<tr>
					<td>
					<?= lang("Validation.status"); ?>
					</td>
					<td>
					<?= $status['name']; ?>
					</td>
				</tr>
				<tr>
					<td>
					<?= lang("Validation.description"); ?>
					</td>
					<td>
					<?= $projects['description']; ?>
					</td>
				</tr>
			</table>
			<div class="swissheader">
				<i class="fa fa-map-marker"></i> <?= lang("Validation.projectonmap"); ?>
			</div>
                        
                        <!-- harita -->
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.3.1/leaflet.css" />
            <script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.3.1/leaflet.js"></script>
                        <?php
                            //print_r($companies);
                            $company_array = array();
                            foreach ($companies as $com => $k) {
                                    $company_array[$com][0] = $k['latitude'];
                                    $company_array[$com][1] = $k['longitude'];
                                    $company_array[$com][2] = "<a href='".base_url('company/'.$k['id'])."'>".$k['name']."</a>";
                            }
                            //print_r($company_array);
                        ?>
                        
                        <!-- leaflet map -->
                        <div id="map"></div>
				<script type="text/javascript">
                                    var planes = <?= json_encode($company_array); ?>;
                                    var bounds = new L.LatLngBounds(planes);

                            		var map = L.map('map', {
           								center: [48.505, 11.59],
							           	zoom: 3
							        });
                            map.fitWorld().zoomIn();

                                            map.on('resize', function(e) {
                                                map.fitWorld({reset: true}).zoomIn();
                                            });
                    mapLink =
                        '<a href="http://openstreetmap.org">OpenStreetMap</a>';
                    L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                                                    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
                                            }).addTo(map);

                                            for (var i = 0; i < planes.length; i++) {
                                                    marker = new L.marker([planes[i][0],planes[i][1]])
                                                            .bindPopup(planes[i][2])
                                                            .addTo(map);
                                            }
				</script>
                    <!-- leaflet map end-->    
                        
                        
                        
                        
                        
			<!--<iframe src="../../IS_OpenLayers/map_prj_prj.php?prj_id=<?= $prj_id; ?>" id="myFrame"  marginwidth="0" width='100%' height='500' marginheight="0"  align="middle" scrolling="auto"></iframe>-->
			<?php //echo $map['html']; ?>

			<div class="row">
				<div class="col-md-6">
					<div class="form-group">
						<div class="swissheader" style="font-size:15px;"><i class="fa fa-users"></i> <?= lang("Validation.projectconsultants"); ?></div>
							<ul class="nav nav-list">
						<?php foreach ($constant as $cons): ?>
							<li><a style="text-transform:capitalize;" href="<?= base_url('user/'.$cons['user_name']); ?>"> <?= $cons['name'].' '.$cons['surname']; ?></a></li>
						<?php endforeach ?>
						</ul>
					</div>
				</div>
				<div class="col-md-6">
					<div class="form-group">
						<div class="swissheader" style="font-size:15px;"><i class="fa fa-building"></i> <?= lang("Validation.projectcompanies"); ?></div>
							<ul class="nav nav-list">
						<?php foreach ($companies as $company): ?>
							<li><a style="text-transform:capitalize;" href="<?= base_url('company/'.$company['id']); ?>"> <?= $company['name'];?></a></li>
						<?php endforeach ?>
						</ul>
					</div>
				</div>
			</div>
			
		</div>
	</div>
</div>
