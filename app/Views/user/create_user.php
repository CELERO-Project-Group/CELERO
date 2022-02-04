<div class="container">

	<?php if(validation_errors() != NULL ): ?>
    <div class="alert">
      <button type="button" class="close" data-dismiss="alert">&times;</button>
      <?= validation_errors(); ?>
    </div>
    <?php endif ?>
    <?php //print_r($this->recaptcha->getError()); ?>

	<?= form_open_multipart('register'); ?>
		<div class="row">

			<div class="col-md-6 col-md-offset-3 swissbox">
			<p class="lead"><?= lang("userregister"); ?> 
			<small><small> or <a href="<?= base_url('login'); ?>">login here</a></small></small></p>

				<div class="form-group">
						<label for="username"><?= lang("username"); ?> 
								<small>
									<?= "&nbsp;", lang("validcharacters");?>
								</small>
								<span style="color:red;">* 
									<small><?= lang("mandatory"); ?></small>
							 	</span>
						</label> 
						<input type="text" class="form-control" id="username" value="<?= set_value('username'); ?>" placeholder="<?= lang("username"); ?>" name="username">
				</div>
				<div class="form-group">
						<label for="password"><?= lang("password"); ?> <span style="color:red;">*</span></label>
						<input type="password" class="form-control" id="password" placeholder="<?= lang("password"); ?>" name="password">
				</div>
				<div class="form-group">
					<div class="fileinput fileinput-new" data-provides="fileinput">
						<div class="fileinput-new thumbnail" style="width: 200px; height: 150px;">
								<img data-src="holder.js/100%x100%" alt="...">
						</div>
						<div class="fileinput-preview fileinput-exists thumbnail" style="max-width: 200px; max-height: 150px;"></div>
						<div>
							<small><? echo lang("imageinfo"); ?></small><br>
							<span class="btn btn-default btn-file">
								<span class="fileinput-new"><span class="fui-image"></span>  <?= lang("selectimage"); ?></span>
								<span class="fileinput-exists"><span class="fui-gear"></span>  <?= lang("change"); ?></span>
								<input type="file" name="userfile">
							</span>
							<a href="#" class="btn btn-default fileinput-exists" data-dismiss="fileinput"><span class="fui-trash"></span>  <?= lang("remove"); ?></a>
						</div>
					</div>
				</div>
				<div class="form-group">
	    			<label for="email"><?= lang("email"); ?> <span style="color:red;">*</span></label>
	    			<input type="text" class="form-control" id="email" placeholder="<?= lang("email"); ?>" value="<?= set_value('email'); ?>"  name="email">
	 			</div>
	 			<div class="form-group">
	    			<label for="cellPhone"><?= lang("cellphone"); ?></label>
	    			<input type="text" class="form-control" id="cellPhone" value="<?= set_value('cellPhone'); ?>" placeholder="<?= lang("cellphone"); ?>" name="cellPhone">
	 			</div>
	 			<div class="form-group">
	    			<label for="workPhone"><?= lang("workphone"); ?></label>
	    			<input type="text" class="form-control" id="workPhone" value="<?= set_value('workPhone'); ?>" placeholder="<?= lang("workphone"); ?>" name="workPhone">
	 			</div>
	 			<div class="form-group">
	    			<label for="fax"><?= lang("faxnumber"); ?></label>
	    			<input type="text" class="form-control" id="fax" value="<?= set_value('fax'); ?>" placeholder="<?= lang("faxnumber"); ?>" name="fax">
	 			</div>
				<div class="form-group">
						<label for="name"><?= lang("name"); ?> <span style="color:red;">*</span></label>
						<input type="text" class="form-control" id="name" placeholder="<?= lang("name"); ?>" value="<?= set_value('name'); ?>" name="name">
				</div>
				<div class="form-group">
						<label for="surname"><?= lang("surname"); ?> <span style="color:red;">*</span></label>
						<input type="text" class="form-control" id="surname" placeholder="<?= lang("surname"); ?>" value="<?= set_value('surname'); ?>"  name="surname">
				</div>
				<div class="form-group">
						<label for="jobTitle"><?= lang("job"); ?> <span style="color:red;">*</span></label>
						<input type="text" class="form-control" id="jobTitle" value="<?= set_value('jobTitle'); ?>" placeholder="<?= lang("job"); ?>" name="jobTitle">
				</div>
				<div class="form-group">
						<label for="jobDescription"><?= lang("description"); ?></label>
						<textarea class="form-control" rows="3" name="description" value="<?= set_value('description'); ?>" id="description" placeholder="<?= lang("description"); ?>"></textarea>
				</div>
   		 	<?= $recaptcha_html; ?>
		  	<?php
/*					echo 'Lütfen aşağıda gördüğünüz kodu giriniz. <br>';
					echo $image;
					echo '<br><br><input class="form-control" type="text" name="captcha" value="" placeholder="kod alanı"/>';*/
				?>
				<hr>
				<button type="submit" class="btn btn-info"><?= lang("register"); ?></button>
			</div>
		</div>
	</form>
</div>
