<div class="container">
	<p class="lead"><?= lang("Validation.updateprofile"); ?></p>

	<?= $validation->listErrors() ?>

	<?= form_open_multipart('profile_update'); ?>
		<div class="row">
			<div class="col-md-4">
				<div class="form-group">
						<div class="fileinput fileinput-new" data-provides="fileinput">
							<div class="fileinput-new thumbnail" style="width:100%;">
							<?php if(file_exists("assets/user_pictures/".$photo)): ?>
									<img class="img-rounded" style="width:100%;" src="<?= asset_url("user_pictures/".$photo); ?>">
								<?php else: ?>
									<img class="img-rounded" style="width:100%;" src="<?= asset_url("user_pictures/default.jpg"); ?>">
							<?php endif ?>
							</div>
							<div class="fileinput-preview fileinput-exists thumbnail" style="max-width: 200px; max-height: 150px;"></div>
							<div>
									<small><? echo lang("Validation.imageinfo"); ?></small><br>
									<span class="btn btn-primary btn-block btn-file" name="photo">
										<span class="fileinput-new"><span class="fui-image"></span> <?= lang("Validation.selectimage"); ?></span>
										<span class="fileinput-exists"><span class="fui-gear"></span> <?= lang("Validation.change"); ?></span>
										<input type="file" name="userfile">
									</span>
									<a href="#" class="btn btn-primary btn-embossed fileinput-exists" data-dismiss="fileinput"><span class="fui-trash"></span> <?= lang("Validation.remove"); ?></a>
							</div>
						</div>
				</div>
			</div>
			<div class="col-md-8">
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
<!-- 				<div class="form-group">
					<label for="company">Company</label>

					<select title="Choose at least one" class="select-block" id="company" name="company">
						<?php foreach ($companies as $company): ?>
							<option value="<?= $company['id']; ?>"><?= $company['name']; ?></option>
						<?php endforeach ?>
					</select>

				</div> -->
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