<div class="container">
	<div class="row">
		<div class="col-md-4 col-md-offset-4 swissbox">
			<p class="lead"><?= lang("Validation.userlogin"); ?></p>

			<?php
				if($validation != NULL)
				echo $validation->listErrors();
			?>

			<form action="login" method="post" autocomplete="off">
				<?= csrf_field() ?>

		    	<div class="form-group">
					<label for="username"><?= lang("Validation.username"); ?></label>
					<input type="text" class="form-control" id="username" autocomplete="off" value="<?= set_value('username'); ?>" placeholder="<?= lang("Validation.username"); ?>" name="username" autofocus>
				</div>
				<div class="form-group">
					<label for="password"><?= lang("Validation.password"); ?></label>
					<input type="password" class="form-control" id="password" autocomplete="off" placeholder="<?= lang("Validation.password"); ?>" name="password">
				</div>

				<button type="submit" class="btn btn-primary"><?= lang("Validation.login"); ?></button>
				<hr>
				<a href="<?= base_url('new_password_email');?>"><?= lang("Validation.forgotyourpassword"); ?></a>
		    </form>
		</div>
	</div>
</div>