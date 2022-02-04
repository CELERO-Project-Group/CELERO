	<div class="col-md-4 borderli">
		<div class="lead"><?= lang("addequipment"); ?></div>
			<?= form_open_multipart('new_equipment/'.$companyID); ?>
			<div class="form-group">
					<label for="status"><?= lang("equipmentname"); ?> <span style="color:red;">*</span></label>
					<div>	    			
				  	<select class="info select-block" name="equipment" id="equipment">
			  			<option value=""><?= lang("pleaseselect"); ?></option>
						<?php foreach ($equipmentName as $eqpmntName): ?>
						<option value="<?= $eqpmntName['id']; ?>"><?= $eqpmntName['name']; ?></option>
					<?php endforeach ?>
					</select>
					</div>
				</div>
				<div class="form-group">
					<label for="status"><?= lang("equipmenttype"); ?> <span style="color:red;">*</span></label>
					<div>	    			
			  		<select  class="select-block" id="equipmentTypeName" name="equipmentTypeName">
							<option value=""><?= lang("pleaseselect"); ?></option>
						</select>
					</div>
				</div>
				<div class="form-group">
					<label for="status"><?= lang("equipmentattname"); ?> <span style="color:red;">*</span></label>
					<div>	    			
			  		<select  class="select-block" id="equipmentAttributeName" name="equipmentAttributeName">
							<option value=""><?= lang("pleaseselect"); ?></option>
						</select>
					</div>
				</div>
				<div class="form-group">
				<div class="row">
					<div class="col-md-8">
						<label for="eqpmnt_attrbt_val"><?= lang("equipmentattvalue"); ?> <span style="color:red;">*</span></label>
						<input class="form-control" id="eqpmnt_attrbt_val" name="eqpmnt_attrbt_val" placeholder="<?= lang("equipmentattvalue"); ?>">
					</div>
					<div class="col-md-4">
						<label for="eqpmnt_attrbt_unit"><?= lang("equipmentattunit"); ?> <span style="color:red;">*</span></label>
						<select id="eqpmnt_attrbt_unit" class="info select-block" name="eqpmnt_attrbt_unit">
							<option value=""><?= lang("pleaseselect"); ?></option>
							<?php foreach ($units as $unit): ?>
								<option value="<?= $unit['id']; ?>"><?= $unit['name']; ?></option>
							<?php endforeach ?>
						</select>
					</div>
				</div>
			</div>
				<div class="form-group">
			  	<label for="description"><?= lang("usedprocess"); ?> <span style="color:red;">*</span></label>
			  	<select class="select-block" id="usedprocess" name="usedprocess">
			    	<?php foreach ($process as $prcss): ?>
						<option value="<?= $prcss['processid']; ?>"><?= $prcss['prcessname']; ?></option>
					<?php endforeach ?>
				</select>
				</div>
			  <button type="submit" class="btn btn-info"><?= lang("addequipment"); ?></button>
			</form>
			<span class="label label-default"><span style="color:red;">*</span> <?= lang("labelarereq"); ?>.</span>

		</div>
		<div class="col-md-8">
			<div class="lead"><?= lang("companyequipment"); ?></div>
			<table class="table table-striped table-bordered">
				<tr>
					<th><?= lang("equipmentname"); ?></th>
					<th><?= lang("equipmenttype"); ?></th>
					<th><?= lang("equipmentattname"); ?></th>
					<th><?= lang("equipmentattvalue"); ?></th>
					<th><?= lang("usedprocess"); ?></th>
					<th><?= lang("manage"); ?></th>
				</tr>
				<?php foreach ($informations as $info): ?>
				<tr>	
						<td><?= $info['eqpmnt_name']; ?></td>
						<td><?= $info['eqpmnt_type_name']; ?></td>
						<td><?= $info['eqpmnt_type_attrbt_name']; ?></td>
						<td><?= $info['eqpmnt_attrbt_val']; ?> <?= $info['unit']; ?></td>
						<td><?= $info['prcss_name']; ?></td>
						<td><a href="<?= base_url('ecotracking/'.$companyID.'/'.$info['cmpny_eqpmnt_id']);?>" class="label label-info"> Tracking Data</a>
						<a href="<?= base_url('delete_equipment/'.$companyID.'/'.$info['cmpny_eqpmnt_id']);?>" class="label label-danger" value="<?= $info['cmpny_eqpmnt_id']; ?>"><span class="fa fa-times"></span> <?= lang("delete"); ?></a></td>
				</tr>
				<?php endforeach ?>
			</table>
		</div>

	