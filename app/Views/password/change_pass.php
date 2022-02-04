<div class="container">

			<?php if(validation_errors() != NULL ): ?>
			    <div class="alert">
					<button type="button" class="close" data-dismiss="alert">&times;</button>
			    	<p><?= validation_errors(); ?></p>
			    </div>
		 	<?php endif ?>

			<?= form_open_multipart('change_pass/'.$random_string);?>
			<div class="row">
				<div class="col-md-4">
					
				</div>
				<div class="col-md-4">
					<p class="lead">Update Password</p>
					<div class="form-group">
		    			<label for="old_pass">Old Password</label>
		    			<input type="password" class="form-control" id="old_pass" placeholder="Enter Old Password" value="<?= set_value('old_pass'); ?>" name="old_pass">
	 				</div>
	 				<div class="form-group">
		    			<label for="new_pass">New Password</label>
		    			<input type="password" class="form-control" id="new_pass" placeholder="Enter New Password" value="<?= set_value('new_pass'); ?>" name="new_pass">
	 				</div>
	 				<div class="form-group">
		    			<label for="new_pass_again">New Password(Again)</label>
		    			<input type="password" class="form-control" id="new_pass_again" placeholder="Enter New Password" value="<?= set_value('new_pass_again'); ?>" name="new_pass_again">
	 				</div>
	 				<button type="submit" class="btn btn-primary pull-right">Update Password</button>
				</div>
				<div class="col-md-4">
				
				</div>
			</div>
			</form>
			</div>
		</div>
	</div>
</div>