<div class="container">
	<p class="lead"><?= lang("Validation.updateprofile"); ?></p>

	<?php
		if($validation != NULL)
		echo $validation->listErrors();
	?>

	<form action="profile_update" method="post" autocomplete="off">

		<?= csrf_field() ?>
		<div class="row">
			<div class="col-md-12">
				<input class="form-control" id="id" value="<?= set_value('id',$id); ?>" name="id" type="hidden" />

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
						<label for="name"><?= lang("Validation.name"); ?></label>
						<input type="text" class="form-control" id="name" placeholder="<?= lang("Validation.name"); ?>" value="<?= set_value('name',$name); ?>" name="name">
				</div>
				<div class="form-group">
						<label for="surname"><?= lang("Validation.surname"); ?></label>
						<input type="text" class="form-control" id="surname" placeholder="<?= lang("Validation.surname"); ?>" value="<?= set_value('surname',$surname); ?>"  name="surname">
				</div>
				<button type="submit" class="btn btn-inverse col-md-9"><?= lang("Validation.save"); ?></button>
				<a href="<?= base_url('user/'.$user_name); ?>" class="btn btn-warning col-md-2 col-md-offset-1"><?= lang("Validation.cancel"); ?></a>
			</div>
		</div>
	</form>
</div>