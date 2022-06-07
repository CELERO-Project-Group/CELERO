<div class="container">
	<div class="row">
		<div class="col-md-4 col-md-offset-4 swissbox">
	<p class="lead">Open Project</p>

	<?php
		if($validation != NULL)
		echo $validation->listErrors();
	?>
	<?php //print_r($projects); ?>
	<?= form_open('openproject'); ?>
		<div class="row">
			<div class="col-md-4">
				<select name="projectid">
					<?php foreach ($projects as $p) {
						echo "<option value='".$p['id']."'>".$p['name']."</option>";
					} ?>
				</select>
			</div>
		</div>
		<button type="submit" class="btn btn-primary">Open Project</button>
	</form>
</div>
</div>
</div>
