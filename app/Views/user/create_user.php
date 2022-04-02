<div class="container">

	<?php
		if($validation != NULL)
		echo $validation->listErrors();
	?>

		<form action="register" method="post" autocomplete="off">
		<?= csrf_field() ?>
		<div class="row">

			<div class="col-md-6 col-md-offset-3 swissbox">
			<p class="lead"><?= lang("Validation.userregister"); ?> 
			<small><small> or <a href="<?= base_url('login'); ?>">login here</a></small></small></p>

				<div class="form-group">
						<label for="username"><?= lang("Validation.username"); ?> 
								<small>
									<?= "&nbsp;", lang("Validation.validcharacters");?>
								</small>
								<span style="color:red;">* 
									<small><?= lang("Validation.mandatory"); ?></small>
							 	</span>
						</label> 
						<input type="text" class="form-control" id="username" value="<?= set_value('username'); ?>" placeholder="<?= lang("Validation.username"); ?>" name="username">
				</div>
				<div class="form-group">
						<label for="password"><?= lang("Validation.password"); ?> <span style="color:red;">*</span></label>
						<input type="password" class="form-control" id="password" placeholder="<?= lang("Validation.password"); ?>" name="password">
				</div>
				<div class="form-group">
	    			<label for="email"><?= lang("Validation.email"); ?> <span style="color:red;">*</span></label>
	    			<input type="text" class="form-control" id="email" placeholder="<?= lang("Validation.email"); ?>" value="<?= set_value('email'); ?>"  name="email">
	 			</div>
				<div class="form-group">
						<label for="name"><?= lang("Validation.name"); ?> <span style="color:red;">*</span></label>
						<input type="text" class="form-control" id="name" placeholder="<?= lang("Validation.name"); ?>" value="<?= set_value('name'); ?>" name="name">
				</div>
				<div class="form-group">
						<label for="surname"><?= lang("Validation.surname"); ?> <span style="color:red;">*</span></label>
						<input type="text" class="form-control" id="surname" placeholder="<?= lang("Validation.surname"); ?>" value="<?= set_value('surname'); ?>"  name="surname">
				</div>
				<hr>
				<button type="submit" class="btn btn-info"><?= lang("Validation.register"); ?></button>
			</div>
		</div>
	</form>
</div>
