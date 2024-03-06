<div class="container">
	<p class="lead">
		<?= lang("Validation.createcompany"); ?>
	</p>
	<?php
	if ($validation != NULL)
		echo $validation->listErrors();
	?>

	<form action="newcompany" method="post">
		<?= csrf_field() ?>
		<div class="row">
			<div class="col-md-8">
				<div class="form-group">
					<label for="companyName">
						<?= lang("Validation.companyname"); ?>
					</label>
					<input type="text" class="form-control" id="companyName"
						placeholder="<?= lang("Validation.companyname"); ?>" value="<?= set_value('companyName'); ?>"
						name="companyName">
				</div>

				<div class="form-group">
					<label for="naceCode">
						<?= lang("Validation.nacecode"); ?> <i
							title="NACE is the Statistical Classification of Economic Activities in the European Community derived from the UN classification ISIC. The aim of this systematics is to make statistics from different Countries comparable."
							class="fa fa-question-circle" rel="tooltip" href="#"></i>
					</label>
					<button type="button" data-toggle="modal" data-target="#myModalNACE"
						class="btn btn-block btn-primary" id="nacecode-button">
						<?= lang("Validation.selectnace"); ?>
					</button><br>
					<div class="row">
						<div class="col-md-12">
							<input type="text" class="form-control" placeholder="NACE Code" id="naceCode"
								name="naceCode" style="color:#333333;" value="<?= set_value('naceCode'); ?>" readonly />
							<input type="hidden" class="form-control" id="naceId" value="<?= set_value("naceId") ?>" name="naceId"/>
							</div>
					</div>
				</div>
				<div class="form-group">
					<label for="country">
						<?= lang("Validation.country");?>
					</label>
					<select id="country" name="country" class="select-block" data-live-search="true">
						<option value="" disabled selected>
							<?= lang("Validation.pleaseselect"); ?>
						</option>
						<?php foreach ($countries as $anc): ?>
							<option value="<?= $anc; ?>">
								<?= $anc; ?>
							</option>
						<?php endforeach ?> 
		
					</select>
					<small></small>
				</div>
				<div class="form-group">
					<label for="email">
						<?= lang("Validation.email"); ?>
					</label>
					<input type="text" class="form-control" id="email" placeholder="<?= lang("Validation.email"); ?>"
						value="<?= set_value('email'); ?>" name="email">
				</div>
				<div class="form-group">
					<label for="workPhone">
						<?= lang("Validation.workphone"); ?>
					</label>
					<input type="text" class="form-control" id="workPhone"
						placeholder="<?= lang("Validation.workphone"); ?>" value="<?= set_value('workPhone'); ?>"
						name="workPhone">
				</div>
				<div class="form-group">
					<label for="coordinates">
						<?= lang("Validation.coordinates"); ?>
					</label>
					<button type="button" data-toggle="modal" data-target="#myModal" class="btn btn-block btn-primary"
						id="coordinates">
						<?= lang("Validation.selectonmap"); ?>
					</button><br>
					<div class="row">
						<div class="col-md-6">
							<input type="text" class="form-control" id="lat"
								placeholder="<?= lang("Validation.lat"); ?>" name="lat" style="color:#333333;"
								value="<?= set_value('lat'); ?>" readonly />
						</div>
						<div class="col-md-6">
							<input type="text" class="form-control" id="long"
								placeholder="<?= lang("Validation.long"); ?>" name="long" style="color:#333333;"
								value="<?= set_value('long'); ?>" readonly />
						</div>
					</div>
				</div>
				<div class="form-group">
					<label for="companyDescription">
						<?= lang("Validation.companydescription"); ?>
					</label>
					<textarea class="form-control" rows="3" name="companyDescription" id="companyDescription"
						placeholder="<?= lang("Validation.companydescription"); ?>"><?= set_value('companyDescription'); ?></textarea>
				</div>
				<div class="form-group">
					<label for="users">
						<?= lang("Validation.assignconsultant"); ?>
					</label>
					<select multiple="multiple" title="Choose at least one" class="select-block" id="users"
						name="users[]">
						<?php foreach ($users as $consultant): ?>

							<option value="<?= $consultant['id']; ?>">
								<?= $consultant['name'] . ' ' . $consultant['surname'] . ' (' . $consultant['user_name'] . ')'; ?>
							</option>

						<?php endforeach ?>
					</select>
				</div>
				<button type="submit" class="btn btn-primary btn-block">
					<?= lang("Validation.createcompany"); ?>
				</button>
			</div>
		</div>
	</form>
	<!-- Map Modal -->
	<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
					<h4 class="modal-title" id="myModalLabel">Click Map</h4>
					<hr>
					<div class="row">
						<div class="col-md-6">
							<input type="text" class="form-control" id="latId" name="lat" style="color:#333333;"
								readonly />
						</div>
						<div class="col-md-6">
							<input type="text" class="form-control" id="longId" name="long" style="color:#333333;"
								readonly />
						</div>
					</div>
				</div>
				<div class="modal-body">
					<!-- Map Selector -->
					<div id="map"></div>
					<br>
					<button type="button" data-dismiss="modal" class="btn btn-info btn-block" aria-hidden="true">
						<?= lang("Validation.done"); ?>
					</button>
				</div>
				<div class="modal-footer"></div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="myModalNACE" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
		aria-hidden="true">
		<div class="modal-dialog-nace">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
					<h4 class="modal-title" id="myModalLabel">
						<?= lang("Validation.selectlevel4nace"); ?>
					</h4>
					<hr>
					<div class="row">
						<div class="col-md-12">
							<input type="text" class="form-control" id="naceCode" name="nace-code"
								style="color:#333333;" readonly />
						</div>
					</div>
				</div>
				<div class="modal-body">
					<!-- Miller column NACE Code selector -->
					<div id="miller_col"></div>
					<br>
					<button type="button" data-dismiss="modal" class="btn btn-info btn-block" aria-hidden="true">
						<?= lang("Validation.done"); ?>
					</button>
				</div>
				<div class="modal-footer"></div>
			</div>
		</div>
	</div>
</div>

<script type="text/javascript">

	// $('#country').selectize({
	// 	create: false
	// });

	//js function for miller-coloumn NACE-code selector
	miller_column_nace();

	$(document).ready(function () {
		$("[rel=tooltip]").tooltip({ placement: 'right' });
	});

	$('#myModal').on('shown.bs.modal', function () {
    map_location_chooser();
});


</script>