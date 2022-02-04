		<div class="container">

			<?php if(validation_errors() != NULL ): ?>
			    <div class="alert">
					<button type="button" class="close" data-dismiss="alert">&times;</button>
			    	<p><?= validation_errors(); ?></p>
			    </div>
		 	<?php endif ?>

			<?= form_open_multipart('new_password_email');?>
			<div class="row">
				<div class="col-md-4">
					
				</div>
				<div class="col-md-4">
					<p class="lead">Send E-mail</p>
					<div class="form-group">
		    			<label for="email">E-mail</label>
		    			<input type="email" class="form-control" id="email" placeholder="Enter Your E-mail" value="<?= set_value('email'); ?>" name="email">
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
