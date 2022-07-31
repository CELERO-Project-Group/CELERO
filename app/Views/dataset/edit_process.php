<div class="col-md-6 col-md-offset-3">
	<?php
		if($validation != NULL)
		echo $validation->listErrors();
	?>
	<?= form_open_multipart('edit_process/'.$companyID.'/'.$process['id']); ?>
		<?= csrf_field() ?>
		<p class="lead"><?= lang("Validation.editprocess"); ?></p>
		<div class="form-group">
			<label for="comment"><?= lang("Validation.comments"); ?></label>
			<textarea class="form-control" id="comment" name="comment" placeholder="<?= lang("Validation.comments"); ?>"><?= set_value('comment',$process['comment']); ?></textarea>
		</div>
	<button type="submit" class="btn btn-info"><?= lang("Validation.savedata"); ?></button>
	</form>
</div>