<div class="col-md-6 col-md-offset-3">
	<?php
		if($validation != NULL)
		echo $validation->listErrors();
	?>
	<p class="lead"><?= lang("Validation.editproduct"); ?></p>
	<?= form_open_multipart('edit_product/'.$companyID.'/'.$product['id']); ?>
		<?= csrf_field() ?>
		<div class="form-group">
			<label for="product"><?= lang("Validation.productname"); ?> <span style="color:red;">*</span></label>
			<input class="form-control" id="product" name="product" placeholder="<?= lang("Validation.productname"); ?>" value="<?= set_value('name',$product['name']); ?>">
		</div>				
		<div class="form-group">
			<div class="row">
				<div class="col-md-8">
					<label for="quantities"><?= lang("Validation.quantities"); ?></label>
					<input class="form-control" id="quantities" name="quantities" placeholder="<?= lang("Validation.quantities"); ?>" value="<?= set_value('quantities',$product['quantities']); ?>">
				</div>
				<div class="col-md-4">
					<label for="qunit"><?= lang("Validation.quantitiesunit"); ?></label>
					<select id="qunit" class="info select-block" name="qunit">
						<?php foreach ($units as $unit): ?>
							<?php if($product['qunit']==$unit['name']) {$deger = TRUE;}else{$deger=False;} ?>
							<option value="<?= $unit['name']; ?>" <?= set_select('qunit', $unit['id'], $deger); ?>><?= $unit['name']; ?></option>
						<?php endforeach ?>
					</select>
				</div>
			</div>
		</div>				
		<div class="form-group">
			<div class="row">
				<div class="col-md-8">
					<label for="ucost"><?= lang("Validation.unitcost"); ?></label>
					<input class="form-control" id="ucost" name="ucost" placeholder="<?= lang("Validation.unitcost"); ?>" value="<?= set_value('ucost',$product['ucost']); ?>">
				</div>
				<div class="col-md-4">
					<label for="ucostu"><?= lang("Validation.unitcostunit"); ?></label>
					<select id="ucostu" class="info select-block" name="ucostu">
						<?php $edeger = FALSE; ?>
						<?php $ddeger = FALSE; ?>
						<?php $tdeger = FALSE; ?>
						<?php $cdeger = FALSE; ?>
						<?php if($product['ucostu']=="Euro") {$edeger = TRUE;} ?>
						<?php if($product['ucostu']=="Dollar") {$ddeger = TRUE;} ?>
						<?php if($product['ucostu']=="TL") {$tdeger = TRUE;} ?>
						<?php if($product['ucostu']=="CHF") {$cdeger = TRUE;} ?>
						<option value="Euro" <?= set_select('ucostu', 'Euro', $edeger); ?>>Euro</option>
						<option value="Dollar" <?= set_select('ucostu', 'Dollar', $ddeger); ?>>Dollar</option>
						<option value="TL" <?= set_select('ucostu', 'TL', $tdeger); ?>>TL</option>
						<option value="CHF" <?= set_select('ucostu', 'CHF', $cdeger); ?>>CHF</option>
					</select>
				</div>
			</div>
		</div>
		<div class="form-group">
			<label for="tper"><?= lang("Validation.timeperiod"); ?></label>
			<select id="tper" class="info select-block" name="tper">
				<?php $bir = FALSE; ?>
				<?php $iki = FALSE; ?>
				<?php $uc = FALSE; ?>
				<?php $dort = FALSE; ?>
				<?php if($product['tper']=="Daily") {$bir = TRUE;} ?>
				<?php if($product['tper']=="Weekly") {$iki = TRUE;} ?>
				<?php if($product['tper']=="Monthly") {$uc = TRUE;} ?>
				<?php if($product['tper']=="Annually") {$dort = TRUE;} ?>
				<option value="Daily" <?= set_select('tper', 'Daily', $bir); ?>><?= lang("Validation.daily"); ?></option>
				<option value="Weekly" <?= set_select('tper', 'Weekly', $iki); ?>><?= lang("Validation.weekly"); ?></option>
				<option value="Monthly" <?= set_select('tper', 'Monthly', $uc); ?>><?= lang("Validation.monthly"); ?></option>
				<option value="Annually" <?= set_select('tper', 'Annually', $dort); ?>><?= lang("Validation.annually"); ?></option>
			</select>
		</div>
		<button type="submit" class="btn btn-info">Update Product</button>
	</form>
	<span class="label label-default"><span style="color:red;">*</span> labels are required.</span>
</div>
