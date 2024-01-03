<?php //print_r($flow); ?>
<div class="row">
	<div class="col-md-6 col-md-offset-3">
		<?php
		if ($validation != NULL)
			echo $validation->listErrors();
		?>
		<?= form_open_multipart('edit_flow/' . $companyID . '/' . $flow['flow_id'] . '/' . $flow['flow_type_id']); ?>
		<?= csrf_field() ?>

		<p class="lead">
			<?= lang("Validation.editflow"); ?>
		</p>
		<div class="well">
			<div>
				<?= lang("Validation.flowname"); ?>:
				<?= $flow['flowname']; ?>
			</div>
			<div>
				<?= lang("Validation.flowtype"); ?>:
				<?= $flow['flowtype']; ?>
			</div>
			<div>
				<?= lang("Validation.flowfamily"); ?>:
				<?= $flow['flowfamily']; ?>
			</div>
		</div>
		<div class="form-group">
			<div class="row">
				<div class="col-md-8">
					<label for="quantity">
						<?= lang("Validation.quantity"); ?> (
						<?= lang("Validation.annual"); ?>)
						<span style="color:red;">*
							<small>
								<?= lang("Validation.mandatory"); ?>
							</small>
						</span>
					</label>
					<input class="form-control" id="quantity" name="quantity"
						placeholder="<?= lang("Validation.quantity"); ?>"
						value="<?= set_value('quantity', $flow['qntty']); ?>">
				</div>
				<div class="col-md-4">
					<label for="quantityUnit">
						<?= lang("Validation.quantity"); ?>
						<?= lang("Validation.unit"); ?> <span style="color:red;">*</span>
					</label>
					<select id="selectize-units" class="info select-block" name="quantityUnit">
						<option value="" disabled selected>
							<?= lang("Validation.pleaseselect"); ?>
						</option>
						<?php foreach ($units as $unit): ?>
							<!-- sets the "qntty unit" in the dropdown by setting set_flow_unit to TRUE if id equals -->
							<?php
							$set_flow_unit = FALSE;
							if ($flow['qntty_unit_id'] == $unit['id']) {
								$set_flow_unit = TRUE;
							}
							?>
							<option value="<?= $unit['id']; ?>" <?= set_select('quantityUnit', $unit['id'], $set_flow_unit); ?>>
								<?= $unit['name']; ?>
							</option>
						<?php endforeach ?>
					</select>
				</div>
			</div>
		</div>
		<div class="form-group">
			<div class="row">
				<div class="col-md-8">
					<label for="cost">
						<?= lang("Validation.cost"); ?> (
						<?= lang("Validation.annual"); ?>) <span style="color:red;">*</span>
					</label>
					<input class="form-control" id="cost" name="cost" placeholder="<?= lang("Validation.cost"); ?>"
						value="<?= set_value('cost', $flow['cost']); ?>">
				</div>
				<div class="col-md-4">
					<label for="cost">
						<?= lang("Validation.costunit"); ?> <span style="color:red;">*</span>
					</label>
					<select id="costUnit" class="info select-block" name="costUnit">
						<?php $edeger = FALSE; ?>
						<?php $ddeger = FALSE; ?>
						<?php $tdeger = FALSE; ?>
						<?php $cdeger = FALSE; ?>
						<?php if ($flow['cost_unit_id'] == "Euro") {
							$edeger = TRUE;
						} ?>
						<?php if ($flow['cost_unit_id'] == "Dollar") {
							$ddeger = TRUE;
						} ?>
						<?php if ($flow['cost_unit_id'] == "TL") {
							$tdeger = TRUE;
						} ?>
						<?php if ($flow['cost_unit_id'] == "CHF") {
							$cdeger = TRUE;
						} ?>
						<option value="Euro" <?= set_select('costUnit', 'Euro', $edeger); ?>>Euro</option>
						<option value="Dollar" <?= set_select('costUnit', 'Dollar', $ddeger); ?>>Dollar</option>
						<option value="TL" <?= set_select('costUnit', 'TL', $tdeger); ?>>TL</option>
						<option value="CHF" <?= set_select('costUnit', 'CHF', $cdeger); ?>>CHF</option>
					</select>
				</div>
			</div>
		</div>
		<div class="form-group">
			<div class="row">
				<div class="col-md-8">
					<label for="ep">EP (
						<?= lang("Validation.annual"); ?>)
					</label>
					<input class="form-control" id="ep" name="ep" placeholder="EP"
						value="<?= set_value('ep', $flow['ep']); ?>">
				</div>
				<div class="col-md-4">
					<label for="epUnit">
						<?= lang("Validation.epunit"); ?>
					</label>
					<input type="text" class="form-control" id="epUnit" value="EP" name="epUnit" readonly>
				</div>
			</div>
		</div>

		<!--hidden placeholder input (set to "true") for deactivated "availability" selection -->
		<div class="form-group">
			<input class="form-control" id="availability" name="availability" type="hidden"
				value="<?= set_value('availability', 'true'); ?>">
		</div>

		<div class="form-group">
			<label for="state">
				<?= lang("Validation.state"); ?>
			</label>
			<select id="state" class="info select-block" name="state">
				<?php $x = FALSE; ?>
				<?php $y = FALSE; ?>
				<?php $z = FALSE; ?>
				<?php $w = FALSE; ?>
				<?php if ($flow['state_id'] == "1") {
					$x = TRUE;
				} ?>
				<?php if ($flow['state_id'] == "2") {
					$y = TRUE;
				} ?>
				<?php if ($flow['state_id'] == "3") {
					$z = TRUE;
				} ?>
				<?php if ($flow['state_id'] == "4") {
					$w = TRUE;
				} ?>
				<option value="1" <?= set_select('state', '1', $x); ?>>Solid</option>
				<option value="2" <?= set_select('state', '2', $y); ?>>Liquid</option>
				<option value="3" <?= set_select('state', '3', $z); ?>>Gas</option>
				<option value="4" <?= set_select('state', '4', $w); ?>>n/a</option>
			</select>
		</div>

		<div class="form-group">
			<label for="desc">
				<?= lang("Validation.description"); ?>
			</label>
			<textarea class="form-control" rows="5" id="desc" name="desc"
				placeholder="<?= lang("Validation.description"); ?>"><?= set_value('description', $flow['description']); ?></textarea>
		</div>

		<button type="submit" class="btn btn-info">
			<?= lang("Validation.savedata"); ?>
		</button>
		</form>
		<span class="label label-default"><span style="color:red;">*</span>
			<?= lang("Validation.labelarereq"); ?>.
		</span>
	</div>
</div>
<script type="text/javascript">
	$('#selectize-units').selectize({
		create: false
	});
</script>