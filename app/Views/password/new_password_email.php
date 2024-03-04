<div class="container">

	<?php if (session()->has('errors')): ?>
		<div class="alert alert-danger" role="alert">
			<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
			<?php echo \Config\Services::validation()->listErrors(); ?>
		</div>
	<?php endif; ?>


	<?= form_open_multipart('new_password_email'); ?>
	<?= csrf_field(); ?>
	<div class="row">
		<div class="col-md-4">

		</div>
		<div class="col-md-4">
			<p class="lead">Send E-mail</p>
			<div class="form-group">
				<label for="email">E-mail</label>
				<input type="email" class="form-control" id="email" placeholder="Enter Your E-mail"
					value="<?= set_value('email'); ?>" name="email">
			</div>
			<button type="submit" class="btn btn-primary pull-right">Send Mail</button>
		</div>
		<div class="col-md-4">

		</div>
	</div>
	</form>
</div>
</div>
</div>
</div>