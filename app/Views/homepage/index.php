<div>
	<div class="text-center">
		<div><?= lang('slogan'); ?></div>
		<?php if (session('user_in')) : ?>
			<div style="margin-top:450px;">
				<a class="btn btn-lg btn-success" style="font-size: 15px;padding: 10px 40px;" href="<?= base_url('register'); ?>"><?= lang("Validation.startusing"); ?></a>
			</div>
		<?php endif ?>
			<img class="img-responsive center-block" src="<?php echo base_url('assets/images/home.jpg'); ?>" />
	</div>
</div>