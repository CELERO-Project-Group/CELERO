<div class="container">
	<div class="row">
		<div class="col-md-8">
				<div class="swissheader"><?= lang("Validation.allprojects"); ?></div>
						<!-- harita -->
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.3.1/leaflet.css" />
            <script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.3.1/leaflet.js"></script>
				<?php
				$project_array = array();
                                $counter=0;
			 	foreach ($projects as $prj => $k) {
//print_r($prj);
//print_r($k);
                                    if($k['latitude']!="" || $k['longitude']!="") {
                                        $project_array[$prj][0] = $k['latitude'];
					$project_array[$prj][1] = $k['longitude'];
					$project_array[$counter][2] = "<a href='".base_url('project/'.$k['id'])."'>".$k['name']."</a>";
                                    } else {
                                        $project_array[$prj][0] = '39';
					$project_array[$prj][1] = '32';
					$project_array[$prj][2] = "<a href='".base_url('project/'.$k['id'])."'>".$k['name']."</a>";
                                    }
                                    /*if($k['latitude']!="" && $k['longitude']!="") {
                                        $project_array[$prj][0] = $k['latitude'];
					$project_array[$prj][1] = $k['longitude'];
					$project_array[$prj][2] = "<a href='".base_url('project/'.$k['id'])."'>".$k['name']."</a>";
                                    }*/

                                    /*$project_array[$prj][0] = $k['latitude'];
                                    $project_array[$prj][1] = $k['longitude'];
                                    $project_array[$prj][2] = "<a href='".base_url('project/'.$k['id'])."'>".$k['name']."</a>";

                                     */
                                    $counter++;
				}
				//print_r($project_array);
				?>
				<div id="map"></div>
				<script type="text/javascript">

  			var project = <?= json_encode($project_array); ?>;
                        //console.log(project);
  			var bounds = new L.LatLngBounds(project);

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

				for (var i = 0; i < project.length; i++) {
                                    /*if(project[i][0]!=null || project[i][1]!=null) {
                                        marker = new L.marker([project[i][0],project[i][1]])
						.bindPopup(project[i][2])
						.addTo(map);
                                    }*/
                                    marker = new L.marker([project[i][0],project[i][1]])
						.bindPopup(project[i][2])
						.addTo(map);

				}
				</script>
				<!-- harita bitti -->
			<table class="table-hover" style="clear:both; width: 100%;">
			<?php foreach ($projects as $pro): ?>
				<tr>
        <td style="padding: 10px 15px;">
          <a href="<?= base_url('project/'.$pro['id']) ?>">
          <div class="row">
            <div class="col-md-9">
              <div><b><?= $pro['name']; ?></b></div>
              <div><span style="color:#999999; font-size:12px;"><?= $pro['description']; ?></span></div>
            </div>
            <div class="col-md-3">
              <?php if($pro['have_permission']==1): ?>
              <div style="overflow:hidden;">
                <?php if(session()->project_id==$pro['id']): ?>
                  <a class="btn btn-tuna" href="<?= base_url('closeproject'); ?>"><i class="fa fa-times-circle"></i> Close This Project</a>
                <?php else: ?>
                  <?= form_open('openproject'); ?>
                    <input type="hidden" name="projectid" value="<?= $pro['id']; ?>">
                    <button type="submit" class="btn btn-tuna"><i class="fa fa-plus-square-o"></i> <?= lang("Validation.openproject"); ?></button>
                  </form>
                <?php endif ?>
              <a class="btn btn-tuna" href="<?= base_url("update_project/".$pro['id']); ?>"><i class="fa fa-pencil-square-o"></i> <?= lang("Validation.editprojectinfo"); ?></a>
            <?php endif ?>
            </div>
          </div>
          </a>
        </td>
        </tr>
			<?php endforeach ?>
			</table>
		</div>
		<div class="col-md-4">
			<div class="well">
        <?= lang("Validation.allprojectsinfo"); ?>
			</div>
		</div>
	</div>
</div>
