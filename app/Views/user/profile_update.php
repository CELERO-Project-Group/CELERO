<div class="container">
	<p class="lead"><?= lang("Validation.updateprofile"); ?></p>

	<?php
		if($validation != NULL)
		echo $validation->listErrors();
	?>

	<?= form_open_multipart('profile_update'); ?>
		<div class="row">
			<div class="col-md-12">
				<div class="form-group">
						<label for="username"><?= lang("Validation.username");?></label>
						<small><?= "&nbsp;", lang("Validation.validcharacters");?></small>
						<input type="text" class="form-control" id="username" value="<?= set_value('username',$user_name); ?>" placeholder="<?= lang("Validation.username"); ?>" name="username">
				</div>
				<div class="form-group">
	    			<label for="email"><?= lang("Validation.email"); ?></label>
	    			<input type="text" class="form-control" id="email" placeholder="<?= lang("Validation.email"); ?>" value="<?= set_value('email',$email); ?>"  name="email">
	 			</div>
	 			<div class="form-group">
	    			<label for="cellPhone"><?= lang("Validation.cellphone"); ?></label>
	    			<input type="text" class="form-control" id="cellPhone" value="<?= set_value('cellPhone',$phone_num_1); ?>" placeholder="<?= lang("Validation.cellphone"); ?>" name="cellPhone">
	 			</div>
	 			<div class="form-group">
	    			<label for="workPhone"><?= lang("Validation.workphone"); ?></label>
	    			<input type="text" class="form-control" id="workPhone" value="<?= set_value('workPhone',$phone_num_2); ?>" placeholder="<?= lang("Validation.workphone"); ?>" name="workPhone">
	 			</div>
	 			<div class="form-group">
	    			<label for="fax"><?= lang("Validation.faxnumber"); ?></label>
	    			<input type="text" class="form-control" id="fax" value="<?= set_value('fax',$fax_num); ?>" placeholder="<?= lang("Validation.faxnumber"); ?>" name="fax">
	 			</div>
				<div class="form-group">
						<label for="name"><?= lang("Validation.name"); ?></label>
						<input type="text" class="form-control" id="name" placeholder="<?= lang("Validation.name"); ?>" value="<?= set_value('name',$name); ?>" name="name">
				</div>
				<div class="form-group">
						<label for="surname"><?= lang("Validation.surname"); ?></label>
						<input type="text" class="form-control" id="surname" placeholder="<?= lang("Validation.surname"); ?>" value="<?= set_value('surname',$surname); ?>"  name="surname">
				</div>
				<div class="form-group">
						<label for="jobTitle"><?= lang("Validation.job"); ?></label>
						<input type="text" class="form-control" id="jobTitle" value="<?= set_value('jobTitle',$title); ?>" placeholder="<?= lang("Validation.job"); ?>" name="jobTitle">
				</div>
				<div class="form-group">
						<label for="jobDescription"><?= lang("Validation.description"); ?></label>
						<textarea class="form-control" rows="3" name="description" id="description" placeholder="<?= lang("Validation.description"); ?>"><?= set_value('description',$description); ?></textarea>
				</div>
				<button type="submit" class="btn btn-inverse col-md-9"><?= lang("Validation.save"); ?></button>
				<a href="<?= base_url('user/'.$user_name); ?>" class="btn btn-warning col-md-2 col-md-offset-1"><?= lang("Validation.cancel"); ?></a>
			</div>
		</div>
	</form>
</div>