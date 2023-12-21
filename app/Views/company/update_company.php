<div class="container">
	<p class="lead"><?= lang("Validation.editcompanyinfo"); ?></p>

	<?php
		if($validation != NULL)
		echo $validation->listErrors();
	?>
		
	<form action="<?= $companies['id'] ?>" method="post" autocomplete="off">
	<?= csrf_field() ?>

	<input class="form-control" id="id" value="<?= set_value('id',$companies['id']); ?>" name="id" type="hidden" />

	<div class="row">
		<div class="col-md-8">
			<div class="form-group">
    			<label for="companyName"><?= lang("Validation.companyname"); ?></label>
    			<input type="text" class="form-control" id="companyName" placeholder="<?= lang("Validation.companyname"); ?>" value="<?= set_value('companyName',$companies['name']); ?>" name="companyName">
 			</div>
 			<div class="form-group">
	 			<label for="naceCode"><?= lang("Validation.nacecode"); ?></label>
		    	<button type="button" data-toggle="modal" data-target="#myModalNACE" class="btn btn-block btn-primary" id="nacecode-button"><?= lang("Validation.selectnace"); ?></button><br>
	    		<div class="row">
		    		<div class="col-md-12">
		    			<input type="text" class="form-control" placeholder="NACE Code" id="naceCode" name="naceCode" style="color:#333333;" value="<?= set_value('naceCode',$nace_code['code']); ?>" readonly/>
		    		</div>
		    	</div>

				<!--<label for="naceCode"><?= lang("Validation.nacecode"); ?></label>
				<select id="selectize" name="naceCode">
					<?php foreach ($all_nace_codes as $anc): ?>
						<?php if($nace_code['code']==$anc['code']) {$d=TRUE;} else {$d=FALSE;} ?>
						<option value="<?= $anc['code']; ?>" <?= set_select('naceCode', $anc['code'], $d); ?> ><?= $anc['code']; ?></option>
					<?php endforeach ?>
				</select>-->
 			</div>
			<div class="form-group">
    			<label for="email"><?= lang("Validation.email"); ?></label>
    			<input type="text" class="form-control" id="email" placeholder="<?= lang("Validation.email"); ?>" value="<?= set_value('email',$companies['email']); ?>"  name="email">
 			</div>
			<!-- <div class="form-group">
    			<label for="cellPhone">Cell Phone</label>
    			<input type="text" class="form-control" id="cellPhone" placeholder="Cell Phone" value="<?= set_value('cellPhone',$companies['phone_num_1']); ?>" name="cellPhone">
 			</div>  -->
 			<div class="form-group">
    			<label for="workPhone"><?= lang("Validation.workphone"); ?></label>
    			<input type="text" class="form-control" id="workPhone" placeholder="<?= lang("Validation.workphone"); ?>" value="<?= set_value('workPhone',$companies['phone_num_2']); ?>" name="workPhone">
 			</div>
 			<div class="form-group">
    			<label for="coordinates"><?= lang("Validation.coordinates"); ?></label><br>
    			<button type="button" data-toggle="modal" data-target="#myModal" class="btn btn-primary btn-block" id="coordinates" ><?= lang("Validation.selectonmap"); ?></button>
    			<div class="row" style="margin-top: 10px;">
	    			<div class="col-md-6">
	    				<input type="text" class="form-control" id="lat" placeholder="<?= lang("Validation.lat"); ?>" name="lat" style="color:#333333;" value="<?= set_value('lat',$companies['latitude']); ?>" readonly/>
	    			</div>
	    			<div class="col-md-6">
	    				<input type="text" class="form-control" id="long" placeholder="<?= lang("Validation.long"); ?>" name="long" style="color:#333333;" value="<?= set_value('long',$companies['longitude']); ?>" readonly/>
	    			</div>
    			</div>
 			</div>
 			<div class="form-group">
    			<label for="companyDescription"><?= lang("Validation.description"); ?></label>
    			<textarea class="form-control" rows="3" name="companyDescription" id="companyDescription" placeholder="<?= lang("Validation.description"); ?>"><?= set_value('companyDescription',$companies['description']); ?></textarea>
 			</div>
        <button type="submit" class="btn btn-inverse col-md-9"><?= lang("Validation.save"); ?></button>
        <a href="<?= base_url('company/'.$companies['id']); ?>" class="btn btn-warning col-md-2 col-md-offset-1"><?= lang("Validation.cancel"); ?></a>
			</div>
		</div>
	</form>
	<!-- NACE MODAL -->
	<div class="modal fade" id="myModalNACE" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
		aria-hidden="true">
		<div class="modal-dialog-nace">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
					<h4 class="modal-title" id="myModalLabel">
						<?= lang("Validation.selectlevel4nace"); ?>
					</h4>
					<hr>
					<div class="row">
						<div class="col-md-12">
							<input type="text" class="form-control" id="naceCode" name="nace-code"
								style="color:#333333;" readonly />
						</div>
					</div>
				</div>
				<div class="modal-body">
					<!-- Miller column NACE Code selector -->
					<div id="miller_col"></div>
					<br>
					<button type="button" data-dismiss="modal" class="btn btn-info btn-block" aria-hidden="true">
						<?= lang("Validation.done"); ?>
					</button>
				</div>
				<div class="modal-footer"></div>
			</div>
		</div>
	</div>
</div>
<!-- MAP MODAL -->
<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
					<h4 class="modal-title" id="myModalLabel">Click Map</h4>
					<hr>
					<div class="row">
						<div class="col-md-6">
							<input type="text" class="form-control" id="latId" name="lat" style="color:#333333;"
							value="<?= set_value('lat',$companies['latitude']); ?>" readonly />
						</div>
						<div class="col-md-6">
							<input type="text" class="form-control" id="longId" name="long" style="color:#333333;"
							value="<?= set_value('long',$companies['latitude']); ?>" readonly />
						</div>
					</div>
				</div>
				<div class="modal-body">
					<!-- Map Selector -->
					<div id="map"></div>
					<br>
					<button type="button" data-dismiss="modal" class="btn btn-info btn-block" aria-hidden="true">
						<?= lang("Validation.done"); ?>
					</button>
				</div>
				<div class="modal-footer"></div>
			</div>
		</div>
	</div>





<script type="text/javascript">
	$('#selectize').selectize({ 
    	create: false
 	});

	//js function for miller-coloumn NACE-code selector, see miller.js
	miller_column_nace();

	$('#myModal').on('shown.bs.modal', function () {
    map_location_chooser();
});

	//UNUSED CODE?
  	function getCountryIdName() {
	    //alert($('#latId').val());
	    //alert($('#longId').val());

      	if($('#latId').val()!=""  && $('#longId').val()!="") {
	        //alert($('#latId').val());
	        $.ajax({
	            url : '../../../Proxy/SlimProxy.php',
	            data : {
	                	url : 'deleteScenario_scn',
	                	lat : $('#latId').val(),
	                	long : $('#longId').val()
			        	},
			            type: 'GET',
			            dataType : 'json',
				        success: function(data, textStatus, jqXHR) {
			                $('#tt_grid_scenarios').datagrid('reload');
			                if(!data['notFound']) {

			                } else {
			                    console.warn('data notfound-->'+textStatus);
			                }
			            },
			            error: function(jqXHR , textStatus, errorThrown) {
			            	console.warn('error text status-->'+textStatus);
	            		}
    		});
        }
    }
</script>