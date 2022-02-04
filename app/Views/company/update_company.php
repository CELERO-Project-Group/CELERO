<?= $map['js']; ?>
<div class="container">
	<p class="lead"><?= lang("editcompanyinfo"); ?></p>

	<?php if(validation_errors() != NULL ): ?>
    <div class="alert">
			<button type="button" class="close" data-dismiss="alert">&times;</button>
      <p>
      	<?= validation_errors(); ?>
      </p>
    </div>
  	<?php endif ?>

	<?= form_open_multipart('update_company/'.$companies['id']);?>
	<div class="row">
		<div class="col-md-4">
			<div class="form-group">
  				<div class="fileinput fileinput-new" data-provides="fileinput">
    				<div class="fileinput-new thumbnail" style="width:100%;">
      					<img class="img-rounded" style="width:100%;" src="<?= asset_url("company_pictures/".$companies['logo']);?>">
    				</div>
    				<div class="fileinput-preview fileinput-exists thumbnail" ></div>
    				<div>
    					<small><? echo lang("imageinfo"); ?></small><br>
      					<span class="btn btn-primary btn-file btn-block">
					        <span class="fileinput-new"><span class="fui-image"></span> <?= lang("selectimage"); ?></span>
					        <span class="fileinput-exists"><span class="fui-gear"></span> <?= lang("change"); ?></span>
					        <input type="file" name="userfile">
      					</span>
      					<a href="#" class="btn btn-primary fileinput-exists" data-dismiss="fileinput"><span class="fui-trash"></span> <?= lang("remove"); ?></a>
    				</div>
  				</div>
			</div>
      	</div>
     	<div class="col-md-8">
			<div class="form-group">
    			<label for="companyName"><?= lang("companyname"); ?></label>
    			<input type="text" class="form-control" id="companyName" placeholder="<?= lang("companyname"); ?>" value="<?= set_value('companyName',$companies['name']); ?>" name="companyName">
 			</div>
 			<div class="form-group">
	 			<label for="naceCode"><?= lang("nacecode"); ?></label>
		    	<button type="button" data-toggle="modal" data-target="#myModalNACE" class="btn btn-block btn-primary" id="nacecode-button"><?= lang("selectnace"); ?></button><br>
	    		<div class="row">
		    		<div class="col-md-12">
		    			<input type="text" class="form-control" placeholder="NACE Code" id="naceCode" name="naceCode" style="color:#333333;" value="<?= set_value('naceCode',$nace_code['code']); ?>" readonly/>
		    		</div>
		    	</div>

				<!--<label for="naceCode"><?= lang("nacecode"); ?></label>
				<select id="selectize" name="naceCode">
					<?php foreach ($all_nace_codes as $anc): ?>
						<?php if($nace_code['code']==$anc['code']) {$d=TRUE;} else {$d=FALSE;} ?>
						<option value="<?= $anc['code']; ?>" <?= set_select('naceCode', $anc['code'], $d); ?> ><?= $anc['code']; ?></option>
					<?php endforeach ?>
				</select>-->
 			</div>
			<div class="form-group">
    			<label for="email"><?= lang("email"); ?></label>
    			<input type="text" class="form-control" id="email" placeholder="<?= lang("email"); ?>" value="<?= set_value('email',$companies['email']); ?>"  name="email">
 			</div>
			<!-- <div class="form-group">
    			<label for="cellPhone">Cell Phone</label>
    			<input type="text" class="form-control" id="cellPhone" placeholder="Cell Phone" value="<?= set_value('cellPhone',$companies['phone_num_1']); ?>" name="cellPhone">
 			</div>  -->
 			<div class="form-group">
    			<label for="workPhone"><?= lang("workphone"); ?></label>
    			<input type="text" class="form-control" id="workPhone" placeholder="<?= lang("workphone"); ?>" value="<?= set_value('workPhone',$companies['phone_num_2']); ?>" name="workPhone">
 			</div>
 			<div class="form-group">
    			<label for="fax"><?= lang("faxnumber"); ?></label>
    			<input type="text" class="form-control" id="fax" placeholder="<?= lang("faxnumber"); ?>" value="<?= set_value('fax',$companies['fax_num']); ?>" name="fax">
 			</div>
			<div class="form-group">
    			<label for="coordinates"><?= lang("coordinates"); ?></label><br>
    			<button type="button" data-toggle="modal" data-target="#myModal" class="btn btn-primary btn-block" id="coordinates" ><?= lang("selectonmap"); ?></button>
    			<div class="row" style="margin-top: 10px;">
	    			<div class="col-md-6">
	    				<input type="text" class="form-control" id="lat" placeholder="<?= lang("lat"); ?>" name="lat" style="color:#333333;" value="<?= set_value('lat',$companies['latitude']); ?>" readonly/>
	    			</div>
	    			<div class="col-md-6">
	    				<input type="text" class="form-control" id="long" placeholder="<?= lang("long"); ?>" name="long" style="color:#333333;" value="<?= set_value('long',$companies['longitude']); ?>" readonly/>
	    			</div>
    			</div>
 			</div>
 			<div class="form-group">
    			<label for="address"><?= lang("address"); ?></label>
    			<textarea class="form-control" rows="3" name="address" id="address" placeholder="<?= lang("address"); ?>"><?= set_value('address',$companies['address']); ?></textarea>
 			</div>
 			<div class="form-group">
    			<label for="companyDescription"><?= lang("description"); ?></label>
    			<textarea class="form-control" rows="3" name="companyDescription" id="companyDescription" placeholder="<?= lang("description"); ?>"><?= set_value('companyDescription',$companies['description']); ?></textarea>
 			</div>
        <button type="submit" class="btn btn-inverse col-md-9"><?= lang("save"); ?></button>
        <a href="<?= base_url('company/'.$companies['id']); ?>" class="btn btn-warning col-md-2 col-md-offset-1"><?= lang("cancel"); ?></a>
			</div>
		</div>
	</form>
	<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" rendered="<?= $map['js']; ?>">
		<div class="modal-dialog">
		    <div class="modal-content">
			    <div class="modal-header">
			        <button type="button" class="close" onclick="getCountryIdName();" data-dismiss="modal" aria-hidden="true">&times;</button>
			        <h4 class="modal-title" id="myModalLabel">Click Map</h4>
			        <hr>
			        <div class="row">
			        	<div class="col-md-6">
			        		<input type="text" class="form-control" id="latId" name="lat" style="color:#333333;" readonly/>
			        	</div>
			        	<div class="col-md-6">
			        		<input type="text" class="form-control" id="longId" name="long"  style="color:#333333;" readonly/>
			        	</div>
			        </div>
			    </div>
			    <div class="modal-body">
			      	<?= $map['html']; ?>
			      	<br>
			      	<button type="button" onclick="getCountryIdName();" data-dismiss="modal" class="btn btn-info btn-block" aria-hidden="true"><?= lang("done"); ?></button>
			    </div>
				<div class="modal-footer"></div>
			</div>
	  	</div>
	</div>
	<div class="modal fade" id="myModalNACE" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog-nace">
		    <div class="modal-content">
			    <div class="modal-header">
			        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
			        <h4 class="modal-title" id="myModalLabel"><?= lang("selectlevel4nace"); ?></h4>
			        <hr>
			        <div class="row">
			        	<div class="col-md-12">
			        		<input type="text" class="form-control" id="naceCode" name="nace-code" style="color:#333333;" readonly/>
			        	</div>
			  
			        </div>
			    </div>
			    <div class="modal-body">
			    	<!-- Miller column NACE Code selector -->
					<div id="miller_col"></div>
			      	<br>
		      		<button type="button" data-dismiss="modal" class="btn btn-info btn-block" aria-hidden="true"><?= lang("done"); ?></button>
			    </div>
			    <div class="modal-footer"></div>
		    </div>
	 	</div>
	</div>
</div>
<script type="text/javascript">
	$('#selectize').selectize({
    	create: false
 	});

	//js function for miller-coloumn NACE-code selector, see miller.js
	miller_column_nace();

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