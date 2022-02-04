<div class="container">
	<?php if(validation_errors() != NULL ): ?>
    <div class="alert">
			<button type="button" class="close" data-dismiss="alert">&times;</button>
			<h4>Form couldn't be saved</h4>
      <p>
      	<?= validation_errors() ?>
      </p>
    </div>
  <?php endif ?>

	<?= form_open_multipart('cluster'); ?>
		<div class="row">
			<div class="col-md-4">

			</div>
			<div class="col-md-4">
				<p class="lead">Company To Match Company</p>
				<div class="form-group">
	    			<label for="assignedCompanies">Select Company</label>
	    			<select title="Choose at least one" class="select-block" id="company" name="company">
	    				<option value="">Nothing Selected</option>
						<?php foreach ($companies as $company): ?>
							<option value="<?= esc($company['id']) ?>"><?= esc($company['name']) ?></option>
						<?php endforeach ?>
					</select>
	 			</div>
				<div class="form-group">
	    			<label for="assignedCompanies">Select Cluster</label>
	    			<select title="Choose at least one" class="select-block" id="cluster" name="cluster">
	    				<option value="">Nothing Selected</option>
						<?php foreach ($clusters as $cluster): ?>
							<option value="<?= esc($cluster['id']) ?>"><?= esc($cluster['name']) ?></option>
						<?php endforeach ?>
					</select>
	 			</div>
	 			<button type="submit" class="btn btn-primary pull-right">To Match</button>
			</div>
			<div class="col-md-4">

			</div>
		</div>
	</form>
</div>
