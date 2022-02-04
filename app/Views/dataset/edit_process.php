	<?php //print_r($process); ?>
	<div class="col-md-6 col-md-offset-3">
		<?= form_open_multipart('edit_process/'.$companyID.'/'.$process['id']); ?>
			<p class="lead"><?= lang("editprocess"); ?></p>
			<div class="form-group">
				<label for="comment"><?= lang("comments"); ?></label>
				<textarea class="form-control" id="comment" name="comment" placeholder="<?= lang("comments"); ?>"><?= set_value('comment',$process['comment']); ?></textarea>
			</div>
	    <button type="submit" class="btn btn-info"><?= lang("savedata"); ?></button>
	    </form>
</div>