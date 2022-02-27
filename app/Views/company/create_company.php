<?= $map['js']; ?>
<div class="container">
	<p class="lead"><?= lang("Validation.createcompany"); ?></p>

	<?php if(validation_errors() != NULL ): ?>
    <div class="alert">
		<button type="button" class="close" data-dismiss="alert">&times;</button>
		<h4>Form couldn't be saved</h4>
      	<p>
      		<?= validation_errors(); ?>
      	</p>
    </div>
  	<?php endif ?>

	<?= form_open_multipart('newcompany'); ?>
		<div class="row">
			<div class="col-md-4">
				<div class="form-group">
	  				<div class="fileinput fileinput-new" data-provides="fileinput">
	    				<div class="fileinput-new thumbnail" style="width: 100%; height: 200px;">
	      					<img data-src="holder.js/100%x100%" alt="..." style="width: 100%; ">
	    				</div>
	    				<div class="fileinput-preview fileinput-exists thumbnail" style="max-width: 200px; max-height: 150px;"></div>
	    				<div>
	    					<small><? echo lang("Validation.imageinfo"); ?></small><br>
	      					<span class="btn btn-primary btn-block btn-file">
						        <span class="fileinput-new"><span class="fui-image"></span>  <?= lang("Validation.selectimage"); ?></span>
						        <span class="fileinput-exists"><span class="fui-gear"></span>  <?= lang("Validation.change"); ?></span>
						        <input type="file" name="userfile">
	      					</span>
	      					<a href="#" class="btn btn-primary fileinput-exists" data-dismiss="fileinput"><span class="fui-trash"></span>  <?= lang("Validation.remove"); ?></a>
	    				</div>
	  				</div>
				</div>
				<div class="alert"><?= lang("Validation.createcompanyinfo2"); ?></div>
			</div>
			<div class="col-md-8">
				<div class="form-group">
	    			<label for="companyName"><?= lang("Validation.companyname"); ?></label>
	    			<input type="text" class="form-control" id="companyName" placeholder="<?= lang("Validation.companyname"); ?>" value="<?= set_value('companyName'); ?>" name="companyName">
	 			</div>

	 			<div class="form-group">
	 				<label for="naceCode"><?= lang("Validation.nacecode"); ?> <i title="NACE is the Statistical Classification of Economic Activities in the European Community derived from the UN classification ISIC. The aim of this systematics is to make statistics from different Countries comparable." class="fa fa-question-circle" rel="tooltip" href="#"></i></label>
	    			<button type="button" data-toggle="modal" data-target="#myModalNACE" class="btn btn-block btn-primary" id="nacecode-button"><?= lang("Validation.selectnace"); ?></button><br>
	    			<div class="row">
		    			<div class="col-md-12">
		    				<input type="text" class="form-control" placeholder="NACE Code" id="naceCode" name="naceCode" style="color:#333333;" value="<?= set_value('naceCode'); ?>" readonly/>
		    			</div>
		    		</div>
	 			</div>

                            
                <div class="form-group">
                    <label for="country">Country</label>
					<select id="selectize" name="country">
						<option value="" disabled selected><?= lang("Validation.pleaseselect"); ?></option>
						<?php foreach ($countries as $anc): ?>
							<option value="<?= $anc['id']; ?>"><?= $anc['country_name']; ?> </option>
						<?php endforeach?>
					</select>
					<small></small>
	 			</div>      
				<div class="form-group">
	    			<label for="email"><?= lang("Validation.email"); ?></label>
	    			<input type="text" class="form-control" id="email" placeholder="<?= lang("Validation.email"); ?>" value="<?= set_value('email'); ?>"  name="email">
	 			</div>
	 			<div class="form-group">
	    			<label for="workPhone"><?= lang("Validation.workphone"); ?></label>
	    			<input type="text" class="form-control" id="workPhone" placeholder="<?= lang("Validation.workphone"); ?>" value="<?= set_value('workPhone'); ?>" name="workPhone">
	 			</div>
	 			<div class="form-group">
	    			<label for="fax"><?= lang("Validation.faxnumber"); ?></label>
	    			<input type="text" class="form-control" id="fax" placeholder="<?= lang("Validation.faxnumber"); ?>" value="<?= set_value('fax'); ?>" name="fax">
	 			</div>
				<div class="form-group">
	    			<label for="coordinates"><?= lang("Validation.coordinates"); ?></label>
	    			<button type="button" data-toggle="modal" data-target="#myModal" class="btn btn-block btn-primary" id="coordinates" ><?= lang("Validation.selectonmap"); ?></button><br>
	    			<div class="row">
		    			<div class="col-md-6">
		    				<input type="text" class="form-control" id="lat" placeholder="<?= lang("Validation.lat"); ?>" name="lat" style="color:#333333;" value="<?= set_value('lat'); ?>" readonly/>
		    			</div>
		    			<div class="col-md-6">
		    				<input type="text" class="form-control" id="long" placeholder="<?= lang("Validation.long"); ?>" name="long" style="color:#333333;" value="<?= set_value('long'); ?>" readonly/>
		    			</div>
	    			</div>
	 			</div>
	 			<div class="form-group">
	    			<label for="address"><?= lang("Validation.address"); ?></label>
	    			<textarea class="form-control" rows="3" name="address" id="address" placeholder="<?= lang("Validation.address"); ?>"><?= set_value('address'); ?></textarea>
	 			</div>
	 			<div class="form-group">
	    			<label for="companyDescription"><?= lang("Validation.companydescription"); ?></label>
	    			<textarea class="form-control" rows="3" name="companyDescription" id="companyDescription" placeholder="<?= lang("Validation.companydescription"); ?>"><?= set_value('companyDescription'); ?></textarea>
	 			</div>
				 <div class="form-group">
	    			<label for="users"><?= lang("Validation.assignconsultant"); ?></label>
	    			<select multiple="multiple"  title="Choose at least one" class="select-block" id="users" name="users[]">
						<?php foreach ($users as $consultant): ?>
							<?php if (in_array($consultant['id'], $_POST['users'])) { ?>
								<option value="<?= $consultant['id']; ?>" selected><?= $consultant['name'].' '.$consultant['surname'].' ('.$consultant['user_name'].')'; ?></option>
							<?php } else { ?>
								<option value="<?= $consultant['id']; ?>"><?= $consultant['name'].' '.$consultant['surname'].' ('.$consultant['user_name'].')'; ?></option>
							<?php } ?>
						<?php endforeach ?>
					</select>
	 			</div>
	 			<button type="submit" class="btn btn-primary btn-block"><?= lang("Validation.createcompany"); ?></button>
			</div>
		</div>
	</form>
	<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" 
		rendered="<?= $map['js']; ?>">
		<div class="modal-dialog">
		    <div class="modal-content">
			    <div class="modal-header">
			        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
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
		      		<button type="button" data-dismiss="modal" class="btn btn-info btn-block" aria-hidden="true"><?= lang("Validation.done"); ?></button>
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
			        <h4 class="modal-title" id="myModalLabel"><?= lang("Validation.selectlevel4nace"); ?></h4>
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
		      		<button type="button" data-dismiss="modal" class="btn btn-info btn-block" aria-hidden="true"><?= lang("Validation.done"); ?></button>
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

	//js function for miller-coloumn NACE-code selector
	miller_column_nace();
    $(document).ready(function(){
        $("[rel=tooltip]").tooltip({ placement: 'right' });
    });
</script>
