<?php //print_r($component); ?>
	<div class="col-md-6 col-md-offset-3">
		<?= form_open_multipart('edit_component/'.$companyID.'/'.$component['id']); ?>
			<p class="lead"><?= lang("editcomponent"); ?></p>
			<div class="form-group">
			    <label for="component_name"><?= lang("componentname"); ?> <span style="color:red;">*</span></label>
			   	<input class="form-control" id="component_name" name="component_name" placeholder="<?= lang("componentname"); ?>" value="<?= set_value('component_name',$component['component_name']); ?>">
		 	</div>

		 	<div class="form-group">
			  <label for="component_type"><?= lang("componenttype"); ?></label>
				<select id="component_type" class="info select-block" name="component_type">
					<option value="0"><?= lang("pleaseselect"); ?></option>
					<?php foreach ($ctypes as $ctype): ?>
						<?php if($component['type_name']==$ctype['name']) {$deger = TRUE;}else{$deger=False;} ?>
						<option value="<?= $ctype['id']; ?>" <?= set_select('component_type', $ctype['id'], $deger); ?>><?= $ctype['name']; ?></option>
					<?php endforeach ?>
				</select>
		 	</div>

			<div class="form-group">
				<label for="description"><?= lang("description"); ?></label>
				<input class="form-control" id="description" name="description" placeholder="<?= lang("description"); ?>" value="<?= set_value('description',$component['description']); ?>">
			</div>

			<div class="form-group">
				<div class="row">
					<div class="col-md-8">
						<label for="quantity"><?= lang("quantity"); ?> (<?= lang("annual"); ?>)</label>
						<input class="form-control" id="quantity" name="quantity" placeholder="<?= lang("quantity"); ?>" value="<?= set_value('quantity',$component['qntty']); ?>">
					</div>
					<div class="col-md-4">
						<label for="quantity"><?= lang("quantityunit"); ?></label>
				        <select id="selectize-units" class="info select-block" name="quantityUnit"> 
		                    <option value="" disabled selected><?= lang("pleaseselect"); ?></option>
		                    <?php foreach ($units as $unit): ?>
		                        <option value="<?= $unit['id']; ?>" <?= set_select('quantityUnit', $unit['id']); ?>><?= $unit['name']; ?></option>
		                    <?php endforeach ?>
		                </select>
					</div>
				</div>
			</div>
			<div class="form-group">
				<div class="row">
					<div class="col-md-8">
						<label for="cost"><?= lang("supplycost"); ?> (<?= lang("annual"); ?>)</label>
						<input class="form-control" id="cost" name="cost" placeholder="Supply Cost of flow (number)" value="<?= set_value('cost',$component['supply_cost']); ?>">
					</div>
					<div class="col-md-4">
						<label for="cost"><?= lang("supplycostunit"); ?></label>
						<select id="costUnit" class="info select-block" name="costUnit">
							<?php $edeger = FALSE; ?>
							<?php $ddeger = FALSE; ?>
							<?php $tdeger = FALSE; ?>
							<?php $cdeger = FALSE; ?>
							<?php if($component['supply_cost_unit']=="Euro") {$edeger = TRUE;} ?>
							<?php if($component['supply_cost_unit']=="Dollar") {$ddeger = TRUE;} ?>
							<?php if($component['supply_cost_unit']=="TL") {$tdeger = TRUE;} ?>
							<?php if($component['supply_cost_unit']=="CHF") {$cdeger = TRUE;} ?>
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
						<label for="ocost"><?= lang("outputcost"); ?> (<?= lang("annual"); ?>)</label>
						<input class="form-control" id="ocost" name="ocost" placeholder="Output Cost of flow (number)" value="<?= set_value('ocost',$component['output_cost']); ?>">
					</div>
					<div class="col-md-4">
						<label for="ocostunit"><?= lang("outputcostunit"); ?></label>
						<select id="ocostunit" class="info select-block" name="ocostunit">
							<?php $edeger = FALSE; ?>
							<?php $ddeger = FALSE; ?>
							<?php $tdeger = FALSE; ?>
							<?php $cdeger = FALSE; ?>
							<?php if($component['output_cost_unit']=="Euro") {$edeger = TRUE;} ?>
							<?php if($component['output_cost_unit']=="Dollar") {$ddeger = TRUE;} ?>
							<?php if($component['output_cost_unit']=="TL") {$tdeger = TRUE;} ?>
							<?php if($component['output_cost_unit']=="CHF") {$cdeger = TRUE;} ?>
							<option value="Euro" <?= set_select('ocostunit', 'Euro', $edeger); ?>>Euro</option>
							<option value="Dollar" <?= set_select('ocostunit', 'Dollar', $ddeger); ?>>Dollar</option>
							<option value="TL" <?= set_select('ocostunit', 'TL', $tdeger); ?>>TL</option>
							<option value="CHF" <?= set_select('ocostunit', 'CHF', $cdeger); ?>>CHF</option>
						</select>
					</div>
				</div>
			</div>

			<div class="form-group">
				<label for="quality"><?= lang("quality"); ?></label>
				<input class="form-control" id="quality" name="quality" placeholder="<?= lang("quality"); ?>" value="<?= set_value('quality',$component['data_quality']); ?>">
			</div>

			<div class="form-group">
				<label for="spot"><?= lang("substitute_potential"); ?></label>
				<input class="form-control" id="spot" name="spot" placeholder="<?= lang("substitute_potential"); ?>" value="<?= set_value('substitute_potential',$component['substitute_potential']); ?>">
			</div>
		  
		  <div class="form-group">
				<label for="comment"><?= lang("comments"); ?></label>
				<input class="form-control" id="comment" name="comment" placeholder="<?= lang("comments"); ?>" value="<?= set_value('comment',$component['comment']); ?>">
			</div>
		  
		  <button type="submit" class="btn btn-info"><?= lang("savedata"); ?></button>
		</form>
		<span class="label label-default"><span style="color:red;">*</span> <?= lang("labelarereq"); ?>.</span>
</div>
<script type="text/javascript">
    $('#selectize-units').selectize({
        create: false
    });
</script>